/*
 * Copyright 2009 as3-ical authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.rra.ical
{
	import com.rra.ical.utils.ICalDate;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import com.rra.ical.utils.VUtils;

	public class VEvent
	{
		private static var log: ILogger = Log.getLogger("com.rra.ical.VEvent");
		
		private var _description: String;
		
		private var _url: String;
		public function get url(): String {
			return this._url;
		}
		
		private var _duration: uint;
		public function get duration(): uint { 
			return this._duration; 
		}
		
		private var _uid: String;
		public function get uid(): String { 
			return this._uid; 
		}
		
		private var _summary: String;
		public function get summary(): String { 
			return this._summary; 
		}
		
		private var _dtstart: Date;
		public function get dtstart(): Date { 
			return this._dtstart; 
		}
		
		private var _dtend: Date;
		public function get dtend(): Date {
			return this._dtend;
		}
		
		private var _dtstamp: Date;
		public function get dtstamp(): Date {
			return this._dtstamp;
		}
		
		private var _rrule: String;
		public function get rrule(): String { 
			return this._rrule; 
		}
		
		private var _location: String;
		public function get location(): String { 
			return this._location; 
		}
		
		public function VEvent(p: Dictionary = null, recurrence_count: int = -1) {
			super();
			
			if (p) {
				this._dtend   	= p["DTEND"];
				this._dtstamp 	= p["DTSTAMP"];
				this._dtstart 	= p["DTSTART"];
				this._uid 	  	= p["UID"];
				this._summary 	= p["SUMMARY"];
				this._location	= p["LOCATION"];
				
				if (p["URL"])
					this._url 	  	= p["URL"];
				
				if (p["DURATION"])
					this._duration 	= p["DURATION"];
			}
			
			if (recurrence_count >= 0) {
				this._uid 	  = this._uid + "_" + recurrence_count;
			}
		}
		
		public static function parse(content: String): Array {
			var arr: Array = new Array();
			var i: int;
			var skip: int;
			var duration: int;
			var event: VEvent
			var edic: Dictionary = new Dictionary();
			var props: Dictionary = VUtils.allProperties(content);
			
			var dts: Dictionary = props["DTSTART"];
			var dte: Dictionary = props["DTEND"]
			var dtstart: Date = VUtils.parseIso8601(dts[0]);
			var dtend: Date = VUtils.parseIso8601(dte[0]);
			var dtstamp: Date = VUtils.parseIso8601(props["DTSTAMP"][0]);
			var until: Date;
			var times: int;
			
			edic["DTSTART"] = dtstart;
			edic["DTEND"] = dtend;
			edic["DTSTAMP"] = dtstamp;
			edic["UID"] = props["UID"][0];
			edic["SUMMARY"] = props["SUMMARY"][0];
			edic["LOCATION"] = props["LOCATION"][0];
			edic["URL"] = props["URL"][0];
			
			duration = (dtend.getTime() - dtstart.getTime()) / (1000 * 60);
			if (props["RRULE"]) {
				var rrule: String = props["RRULE"][0]
				var p: Dictionary = ICalDate.parse_recurrence(rrule);
				if (!p["INTERVAL"])
					p["INTERVAL"] = 1;
				else 
					p["INTERVAL"] = parseInt(p["INTERVAL"]);
				
				var other: Array;
				if (p["FREQ"] == "DAILY") {
					other = VUtils.parseDaily(edic, p);
				} else if (p["FREQ"] == "MONTHLY") {
					other = VUtils.parseMonthly(edic, p);
				} else if (p["FREQ"] == "WEEKLY") {
					other = VUtils.parseWeekly(edic, p);
				} else if (p["FREQ"] == "YEARLY") {
					log.debug("Yearly events not supported! " + dtstart);
				} else {
					log.error("Invalid frequency: " + p["FREQ"]);
				}
				
				if (other)
					for (i = 0; i < other.length; ++i)
						arr.push(other[i]);
			} else {
				// all day events!
				if (dts["VALUE"] && "DATE" == dts["VALUE"]) {
					var days: int = dtend.getTime() - dtstart.getTime();
					days /= 24 * 60 * 60 * 1000;
					for (i = 0; i < days; ++i) {
						event = new VEvent(edic, i);
						event._dtstart 		= new Date(dtstart.fullYear, dtstart.month, dtstart.date+i);
						event._duration 	= 24 * 60;
						arr.push(event);
					}
				} else {
					event = new VEvent(edic);
					event._duration = duration;
					arr.push(event);
				}
				
			}
			
			return arr;
		}
		
		public function toString(): String {
			return _uid+"--"+_dtstart + ";" + _dtend + "("+_duration+")";
		}
	}
}