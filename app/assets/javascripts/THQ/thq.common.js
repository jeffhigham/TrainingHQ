// Common Config
var gutterLeft = 120;
var gutterRight = 120;
var gutterTop   = 25;
var power_color = "#FF9900";
var hr_color = "#ff5600";
var alt_color = "#7fff00";
var cadence_color = "#0f8bff";


// Supporting functions for 
Array.max = function(array){
    return Math.max.apply( Math, array);
}

Array.min = function(array){
    return Math.min.apply( Math, array);
}


function resetGraph(element_id){
    RGraph.Reset(document.getElementById(element_id));
}

function drawLinePlot(params){

    var obj = new RGraph.Line(params['element_id'], params['graph_data']);
    obj.Set('ymax', params['ymax']);
    obj.Set('ymin', params['ymin']);
    obj.Set('hmargin', 5);
    obj.Set('background.grid', false);
    obj.Set('linewidth', params['linewidth']);          
    obj.Set('gutter.right', gutterRight);
    obj.Set('gutter.left', gutterLeft);
    obj.Set('gutter.top', gutterTop);
    obj.Set('colors', params['colors']);
    obj.Set('noaxes', true);
    obj.Set('ylabels', false);
    obj.Set('filled', params['filled']);
    obj.Set('fillstyle', params['fillstyle']);
    obj.Draw();

    RGraph.DrawAxes(obj, {
                                'axis.x': params['axis_x'],
                                'axis.title': params['axis_title'],
                                'axis.color': params['axis_color'],
                                'axis.text.color': params['axis_text_color'],
                                'axis.max': params['ymax'],
                                'axis.min': params['ymin'],
                                'axis.align': params['axis_align']
                               });
}

// Returns a max value in a range of values.
function maxValuesScaledBy(list,scale_factor) {
    var loop_count = 0;
    var max_loop_value = 0;
    var list_count = list.length;
    var loop_rollover = Math.round( list_count * (scale_factor/1000) );
    var return_list = new Array();

    if(loop_rollover <= 1){ return list; }

    for (var i = 0; i < list.length; i++) {
        loop_count++;
        if(max_loop_value < list[i]){
            max_loop_value = list[i];
        }
        if(loop_count == loop_rollover){
            return_list.push(max_loop_value);
            loop_count = 0;
            max_loop_value = 0;
        }  
    }
    return return_list;  
}

// Returns an average value for a range of values.
function aveValuesScaledBy(list,scale_factor) {
    var loop_count = 0;
    var loop_value_sum = 0;
    var list_count = list.length;
    var loop_rollover = Math.round( list_count * (scale_factor/1000) );
    var return_list = new Array();

    if(loop_rollover <= 1){ return list; }

    for (var i = 0; i < list.length; i++) {
        loop_count++;
        loop_value_sum += list[i];
        if(loop_count == loop_rollover){
            return_list.push(loop_value_sum/loop_count);
            loop_count = 0;
            loop_value_sum = 0;
        }  
    }
    return return_list;  
}