module RBase
  module Columns
    # Base class for all column types
    class Column
      @@types = {}

      # Assigns column type string to current class
      def self.column_type(type)
        @type = type
        @@types[type] = self
      end

      # Returns column type class that correspond to given column type string
      def self.column_for(type)
        throw "Unknown column type '#{type}'" unless @@types.key?(type)
        @@types[type]
      end

      # Returns column type as 1 character string
      def self.type
        @type
      end

      # Returns column type as 1 character string
      def type
        self.class.type
      end

      # Column name, Column offset from the beginning of the record,
      # Column size in characters and Number of decimal places
      attr_reader :name, :offset, :size, :decimal

      def initialize(name, options = {})
        options.merge(name: name, type: self.class.type)
               .each { |k, v| instance_variable_set("@#{k}", v) }
      end

      def attach_to(table)
        @table = table
      end

      # Packs column value for storing it in XBase file.
      def pack(_value)
        throw 'Not implemented'
      end

      # Unpacks stored in XBase column data into appropriate Ruby form.
      def unpack(_value)
        throw 'Not implemented'
      end

      def inspect
        "#{name}(type=#{type}, size=#{size})"
      end

      protected

      attr_reader :table
    end

    class CharacterColumn < Column
      column_type 'C'

      def initialize(name, options = {})
        size = if options[:size] && options[:decimal]
                 options[:decimal] * 256 + options[:size]
               else
                 options[:size] || 254
               end

        super(name, options.merge(size: size))

        @encoding = options[:encoding]
        if @encoding
          @unpack_converter = Encoder.new(options[:encoding], 'utf-8')
          @pack_converter = Encoder.new('utf-8', options[:encoding])
        end
      end

      def pack(value)
        value = value.to_s
        @encoding ? @pack_converter.en(value) : [value].pack("A#{size}")
      end

      def unpack(value)
        value = value.to_s.rstrip
        @encoding ? @unpack_converter.en(value) : value
      end

      def inspect
        "#{name}(string #{size})"
      end
    end

    class NumberColumn < Column
      column_type 'N'

      def initialize(name, options = {})
        size = options[:size] || 18
        size = 18 if size > 18

        super(name, options.merge(size: size))
      end

      def pack(value)
        if value
          if float?
            [format("%#{size - decimal - 1}.#{decimal}f", value)]
              .pack("A#{size}")
          else
            [format("%#{size}d", value)].pack("A#{size}")
          end
        else
          ' ' * size
        end
      end

      def unpack(data)
        return nil if data.strip == ''
        data = data.strip
        float? ? data.to_f : data.to_i
      end

      def inspect
        if float?
          "#{name}(decimal)"
        else
          "#{name}(integer)"
        end
      end

      def float?
        decimal && decimal.nonzero?
      end
    end

    class LogicalColumn < Column
      column_type 'L'

      def initialize(name, options = {})
        super name, options.merge(size: 1)
      end

      def pack(value)
        case value
        when true then 'T'
        when false then 'F'
        else '?'
        end
      end

      def unpack(data)
        case data.upcase
        when 'Y', 'T'
          true
        when 'N', 'F'
          false
        end
      end

      def inspect
        "#{name}(boolean)"
      end
    end

    class DateColumn < Column
      column_type 'D'

      def initialize(name, options = {})
        super(name, options.merge(size: 8))
      end

      def pack(value)
        value ? value.strftime('%Y%m%d') : ' ' * 8
      end

      def unpack(data)
        return nil if data.rstrip == ''
        Date.new(*data.unpack('a4a2a2').map(&:to_i))
      end

      def inspect
        "#{name}(date)"
      end
    end

    class MemoColumn < Column
      column_type 'M'

      def initialize(name, options = {})
        super(name, options.merge(size: 10))
      end

      def pack(value)
        packed_value = table.memo.write(value)
        [format('%-10d', packed_value)].pack('A10')
      end

      def unpack(data)
        table.memo.read(data.to_i)
      end

      def inspect
        "#{name}(memo)"
      end
    end

    class FloatColumn < Column
      column_type 'F'

      def initialize(name, options = {})
        super(name, options.merge(size: 20))
      end

      def decimal
        @decimal && @decimal <= 15 ? @decimal : 2
      end

      def pack(value)
        [format("%-#{size - decimal - 1}.#{decimal}f", value || 0.0)]
          .pack("A#{size}")
      end

      def unpack(data)
        data.rstrip.to_f
      end

      def inspect
        "#{name}(float)"
      end
    end
  end
end
