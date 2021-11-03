require "zebra/zpl/printable"

module Zebra
  module Zpl
    class Barcode
      APPLICATION_IDENTIFIER_REGEX = /^\(\d+\).+/.freeze

      include Printable

      class InvalidRatioError < StandardError; end
      class InvalidNarrowBarWidthError < StandardError; end
      class InvalidWideBarWidthError   < StandardError; end

      attr_accessor :height, :application_identifier
      attr_reader :type, :ratio, :narrow_bar_width, :wide_bar_width
      attr_writer :print_human_readable_code, :print_text_above

      def width=(value)
        @width = value || 0
      end

      def width
        @width || @narrow_bar_width || @wide_bar_width || 0
      end

      def type=(type)
        BarcodeType.validate_barcode_type(type)
        @type = type
      end

      def ratio=(value)
        raise InvalidRatioError unless value.to_f >= 2.0 && value.to_f <= 3.0
        @ratio = value
      end

      def ratio
        if !@wide_bar_width.nil? && !@narrow_bar_width.nil?
          (@wide_bar_width.to_f / @narrow_bar_width.to_f).round(1)
        else
          @ratio
        end
      end

      def narrow_bar_width=(value)
        raise InvalidNarrowBarWidthError unless (1..10).include?(value.to_i)
        @narrow_bar_width = value
      end

      def wide_bar_width=(value)
        raise InvalidWideBarWidthError unless (2..30).include?(value.to_i)
        @wide_bar_width = value
      end

      def print_human_readable_code
        @print_human_readable_code || false
      end

      def human_readable
        print_human_readable_code ? "Y" : "N"
      end

      def print_text_above
        @print_text_above || false
      end

      def text_above
        print_text_above ? "Y" : "N"
      end

      # ShipHawk trick: Start
      def mode
        if application_identifier || data.to_s.match?(APPLICATION_IDENTIFIER_REGEX)
          'D'
        else
          'A'
        end
      end

      def mode_prefix
        application_identifier ? "(#{application_identifier})" : nil
      end
      # ShipHawk trick: End

      def to_zpl
        check_attributes
        "^FW#{rotation}^FO#{x},#{y}^BY#{width},#{ratio},#{height}^B#{type}#{rotation},,#{human_readable},#{text_above},,#{mode}^FD#{mode_prefix}#{data}^FS"
      end

      private

      def check_attributes
        super
        raise MissingAttributeError.new("the barcode type to be used is not given") unless @type
        raise MissingAttributeError.new("the height to be used is not given") unless @height
        raise MissingAttributeError.new("the width to be used is not given") unless @width || @narrow_bar_width || @wide_bar_width
      end
    end
  end
end
