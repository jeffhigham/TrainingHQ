module Guppy
  class DB
    def self.file_type(file_name)
      case File.extname(file_name).downcase
      when '.tcx'
        TCX
      when '.gpx'
        GPX
      else
        raise "Unknown filetype"
      end
    end
    
    def self.open(file_name)
      db = new(file_name)
      db.parse
      return db
    end

    def initialize(file)
      @file_name = file
    end
    
    # In-memory Nokogiri.XML object created from file_name
    def parse 
      case self.class.file_type(@file_name)
      when TCX
        @doc = Guppy::TcxParser.open(@file_name)
      when GPX
        @doc = Guppy::GpxParser.open(@file_name)
      end
    end

    # Loops through Nokogiri.XML object and 
    # populates datastructures in current object
    # calling db.activities again will causes another 
    # run through the XML parser engine (slow).
    #
    # all_activities = @doc.activities

    def activities 
      @doc.activities
    end

    def activity(activity_id)
      @doc.activity(activity_id)
    end
  end
end
