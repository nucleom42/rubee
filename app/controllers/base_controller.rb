class BaseController
  include Hookable

  def initialize(request, route)
    @request = request
    @route = route
  end

  def image
    image_path = File.join(IMAGE_DIR, @request.path.sub('/images/', ''))

    if File.exist?(image_path) && File.file?(image_path)
      mime_type = Rack::Mime.mime_type(File.extname(image_path))
      response_with object: File.read(image_path), type: :image, mime_type: mime_type
    else
      response_with object: "Image not found", type: :text
    end
  end

  def response_with type: nil, object: nil, status: 200, mime_type: nil, render_view: nil
    case type&.to_sym
    in :json
      rendered_json = object.is_a?(Array) ? object&.map(&:to_h).to_json : object.to_json
      return [status, { "content-type" => "application/json" }, [rendered_json]]
    in :image
      return [status, { "content-type" => mime_type }, [object]]
    in :text
      return [status, { "content-type" => "text/plain" }, [object.to_s]]
    in :unauthenticated
      return [401, { "content-type" => "text/plain" }, ["Unauthenticated"]]
    else # rendering erb view is a default behavior
      view_file_name = self.class.name.split("Controller").first.downcase
      erb_file = render_view ? "#{render_view}.erb" : "#{view_file_name}_#{@route[:action]}.erb"
      rendered_erb = ERB.new(File.open("app/views/#{erb_file}").read).result(binding)
      return [status, { "content-type" => "text/html" }, [rendered_erb]]
    end
  end

  def params
    inputs = @request.env['rack.input'].read
    body = JSON.parse(@request.body.read.strip) rescue body = {}
    body.merge!(URI.decode_www_form(inputs).to_h.transform_keys(&:to_sym)) rescue nil
    @params ||= extract_params(@request.path, @route[:path])
      .merge(body)
      .merge(@request.params)
  end

  def headers
    @request.env.select {|k,v| k.start_with? 'HTTP_'}
      .collect {|key, val| [key.sub(/^HTTP_/, ''), val]}
  end

  def extract_params(path, pattern)
    regex_pattern = pattern.gsub(/\{(\w+)\}/, '(?<\1>[^/]+)')
    regex = Regexp.new("^#{regex_pattern}$")

    if match = path.match(regex)
      return match.named_captures&.transform_keys(&:to_sym)
    end

    {}
  end
end
