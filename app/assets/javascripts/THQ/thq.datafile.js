ThqDataFile = function(){

	//var data_url = null; // url of JSON data
	var ajax_request_obj = null; // ajax ajax_request_obj object.
	var lap_count = 0; // number of lap_count in the activity.
	var context = "time" // 'time' or 'distance'
	var lap_context = "all" // 'all' or lap_index
	var scale_factor = 25; //constant to base data scailing % on.
	var scale_algorithm = "performance"; // Calculates appropriate scale_factor ("performance" or "detail"); 
	var lap_data_time = []; // lap array based on activity time (all data)
	var lap_data_distance = []; // lap array based on distance (all data)
	var all_data_time = []; // array of the whole activity based on time (all data)
	var all_data_distance = []; // array of whole activity based on distance (all data)
	var wattage_data = []; //[{watts: nn, time:nn}, {watts:nn, time:nn}, {}];
	var wattage_laps = []; //[{watts: nn, time:nn}, {watts:nn, time:nn}, {}];
	var map_lap_data = []; //[{lng: nn, lat:nn}];
	var wattage_obj = null; // ThqWattage object created in loadRemote()
	var current_dataset = []; // array of current dataset. This is updated often.
	var scaled_data_cache = {}; // cache previously scaled datasets.

	this.loadRemote = function(data_url) {
			ajax_request_obj = $.ajax({
  		dataType: "text",
  		url: data_url,
  		async: false
		});

		this.parse_datafile();
		wattage_obj = new ThqWattage(wattage_data);
	}

	this.status = function(){
		return {
			context: context,
			lap_context: lap_context,
			scale_factor: scale_factor,
			scale_algorithm: scale_algorithm
		};
	}

	// return currently active dataset for graph, map, etc.
	this.dataset = function(selection){

		// check for a request to change context.
		if(typeof(selection) != "undefined"){
			
			// change context to "time".
			if(selection == "time"){
				context = "time";
				// check if a lap is selected.
				current_dataset = (lap_context == "all") ? all_data_time : lap_data_time[lap_context];
			}

			// change context to "distance"
			else if(selection == "distance") {
				context = "distance";
				// check if a lap is selected
				current_dataset = (lap_context == "all") ? all_data_distance : lap_data_distance[lap_context];
			}

			// an incorrect context selection. Warn and do nothing.
			else{
				console.warn("No changes to context. "+ selection +" is not valid.");
			}

		}

		else { // selection == undefined

			if( lap_context == "all"){
				current_dataset = (context == "time") ? all_data_time : all_data_distance;
			}
			else {
				current_dataset = (context == "time") ? lap_data_time[lap_context] : lap_data_distance[lap_context];
			}			
		}


		return this.scale_best_fit(scale_algorithm);
	}

	this.lap = function(lap_id){

		if( lap_id == lap_context){
			console.info("No need to process lap_id:"+ lap_id +" == lap_context:"+ lap_context);
		}
		else {
			// check for a lap reset.
			if( lap_id == "all"){
				lap_context = "all";
			}
			// check for a valid lap
			else if( typeof(lap_data_time[lap_id]) != "undefined" ){
				lap_context = lap_id;
			}
			// no changes, bad lap_id passed.
			else {
				console.warn("No changes made!! Bad lap_id:"+ lap_id +" lap_context: "+ lap_context);
			}

		}

		return this.dataset();

	}

	// return wattage object for the whole activity.
	this.wattage = function(){
		return wattage_obj;
	}

	// create and return a wattage object base on a lap.
	this.wattage_at_lap = function(lap_id){
		return new ThqWattage(wattage_laps[lap_id]);
	}

	// polygon lines for map
	this.map_data = function (lap_id){

		// called without a lap id.
		if(typeof(lap_id) == "undefined"){
			console.info("Loading combined map data." );
			// combine all laps into one.
			var map_data = [];
			for(var i=0; i<map_lap_data.length; i++){
				map_data.push(map_lap_data[i]);
			}
			return map_data;
		}
		// return based on lap id.
		else {
			console.info("Loading map data for lap: "+ lap_id );
			return [ map_lap_data[lap_id] ];
		}
	}

	// return the raw trackpoints imported from the webserver ajax_request_obj.
	// for the current activity.
	this.trackpoints = function(){
		return $.parseJSON(ajax_request_obj.responseText.replace(';',''));
	}

	this.scale_best_fit = function(selection){ // "performance", "detail"
	
		//selection = (typeof(selection) == "undefined") ? "performance" : "detail";
		var percentage = 0;
		var standard_tp = 150;
		var detailed_tp = 600;
		var full_tp = 3000; // this might blow stuff up.
		if( selection == "performance" || selection == "detail" || "full"){
			scale_algorithm = selection;
		}
		else {
			colsole.error("Error! " + selection +" is an invalid selection.");
			return false;
		}
		
		if(selection=="performance"){
			percentage = (current_dataset.length > standard_tp) ? Math.round(standard_tp/current_dataset.length * 100) : 100;
		}
		else if (selection == "detail") {
			percentage = (current_dataset.length > detailed_tp) ? Math.round(detailed_tp/current_dataset.length * 100) : 100;
		}
		else {
			percentage = (current_dataset.length > full_tp) ? Math.round(full_tp/current_dataset.length * 100) : 100;
		}

		if (percentage == 0) { percentage = 1; }
		console.info("Best fit setting for "+ selection +" is "+ percentage +"%");
		return this.scaled(percentage);
	}

	this.scaled = function (percentage){
		console.info("Calling datafile.scaled.");
		if(typeof(percentage) != "undefined"){
			scale_factor = percentage;
		}

		var cache_key = context + "_" + lap_context + "_" + scale_factor;
		if( typeof(scaled_data_cache[cache_key]) == "object"){
			console.log("Found cached value for: "+ cache_key);
			return scaled_data_cache[cache_key];
		}

		var source_dataset = current_dataset; // set by dataset() and lap();
		var scaled_dataset = [];
		var max_values = [0,0,0,0,0,0,0,0,0];
		console.info("Scaling at "+ scale_factor +"%, context: "+ context +"  lap_context: "+ lap_context );

		var scale_now = round(source_dataset.length / (source_dataset.length*(scale_factor/100) ), 2);
		var loop_count = 0;	

		console.info("Scaling "+ source_dataset.length +" values, capturing every "+ scale_now +"th dataset." );

		for(var i=0; i<source_dataset.length; i++){

			// Promote the max values for watts, hr, cadence, and speed when we scale down.
			max_values[0] = source_dataset[i][0]; // time / distance
			max_values[1] = (source_dataset[i][1] > max_values[1])? source_dataset[i][1] : max_values[1]; // watts
			max_values[2] = (source_dataset[i][2] > max_values[2])? source_dataset[i][2] : max_values[2]; // hr
			max_values[3] = (source_dataset[i][3] > max_values[3])? source_dataset[i][3] : max_values[3]; // cadence
			max_values[4] = source_dataset[i][4]; // altitude
			max_values[5] = (source_dataset[i][5] > max_values[5])? source_dataset[i][5] : max_values[5]; // speed
			max_values[6] = source_dataset[i][6]; // lng
			max_values[7] = source_dataset[i][7]; // lat
			max_values[8] = source_dataset[i][8]; // percent grade

			/* 
				It is possible for scale_now to be < 1 for higher scale_factors.
			  so let's capture that here.
			*/
			loop_count += (scale_now < 1) ? scale_now : 1;

			if( scale_now < 1){
				if( loop_count >= 1){
					//scaled_dataset.push(source_dataset[i]);
					scaled_dataset.push(max_values);
					loop_count=0;
					max_values = [0,0,0,0,0,0,0,0,0];
				}
			}
			else if( loop_count == Math.round(scale_now)){ // time to record a value.
				//scaled_dataset.push(source_dataset[i]);
				scaled_dataset.push(max_values);
				loop_count=0;
				max_values = [0,0,0,0,0,0,0,0,0];
			}	
		}

		console.info("Dataset reduced to: "+ scaled_dataset.length +" values.");

		scaled_data_cache[cache_key] = scaled_dataset;
		return scaled_dataset;
	}

	this.parse_datafile = function(){ // this is a horrible mess.

		/*
			trackpoints[lap_id] = [{},{}, ...];
			{	"time_seconds_epoch":1366833927,"distance_feet":25021,"watts":92,"heart_rate":110,"cadence":74,
			"altitude_feet":6057,"speed_mph":6.8,"lng":-111.8356535,"lat":40.4808697,"percent_grade":2,"temp_c":0}
		*/
		
		var trackpoints = this.trackpoints();
		var activity_time_offset = trackpoints[0][0]['time_seconds_epoch'];
		var lap_data_time_offset = 0;
		var lap_data_distance_offset = 0;
		var this_trackpoint = null;
		var trackpoint_distance = 0;

		for(var lap_id=0; lap_id<trackpoints.length; lap_id++){

			// initialize lap array.
			lap_data_time[lap_id] = [];
			lap_data_distance[lap_id] = [];
			wattage_laps[lap_id] = [];
			map_lap_data[lap_id] = [];
			
			// lap-based time and distance offsets.
			lap_data_time_offset = trackpoints[lap_id][0]['time_seconds_epoch'];
			lap_data_distance_offset = trackpoints[lap_id][0]['distance_feet'];

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
				lap_data_time[lap_id].push([
					// time since activity started.
					//this_trackpoint['time_seconds_epoch'] - activity_time_offset,
					// time since lap started.
					this_trackpoint['time_seconds_epoch'] - lap_data_time_offset,
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
				all_data_time.push([
					// time since activity started.
					this_trackpoint['time_seconds_epoch'] - activity_time_offset,
					// time since lap started.
					//this_trackpoint['time_seconds_epoch'] - lap_data_time_offset,
					this_trackpoint['watts'],
					this_trackpoint['heart_rate'],
					this_trackpoint['cadence'],
					this_trackpoint['altitude_feet'],
					this_trackpoint['speed_mph'],
					this_trackpoint['lng'],
					this_trackpoint['lat'],
					this_trackpoint['percent_grade']
				]);

				wattage_data.push(
					{
						watts: this_trackpoint['watts'], 
						time: this_trackpoint['time_seconds_epoch'] - last_trackpoint['time_seconds_epoch']
					}
				);

				wattage_laps[lap_id].push(
					{
						watts: this_trackpoint['watts'], 
						time: this_trackpoint['time_seconds_epoch'] - last_trackpoint['time_seconds_epoch']
					}
				);

        if (this_trackpoint['lng'] > 0 || this_trackpoint['lat'] > 0) {
            map_lap_data[lap_id].push( { lng: this_trackpoint['lng'], lat: this_trackpoint['lat'] } );
        }
 

				// populate distance-bsed data.
				if(trackpoint_distance > 0){
						
					lap_data_distance[lap_id].push([
						// distance since activity started.
						//this_trackpoint['distance_feet'],
						// distance since lap started.
						this_trackpoint['distance_feet'] - lap_data_distance_offset,
						this_trackpoint['watts'],
						this_trackpoint['heart_rate'],
						this_trackpoint['cadence'],
						this_trackpoint['altitude_feet'],
						this_trackpoint['speed_mph'],
						this_trackpoint['lng'],
						this_trackpoint['lat'],
						this_trackpoint['percent_grade']
					]);

					all_data_distance.push([
						// distance since activity started.
						this_trackpoint['distance_feet'],
						// distance since lap started.
						//this_trackpoint['distance_feet'] - lap_data_distance_offset,
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

		lap_count = lap_data_time.length;
		lap_context = "all";
		context = "time";
		current_dataset = all_data_time;
		//current_dataset = this.scaled(scale_factor);

	} // this.parse

}

//ThqDataFile.prototype = new ThqWattage();