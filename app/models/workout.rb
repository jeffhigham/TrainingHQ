class Workout < ActiveRecord::Base
  attr_accessible :name, :datafile
  has_attached_file :datafile

  def get_basic_ride_data
  	xmldoc = Nokogiri::XML::Reader(open(self.datafile.path))
  	xmldoc.namespaces
  	all_tp_data = {}
  	this_tp = {}
  	xmldoc.each do |node|
  		if node.name == "Trackpoint"
  				node.read()
  				while node.name != "Trackpoint"
  					if node.node_type == 1
  						name = node.name unless node.name == "Value"
  					end
  					if node.name == '#text'
  						#printf("%s = %s\n", name, node.value)
  						this_tp[name.to_s] = node.value
  					end
  					node.read()
  				end
  				all_tp_data[this_tp["Time"]] = this_tp
  				this_tp = {}
  				return all_tp_data
  		end
  	end
  	return all_tp_data
  end

end