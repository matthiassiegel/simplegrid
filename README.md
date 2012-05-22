# SimpleGrid

A Ruby wrapper class for MongoDB's GridFS file storage.

This class was created mostly as a learning experience while working with MongoDB and GridFS. Its aim was to simplify working with GridFS by providing a simple Rails-like API for the most common operations in the app I was working on. Internally it simply forwards to the Grid and GridFileSystem classes of the official Mongo Ruby driver.

The class provides the following methods:

* #find
* #create
* #update
* #read
* #delete
* #find\_by\_filename
* #read\_by\_filename
* #delete\_by\_filename

See the code for info on arguments and return values.

## How to use

In Rails, put files in the lib folder and make sure it's loaded by the app.

    class Theme
      
      def files
        SimpleGrid.new(MongoMapper.database, 'themes')
      end
      
      def templates
        files.find_by_filename(/\/path\/to\/templates\//)
      end
      
    end
    
    
    theme = Theme.first
    theme.templates.first.read
    
    file = theme.files.find_by_filename("path/to/file")

Tested with Rails 3.2, Mongo 1.6.2 and MongoMapper. Should work with Mongoid as well by using `Mongoid.database` in the example above.

## Copyright

Copyright (c) 2012 Matthias Siegel.
See [LICENSE](https://github.com/matthiassiegel/simplegrid/tree/master/LICENSE.md) for details.