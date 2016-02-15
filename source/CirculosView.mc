using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Math as Math;
using Toybox.Activity as Act;

class CirculosView extends Ui.WatchFace {

	hidden var width 	= 0;
	hidden var height 	= 0;
	hidden var xCenter	= 0;
	hidden var yCenter 	= 0;
	hidden const PI 	= Math.PI;
	hidden var rFont	= null;
	
	hidden var hourRads = [
		//! make a zero-element pad to align the indicies
		//! with a one-based clock numbering scheme
		[0, 0],
		//! the clock begins... 
		[1, 5*PI/3],	[2, 11*PI/6], 	[3, 0],
		[4, PI/6], 		[5, PI/3], 		[6, PI/2], 
		[7, 2*PI/3], 	[8, 5*PI/6], 	[9, PI],
		[10, 7*PI/6],	[11, 4*PI/3], 	[12, 3*PI/2]
	];
	
	hidden var numToWord = [
		[0, "o'clock"], 
		[1, "one"], [2, "two"], [3, "three"], [4, "oh four"], [5, "oh five"], [6, "oh six"],
		[7, "oh seven"], [8, "oh eight"], [9, "oh nine"], [10, "ten"], [11, "eleven"], [12, "twelve"],
		[13, "thirteen"], [14, "fourteen"], [15, "fifteen"], [16, "sixteen"], [17, "seventeen"], [18, "eighteen"],
		[19, "nineteen"], [20, "twenty"], [21, "twenty\none"], [22, "twenty\ntwo"], [23, "twenty\nthree"], [24, "twenty\nfour"],
		[25, "twenty\nfive"], [26, "twenty\nsix"], [27, "twenty\nseven"], [28, "twenty\neight"], [29, "twenty\nnine"], [30, "thirty"],
		[31, "thirty\none"], [32, "thirty\ntwo"], [33, "thirty\nthree"], [34, "thirty\nfour"], [35, "thirty\nfive"], [36, "thirty\nsix"],
		[37, "thirty\nseven"], [38, "thirty\neight"], [39, "thirty\nnine"], [40, "forty"], [41, "forty\none"], [42, "forty\ntwo"],
		[43, "forty\nthree"], [44, "forty\nfour"], [45, "forty\nfive"], [46, "forty\nsix"], [47, "forty\nseven"], [48, "forty\neight"],
		[49, "forty\nnine"], [50, "fifty"], [51, "fifty\none"], [52, "fifty\ntwo"], [53, "fifty\nthree"], [54, "fifty\nfour"],
		[55, "fifty\nfive"], [56, "fifty\nsix"], [57, "fifty\nseven"], [58, "fifty\neight"], [59, "fifty\nnine"] 
	];
	
    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        rFont = Ui.loadResource(Rez.Fonts.squared_circle);
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    
    	var info = Act.getActivityInfo();
    	
        //! Get the current time
        var time 	= Sys.getClockTime();
        var vMin	= View.findDrawableById("lTime");
        var sMin	= numToWord[time.min][1];
        vMin.setFont(rFont);
        vMin.setText(sMin);
        vMin.setColor(App.getApp().getProperty("TimeColor"));
        
        //! get some basic screen dimensions and coords
        width 	= dc.getWidth();
        height 	= dc.getHeight();
        xCenter = width/2;
        yCenter = height/2;
        
        //! Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);        
        
        //! bezel circle; I could take it or leave it
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
		dc.drawCircle(xCenter, yCenter, width/2 - 2);
		
		//! draw the layout hour circles
		dc.setColor(App.getApp().getProperty("DialColor"), Gfx.COLOR_BLACK);
		for (var i = 1; i < hourRads.size(); i++) {
			var coords = calcCircleCoord(hourRads[i][1]);
			dc.drawCircle(coords[0], coords[1], 10);
		}
		
		drawHourCircle(dc, time.hour);		
    }
    
    function drawHourCircle(dc, hour) {
    	//! get the current hour value
		if (hour == 0) {
			hour = 12;
		}
		
		if (hour > 12) {
			hour = hour - 12;
		}
		
		//! calculate the hour/rads coordinates
		var coords = calcCircleCoord(hourRads[hour][1]);
		
		//! get battery info
		/*var sysStats 		= Sys.getSystemStats();
		var sBatteryLife 	= sysStats.battery.format("%.0f")+"%";
		var vBatt = View.findDrawableById("lBatt");
		vBatt.setText(sBatteryLife);
		vBatt.setLocation(coords[0], coords[1]);*/
		
		//! draw it
		dc.setColor(App.getApp().getProperty("TimeColor"), Gfx.COLOR_BLACK);
		dc.fillCircle(coords[0], coords[1], 17);		
    }
    
    function calcCircleCoord(rads) {
    	//! x = cx + r * cos(a)
		//! y = cy + r * sin(a)
    	var coords = new[2];
    	coords[0] = xCenter + 80 * Math.cos(rads);
    	coords[1] = yCenter + 80 * Math.sin(rads);
    	return coords;    	
    }
    
    function onSettingsChanged() {
        //settingsChange = true;
        Ui.requestUpdate();
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
