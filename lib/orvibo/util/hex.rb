module Orvibo; module Util; module Hex

  def self.string2Bytes(hexStr)
    return [hexStr].pack("H*")
  end

end; end; end;
