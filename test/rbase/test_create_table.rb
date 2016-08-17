require 'test_helper'

class TestCreateTable < Minitest::Test
  def setup
    @schema = RBase::Schema.new
    @schema.column(:name, :string, size: 20)
    @schema.column(:birthdate, :date)
    @schema.column(:active, :boolean)
    @schema.column(:age, :integer, size: 10, decimal: 2)

    RBase::Table.create('users', @schema, language: RBase::LANGUAGE_RUSSIAN_WINDOWS)
  end

  def test_file_headers
    date = Date.today

    assert_equal [0x03], file[0].unpack('C') # version
    assert_equal [date.year % 100, date.month, date.day], file[1..3].unpack('CCC') # last modification date
    assert_equal [0], file[4..7].unpack('L') # number of records
    assert_equal [32 + @schema.columns.size * 32 + 1], file[8..9].unpack('v') # data size
    assert_equal [40], file[10..11].unpack('v') # record size
    assert_equal [], file[12..27].unpack('x16') # reserved
    assert_equal [0], file[28].unpack('c') # mdx flag
    assert_equal [RBase::LANGUAGE_RUSSIAN_WINDOWS], file[29].unpack('C') # language driver
    assert_equal [], file[30..31].unpack('x2') # reserved
  end

  def test_columns
    test_column('NAME', 'C', 32, size: 20, column_offset: 1)
    test_column('BIRTHDATE', 'D', 64, size: 8, column_offset: 21)
    test_column('ACTIVE', 'L', 96, size: 1, column_offset: 29)
    test_column('AGE', 'N', 128, size: 10, column_offset: 30)
  end

  def teardown
    FileUtils.rm('users.dbf')
  end

  private

  def test_column(name, type, offset, options = {})
    assert_equal [name], file[offset..(offset += 10)].unpack('A11') # field name

    assert_equal [type], file[offset += 1].unpack('A') # field type

    assert_equal [options[:column_offset]], file[(offset += 1)..(offset += 3)].unpack('L') # field data offset
    assert_equal [options[:size]], file[offset += 1].unpack('C') # field size

    assert_equal [], file[(offset += 1)..(offset + 13)].unpack('x14') # reserved
  end

  def file
    @file ||= File.open('users.dbf', 'rb').read
  end
end
