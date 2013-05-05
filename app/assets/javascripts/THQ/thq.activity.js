ThqActivity = function(activity_id){

	this.activity_id = activity_id;
	this.name = "My " + activity_id;
	this.get = new ThqDataFile();
	this.get.loadRemote('/activities/'+ activity_id +'/load_trackpoint.json');

}