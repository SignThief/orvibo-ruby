require 'orvibo/util/string'
require 'timeout'
require 'pp'

module Orvibo

  class S20Outlet
    attr_accessor :mac, :ip, :name, :state, :revision, :last_update
    def initialize(mac, state = nil, ip = nil, revision = nil)
      @mac = mac
      @state = state
      @ip = ip
      @revision = revision
      @name = nil
    end

    def reverse_mac()
      @mac.packHex.reverse.unpackHex
    end

    def to_s()
      return "#{@mac}(#{@ip}):#{@revision}:#{@state}"
    end
  end
end
