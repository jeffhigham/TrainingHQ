ThqDataFile = function(){

	this.data_source = null;
	this.request = null;
	this.laps = 0;
	this.laps_time = [];
	this.laps_distance = [];
	this.all_time = [];
	this.all_distance = [];
	this.wattage_data = []; //[{watts: nn, time:nn}, {watts:nn, time:nn}, {}];
	this.wattage_laps = [];
	this.map_data = []; //[{watts: nn, time:nn}, {watts:nn, time:nn}, {}];


	this.loadRemote = function(data_source) {
		this.data_source = data_source;
		this.request = $.ajax({
  		dataType: "text",
  		url: this.data_source,
  		async: false
		});
		this.parse();
	}

	this.trackpoints = function(){
		return $.parseJSON(this.request.responseText.replace(';',''));
	}

	this.parse = function(){ // this is a horrible mess.

		/*
			trackpoints[lap_id] = [{},{}, ...];
			{	"time_seconds_epoch":1366833927,"distance_feet":25021,"watts":92,"heart_rate":110,"cadence":74,
			"altitude_feet":6057,"speed_mph":6.8,"lng":-111.8356535,"lat":40.4808697,"percent_grade":2,"temp_c":0}
		*/
		
		var trackpoints = this.trackpoints();
		var activity_time_offset = trackpoints[0][0]['time_seconds_epoch'];
		var laps_time_offset = 0;
		var laps_distance_offset = 0;
		var this_trackpoint = null;
		var trackpoint_distance = 0;

		for(var lap_id=0; lap_id<trackpoints.length; lap_id++){

			// initialize lap array.
			this.laps_time[lap_id] = [];
			this.laps_distance[lap_id] = [];
			this.wattage_laps[lap_id] = [];
			
			// lap-based time and distance offsets.
			laps_time_offset = trackpoints[lap_id][0]['time_seconds_epoch'];
			laps_distance_offset = trackpoints[lap_id][0]['distance_feet'];

			// loop for trackpoints in current lap.
			for(var trackpoint_id=0; trackpoint_id<trackpoints[lap_id].length; trackpoint_id++){
				//console.info("Entering lap["+ lap_id +"] trackpoint["+ trackpoint_id +"]" );

				// make it easy on ourselves.
				this_trackpoint = trackpoints[lap_id][trackpoint_id];
				
				// find out if this is the first trackpoint in the activity.
				if(lap_id == 0 && trackpoint_id ==0 ){ 
					last_trackpoint = this_trackpoint; 					
					trackpoint_distance = 0;
				}
				else {
					// find out if we started a new lap.
					if( trackpoint_id == 0 ){
						// last trackpoint in the previous lap.
						last_trackpoint = trackpoints[lap_id-1][ trackpoints[lap_id-1].length-1 ];
					}
					else {
						// last trackpoint in current lap.
						last_trackpoint = trackpoints[lap_id][trackpoint_id-1];
					}
					// find out if we moved
					trackpoint_distance = this_trackpoint['distance_feet'] - last_trackpoint['distance_feet'];
					//console.info( this_trackpoint['distance_feet'] + " - " + last_trackpoint['distance_feet'] + "=" + trackpoint_distance);
				}
				
				// populate time-based data.
				this.laps_time[lap_id].push([
					// time since activity started.
					//this_trackpoint['time_seconds_epoch'] - activity_time_offset,
					// time since lap started.
					this_trackpoint['time_seconds_epoch'] - laps_time_offset,
					this_trackpoint['watts'],
					this_trackpoint['heart_rate'],
					this_trackpoint['cadence'],
					this_trackpoint['altitude_feet'],
					this_trackpoint['speed_mph'],
					this_trackpoint['lng'],
					this_trackpoint['lat'],
					this_trackpoint['percent_grade']
				]);

				// whole activity
				this.all_time.push([
					// time since activity started.
					this_trackpoint['time_seconds_epoch'] - activity_time_offset,
					// time since lap started.
					//this_trackpoint['time_seconds_epoch'] - laps_time_offset,
					this_trackpoint['watts'],
					this_trackpoint['heart_rate'],
					this_trackpoint['cadence'],
					this_trackpoint['altitude_feet'],
					this_trackpoint['speed_mph'],
					this_trackpoint['lng'],
					this_trackpoint['lat'],
					this_trackpoint['percent_grade']
				]);

				this.wattage_data.push(
					{
						watts: this_trackpoint['watts'], 
						time: this_trackpoint['time_seconds_epoch'] - last_trackpoint['time_seconds_epoch']
					}
				);

				this.wattage_laps[lap_id].push(
					{
						watts: this_trackpoint['watts'], 
						time: this_trackpoint['time_seconds_epoch'] - last_trackpoint['time_seconds_epoch']
					}
				);

        if (this_trackpoint['lng'] > 0 || this_trackpoint['lat'] > 0) {
            this.map_data.push( { lng: this_trackpoint['lng'], lat: this_trackpoint['lat'] } );
        }
 

				// populate distance-bsed data.
				if(trackpoint_distance > 0){
						
					this.laps_distance[lap_id].push([
						// distance since activity started.
						//this_trackpoint['distance_feet'],
						// distance since lap started.
						this_trackpoint['distance_feet'] - laps_distance_offset,
						this_trackpoint['watts'],
						this_trackpoint['heart_rate'],
						this_trackpoint['cadence'],
						this_trackpoint['altitude_feet'],
						this_trackpoint['speed_mph'],
						this_trackpoint['lng'],
						this_trackpoint['lat'],
						this_trackpoint['percent_grade']
					]);

					this.all_distance.push([
						// distance since activity started.
						this_trackpoint['distance_feet'],
						// distance since lap started.
						//this_trackpoint['distance_feet'] - laps_distance_offset,
						this_trackpoint['watts'],
						this_trackpoint['heart_rate'],
						this_trackpoint['cadence'],
						this_trackpoint['altitude_feet'],
						this_trackpoint['speed_mph'],
						this_trackpoint['lng'],
						this_trackpoint['lat'],
						this_trackpoint['percent_grade']
					]);

				}

			} // trackpoint_id

		} // lap_id

		this.laps = this.laps_time.length;

	} // this.parse

}

//ThqDataFile.prototype = new ThqWattage();