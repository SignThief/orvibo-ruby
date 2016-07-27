module Orvibo
  class S20Controller
    def initialize(id, udpSocket)
      @id = id
      @socket = udpSocket
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
