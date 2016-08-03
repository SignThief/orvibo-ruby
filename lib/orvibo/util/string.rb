class String
  def packHex()
    [self].pack("H*")
  end

  def unpackHex()
    unpack("H*").first
  end

  def unpackSInt()
    unpack("n").first
  end
end
