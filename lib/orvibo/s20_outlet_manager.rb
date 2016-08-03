require 'orvibo/util/string'
require 'orvibo/s20_outlet'
require 'timeout'
require 'pp'
require 'ostruct'

module Orvibo

  class S20OutletManager
    BIND_IP = "0.0.0.0"
    DEFAULT_PORT = 10000
    MAGIC_KEY = "6864"
    SIX_SPACES = "202020202020"
    FOUR_ZEROS = "00000000";
    GDISCOVER_CMD = "7161"
    DISCOVER_CMD = "7167"
    SUBSCRIBE_CMD = "636c"
    INFO_CMD = "7274"
    INFO_TABLE = "040017"
    GLOBAL_DISCOVERY_MSG = MAGIC_KEY + "0006" + GDISCOVER_CMD
    DISCOVERY_MSG = MAGIC_KEY + "0012" + DISCOVER_CMD
    SUBSCRIBE = MAGIC_KEY + "001e" + SUBSCRIBE_CMD
    INFO_MSG = MAGIC_KEY + "001d" + INFO_CMD
    ACTION = MAGIC_KEY + "00176463"
    ON = "0000000001"
    OFF = "0000000000"
    ONT = "01"
    OFFT = "00"
    MAX_RETRIES = 20
    TIMEOUT = 0.3
    BUFFER_SIZE = 500
    WRITE_OUTLET_CODE = "746D"
    NULL_MAC = "000000000000"
    DEFAULT_BROADCAST_ADDRESS = "192.168.1.255"
    DEFAULT_TIMEOUT = 3
    GLOBAL_DISCOVERY_MSG_SIZE = 42
    DISCOVERY_MSG_SIZE = 42

    def initialize(timeout = DEFAULT_TIMEOUT, broadcast_address = DEFAULT_BROADCAST_ADDRESS)
      @socket = UDPSocket.new()
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      @socket.bind(BIND_IP, DEFAULT_PORT)
      @timeout = timeout
      @broadcast_address = broadcast_address
    end

    def discoverOutlets()
      @socket.send(GLOBAL_DISCOVERY_MSG.packHex(), 0, @broadcast_address, DEFAULT_PORT)
      outlets = {}
      receiveMsg do |msg, addr|
        data = getDiscoveryFields(msg, addr)
        puts data.time
        if !outlets.has_key?("#{data.ip}:#{data.mac}")
          s = S20Outlet.new(data.mac, data.state, data.ip, data.revision)
          outlets["#{data.ip}:#{data.mac}"] = s
        else
          s = outlets["#{data.ip}:#{data.mac}"]
          s.state = data.state
        end
      end
      return outlets
    end

    def refresh(outlet)
      s_msg = DISCOVERY_MSG + outlet.mac + SIX_SPACES
      @socket.send(s_msg.packHex(), 0, @broadcast_address, DEFAULT_PORT)
      receiveMsg do |msg, addr|
        if msg[0..1].unpackHex == MAGIC_KEY && msg[2..3].unpackSInt == DISCOVERY_MSG_SIZE && msg[4..5].unpackHex == DISCOVER_CMD
          data = getDiscoveryFields(msg, addr)
          puts data.time
          outlet.ip = data.ip
        end
      end
    end

    def subscribe(outlet)
      s_msg = SUBSCRIBE + outlet.mac + SIX_SPACES +
        outlet.reverse_mac + SIX_SPACES
      puts "Sending #{s_msg} to #{outlet.ip}"
      @socket.send(s_msg.packHex(), 0, outlet.ip, DEFAULT_PORT)
      receiveMsg do |msg, addr|
        puts "Received: #{msg}"
        if msg[4..5].unpackHex == SUBSCRIBE_CMD && addr.last == outlet.ip
          outlet.status = msg.last.unpackHex
        end
      end
    end

    def outletInfo(outlet)
      s_msg = INFO_MSG + outlet.mac + SIX_SPACES + FOUR_ZEROS + INFO_TABLE + FOUR_ZEROS
      puts s_msg
      @socket.send(s_msg, 0, outlet.ip, DEFAULT_PORT)
      receiveMsg do |msg, addr|
        puts "Received: #{msg}"
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
    private
    def getDiscoveryFields(msg, addr)
      fields = OpenStruct.new
      fields.mac = msg[7..12].unpackHex
      fields.ip = addr.last
      fields.state = msg[-1].unpackHex
      fields.command = msg[4..6].unpackHex
      fields.revision = msg[31..36]
      fields.time = "#{msg[40].ord} #{msg[39].ord} #{msg[38].ord} #{msg[37].ord}"
      return fields
    end

    def receiveMsg()
      begin
        loop do
          msg = nil
          addr = nil
          status = Timeout::timeout(@timeout) do
            msg, addr = @socket.recvfrom(BUFFER_SIZE)
            if msg[0..1].unpackHex == MAGIC_KEY && msg[2..3].unpackSInt == GLOBAL_DISCOVERY_MSG_SIZE && msg[4..5].unpackHex == GDISCOVER_CMD
              yield msg, addr
            end
          end
        end
      rescue Timeout::Error
      end
    end

    def parseTimeFields(timeBytes)
    end




  end
end
