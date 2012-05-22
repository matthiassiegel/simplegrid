# coding: utf-8

class SimpleGrid
  
  #
  # Create a new instance of GridFS, and for the requested collection
  #
  # @param [Object] Mongo database object
  # @param [String] GridFS collection prefix
  #
  def initialize(database, prefix = 'fs')
    @grid ||= Mongo::Grid.new(database, prefix)
    @coll ||= database["#{prefix}.files"]
  end
  
  
  #
  # Store a new file
  #
  # @param [String, #read] String or IO-like object
  # @param [Hash] Options Hash. See http://api.mongodb.org/ruby/current/Mongo/Grid.html#put-instance_method for options.
  # @return [BSON::ObjectId] BSON::ObjectId of the newly created file
  #
  def create(data, options = {})
    @grid.put(data, options)
  end
  
  
  #
  # Update an existing file, replacing the current version. If the file doesn't exist it will be created.
  #
  # @param [BSON::ObjectId] BSON::ObjectId of the file that should be updated
  # @param [String, #read] String or IO-like object
  # @param [Hash] Options Hash. See http://api.mongodb.org/ruby/current/Mongo/Grid.html#put-instance_method for options.
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
  # @param [BSON::ObjectId] BSON::ObjectId of the file to get
  # @return [GridIO] GridIO instance of the requested file, or nil
  #
  def find(id)
    begin
      @grid.get(id)
    rescue
      nil
    end
  end
  
  
  #
  # Find one or more files by their filenames
  #
  # @param [String, Regexp] Filename or regular expression
  # @return [Array] Array of GridIO instances
  #
  def find_by_filename(filename)
    result = @coll.find(:filename => filename).to_a
    
    if result.count > 1
      new_result = []
      result.each {|r| new_result << find(r['_id'])}
      new_result
    else
      result.blank? ? [] : [find(result.first['_id'])]
    end
  end
  
  
  #
  # Read a file by its unique ID
  #
  # @param [BSON::ObjectId] BSON::ObjectId of the file to read
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
  # @param [String, Regexp] Filename or regular expression
  # @return [Array] Array of file content strings
  #
  def read_by_filename(filename)
    result = find_by_filename(filename)
    
    if result.count > 1
      content = []
      result.each { |r| content << r.read }
      content
    else
      result.blank? ? [] : [result.first.read]
    end
  end
  
  
  #
  # Delete a file by its unique ID
  # Note: in safe mode, Grid.delete doesn't return Boolean, so success is confirmed by calling #find
  #
  # @param [BSON::ObjectId] BSON::ObjectId of the file to delete
  # @return [Boolean] False if the file didn't exist or couldn't be deleted. True otherwise.
  #
  def delete(id)
    begin
      @grid.delete(id)
      find(id) ? false : true
    rescue
      false
    end
  end
  
  
  #
  # Delete one or more files by their filenames
  #
  # @param [String, Regexp] Filename or regular expression
  # @return [Boolean] True if all went well. False if one or more files couldn't be deleted.
  #
  def delete_by_filename(filename)
    result = find_by_filename(filename)
    result.each { |r| delete(r['_id']) } ? true : false
  end
  
end