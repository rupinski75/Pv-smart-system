require 'socket'

module Plug

  extend self
  def test
    p "test"
  end

  def encrypt(string)
    key = 171
    result = ''
    string.each_byte do |byte|
      a = key ^ byte
      key = a
      result += a.chr
    end
    return "\x00\x00\x00*" + result
  end

  def decrypt(string)
    #string.dup.force_encoding('BINARY')
    # p string.bytes.to_a
    # p string.inspect
    string = string[4..-1]
    key = 171
    result = ''
    #p "here "
    string.each_byte do |byte|
      #p "key: #{key} char: #{byte}"
      a = key ^ byte
      #p "key: #{key} char: #{a}"
      key = byte
      result += a.chr
      #p "----"
    end
    return  result
  end

  def sendOrderToPlug(order)
    ip = '192.168.1.30'
    port = 9999

    socket = TCPSocket.new(ip, port)

    #p Socket.getnameinfo(Socket.sockaddr_in(9999, "192.168.1.23"))
    off = "{\"system\":{\"set_relay_state\":{\"state\":0}}}"
    on = "{\"system\":{\"set_relay_state\":{\"state\":1}}}"

    orderMessage = ""
    order == "on" ? orderMessage = on : orderMessage = off
    # on = "\x00\x00\x00*\xd0\xf2\x81\xf8\x8b\xff\x9a\xf7\xd5\xef\x94\xb6\xc5\xa0\xd4\x8b\xf9\x9c\xf0\x91\xe8\xb7\xc4\xb0\xd1\xa5\xc0\xe2\xd8\xa3\x81\xf2\x86\xe7\x93\xf6\xd4\xee\xdf\xa2\xdf\xa2"
    #off = "\x00\x00\x00*\xd0\xf2\x81\xf8\x8b\xff\x9a\xf7\xd5\xef\x94\xb6\xc5\xa0\xd4\x8b\xf9\x9c\xf0\x91\xe8\xb7\xc4\xb0\xd1\xa5\xc0\xe2\xd8\xa3\x81\xf2\x86\xe7\x93\xf6\xd4\xee\xde\xa3\xde\xa3"

    #p encrypt(orderMessage)
    log_file = File.open('pv_system_log.txt', 'a')
    log_file.puts "Message sent: \"#{order}\" ->  #{orderMessage}."
    puts "Message sent: \"#{order}\" ->  #{orderMessage}."
    
    socket.write(encrypt(orderMessage))
    message = socket.recv(2048)

    log_file.puts "Message recived: #{decrypt(message)}."
    puts "Message recived: #{decrypt(message)}."
    log_file.puts "\n"
    puts "\n"
    log_file.close
    
    socket.close
  end
end