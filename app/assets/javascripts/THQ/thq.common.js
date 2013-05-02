// Supporting functions for 
Array.max = function(array){
    return Math.max.apply( Math, array);
}

Array.min = function(array){
    return Math.min.apply( Math, array);
}

function roundNumber(number, digits) {
            var multiple = Math.pow(10, digits);
            var rndedNum = Math.round(number * multiple) / multiple;
            return rndedNum;
}

function timeFormatFromSeconds(seconds){
    var hours = parseInt( seconds / 3600 ) % 24;
    var minutes = parseInt( seconds / 60 ) % 60;
    var seconds = parseInt(seconds % 60, 10);
    return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds  < 10 ? "0" + seconds : seconds);
}

function milesFormatFromFeet(feet){
    return roundNumber(feet/5280,2);
}

function mphFromMps(mps) { // miles/hour from meters/second
    return roundNumber(mps*2.2369,2);
}

function withinRange(x, min, max) {
  return x >= min && x <= max;
}

/* 
    
    Raw data for NP, IF, TSS calculations.
*/
function calcNpRawData(data){

    var time_sum = 0;
    var pr4_sum = 0; 

    for (var i =0; i<data.length; i++){
        
        // First iteration:  power^4 * time
        if( i == 0 ){ 
            pr4_sum += Math.pow(data[i].watts,4)*data[i].time;
        }
        // Subsequent iterations:
        // ( power^4 * time - 0.5 ) + ( ( ( power + previous power ) / 2 )^4 ) * 0.5
        else {
            pr4_sum += Math.pow(data[i].watts,4)*(data[i].time-0.5)+
                                                ( Math.pow( ((data[i].watts+data[i-1].watts)/2),4 ) )*0.5
        }
        time_sum += data[i].time;
    }
    return [roundNumber(pr4_sum,2), time_sum ];
}

// Normalized Power
function calcNP(pr4,time) { // calcNpRawData[0], calcNpRawData[1]
    var np = Math.pow((pr4/time),0.25);
    return roundNumber(np,2);
}

// Normalized Work
function calcNW(np,time){
    var nw = np*time*60;
    return roundNumber(nw,3);
}

// Raw TSS = normalized work * intensity factor
function calcRawTss(nw,IF){
    var raw_tss = nw*IF
    return roundNumber(raw_tss,2);
}

// Intensity Factor = normalized power / functional threshold power
function calcIF(np,ftp){
    return roundNumber(np/ftp,2);
}

/* Training Stress Score = 
    (normalized work * functional threshold power)/(functional threshold power * 3600)*100
*/ 
function calcTSS(nw,ftp){ 
    var raw_tss = nw*IF;
    var tss = raw_tss/(ftp*3600)*100;
    return roundNumber(tss,2);
}

// Straight average power calculation
function calcAvgP(data){
    var power_sum = 0;
    for (var i =0; i<data.length; i++){
        power_sum += data[i].watts;
    }
    return roundNumber(power_sum/data.length,1);
}

// Returns a max value in a range of values for multi-arrays.
function maxMultiValuesScaledBy(list,scale_factor) {
    
    var max_values = [];
    var max_row_values = [];
    var loop_rollover = Math.round( list.length * (scale_factor/1000) );
    var loop_count = 0;

    if(loop_rollover <= 1){ return list; }

    for (var row = 0; row < list.length; row++) {

        loop_count++;

        /*
            In the activity model we set:

            data_time << [ Time.parse(trackpoint.time).to_time.to_i - time_offset, trackpoint.watts, trackpoint.heart_rate, 
                            trackpoint.cadence, trackpoint.altitude_feet, trackpoint.speed.to_f, trackpoint.longitude, trackpoint.latitude  ];

            Here we don't want to mess with the trackpoints and take the one associated with the max elevation value.

            >> not implemented yet.
        */
        for (var col = 0; col < list[row].length; col++){
            if( typeof(max_row_values[col]) == 'undefined' || 
                max_row_values[col] < list[row][col] ){
                max_row_values[col] = list[row][col];
            }
        }

        if (loop_count == loop_rollover){
            max_values.push(max_row_values);
            loop_count = 0;
            max_row_values = [];
        }

    }

    return max_values;  
}