module Orvibo; module Message
  class UDPReceiveMessage
    attr_accessor :mac, :ip, :type, :length
    protected
    def initialize(mac, ip, type, length)
      @mac = mac
      @ip = ip
      @type = type
      @length = length
    end

    def supported?(type, length)
      @type.include?(type) && @length == length
    end
  end

  class DiscoveryReceiveMessage
    LENGTH = 42
    TYPE = ["7167", "7161"]
    def initialize(mac, ip, revision)
      
    end
  end
end; end
