require 'dnssd'

module Medusa

  class LabyrinthAnnouncer

    def self.announce(port)
      LabyrinthAnnouncer.new.announce(port)
    end

    def initialize(args={})
      @logger = args.fetch(:logger, Medusa.logger.tagged(self.class.name))
    end

    def announce(port)
      @logger.debug("Announcing #{service_name} as type #{service_type} on port #{port}")
      DNSSD.announce labyrinth_tcp_server(port), service_name, service_type
      @logger.info("Bonjour, I am #{service_name} acting as a #{service_type} service on port #{port}")
    rescue => e
      @logger.error("Failed to announce labyrinth on Bonjour as #{service_name} #{service_type} on port #{port}", e)
    end

    def labyrinth_tcp_server(port)
      TCPServer.new nil, port
    end

    def service_name
      "MedusaLabyrinth"
    end

    def service_type
      "http"
    end

  end

end
