using Toybox.Application as App;
using Toybox.System as Sys;

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