require "http/server"

server = HTTP::Server.new do |context|
  serve(context.response, context.request.path)

  puts "#{context.request.method} request:"
  puts "Headers:"
  context.request.headers.pretty_print PrettyPrint.new(STDOUT)
  puts "Body #{context.request.body}"
  puts "Path: #{context.request.path}"
  puts
end

def serve(response : IO, path)
  prefix = "src"
  index = "#{prefix}/index.html"
  not_found = "#{prefix}/404.html"
  filetypes = {"html" => "text/html", "css" => "text/css"}
  filetype = ""
  
  case path
  when "/"
    path = index
  else
    path = "#{prefix}#{path}"
  end

  path = "#{prefix}/#{not_found}" unless File.exists? path

  begin
    filetype = filetypes[path.split('.')[-1]]
  rescue exception
    path = not_found
    filetype = "text/html"
  end

  response.content_type = filetype
  response.print File.read(path)
end

puts "Running server on localhost:8080"
server.listen(8080)