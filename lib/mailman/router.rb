require 'pp'

module Mailman
  # The router. Stores routes and uses them to process messages.
  class Router

    # @return [Array] the list of routes
    attr_accessor :routes

    # @return [Hash] the params of the most recently processed message. Used by
    #   route blocks.
    attr_reader :params

    def initialize
      @routes = []
      @params = {}
    end

    # Adds a route to the router.
    # @param [Mailman::Route] the route to add.
    # @return [Mailman::Route] the route object that was added (allows
    #   chaining).
    def add_route(route)
      @routes.push(route)[-1]
    end

    # Route a message. If the route block accepts arguments, it passes any
    # captured params. Named params are available from the +params+ helper.
    # @param [Mail::Message] the message to route.
    def route(message)
      result = nil

      routes.each do |route|
        break if result = route.match!(message)
      end

      if result
        @params.merge!(result[:params])
        if result[:block].arity > 0
          instance_exec(*result[:args], &result[:block])
        else
          instance_exec(&result[:block])
        end
      end
    end

  end
end
