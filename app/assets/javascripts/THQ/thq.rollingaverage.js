ThqRollingAverage = function(rollover_value){
	
	var container = [];
	var current_avg = 0;

	if( typeof(rollover_value) != "number" ){
		console.error("Incorrect rollover_value value: "+ rollover_value);
		return false;
	}

	this.ready = function(){
		// need to +1 to container.length due to shift after calculation.
		return (container.length +1 == rollover_value) ? true : false;	
	}

	this.show = function(){
		return current_avg;
	}

	this.status = function(){
		return {
			'Container Size': container.length,
			'Rollover Value': rollover_value,
			'Ready?': this.ready(),
			'Current Avg': current_avg
		};
	}

	this.push = function(number){
		
		if( typeof(number) == "number"){
			container.push(number);

		 if(container.length == rollover_value){
				current_avg = Array.average(container);
				container.shift();
			}

		}
		return current_avg;
	}

	Array.average = function(array){
		return Math.round_highres(Array.sum(array)/array.length, 2);
	}

	Array.sum = function(array){
		var sum = 0;
		for(var i=0; i<array.length; i++){
			sum += array[i];
		}
		return sum;
	}

	Math.round_highres = function(number, digits) {
            var multiple = Math.pow(10, digits);
            var rndedNum = Math.round(number * multiple) / multiple;
            return rndedNum;
	}

}