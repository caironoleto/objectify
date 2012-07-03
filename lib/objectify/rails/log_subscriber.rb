require "active_support/all"

module Objectify
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      def start_processing(event)
        debug("    [Objectify] Started #{event.payload[:route]}")
      end

      def inject(event)
        return unless debug?

        object     = event.payload[:object]
        method     = event.payload[:method]
        parameters = event.payload[:parameters].map do |req, param|
          param if req == :req
        end.compact
        arguments  = event.payload[:arguments].map(&:class).inspect[1..-2]

        message = "      [Injector] Invoking #{object}.#{method}(#{arguments}). "
        message << duration(event)

        debug(message)
      end

      def executor_start(event)
        return unless debug?

        type = event.payload[:type].to_s.capitalize
        debug("    [#{type}] Executing #{event.payload[:name]} " + duration(event))
      end

      def executor(event)
        return unless debug?

        type = event.payload[:type].to_s.capitalize
        debug("    [#{type}] Executed #{event.payload[:name]} " + duration(event))
      end

      def policy_chain_halted(event)
        return unless debug?

        debug("    [Policy] Chain halted at #{event.payload[:policy]}. Responding with #{event.payload[:responder]}." + duration(event))
      end

      def logger(logger_object = ::Rails.logger)
        logger_object
      end

      private

      def debug(message)
        logger.debug message
      end

      def debug?
        logger.debug?
      end

      def duration(event)
        "#{"(%.1fms)" % event.duration}"
      end
    end
  end
end

Objectify::Rails::LogSubscriber.attach_to(:objectify)
