require "zebra/zpl/printable"

module Zebra
  module Zpl
    class Raw
      include Printable

      attr_reader :width

      def width=(width)
        if margin.nil? || margin < 1
          @width = width || 0
        else
          @width = (width - (margin * 2))
        end
      end

      def to_zpl
        # check_attributes
        "^FW#{rotation}^FO#{x},#{y}#{data}^FS"
      end
    end
  end
end
