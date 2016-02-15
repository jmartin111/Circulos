using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class CirculosApp extends App.AppBase {

	hidden var vCirculos;

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	vCirculos = new CirculosView();
        return [ vCirculos ];
    }
    
    //! New app settings have been received so trigger a UI update
    function onSettingsChanged() {
    	vCirculos.onSettingsChanged();
 	}

}

class Background extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        dc.setColor(Gfx.COLOR_TRANSPARENT, App.getApp().getProperty("BgColor"));
        dc.clear();
    }

}