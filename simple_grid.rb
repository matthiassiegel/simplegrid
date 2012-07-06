# coding: utf-8

class SimpleGrid
  
  #
  # Create a new instance of GridFS, and for the requested collection
  #
  # @param [Object] database Mongo database object
  # @param [String] prefix GridFS collection prefix
  #
  def initialize(database, prefix = 'fs')
    @@grid ||= Mongo::Grid.new(database, prefix)
    @@coll ||= database["#{prefix}.files"]
  end
  
  
  #
  # Check if a file exists
  #
  # @param [Hash] selector A query selector, e.g. :filename => 'foo.txt', :content_type => 'image/jpg'
  # @param [Boolean] prefix GridFS collection prefix
  #
  def exist?(selector)
    @@grid.exist?(selector) ? true : false
  end
  
  
  #
  # Store a new file
  #
  # @param [String, #read] data String or IO-like object
  # @param [Hash] options Options Hash. See http://api.mongodb.org/ruby/current/Mongo/Grid.html#put-instance_method for options.
  # @return [BSON::ObjectId] BSON::ObjectId of the newly created file
  #
  def create(data, options = {})
    @@grid.put(data, options)
  end
  
  
  #
  # Update an existing file, replacing the current version. If the file doesn't exist it will be created.
  #
  # @param [BSON::ObjectId] ID BSON::ObjectId of the file that should be updated
  # @param [String, #read] data String or IO-like object
  # @param [Hash] options Options Hash. See http://api.mongodb.org/ruby/current/Mongo/Grid.html#put-instance_method for options.
  # @return [BSON::ObjectId, Boolean] BSON::ObjectId of the newly created file, or false 
  #
  def update(id, data, options = {})
    if delete(id)
      create(data, options)
    else
      false
    end
  end
  
  
  #
  # Find a file by its unique ID
  #
  # @param [BSON::ObjectId] ID BSON::ObjectId of the file to get
  # @return [GridIO] GridIO instance of the requested file, or nil
  #
  def find(id)
    begin
      @@grid.get(id)
    rescue
      nil
    end
  end
  
  
  #
  # Find one or more files by their filenames
  #
  # @param [String, Regexp] Filename Filename or regular expression
  # @return [Array] Array of GridIO instances
  #
  def find_by_filename(filename)
    result = @@coll.find(:filename => filename).to_a
    
    if result.count > 1
      result.map! { |r| find(r['_id']) }
    else
      result.blank? ? [] : [find(result.first['_id'])]
    end
  end
  
  
  #
  # Read a file by its unique ID
  #
  # @param [BSON::ObjectId] ID BSON::ObjectId of the file to read
  # @return [String, nil] File content, or nil
  #
  def read(id)
    begin
      find(id).read
    rescue
      nil
    end
  end
  
  
  #
  # Read one or more files by their filenames
  #
  # @param [String, Regexp] Filename Filename or regular expression
  # @return [Array] Array of file content strings
  #
  def read_by_filename(filename)
    result = find_by_filename(filename)
    
    if result.count > 1
      result.map! { |r| read(r['_id']) }
    else
      result.blank? ? [] : [read(result.first['_id'])]
    end
  end
  
  
  #
  # Delete a file by its unique ID
  # Note: in safe mode, Grid.delete doesn't return Boolean, so success is confirmed by calling #exist?
  #
  # @param [BSON::ObjectId] ID BSON::ObjectId of the file to delete
  # @return [Boolean] False if the file didn't exist or couldn't be deleted. True otherwise.
  #
  def delete(id)
    begin
      return false unless exist?(id)
      @@grid.delete(id)
      exist?(id) ? false : true
    rescue
      false
    end
  end
  
  
  #
  # Delete one or more files by their filenames
  #
  # @param [String, Regexp] Filename Filename or regular expression
  # @return [Boolean] True if all went well. False if one or more files couldn't be deleted.
  #
  def delete_by_filename(filename)
    result = find_by_filename(filename)
    
    if result.count > 1
      success = true
      result.each { |r| success = false unless delete(r['_id']) }
      success
    else
      result.blank? ? false : delete(result.first['_id'])
    end
  end
  
end