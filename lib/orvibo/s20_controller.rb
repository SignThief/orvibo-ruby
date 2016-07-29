require 'orvibo/util/string'

module Orvibo

  class S20Controller
    BIND_IP = "0.0.0.0"
    DEFAULT_PORT = 10000
    MAGIC_KEY = "6864"
    SIX_TWENTIES = "202020202020"
    FOUR_ZEROS = "00000000";
    DISCOVERY_MSG = MAGIC_KEY + "00067161"
    SUBSCRIBE = MAGIC_KEY + "001e636C"
    ACTION = MAGIC_KEY + "00176463"
    ON = "0000000001"
    OFF = "0000000000"
    ONT = "01"
    OFFT = "00"
    MAX_RETRIES = 20
    TIMEOUT = 0.3
    BUFFER_SIZE = 500
    WRITE_SOCKET_CODE = "746D"
    SEARCH_IP = "7167"
    NULL_MAC = "000000000000"
    BROADCAST_ADDRESS = "192.168.1.255"
    def initialize()
      @socket = UDPSocket.new()
      @socket.bind(BIND_IP, DEFAULT_PORT)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def discoverSockets()
      @socket.send(DISCOVERY_MSG.packHex(), 0, BROADCAST_ADDRESS, DEFAULT_PORT)
      loop do
        msg, addr = @socket.recvfrom(BUFFER_SIZE)
        puts "Received: #{msg.unpackHex()}"
      end
    end

    def on()
      # Send on event
    end

    def off()
      # Send off event
    end

    def addTimer(timerEvent)
      # Add timer event
    end

    def removeTimer(timerEvent)
      # Remove timer event
    end

    def setName(name)
      # Set the name for the socket
    end
  end
end
