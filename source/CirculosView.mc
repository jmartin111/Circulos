using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Math as Math;
using Toybox.Activity as Act;
using Toybox.Time.Gregorian as Date;

class CirculosView extends Ui.WatchFace {

	hidden var width 		= 0;
	hidden var height 		= 0;
	hidden var xCenter		= 0;
	hidden var yCenter 		= 0;
	hidden const PI 		= Math.PI;
	hidden var rFont		= null;
	hidden var rFontDate 	= null;
	hidden var layout		= null;
	
	hidden var hourRads = [
		//! make a zero-element pad to align the indicies
		//! for a one-based clock numbering scheme
		[0, 0],
		//! the clock begins... 
		[1, 5*PI/3],	[2, 11*PI/6], 	[3, 0],
		[4, PI/6], 		[5, PI/3], 		[6, PI/2], 
		[7, 2*PI/3], 	[8, 5*PI/6], 	[9, PI],
		[10, 7*PI/6],	[11, 4*PI/3], 	[12, 3*PI/2]
	];
	
	hidden var numToWord = [
		[0, "o'clock"], 
		[1, "oh one"], [2, "oh two"], [3, "oh three"], [4, "oh four"], [5, "oh five"], [6, "oh six"],
		[7, "oh seven"], [8, "oh eight"], [9, "oh nine"], [10, "ten"], [11, "eleven"], [12, "twelve"],
		[13, "thirteen"], [14, "fourteen"], [15, "fifteen"], [16, "sixteen"], [17, "seven\nteen"], [18, "eighteen"],
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
        rFontDate = Ui.loadResource(Rez.Fonts.squared_circle_date);
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    
    	//! get some basic screen dimensions and coords
        width 	= dc.getWidth();
        height 	= dc.getHeight();
        xCenter = width/2;
        yCenter = height/2;
           
    	//! get battery info
		var sysStats 		= Sys.getSystemStats();
		var sBatteryLife 	= sysStats.battery.format("%.0f")+"%";
		var vBatt = View.findDrawableById("lBatt");
		vBatt.setColor(App.getApp().getProperty("DateColor"));
		vBatt.setFont(rFontDate);
		vBatt.setText(sBatteryLife);			
    	
        //! Get the current time
        var time 	= Sys.getClockTime();
        var vMin	= View.findDrawableById("lTime");
        var sMin	= numToWord[time.min][1];
        var hour	= time.hour;
        vMin.setFont(rFont);
        
        //! convert hour to 12-hr format
		if (hour == 0) {
			hour = 12;
		}
		
		if (hour > 12) {
			hour = hour - 12;
		}
        
        //! format for single vs. double line text
        if (sMin.find("\n")) {
        	vMin.setLocation(xCenter, yCenter - 42);
        }else{
        	vMin.setLocation(xCenter, yCenter - 22);
        }
        
        vMin.setText(sMin);
        vMin.setColor(App.getApp().getProperty("TimeColor"));
        
        //! Get the date
        var now 		= Time.now();
		var dateInfo 	= Date.info(now, Time.FORMAT_SHORT);		
		var sMonth	 	= dateInfo.month;
    	var sDay 		= dateInfo.day;
    	//var sYear		= dateInfo.year;
    	var sDate 		= sMonth + "." + sDay;
    	
    	//! draw the date
		var vDate = View.findDrawableById("lDate");
		vDate.setText(sDate);
		vDate.setFont(rFontDate);
		vDate.setColor(App.getApp().getProperty("DateColor"));
		//vDate.setLocation(xCenter, yCenter + 45);
                
        //! Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);          
		
		//! bluetooth
		var btCoords = calcCircleCoord(hourRads[hour][1], 85);
		var btPts = [ [btCoords[0]-5, btCoords[1]+5], [btCoords[0]+5, btCoords[1]-5], 
					  [btCoords[0], btCoords[1]-10],   [btCoords[0], btCoords[1]+10], 
					  [btCoords[0]+5, btCoords[1]+5], [btCoords[0]-5, btCoords[1]-5] 
					];
					
		if (Sys.getDeviceSettings().phoneConnected) {
			dc.setColor(App.getApp().getProperty("DateColor"), 
						App.getApp().getProperty("BgColor"));
			dc.fillPolygon(btPts);
	    }
        				
		//! draw the bezel markers and the current time marker
		for (var i = 1; i < hourRads.size(); i++) {
			var coords = calcCircleCoord(hourRads[i][1], 85);
			if (i == hour) {
				drawHourCircle(dc, hour);
			}else{
				dc.setColor(App.getApp().getProperty("DialColor"), Gfx.COLOR_BLACK);
				drawCircle(dc, coords[0], coords[1], 8, 2);
			}
		}			
    }
    
    //! HACK for setPenWidth() - draws a series of concentric rings
    //! radius is the inner radius of the circle. uses drawEllipse() because it results in a more
	//! rounded circle than drawCircle() for small circles.
	function drawCircle(dc, x, y, radius, penWidth) {
    	for (var i = 0; i < penWidth; ++i) {
        	dc.drawEllipse(x, y, radius + i, radius + i);
    	}
	}
    
    function drawHourCircle(dc, hour) {
    	var coords = calcCircleCoord(hourRads[hour][1], 85);
    	
    	//!	draw a series of concentric rings	
		for (var i = 0; i < 3; i++) {
			dc.setColor(App.getApp().getProperty("TimeColor"), Gfx.COLOR_BLACK);
			//! HACK START!
			drawCircle(dc, coords[0], coords[1], 14, 2);
		}				
    }
    
    //! calculate the hour/rads coordinates
    function calcCircleCoord(rads, radius) {
    	//! x = cx + r * cos(a)
		//! y = cy + r * sin(a)
    	var coords = new[2];
    	coords[0] = xCenter + radius * Math.cos(rads);
    	coords[1] = yCenter + radius * Math.sin(rads);
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
