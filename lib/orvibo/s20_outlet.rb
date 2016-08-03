require 'orvibo/util/string'
require 'timeout'
require 'pp'

module Orvibo

  class S20Outlet
    attr_accessor :mac, :ip, :name, :state, :revision
    def initialize(mac, state = nil, ip = nil, revision = nil)
      @mac = mac
      @state = state
      @ip = ip
      @revision = revision
    end

    def reverse_mac()
      @mac.reverse
    end

    def to_s()
      return "#{@mac}(#{@ip}):#{@revision}:#{@state}"
    end
  end
end
