module Guppy

	class FitParser 
		require 'securerandom'

		def self.open(file)
      fit_parser = self.new(file)
      fit_parser.parse
      fit_parser
    end

    def initialize(file)
      @file = file
    end

		def parse
			fit2tcx_path = "/usr/local/Fit2TCX/fit2tcx"
			tmp_file = "/tmp/#{SecureRandom.hex(16)}.tcx"
			system "#{fit2tcx_path} #{@file} #{tmp_file}"
			@doc = Guppy::TcxParser.open(tmp_file)
			system "rm #{tmp_file}"

			@doc
    end

    def activities
    	@doc.activities
    end

	end

end