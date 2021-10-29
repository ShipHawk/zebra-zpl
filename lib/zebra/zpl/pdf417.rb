require "zebra/zpl/printable"

module Zebra
  module Zpl
    class PDF417
      include Printable

      class InvalidWidthError < StandardError; end
      class InvalidHeightError < StandardError; end
      class InvalidSecurityLevelError < StandardError; end
      class InvalidRowColumnNumberError < StandardError; end

      attr_reader :row_width, :row_height, :security_level, :column_number, :row_number, :truncate

      def row_width=(value)
        raise InvalidWidthError unless (1..10).include?(value.to_i)
        @row_width = value
      end

      def row_height=(value)
        raise InvalidHeightError unless value.to_i > 0
        @row_height = value
      end

      def row_number=(value)
        raise InvalidRowColumnNumberError unless (3..90).include?(value.to_i)
        @row_number = value
      end

      def column_number=(value)
        raise InvalidRowColumnNumberError unless (1..30).include?(value.to_i)
        @column_number = value
      end

      def truncate=(value)
        @truncate = value
      end

      def security_level=(value)
        raise InvalidSecurityLevelError unless (0..8).include?(value.to_i)
        @security_level = value
      end

      def to_zpl
        check_attributes
        "^FO#{x},#{y}^BY#{row_width},,10^B7#{rotation},#{row_height},#{security_level},#{column_number},#{row_number},#{truncate}^FH_^FD#{data}^FS"
      end

      private

      def check_attributes
        super
        raise InvalidRowColumnNumberError if !@row_number.nil? && !@column_number.nil? && @row_number.to_i * @column_number.to_i > 928
      end
    end
  end
end
