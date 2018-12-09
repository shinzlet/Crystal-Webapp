require "http/server"

server = HTTP::Server.new do |context|
  context.response.content_type = "text/html"
  
  serve(context.response, context.request.path)

  puts "#{context.request.method} request:"
  puts "Headers:"
  context.request.headers.pretty_print PrettyPrint.new(STDOUT)
  puts "Body #{context.request.body}"
  puts "Path: #{context.request.path}"
  puts
end

def serve(io : IO, path)
  prefix = "src"
  index = "index.html"
  not_found = "404.html"
  
  case path
  when "/"
    path = "#{prefix}/#{index}"
  else
    path = "#{prefix}#{path}"
  end

  puts "seeking resource #{path}"

  if File.exists? path
    io.print File.read(path)
  else
    io.print File.read("#{prefix}/#{not_found}")
  end
end

puts "Running server on localhost:8080"
server.listen(8080)