require 'orvibo/util/string'
require 'orvibo/s20_outlet'
require 'time'
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
    POWER_CMD = "6463"
    INFO_TABLE = "040003"
    NAME_INDEX = 70
    NAME_SIZE = 16
    GLOBAL_DISCOVERY_MSG = MAGIC_KEY + "0006" + GDISCOVER_CMD
    POWER_TOGGLE_MSG = MAGIC_KEY + "0017" + POWER_CMD
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
    DEFAULT_TIMEOUT = 2
    GLOBAL_DISCOVERY_MSG_SIZE = 42
    DISCOVERY_MSG_SIZE = 42
    EPOCH_TIME_DIFF_SECS = Time.at(0) - Time.new(1900, 1, 1, 0, 0, 0, "+00:00")

    def initialize(timeout = DEFAULT_TIMEOUT, broadcast_address = DEFAULT_BROADCAST_ADDRESS)
      @socket = UDPSocket.open
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      @socket.bind(Socket::INADDR_ANY, DEFAULT_PORT)
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
      @timeout = timeout
      @broadcast_address = broadcast_address
    end

    def discoverOutlets()
      sendBroadcastMessage(GLOBAL_DISCOVERY_MSG)
      outlets = {}
      receiveMsg do |msg, addr|
        if msg[0..1].unpackHex == MAGIC_KEY && msg[2..3].unpackSInt == GLOBAL_DISCOVERY_MSG_SIZE && msg[4..5].unpackHex == GDISCOVER_CMD
          data = getDiscoveryFields(msg, addr)
          if !outlets.has_key?("#{data.ip}")
            s = S20Outlet.new(data.mac, data.state, data.ip, data.revision)
            s.last_update = data.time
            outlets["#{data.ip}"] = s
          else
            s = outlets["#{data.ip}"]
            s.state = data.state
          end
        end
      end
      return outlets
    end

    def refresh(outlet)
      s_msg = DISCOVERY_MSG + outlet.mac + SIX_SPACES
      sendBroadcastMessage(s_msg)
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
      sendMessage(s_msg, outlet)
      receiveMsg do |msg, addr|
        if msg[4..5].unpackHex == SUBSCRIBE_CMD && addr.last == outlet.ip
          outlet.state = msg[-1].unpackHex
        end
      end
    end

    def outletInfo(outlet)
      s_msg = INFO_MSG + outlet.mac + SIX_SPACES + FOUR_ZEROS + INFO_TABLE + FOUR_ZEROS
      sendMessage(s_msg, outlet)
      receiveMsg do |msg, addr|
        if msg[4..5].unpackHex == INFO_CMD
          outlet.name = msg[NAME_INDEX, NAME_SIZE].strip
        end
      end
    end

    def powerOn(outlet)
      s_msg = POWER_TOGGLE_MSG + outlet.mac + SIX_SPACES + FOUR_ZEROS + "01"
      sendMessage(s_msg, outlet)
      receiveMsg do |msg, addr|
        puts "Received: #{msg.unpackHex}"
      end
    end

    def powerOff(outlet)
      s_msg = POWER_TOGGLE_MSG + outlet.mac + SIX_SPACES + FOUR_ZEROS + "00"
      sendMessage(s_msg, outlet)
      receiveMsg do |msg, addr|
        puts "Received: #{msg.unpackHex}"
      end
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
      fields.time = parseTime(msg[37..40])
      return fields
    end

    def sendBroadcastMessage(msg)
      @socket.send(msg.packHex(), 0, @broadcast_address, DEFAULT_PORT)
    end

    def sendMessage(msg, outlet)
      @socket.send(msg.packHex(), 0, outlet.ip, DEFAULT_PORT)
    end

    def receiveMsg()
      begin
        loop do
          msg = nil
          addr = nil
          status = Timeout::timeout(@timeout) do
            msg, addr = @socket.recvfrom(BUFFER_SIZE)
            if msg[0..1].unpackHex == MAGIC_KEY
              yield msg, addr
            end
          end
        end
      rescue Timeout::Error
      end
    end

    def parseTime(timeBytes)
      num_seconds = timeBytes.unpack("I*").first
      return Time.at(num_seconds - EPOCH_TIME_DIFF_SECS)
    end
  end
end
