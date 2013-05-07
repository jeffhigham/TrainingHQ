ThqActivity = function(activity_id){

	this.activity_id = activity_id;
	this.name = "My " + activity_id;
	this.datafile = new ThqDataFile();
	this.datafile.loadRemote('/activities/'+ activity_id +'/load_trackpoint.json');

}