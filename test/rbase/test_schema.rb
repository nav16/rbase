require 'test_helper'

class TestSchema < Minitest::Test
  def setup
    @schema = RBase::Schema.new
  end

  def test_string_column
    @schema.column(:name, :string, size: 20)
    test_column('NAME', 'C', 20)
  end

  def test_integer_column
    @schema.column(:age, :integer, size: 10)
    test_column('AGE', 'N', 10)
  end

  def test_boolean_column
    @schema.column(:active, :boolean)
    test_column('ACTIVE', 'L', 1)
  end

  def test_date_column
    @schema.column(:birthdate, :date)
    test_column('BIRTHDATE', 'D', 8)
  end

  def test_float_column
    @schema.column(:amount, :float)
    test_column('AMOUNT', 'N', 18)
  end

  private

  def test_column(name, type, size)
    assert_equal 1, @schema.columns.count

    column = @schema.columns.first
    assert_equal name, column.name
    assert_equal type, column.type
    assert_equal size, column.size
  end
end
