require 'test_helper'

class TestCreateRecord < Minitest::Test
  def setup
    RBase.create_table('users') do |t|
      t.column :name, :string, size: 20
      t.column :birthdate, :date
      t.column :active, :boolean
      t.column :tax, :integer, size: 10, decimal: 2
    end

    dbf.create(data)
    dbf.close

    @table = RBase::Table.open('users', encoding: 'utf-8')
  end

  def test_has_one_row_of_data
    assert_equal 1, @table.count
  end

  def test_has_correct_data
    file_data = @table[0]
    assert_equal data[:name], file_data.name
    assert_equal data[:birthdate], file_data.birthdate
    assert_equal data[:active], file_data.active
    assert_equal data[:tax], file_data.tax
  end

  def teardown
    FileUtils.rm('users.dbf')
  end

  private

  def data
    @_data ||= {
      name: 'John Doe',
      birthdate: Date.today,
      active: true,
      tax: 134.23
    }
  end

  def dbf
    @_dbf ||= RBase::Table.open('users')
  end
end
