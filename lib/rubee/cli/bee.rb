# frozen_string_literal: true

require "json"

module Rubee
  module CLI
    class Bee
      VERSION = "0.1.0"

      # ── Config ───────────────────────────────────────────────────────────────
      KNOWLEDGE_FILE       = ENV.fetch("BEE_KNOWLEDGE", File.join(__dir__, "bee_knowledge.json"))
      README_GLOB          = "readme.md"
      TOP_K                = 2       # sections merged as answer
      CONFIDENCE_THRESHOLD = 0.05   # cosine score below which we admit we don't know
      WORD_DELAY           = 0.045  # seconds between words when typewriting
      WORD_JITTER          = 0.030  # random extra delay for realism
      OLLAMA_URL           = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      OLLAMA_DEFAULT_MODEL = "qwen2.5:1.5b"

      STOPWORDS = %w[
        a an the is are was were be been being have has had do does did
        will would could should may might shall can i you we they he she it
        what how when where why which who whom whose that this these those
        to of in on at by for with about from into as if up out so or and
        me my your our its their s re ll ve dont doesnt didnt isnt wasnt
        please tell show just also note make sure example following get set
        run using use via rubee rube ru bee
      ].freeze

      CONFUSED = [
        "That's outside my hive. Try rephrasing?",
        "I don't have anything on that in the README.",
        "Nothing in the docs matches that — try https://rubee.dedyn.io/",
        "I'm not sure about that one. Check https://rubee.dedyn.io/"
      ].freeze

      THINKING_FRAMES = ["⬡ ⬢ ⬢", "⬢ ⬡ ⬢", "⬢ ⬢ ⬡", "⬢ ⬡ ⬢"].freeze

      # ── Entry point ──────────────────────────────────────────────────────────
      class << self
        def call(_command, argv)
          args  = argv[1..].map(&:to_s)
          # Extract --llm[=model] flag
          llm_flag = args.find { |a| a.start_with?("--llm") }
          args.delete(llm_flag)
          llm_model = if llm_flag
            llm_flag.include?("=") ? llm_flag.split("=", 2).last : OLLAMA_DEFAULT_MODEL
          end

          sub = args.first.to_s.strip.downcase
          case sub
          when "generate", "gen" then generate
          when ""                then interactive_mode(llm_model)
          else                        single_mode(args.join(" "), llm_model)
          end
        end

        private

        # ════════════════════════════════════════════════════════════════════════
        # GENERATOR — README → TF-IDF vectors → bee_knowledge.json
        # ════════════════════════════════════════════════════════════════════════

        def generate
          path = File.join(Rubee::ROOT_PATH, 'readme.md')
          unless path
            puts "#{bee} \e[31mreadme.md not found in #{Dir.pwd}\e[0m"
            return
          end

          puts "\n#{bee} Reading #{path}..."
          sections = parse_readme(path)
          puts "#{bee} Found \e[1m#{sections.size}\e[0m sections"
          puts "#{bee} Building TF-IDF vectors..."

          corpus       = sections.map { |s| tokenize("#{s["label"]} #{s["body"]}") }
          idf          = compute_idf(corpus)
          unit_vectors = corpus.map { |tokens| normalise(tfidf_vector(tokens, idf)) }

          knowledge = {
            "version"  => VERSION,
            "idf"      => idf,
            "sections" => sections.each_with_index.map { |s, i|
              { "label" => s["label"], "body" => s["body"],
                "parent" => s["parent"], "vector" => unit_vectors[i] }
            }
          }

          File.write(KNOWLEDGE_FILE, JSON.generate(knowledge))
          @kb = nil

          puts "#{bee} \e[32mDone!\e[0m #{sections.size} sections, #{idf.size} vocab terms."
          puts "  Run \e[36mrubee bee\e[0m to start chatting.\n\n"
        end

        # ════════════════════════════════════════════════════════════════════════
        # README PARSER
        # ════════════════════════════════════════════════════════════════════════

        TOC_LABELS  = %w[content contents table index navigation back roadmap license contributing].freeze
        # Inline nav links like [Back to content](#content) — strip them
        NAV_LINK_RE = /\[Back to [^\]]+\]\([^)]*\)/i

        def parse_readme(path)
          raw      = File.read(path)
          sections = []

          raw.split(/^(?=## )/).each do |h2_chunk|
            h2_lines = h2_chunk.lines
            h2_head  = h2_lines.first&.strip
            next unless h2_head&.start_with?("## ")

            h2_label = h2_head.sub(/^##\s+/, "").strip
            next if TOC_LABELS.include?(h2_label.downcase)

            h2_raw_body = h2_lines[1..].join

            if h2_raw_body.match?(/^### /m)
              # Has sub-sections — index each ### separately, plus the parent as a whole
              intro_raw = h2_raw_body.split(/^(?=### )/m).first
              intro     = clean_body(intro_raw)

              # Full section = intro + all sub-section bodies joined
              full_body = clean_body(h2_raw_body)
              sections << { "label" => h2_label, "body" => full_body, "parent" => nil } unless full_body.empty?

              h2_raw_body.split(/^(?=### )/m).each do |h3_chunk|
                h3_lines = h3_chunk.lines
                h3_head  = h3_lines.first&.strip
                next unless h3_head&.start_with?("### ")

                h3_label = h3_head.sub(/^###\s+/, "").strip
                body     = clean_body(h3_lines[1..].join)
                next if body.empty?

                sections << { "label" => "#{h2_label} — #{h3_label}", "body" => body, "parent" => h2_label }
              end
            else
              # No sub-sections — store the whole section as one entry
              body = clean_body(h2_raw_body)
              next if body.empty?
              sections << { "label" => h2_label, "body" => body, "parent" => nil }
            end
          end

          sections
        end

        # Full markdown → clean plain text.
        # Code blocks are preserved with a CODE> prefix so typewrite can render them.
        def clean_body(text)
          # 1. Strip nav/backslash artefacts first
          out = text
            .gsub(NAV_LINK_RE, "")
            .gsub(/\s*\\\s*\n/, "\n")

          # 2. Strip HTML *before* inserting CODE> markers (avoids > in CODE> being eaten)
          out = out
            .gsub(/<br\s*\/?>/, "\n")
            .gsub(/<[^>]+>/, "")
            .gsub(/&amp;/, "&").gsub(/&lt;/, "<")
            .gsub(/&gt;/, ">").gsub(/&nbsp;/, " ")

          # 3. Replace fenced code blocks with CODE>-prefixed lines
          out = out.gsub(/````?[a-z]*\r?\n(.*?)````?/m) do
            lines = $1.lines.map { |l| "CODE>#{l.rstrip}" }.join("\n")
            "\n#{lines}\n"
          end

          # 4. Strip remaining markdown decoration
          out
            .gsub(/\[([^\]]+)\]\([^)]*\)/, '\1')
            .gsub(/^[#]{1,6}\s+/, "")
            .gsub(/^\s*[-*]\s+/, "  • ")
            .gsub(/\*{3}([^*]+)\*{3}/, '\1')
            .gsub(/\*{2}([^*]+)\*{2}/, '\1')
            .gsub(/\*([^*\n]+)\*/, '\1')
            .gsub(/_{2}([^_]+)_{2}/, '\1')
            .gsub(/`([^`\n]+)`/, '\1')
            .gsub(/^\|.*\|.*$/, "")
            .gsub(/^[-|: ]+$/, "")
            .gsub(/\n{3,}/, "\n\n")
            .strip
        end

        # ════════════════════════════════════════════════════════════════════════
        # TF-IDF + COSINE SIMILARITY
        # ════════════════════════════════════════════════════════════════════════

        # IDF: log((N+1) / (df+1)) + 1  — smooth, never zero
        def compute_idf(corpus)
          n  = corpus.size.to_f
          df = Hash.new(0)
          corpus.each { |tokens| tokens.uniq.each { |t| df[t] += 1 } }
          df.transform_values { |count| Math.log((n + 1.0) / (count + 1.0)) + 1.0 }
        end

        # TF: relative term frequency × IDF weight
        def tfidf_vector(tokens, idf)
          return {} if tokens.empty?
          tf = Hash.new(0)
          tokens.each { |t| tf[t] += 1 }
          tf.each_with_object({}) do |(term, count), vec|
            vec[term] = (count.to_f / tokens.size) * (idf[term] || 1.0)
          end
        end

        # L2-normalise to unit vector (stored as Hash for sparse efficiency)
        def normalise(vec)
          mag = Math.sqrt(vec.values.sum { |v| v * v })
          return vec if mag.zero?
          vec.transform_values { |v| v / mag }
        end

        # Cosine of two unit vectors = dot product
        def cosine(a, b)
          a.sum { |term, val| val * (b[term] || 0.0) }
        end

        # Return all sections sorted by score against the query.
        # Score = cosine similarity + label bonus (if query tokens appear in the label).
        LABEL_BONUS = 0.35

        def search(query)
          return [] if kb["sections"].empty?

          tokens    = tokenize(query)
          return [] if tokens.empty?

          query_set = tokens.to_set
          query_vec = normalise(tfidf_vector(tokens, kb["idf"]))

          kb["sections"].map do |s|
            score       = cosine(query_vec, s["vector"])
            label_words = tokenize(s["label"]).to_set
            bonus       = query_set.any? { |t| label_words.include?(t) } ? LABEL_BONUS : 0.0
            [s, score + bonus]
          end.sort_by { |_, score| -score }
        end

        # ════════════════════════════════════════════════════════════════════════
        # KNOWLEDGE BASE (lazy, cached)
        # ════════════════════════════════════════════════════════════════════════

        def kb
          @kb ||= JSON.parse(File.read(KNOWLEDGE_FILE))
        rescue Errno::ENOENT
          warn "\n#{bee} No knowledge file. Run: rubee bee generate"
          { "idf" => {}, "sections" => [] }
        rescue JSON::ParserError => e
          warn "\n#{bee} Corrupt knowledge file: #{e.message}"
          { "idf" => {}, "sections" => [] }
        end

        # ════════════════════════════════════════════════════════════════════════
        # MODES
        # ════════════════════════════════════════════════════════════════════════

        def interactive_mode(llm_model = nil)
          greet(llm_model)
          loop do
            print "\n\e[33m  You:\e[0m "
            input = $stdin.gets&.strip
            break if input.nil? || %w[exit quit bye q].include?(input.downcase)
            next  if input.empty?

            respond_to(input, llm_model)
          end
          puts "\n#{bee} Happy coding with ru.Bee!\n\n"
        end

        def single_mode(question, llm_model = nil)
          respond_to(question, llm_model)
        end

        def respond_to(input, llm_model = nil)
          stop_fn = llm_model ? think_async! : nil
          think!  unless llm_model

          results   = search(input)
          top_score = results.first&.last.to_f

          if top_score < CONFIDENCE_THRESHOLD
            stop_fn&.call
            puts "\n  #{bee}  \e[90m#{CONFUSED.sample}\e[0m\n"
            return
          end

          top_section = results.first[0]
          label       = top_section["label"]
          snippet     = best_snippet(top_section["body"], input)
          suggestions = generate_suggestions(input, results[1..])

          # Stop animation, then print header
          stop_fn&.call
          print_header(label, top_score, llm_model)

          if llm_model
            ollama_stream(input, snippet, llm_model)
          else
            stream_preamble
            typewrite(snippet)
          end

          print_footer(suggestions)
        end

        # ════════════════════════════════════════════════════════════════════════
        # SNIPPET
        # ════════════════════════════════════════════════════════════════════════

        MAX_SNIPPET_WORDS = 300

        def best_snippet(body, _query)
          return body if body.split.size <= MAX_SNIPPET_WORDS

          result    = []
          count     = 0
          in_code   = false

          body.each_line do |line|
            in_code = true  if line.start_with?("CODE>")
            in_code = false if !line.start_with?("CODE>") && in_code && line.strip.empty?

            words = line.split.size
            # Don't cut inside a code block — keep going until it closes
            if count + words > MAX_SNIPPET_WORDS && !in_code
              break
            end

            result << line
            count += words
          end

          result.join.rstrip
        end

        # ════════════════════════════════════════════════════════════════════════
        # ANIMATION + OUTPUT
        # ════════════════════════════════════════════════════════════════════════

        def think!
          print "\n"
          start = Time.now
          i     = 0
          while Time.now - start < 0.9
            frame = THINKING_FRAMES[i % THINKING_FRAMES.size]
            print "\r  \e[33m#{frame}\e[0m \e[90mthinking...\e[0m"
            $stdout.flush
            sleep 0.18
            i += 1
          end
          print "\r\e[K"
          $stdout.flush
        end

        def think_async!
          i    = 0
          done = false
          thr  = Thread.new do
            print "\n"
            until done
              frame = THINKING_FRAMES[i % THINKING_FRAMES.size]
              print "\r  \e[33m#{frame}\e[0m \e[90mthinking...\e[0m"
              $stdout.flush
              sleep 0.18
              i += 1
            end
            print "\r\e[K"
            $stdout.flush
          end
          stopper = -> { done = true; thr.join }
          stopper
        end

        PREAMBLES = [
          "Here's what I found:",
          "Here's the closest match I have:",
          "Found something relevant:",
          "This looks like what you're after:",
          "Here's what the docs say:",
          "Got something on that:",
          "Here's the relevant bit:",
          "Pulling this from the docs:"
        ].freeze

        def stream_preamble
          stream_words(PREAMBLES.sample, color: "90", prefix: "  ")
          puts
        end

        # Build 5 suggested follow-up questions from the next-best scored sections.
        # Each suggestion is phrased as a natural question using the section label.
        SUGGESTION_TEMPLATES = [
          "How does %s work?",
          "Can you explain %s?",
          "What should I know about %s?",
          "How do I use %s?",
          "Tell me more about %s."
        ].freeze

        def generate_suggestions(original_query, remaining_results)
          seen         = {}
          query_tokens = tokenize(original_query).to_set

          candidates = remaining_results.filter_map do |s, _|
            label = s["label"]
            base  = s["parent"] || label   # group child sections under parent name
            next if seen[base]
            next if tokenize(label).to_set == query_tokens
            seen[base] = true
            label
          end.first(5)

          candidates.each_with_index.map do |label, i|
            format(SUGGESTION_TEMPLATES[i % SUGGESTION_TEMPLATES.size], label)
          end
        end

        def print_header(label, score, llm_model = nil)
          dot   = score >= 0.25 ? "\e[32m●\e[0m" : score >= 0.12 ? "\e[33m●\e[0m" : "\e[31m●\e[0m"
          width = 58
          model_badge = llm_model ? "  \e[90m[\e[35m#{llm_model}\e[90m]\e[0m" : ""
          puts
          puts "  \e[33m⬡ ⬢ ⬢\e[0m  #{dot} \e[1m\e[97m#{label}\e[0m#{model_badge}"
          puts "  \e[90m#{"─" * width}\e[0m"
          puts
        end

        # ════════════════════════════════════════════════════════════════════════
        # OLLAMA STREAMING
        # ════════════════════════════════════════════════════════════════════════

        def ollama_pull(model)
          require "net/http"
          require "uri"

          print "  \e[33m⬡ ⬢ ⬢\e[0m  \e[90mModel \e[97m#{model}\e[90m not found — pulling from Ollama...\e[0m\n"

          uri = URI("#{OLLAMA_URL}/api/pull")
          req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
          req.body = JSON.generate({ name: model, stream: true })

          last_status = ""
          Net::HTTP.start(uri.host, uri.port, read_timeout: 600) do |http|
            http.request(req) do |res|
              res.read_body do |chunk|
                chunk.each_line do |line|
                  next if line.strip.empty?
                  begin
                    data   = JSON.parse(line)
                    status = data["status"] || ""
                    total  = data["total"].to_i
                    comp   = data["completed"].to_i
                    if total > 0
                      pct = (comp * 100.0 / total).round
                      bar = ("█" * (pct / 5)).ljust(20)
                      print "\r  \e[90m#{bar} #{pct}%  #{status}\e[0m\e[K"
                    elsif status != last_status
                      print "\r  \e[90m#{status}\e[0m\e[K"
                      last_status = status
                    end
                    $stdout.flush
                  rescue JSON::ParserError
                    next
                  end
                end
              end
            end
          end
          puts "\r  \e[32m✓ #{model} ready\e[0m\e[K"
          true
        rescue => e
          puts "\n  \e[31m[Pull failed: #{e.message}]\e[0m"
          false
        end

        def ollama_stream(query, context, model, stop_fn = nil)
          require "net/http"
          require "uri"

          # Strip CODE> sentinels from context before sending to LLM
          plain_context = context.gsub(/^CODE>/, "  ")

          system_prompt = <<~SYS
            /no_think
            You are a concise assistant for the ru.Bee Ruby web framework.
            Answer the user's question using ONLY the context provided below.
            Be direct and practical. Include relevant code examples from the context.
            Do not invent anything not present in the context.
            Reply with plain text and fenced code blocks only. No markdown headers.
            Keep your response under 150 words.
          SYS

          payload = {
            model:   model,
            stream:  true,
            messages: [
              { role: "system", content: system_prompt },
              { role: "user",   content: "Context:\n#{plain_context}\n\nQuestion: #{query}" }
            ]
          }

          uri = URI("#{OLLAMA_URL}/api/chat")
          req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
          req.body = JSON.generate(payload)

          full_response = +""
          debug = ENV["BEE_DEBUG"]
          model_missing = false

          stop_llm = think_async!
          Net::HTTP.start(uri.host, uri.port) do |http|
            http.read_timeout = 120
            http.request(req) do |res|
              debug && File.write("/tmp/bee_ollama_debug.txt", "STATUS: #{res.code}\n", mode: "a")
              if res.code == "404"
                model_missing = true
              else
                res.read_body do |chunk|
                  debug && File.write("/tmp/bee_ollama_debug.txt", chunk, mode: "a")
                  chunk.each_line do |line|
                    next if line.strip.empty?
                    begin
                      data  = JSON.parse(line)
                      token = data.dig("message", "content")
                      next unless token
                      full_response << token
                    rescue JSON::ParserError
                      next
                    end
                  end
                end
              end
            end
          end

          stop_llm.call

          if model_missing
            return typewrite(context) unless ollama_pull(model)
            return ollama_stream(query, context, model)
          end

          debug && File.write("/tmp/bee_ollama_debug.txt", "\n\nFULL_RESPONSE:\n#{full_response}\n", mode: "a")

          # Strip <think>...</think> blocks (qwen3 chain-of-thought)
          clean = full_response
            .gsub(/<think>.*?<\/think>/m, "")
            .gsub(/^```[a-z]*\n?(.*?)```/m) {
              lines = $1.lines.map { |l| "CODE>#{l.rstrip}" }.join("\n")
              "\n#{lines}\n"
            }
            .strip

          if clean.empty?
            puts "  \e[90m[model returned no answer — showing raw docs]\e[0m\n\n"
            typewrite(context)
          else
            typewrite(clean)
          end
        rescue => e
          stop_llm&.call rescue nil
          puts "  \e[31m[LLM error: #{e.message}]\e[0m"
          puts "  \e[90mFalling back to local answer:\e[0m\n\n"
          typewrite(context)
        end

        # Stream text word-by-word. Lines starting with CODE> are rendered as
        # green code inside a ┌ │ └ box; everything else streams as prose.
        def typewrite(text)
          lines   = text.lines.map(&:rstrip)
          in_code = false

          lines.each do |line|
            if line.start_with?("CODE>")
              puts "  \e[90m┌\e[0m" unless in_code
              in_code   = true
              code_text = line.sub(/^CODE>/, "")
              # Skip bare language hints left as first code line
              next if code_text.strip.match?(/^(ruby|bash|sh|erb|json|yaml|rb|text|html)$/)
              stream_words(code_text, color: "32", prefix: "  \e[90m│\e[0m")
            else
              if in_code
                puts "  \e[90m└\e[0m"
                in_code = false
              end
              stripped = line.strip
              if stripped.empty?
                puts
              else
                stream_words(stripped, color: "97", prefix: "  ")
              end
            end
          end
          puts "  \e[90m└\e[0m" if in_code
        end

        def stream_words(line, color:, prefix:)
          # Preserve leading indentation as a non-streamed prefix
          indent = line[/^\s*/]
          words  = line.lstrip.split(" ")
          print prefix
          print "\e[#{color}m#{indent}\e[0m" unless indent.empty?
          words.each_with_index do |word, idx|
            print "\e[#{color}m#{word}\e[0m"
            print " " unless idx == words.size - 1
            $stdout.flush
            sleep WORD_DELAY + rand * WORD_JITTER
          end
          puts
        end

        def print_footer(suggestions)
          width = 58
          puts
          puts "  \e[90m#{"─" * width}\e[0m"

          if suggestions && !suggestions.empty?
            puts "  \e[90mYou might also ask:\e[0m"
            suggestions.each_with_index do |q, i|
              puts "  \e[90m  #{i + 1}. \e[36m#{q}\e[0m"
            end
            puts
          end

          puts "  \e[90mFull docs: \e[36mhttps://rubee.dedyn.io/\e[0m"
          puts
        end

        # ════════════════════════════════════════════════════════════════════════
        # NLP HELPERS
        # ════════════════════════════════════════════════════════════════════════

        def tokenize(text)
          words = text
            .downcase
            .gsub(/```.*?```/m, " ")
            .gsub(/[^a-z0-9_\s]/, " ")
            .split

          words.flat_map { |w|
            parts = w.split("_").reject(&:empty?)
            parts.size > 1 ? [w] + parts : [w]
          }
          .reject { |w| STOPWORDS.include?(w) || w.length < 3 }
          .map    { |w| stem(w) }
        end

        def stem(word)
          word
            .sub(/ication$/, "icat")
            .sub(/ations?$/,  "ate")
            .sub(/nesses$/,   "ness")
            .sub(/ments?$/,   "ment")
            .sub(/ings?$/,    "ing")
            .sub(/tion$/,     "te")
            .sub(/ers?$/,     "er")
            .sub(/ed$/,       "")
            .sub(/ly$/,       "")
            .sub(/ies$/,      "y")
            .sub(/([^aeiou])s$/, '\1')
        end

        # ════════════════════════════════════════════════════════════════════════
        # UI CHROME
        # ════════════════════════════════════════════════════════════════════════

        def bee
          "\e[33m⬡ ⬢ ⬢\e[0m"
        end

        def greet(llm_model = nil)
          llm_line = llm_model \
            ? "\e[90m  LLM mode: \e[35m#{llm_model}\e[90m  •  make sure ollama is running\e[0m\n" \
            : ""
          puts <<~BANNER

            \e[33m  ⬡ ⬢ ⬢  ru.Bee — domestic AI assistant\e[0m
            \e[90m  ──────────────────────────────────────────────\e[0m
            \e[97m  Ask me anything about the ru.Bee framework.\e[0m
            #{llm_line}\e[90m  Type \e[36mexit\e[90m to leave  •  \e[36mrubee bee generate\e[90m to retrain.\e[0m

          BANNER
        end
      end
    end
  end
end
