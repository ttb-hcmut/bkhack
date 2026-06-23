require 'webrick'
root = File.expand_path '_build/default/src/Doc/dist'
server = WEBrick::HTTPServer.new :Port => 8030, :DocumentRoot => root
trap 'INT' do server.shutdown end
server.start
