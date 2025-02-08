class BaseController
  def initialize(request, route)
    @request = request
    @route = route
  end

  def response_with type: nil, object:, status: 200
    case type&.to_sym
    in :json
      rendered_json = object.is_a?(Array) ? object&.map(&:to_h).to_json : object.to_json
      return [status, { "content-type" => "application/json" }, [rendered_json]]
    else
      view_file_name = self.class.name.split("Controller").first.downcase
      rendered_erb = ERB.new(File.open("app/views/#{view_file_name}_#{@request.action}.erb").read).result
      return [status, { "content-type" => "text/html" }, [rendered_erb]]
    end
  end

  def params
    body = JSON.parse(@request.body.read.strip) rescue body = {}
    extract_params(@request.path, @route[:path])
      .merge(body)
      .merge(@request.params)
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
