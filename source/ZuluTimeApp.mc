using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

class ZuluTimeApp extends App.AppBase {

	hidden var updateTimer = null;
	hidden var firstUpdate = true;
	hidden var myView = null;
	hidden var myInput = null;
	
    function initialize() {
    	updateTimer = new Timer.Timer();
        AppBase.initialize();
    }

	function invokeUpdate() {
		if (firstUpdate) {
			firstUpdate = false;
			updateTimer.start( method( :invokeUpdate ), 60 * 1000, true);
		}
		myView.setTimeText();
		myView.requestUpdate();
	}

	function onSettingsChanged() {
		setMenuItems();
		myView.setTimeText();
		myView.requestUpdate();
	}

    //! onStart() is called on application start up
    function onStart() {
    	firstUpdate = true;
    	updateTimer.start( method( :invokeUpdate ), (60 - Sys.getClockTime().sec) * 1000, false);
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    	updateTimer.stop();
    }
    
    function setMenuItems() {
    	Rez.Strings.str_ShowHours_menu = 
    		getProperty("DisplayHours") 
    		? Rez.Strings.str_ShowHours_menu_hide 
    		: Rez.Strings.str_ShowHours_menu_show;
    	Rez.Strings.str_useOh_menu = 
    		getProperty("UseOh")
    		? Rez.Strings.str_useOh_menu_zero
    		: Rez.Strings.str_useOh_menu_oh;
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	setMenuItems();
    	myView = new ZuluTimeView();
    	myInput = new MainMenuDel(myView);
        return [ myView, myInput ];
    }

}