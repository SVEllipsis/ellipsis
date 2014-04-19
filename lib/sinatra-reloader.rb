class Sinatra::Reloader < Rack::Reloader
  def safe_load(file, mtime, stderr = $stderr)
    if file == File.expand_path(Application.app_file)
      Application.reset!
      stderr.puts "#{self.class}: reseting routes"
    end
    super
  end
end