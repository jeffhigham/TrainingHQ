function ThqWattage(power_time_data){

	/*
		power_time_data = [{watts: nn, time:nn}, {watts:nn, time:nn}, {}];
		watts = watts
		time = seconds
	*/

	this.FTP = 300;
	this.NP = 0;
	this.NW = 0;
	this.AP = 0;
	this.TSS = 0;
	this.data = power_time_data;
	this.total_time_seconds = 0; // sum of time for each sample.
	this.total_joules_based_on_lactate = 0; // sum of segment^4 * 10

	function round(number, digits) {
	  var multiple = Math.pow(10, digits);
	  var rndedNum = Math.round(number * multiple) / multiple;
	  return rndedNum;
	}
	
	this.init = function(){
		this.calcJoulesBolAndTotalTime();
		this.calcNP();
		this.calcNW();
		this.calcAP();
		this.calcIF();
		this.calcTSS();
		return true;
	}
	
	// Intensity Factor = Normalized Power / Functional Threshold Power
	this.calcIF = function(){
    this.IF = round(this.NP/this.FTP,2);
	}

	// Normalized power is (sum of lactate based on power / sum of total time time)^.25
	this.calcNP = function(){
	 this.NP =  round( Math.pow((this.total_joules_based_on_lactate/this.total_time_seconds),0.25),1);
	}

	// Average power.
	this.calcAP = function(){
		var w = 0;
		var t = 0;
		for (var i =0; i<this.data.length; i++){        
        w +=  this.data[i].watts*this.data[i].time;
        t += this.data[i].time;
    }
    this.AP = round(w/t,1);
	}

	// Normaized Work = normalized power*time.
	this.calcNW = function (){
		this.NW = round(this.NP*this.total_time_seconds,2);
	}

	/*
		See: http://www.slowtwitch.com/Training/General_Physiology/Measuring_Power_and_Using_the_Data_302.html
		Lactate = Power^4

		total_joules_based_on_lactate =  Sum of (each segment's watts^4 ) x (each segment's time).
		total_time_seconds =  Sum of each segment's time
	*/
	this.calcJoulesBolAndTotalTime = function(){ 
		var lactate = 0;
    for (var i =0; i<this.data.length; i++){
    		lactate = Math.pow(this.data[i].watts,4);
        this.total_joules_based_on_lactate +=  this.data[i].time * lactate;
        this.total_time_seconds += this.data[i].time;
    }

	}

	this.raw_tss = function (){
		return this.NW * this.IF;
	}

	this.calcTSS = function(){
		this.TSS = round(this.raw_tss()/( this.FTP * 3600 )*100,2);
	}

	this.init();

}

/* 
	A little test to run which should produce:
	AP: 246
	FTP: 300
	IF: 0.8936721602709973
	NP: 268.1016480812992
	NW: 1126026.9219414566
	TSS: 93.17582517173362
*/

function wattage_test(){

	var data = [
		{ time: 5*60, watts:	150},
		{ time: 5.*60, watts: 200},
		{ time: 5.*60, watts: 250},
		{ time: 20*60, watts: 300},
		{ time: 5.*60, watts: 150},
		{ time: 20*60, watts: 300},
		{ time: 10*60, watts: 150}
	];

	var c = new wattage(data);
	return c;
}