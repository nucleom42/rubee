module Rubee
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
        view_file_name = self.class.name.split('Controller').first.downcase
        erb_file = render_view ? render_view.to_s : "#{view_file_name}_#{@route[:action]}"
        lib = Rubee::PROJECT_NAME == 'rubee' ? 'lib/' : ''
        view = render_template(erb_file, { object:, **(options[:locals] || {}) })

        whole_erb = if File.exist?(layout_path = "#{lib}app/views/#{options[:layout] || 'layout'}.erb")
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

    def render_template(file_name, locals = {})
      lib = Rubee::PROJECT_NAME == 'rubee' ? 'lib/' : ''
      path = "#{lib}app/views/#{file_name}.erb"
      erb_template = ERB.new(File.read(path))

      erb_template.result(binding)
    end

    def params
      inputs = @request.env['rack.input'].read
      body = begin
        JSON.parse(@request.body.read.strip)
             rescue StandardError
               {}
      end
      begin
        body.merge!(URI.decode_www_form(inputs).to_h.transform_keys(&:to_sym))
      rescue StandardError
        nil
      end
      @params ||= extract_params(@request.path, @route[:path])
        .merge(body)
        .merge(@request.params)
        .transform_keys(&:to_sym)
        .reject { |k, _v| [:_method].include?(k.downcase.to_sym) }
    end

    def headers
      @request.env.select { |k, _v| k.start_with?('HTTP_') }
        .collect { |key, val| [key.sub(/^HTTP_/, ''), val] }
    end

    def extract_params(path, pattern)
      regex_pattern = pattern.gsub(/\{(\w+)\}/, '(?<\1>[^/]+)')
      regex = Regexp.new("^#{regex_pattern}$")

      if (match = path.match(regex))
        return match.named_captures&.transform_keys(&:to_sym)
      end

      {}
    end
  end
end
