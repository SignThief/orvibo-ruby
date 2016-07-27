require 'socket'
require 'orvibo/util/hex'

module Orvibo; module Net
  include Orvibo::Util
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
  class S20Client
    def initialize(broadcastAddr = BROADCAST_ADDRESS)
      @socket = UDPSocket.new()
      @socket.bind(BIND_IP, 0)
      @broadcastAddr = broadcastAddr
      @messageHandlers = []
    end

    def sendDiscoveryMsg()
      @socket.send(Hex.string2Bytes(DISCOVERY_MSG))
    end

    def registerMessageHandler(messageHandler)
      @messageHandlers << messageHandler
    end

    def unregisterMessageHandler(messageHandler)
      @messageHandlers.delete(messageHandler)
    end

  end
end
