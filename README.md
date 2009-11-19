# as3-ical

as3-ical is an iCal parser written in ActionScript 3. Parsing works as specified in [RFC2445](http://www.ietf.org/rfc/rfc2445.txt).

## Usage

	import com.rra.ical.VCalendar;
	// ...
	var calendar: VCalendar = new VCalendar();
	calendar.addEventListener(Event.COMPLETE, onComplete);
	calendar.load("http://path/to/my/calendar.ics");
	// ...
	function onComplete(e: Event): void {
		var calendar: VCalendar = e.currentTarget as VCalendar;
		for (var i: int = 0; i < calendar.Events.length; ++i) {
			var event: VEvent = calendar.Events[i];
			// do something with event.
		}
	}

## Features

 - Parses ics files
 - Handles recurrences

TODO complete the features-list

## Still missing

 - tests! The test coverage is horrible
 - as3doc! The code is barely documented
 - optimizations! There's plenty of room for improvements.

TODO complete the what's-missing-list 