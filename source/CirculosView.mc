using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Math as Math;

class CirculosView extends Ui.WatchFace {

	hidden var width 	= 0;
	hidden var height 	= 0;
	hidden var xCenter	= 0;
	hidden var yCenter 	= 0;
	hidden const PI 	= Math.PI;
	
	hidden var hourRads = [
		//make a zero-element pad to align the indicies
		//with a one-based clock numbering scheme
		[0, 0],
		//the clock begins... 
		[1, 5*PI/3],	[2, 11*PI/6], 	[3, 0],
		[4, PI/6], 		[5, PI/3], 		[6, PI/2], 
		[7, 2*PI/3], 	[8, 5*PI/6], 	[9, PI],
		[10, 7*PI/6],	[11, 4*PI/3], 	[12, 3*PI/2]
	];
		
    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Get and show the current time
        var clockTime = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel");
        
        width 	= dc.getWidth();
        height 	= dc.getHeight();
        xCenter = width/2;
        yCenter = height/2;
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);        
        
        //bezel circle; I could take it or leave it
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
		dc.drawCircle(xCenter, yCenter, width/2 - 2);
		
		//draw the layout hour circles
		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
		for (var i = 1; i < hourRads.size(); i++) {
			var coords = calcCircleCoord(hourRads[i][1]);
			dc.drawCircle(coords[0], coords[1], 10);
		}
		
		//get the current hour value
		var hour = clockTime.hour;
		if (hour == 0) {
			hour = 12;
		} //some change
		
		if (hour > 12) {
			hour = hour - 12;
		}
		
		//calculate the hour/rads coordinates
		var coords = calcCircleCoord(hourRads[hour][1]);
		
		//draw it
		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
		dc.fillCircle(coords[0], coords[1], 15);
    }
    
    function calcCircleCoord(rads) {
    	//x = cx + r * cos(a)
		//y = cy + r * sin(a)
    	var coords = new[2];
    	coords[0] = xCenter + 80 * Math.cos(rads);
    	coords[1] = yCenter + 80 * Math.sin(rads);
    	return coords;    	
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
