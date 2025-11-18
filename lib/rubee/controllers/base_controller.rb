module Rubee
  class BaseController
    include Hookable
    using ChargedString

    def initialize(request, route)
      @request = request
      @route = route
    end

    def image
      image_path = File.join(IMAGE_DIR, @request.path.sub('/images/', ''))

      if File.exist?(image_path) && File.file?(image_path)
        mime_type = Rack::Mime.mime_type(File.extname(image_path))
        response_with(object: File.read(image_path), type: :image, mime_type: mime_type)
      else
        response_with(object: 'Image not found', type: :text)
      end
    end

    def js
      js_path = File.join(JS_DIR, @request.path.sub('/js/', ''))

      if File.exist?(js_path) && File.file?(js_path)
        response_with(object: File.read(js_path), type: :js)
      else
        response_with(object: 'Js file is not found', type: :text)
      end
    end

    def css
      css_path = File.join(CSS_DIR, @request.path.sub('/css/', ''))

      if File.exist?(css_path) && File.file?(css_path)
        response_with(object: File.read(css_path), type: :css)
      else
        response_with(object: 'Css file is not found', type: :text)
      end
    end

    def response_with type: nil, object: nil, status: 200, mime_type: nil, render_view: nil, headers: {}, to: nil,
      file: nil, filename: nil, **options
      case type&.to_sym
      in :json
        rendered_json = object.is_a?(Array) ? object&.map(&:to_h).to_json : object.to_json
        [status, headers.merge('content-type' => 'application/json'), [rendered_json]]
      in :image
        [status, headers.merge('content-type' => mime_type), [object]]
      in :js
        [status, headers.merge('content-type' => 'application/javascript'), [object]]
      in :css
        [status, headers.merge('content-type' => 'text/css'), [object]]
      in :websocket
        object # hash is expected
      in :file
        [
          status,
          headers.merge(
            'content-disposition' => "attachment; filename=#{filename}",
            'content-type' => 'application/octet-stream'
          ),
          file,
        ]
      in :text
        [status, headers.merge('content-type' => 'text/plain'), [object.to_s]]
      in :unauthentificated
        [401, headers.merge('content-type' => 'text/plain'), ['Unauthentificated']]
      in :redirect
        [302, headers.merge('location' => to.to_s), ['Unauthentificated']]
      in :not_found
        [404, { 'content-type' => 'text/plain' }, ['Route not found']]
      else # rendering erb view is a default behavior
        # TODO: refactor
        view_file_name = self.class.name.split('Controller').first.gsub('::', '').snakeize
        erb_file = render_view ? render_view.to_s : "#{view_file_name}_#{@route[:action]}"
        lib = Rubee::PROJECT_NAME == 'rubee' ? 'lib/' : ''
        path_parts = Module.const_source_location(self.class.name)&.first&.split('/')&.reverse
        controller_index = path_parts.find_index { |part| part == 'controllers' }
        app_name = path_parts[controller_index + 1]
        view = render_template(erb_file, { object:, **(options[:locals] || {}) }, app_name:)
        # Since controller sits in the controllers folder we can get parent folder of it and pull out name of the app
        app_name_prefix = app_name == 'app' ? '' : "#{app_name}_"
        layout_path = "#{lib}#{app_name}/views/#{app_name_prefix}#{options[:layout] || 'layout'}.erb"
        whole_erb = if File.exist?(layout_path)
          context = Object.new
          context.define_singleton_method(:_yield_template) { view }
          layout = File.read(layout_path)
          ERB.new(layout).result(context.instance_eval { binding })
        else
          ERB.new(view).result(binding)
        end

        [status, headers.merge('content-type' => 'text/html'), [whole_erb]]
      end
    end

    def render_template(file_name, locals = {}, **options)
      lib = Rubee::PROJECT_NAME == 'rubee' ? 'lib/' : ''
      path = "#{lib}#{options[:app_name] || 'app'}/views/#{file_name}.erb"
      erb_template = ERB.new(File.read(path))

      erb_template.result(binding)
    end

    def websocket
      action = @params[:action]
      unless ['subscribe', 'unsubscribe', 'publish'].include?(action)
        response_with(object: "Unknown action: #{action}", type: :websocket)
      end

      public_send(action)
    end

    def params
      # Read raw input safely (only once)
      raw_input = @request.body.read.to_s.strip
      @request.body.rewind if @request.body.respond_to?(:rewind)

      # Try parsing JSON first, fall back to form-encoded data
      parsed_input =
        begin
          JSON.parse(raw_input)
        rescue StandardError
          begin
            URI.decode_www_form(raw_input).to_h.transform_keys(&:to_sym)
          rescue
            {}
          end
        end

      # Combine route params, request params, and body
      @params ||= extract_params(@request.path, @route[:path])
        .merge(parsed_input)
        .merge(@request.params)
        .transform_keys(&:to_sym)
        .reject { |k, _v| k.to_sym == :_method }
    end

    def headers
      @request.env.select { |k, _v| k.start_with?('HTTP_') }
        .collect { |key, val| [key.sub(/^HTTP_/, ''), val] }
    end

    def websocket_connections
      Rubee::WebSocketConnections.instance
    end

    def extract_params(path, pattern)
      regex_pattern = pattern.gsub(/\{(\w+)\}/, '(?<\1>[^/]+)')
      regex = Regexp.new("^#{regex_pattern}$")

      if (match = path.match(regex))
        return match.named_captures&.transform_keys(&:to_sym)
      end

      {}
    end

    def handle_websocket
      res = Rubee::WebSocket.call(@request.env) do |payload|
        @params = payload
        yield
      end
      res
    end

    class << self
      def attach_websocket!
        around(
          :websocket, :handle_websocket,
          if: -> do
            redis_available = Rubee::Features.redis_available?
            Rubee::Logger.error(message: 'Please make sure redis server is running') unless redis_available
            redis_available
          end
        )
      end
    end
  end
end
