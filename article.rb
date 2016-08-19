require 'active_record'

class Article < ActiveRecord::Base
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'science_direct.db'
  )
end
