using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Attention as Att;


	var zeroHrs = [
		"Zero Zero",
		"Zero One",
		"Zero Two",
		"Zero Three",
		"Zero Four",
		"Zero Five",
		"Zero Six",
		"Zero Seven",
		"Zero Eight",
		"Zero Nine",
		"Ten",
		"Eleven",
		"Twelve",
		"Thirteen",
		"Fourteen",
		"Fifteen",
		"Sixteen",
		"Seventeen",
		"Eighteen",
		"Nineteen",
		"Twenty",
		"Twenty-One",
		"Twenty-Two",
		"Twenty-Three",
		"Twenty-Four"];
	var ohHrs = [
		"Oh Oh",
		"Oh One",
		"Oh Two",
		"Oh Three",
		"Oh Four",
		"Oh Five",
		"Oh Six",
		"Oh Seven",
		"Oh Eight",
		"Oh Nine",
		"Ten",
		"Eleven",
		"Twelve",
		"Thirteen",
		"Fourteen",
		"Fifteen",
		"Sixteen",
		"Seventeen",
		"Eighteen",
		"Nineteen",
		"Twenty",
		"Twenty-One",
		"Twenty-Two",
		"Twenty-Three",
		"Twenty-Four"];
	var minTens = [
		"",
		"",
		"Twenty",
		"Thirty",
		"Forty",
		"Fifty"];
	var minOnes = [
		"",
		"-One",
		"-Two",
		"-Three",
		"-Four",
		"-Five",
		"-Six",
		"-Seven",
		"-Eight",
		"-Nine"];
	var zoneLabel = [
		"Yankee",	// -12
		"X-ray",
		"Whiskey",
		"Victor",
		"Uniform",
		"Tango",
		"Sierra",
		"Romeo",
		"Quebec",
		"Papa",
		"Oscar",	// -2
		"November",	// -1
		"Zulu",		// UTC
		"Alpha",	// +1
		"Bravo",	// +2
		"Charlie",
		"Delta",
		"Echo",
		"Foxtrot",
		"Golf",
		"Hotel",
		"India",
		"Kilo",
		"Lima",
		"Mike",		// +12
		"Juliet"	// Local time (13)
	];
	var zoneOffsets = {
		:tz_alpha=>1,
		:tz_bravo=>2,
		:tz_charlie=>3,
		:tz_delta=>4,
		:tz_echo=>5,
		:tz_foxtrot=>6,
		:tz_golf=>7,
		:tz_hotel=>8,
		:tz_india=>9,
		:tz_kilo=>10,
		:tz_lima=>11,
		:tz_mike=>12,
		:tz_november=>-1,
		:tz_oscar=>-2,
		:tz_papa=>-3,
		:tz_quebec=>-4,
		:tz_romeo=>-5,
		:tz_sierra=>-6,
		:tz_tango=>-7,
		:tz_uniform=>-8,
		:tz_victor=>-9,
		:tz_whiskey=>-10,
		:tz_xray=>-11,
		:tz_yankee=>-12,
		:tz_zulu=>0,
		:tz_juliet=>13
	};
	
	

class ZuluTimeView extends Ui.View {
	hidden var timeLabel = null;
	hidden var dateLabel = null;
	hidden var visible = false;

    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        timeLabel = findDrawableById("TimeText");
        dateLabel = findDrawableById("DateText");
        setTimeText();
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    	visible = true;
    }
    
    function setTimeText() {
    	if (visible){
	    	// Pull props every update rather than cache
			var app = Application.getApp();
			var displayHours = app.getProperty("DisplayHours") ? "Hundred Hours" : "Hundred";
			var baseNums = app.getProperty("UseOh") ? ohHrs : zeroHrs;
			var timezoneToDisplay = app.getProperty("TimezoneToDisplay");
			if (timezoneToDisplay == null) {
				timezoneToDisplay = 0;
			} else if (timezoneToDisplay instanceof String) {
				timezoneToDisplay = timezoneToDisplay.toNumber();
			}
			
	    	// Get clock time every update so that we pick up changes to daylight and UTC offsets!
	    	var utcOffset = 
	    		timezoneToDisplay == 13 
	    		? new Time.Duration(0) 
		    	: new Time.Duration(0 - Sys.getClockTime().timeZoneOffset + (timezoneToDisplay * 60 * 60));	// Negative duration for subtracting
			var utc = Gregorian.info(Time.now().add(utcOffset), Time.FORMAT_MEDIUM);
	
	    	var hrs = utc.hour;
	    	var mins = utc.min;
	    	var hrsTxt = baseNums[hrs == 0 && mins == 0 ? 24 : hrs];
	    	var minsTxt = mins == 0 ? displayHours : (mins < 25 ? baseNums[mins] : (minTens[mins / 10] + minOnes[mins % 10]));
	    	var secsTxt = "";
	    	
	    	//var secs = utc.sec;
	    	//secsTxt = "\nand " + (secs < 20 ? zeroHrs[secs] : (minTens[secs / 10] + " " + minOnes[secs % 10]));
	
			var dateTxt = "";
			dateTxt = utc.day.format("%02d") + " " + utc.month.toString() + " " + utc.year.toString().substring(2,4);
	    	
	    	timeLabel.setText(hrsTxt + "\n" + minsTxt + "\n" + zoneLabel[timezoneToDisplay + 12]);
	    	dateLabel.setText(dateTxt);
    	}
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        // Att.backlight(true);	// BUG - if widget is reaped with backlight on, backlight will NOT go out!  (firmware v5.10)
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    	visible = false;
    }
    
}

class MainMenuDel extends Ui.BehaviorDelegate {
	var myView = null;
	var myMenuDel = null;
	function initialize(v) {
		myView = v;
		BehaviorDelegate.initialize();
	}
	function onMenu() {
		if (myMenuDel == null) {
			myMenuDel = new MenuSelDel(myView);
		}
		Ui.pushView(new Rez.Menus.MainMenu(), myMenuDel, Ui.SLIDE_UP);
	}
}

class MenuSelDel extends Ui.MenuInputDelegate {
	var myView = null;
	var depth = 0;
	function initialize(v) {
		myView = v;
		depth = 0;
		MenuInputDelegate.initialize();
	}
	function mi_west() {
		++depth;
		Ui.pushView(new Rez.Menus.WestMenu(), self, Ui.SLIDE_UP);
		return false;
	}
	function mi_east() {
		++depth;
		Ui.pushView(new Rez.Menus.EastMenu(), self, Ui.SLIDE_UP);
		return false;
	}
	function mi_hours(app) {
		app.setProperty("DisplayHours", ! app.getProperty("DisplayHours"));
		return true;
	}
	function mi_oh(app) {
		app.setProperty("UseOh", ! app.getProperty("UseOh"));
		return true;
	}
	function onMenuItem(item) {
		var app = Application.getApp();
		var refresh = false;
		if (self has item) {
			refresh = method(item).invoke(app);
		} else {
			app.setProperty("TimezoneToDisplay", zoneOffsets[item]);
			refresh = true;
			if (depth > 0)
			{
				Ui.popView(Ui.SLIDE_DOWN);
				--depth;
			}
		}
		if (refresh) {
			app.onSettingsChanged();
		}
	}
}

