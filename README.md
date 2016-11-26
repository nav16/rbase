rbase
=====

[![Build Status](https://travis-ci.org/cybrilla/rbase.svg?branch=master)](https://travis-ci.org/cybrilla/rbase)
[![Coverage Status](https://coveralls.io/repos/github/cybrilla/rbase/badge.svg?branch=master)](https://coveralls.io/github/cybrilla/rbase?branch=master)

rbase gem is used to create DBF files.

How to use:

First create a DBF file.

##Creating DBF
```ruby
   RBase.create_table 'people' do |t|
     t.column :name, :string, size: 30
     t.column :birthdate, :date
     t.column :active, :boolean
     t.column :tax, :integer, size: 10, decimal: 2
   end
```
You can provide file path in place of name, eg. `people` can be `tmp/dbfs/people`.

###Options:

  * `:size` - size of the column in characters
  * `:decimal` - number of decimal positions
  * `:string` - corresponds to fixed length character column. Column size is limited to 254 (default).
  * `:date` - date column type
  * `:boolean` - logical column type
  * `:integer` - number column type.

  -- Some column types (e.g. :date type) have fixed size that cannot be overridden.

  --Number is stored in human readable form (text representation), so you should specify it's size in characters. Maximum column size is 18 (default).


##Adding Records

  The records can be added once the file is created by opening the file using `RBase::Table.open(file_path)` and then calling `create` method and passing a hash. Eg:

```ruby
    dbf = RBase::Table.open(people)
    row = {
            name: "John Doe",
            birthdate: Date.current,
            active: 1,
            tax: 134.23
          }
    dbf.create(row)
    dbf.close
```
##Points To Remember
  - The column name can not be more than 10 characters and should not have spaces.
  - The column with date type pass the date object not a string or any other.
  - The gem will generate file in `dbase III` format.
