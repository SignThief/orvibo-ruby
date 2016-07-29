class String
  def packHex()
    [self].pack("H*")
  end

  def unpackHex()
    unpack("H*")
  end
end
