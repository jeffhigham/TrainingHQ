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

    var graph = new RGraph.Line(params['element_id'], params['graph_data']);
    graph.Set('ymax', params['ymax']);
    graph.Set('ymin', params['ymin']);
    graph.Set('hmargin', 5);
    graph.Set('chart.background.grid', true);
    graph.Set('chart.background.grid.vlines', false);
    graph.Set('chart.background.grid.autofit.numhlines',20);
    graph.Set('chart.background.grid.color', '#666');
    graph.Set('chart.background.grid.border',false);
    graph.Set('linewidth', params['linewidth']);          
    graph.Set('gutter.right', gutterRight);
    graph.Set('gutter.left', gutterLeft);
    graph.Set('gutter.top', gutterTop);
    graph.Set('colors', params['colors']);
    graph.Set('ylabels', false);
    graph.Set('filled', params['filled']);
    graph.Set('fillstyle', params['fillstyle']);
    graph.Set('chart.crosshairs', true);
    //graph.Set('chart.crosshairs.snap', true);
    graph.Set('chart.labels', [1,2,3,4,5,6,7,8,9,10]);
    graph.Set('chart.gutter.bottom', 5);
    graph.Draw();

    var yaxis = new RGraph.Drawing.YAxis(params['element_id'], params['axis_x']);
    yaxis.Set('chart.colors', params['axis_color'] );
    yaxis.Set('chart.text.color', params['axis_text_color']);
    yaxis.Set('chart.text.size', 8);
    yaxis.Set('chart.max', params['ymax']);
    yaxis.Set('chart.min', params['ymin']);
    yaxis.Set('chart.numlabels',20);
    yaxis.Set('chart.title', params['axis_title']);
    yaxis.Set('chart.align', params['axis_align']);
    yaxis.Draw();

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