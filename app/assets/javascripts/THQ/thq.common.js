// Common Config
//var gutterLeft = 150;
//var gutterRight = 80;
//var gutterTop   = 25;
var power_color = "#FF9900";
var hr_color = "#ff5600";
var alt_color = "#7fff00";
var cadence_color = "#0f8bff";
var speed_color = "#bc65f7";



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

// Returns a max value in a range of values for multi-arrays.
function maxMultiValuesScaledBy(list,scale_factor) {
    
    var max_values = [];
    var max_row_values = [];
    var loop_rollover = Math.round( list.length * (scale_factor/1000) );
    var loop_count = 0;

    if(loop_rollover <= 1){ return list; }

    for (var row = 0; row < list.length; row++) {

        loop_count++;

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