class ApiEngine

  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)

    if api_route?(env) && lower_env?
      bypass_rails(env)
    else
      @app.call(env)
    end

  end

  def api_route?(env)
    req = Rack::Request.new(env)
    req.path_info.include?("/api")
  end

  def lower_env?
    ENV['RAILS_ENV'] == 'production'
  end

  def bypass_rails(env)
    rewrite_route(env)
    BaseApi.call(env)
  end

  def rewrite_route(env)
    env["PATH_INFO"].to_s.gsub!("/api", "")
  end

end
