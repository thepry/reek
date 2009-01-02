$:.unshift File.dirname(__FILE__)

require 'reek/options'

class Class
  def name_words
    class_name = name.split(/::/)[-1]
    class_name.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split
  end
end

module Reek
  module Smells

    class SmellDetector
      
      @@enabled = true
      @@exceptions = []
      
      def self.class_name
        self.name.split(/::/)[-1]
      end

      def self.configure(hash)              # :nodoc:
        section = hash[class_name]
        update(:enabled, section)
        update(:exceptions, section)
        set_default_values(section)
      end

      def self.update(var, hash)
        val = hash[var.to_s]
        class_eval "@@#{var} = #{val.inspect}" if val
      end

      def self.set_default_values(hash)      # :nodoc:
      end

      def self.attach_to(hash)      # :nodoc:
        contexts.each { |ctx| hash[ctx] << self }
      end

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end
      
      def self.config   # :nodoc:
        CONFIG[class_name]
      end

      #
      # Checks the given +context+ for smells.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(context, report)
        before = report.size
        examine_context(context, report) if @@enabled
        report.length > before
      end

      def self.exception?(val)
        @@exceptions.include?(val)
      end

      def self.enable
        @@enabled = true
      end

      def self.disable
        @@enabled = false
      end
    end

    class SmellReport
      include Comparable

      def initialize(context, arg=nil)
        @context = context
      end

      def hash  # :nodoc:
        report.hash
      end

      def <=>(other)  # :nodoc:
        Options[:sort_order].compare(self, other)
      end

      alias eql? <=>

      def self.smell_name
        name_words[0..-2].join(' ')
      end

      def report
        "[#{self.class.smell_name}] #{detailed_report}"
      end

      alias inspect report
    end
  end
end