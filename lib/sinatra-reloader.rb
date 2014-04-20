class Sinatra::Reloader < Rack::Reloader
  def safe_load(file, mtime, stderr = $stderr)
    if file == File.expand_path(App.app_file)
      App.reset!
      stderr.puts "#{self.class}: reseting routes"
    end
    super
  end
end
