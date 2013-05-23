module THQ

	class FitParser 
		require 'securerandom'

		def self.open(file)
      puts "Entering THQ::FitParser..."
      fit_parser = self.new(file)
      time = Benchmark.realtime do
        fit_parser.parse
      end
      puts "Leaving THQ::FitParser Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
      fit_parser
    end

    def initialize(file)
      @file = file
    end

		def parse
			fit2tcx_path = "/usr/local/Fit2TCX/fit2tcx"
			tmp_file = "/tmp/ramdisk/parser/#{SecureRandom.hex(16)}.tcx"
      puts "\tConverting .fit to .tcx..."
      time = Benchmark.realtime do
			 system "#{fit2tcx_path} #{@file} #{tmp_file}"
      end
      puts "\tConverted .fit to .tcx Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
			@doc = THQ::TcxParser.open(tmp_file)
			system "rm #{tmp_file}"
			@doc
    end

    def activities
    	@doc.activities
    end

	end

end