module THQ

  class Datafile

    @@attributes = [ :file_type, :file_name, :datafile, :thq_obj]
    attr_accessor *@@attributes

    def self.open(file_path)
      datafile = self.new(file_path)
      puts "Entering THQ::Datafile..."
      datafile.parse
      puts "Leaving THQ::Datafile..."
      return datafile
    end

    def initialize(file_path)
      @file_name = file_path
      @file_type = find_type(@file_name)
    end

    def find_type(file_name)
      case File.extname(file_name).downcase
        when '.tcx'
          TCX
        when '.gpx'
          GPX
        when '.fit'
          FIT
        else
          raise "Unknown filetype"
      end
    end
    
    def parse 
      case @file_type
      when TCX
        @thq_obj = THQ::TcxParser.open(@file_name)
      when GPX
        @thq_obj = THQ::GpxParser.open(@file_name)
      when FIT
        @thq_obj = THQ::FitParser.open(@file_name)
      end
    end

    def compress
      THQ::Compressor.open(@thq_obj, 3000)
    end

    def activities 
      @thq_obj.activities
    end

    def activity(activity_id)
      @parsed_doc.activity(activity_id)
    end
  end

end
