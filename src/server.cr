require "http/server"
require "json"

posts = [] of Hash(String, String)

server = HTTP::Server.new do |context|
  if context.request.method == "POST"
    if io = context.request.body
      tokens = {} of String => String

      io.gets_to_end.split("&").map do |elem|
        pair = elem.split("=")
        tokens[pair[0]] = pair[1]
      end

      posts.push tokens
    end
  end

  serve(context.response, context.request.path, posts)

  puts "#{context.request.method} request:"
  puts "Headers:"
  context.request.headers.pretty_print PrettyPrint.new(STDOUT)
  puts

  if(safebody = context.request.body)
    puts "Body: #{safebody.gets_to_end}"
  end

  puts "Path: #{context.request.path}"
  puts
end

def serve(response : IO, path, posts)
  prefix = "src"
  index = "#{prefix}/index.html"
  not_found = "#{prefix}/404.html"
  filetypes = {"html" => "text/html", "css" => "text/css", "js" => "text/javascript", "txt" => "text/plain"}
  filetype = ""
  
  case path
  when "/"
    path = index
  when "/getposts"
    response.content_type = "text/plain"
    builder = JSON::Builder.new(response)
    builder.start_document
    posts.to_json(builder)
    builder.end_document
    return
  when "/auth"
    response.content_type = "text/plain"
    response.headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""
    response.print "i dunno man"
    response.status_code = 401
    return
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