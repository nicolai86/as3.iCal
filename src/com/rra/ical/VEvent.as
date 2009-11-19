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
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import com.rra.ical.utils.ICalDate;

	public class VEvent
	{
		private static var log: ILogger = Log.getLogger("com.rra.ical.VEvent");
		
		private var _description: String;
		private var _dtstamp: String;
		private var _url: String;
		
		private var _duration: uint;
		public function get Duration(): uint { return _duration; }
		
		private var _uid: String;
		public function get UID(): String { return _uid; }
		
		private var _summary: String;
		public function get Summary(): String { return _summary; }
		
		private var _dtstart: Date;
		public function get dtstart(): Date { return _dtstart; }
		
		private var _dtend: Date;
		
		private var _rrule: String;
		public function get rrule(): String { return _rrule; }
		
		public function VEvent(p: Dictionary = null) {
			super();
			
			if (p) {
				this._dtend   = p["DTEND"];
				this._dtstamp = p["DTSTAMP"];
				this._dtstart = p["DTSTART"];
				this._uid 	  = p["UID"];
				this._summary = p["SUMMARY"];
			}
		}
		
		public static function createDummy(duration: uint, sum: String): VEvent {
			var e: VEvent = new VEvent;
			
			e._duration = duration;
			e._summary = sum;
			
			return e;
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
			var until: Date;
			var dtstamp: String = props["DTSTAMP"][0];
			var uid: String = props["UID"][0];
			var summary: String = props["SUMMARY"][0];
			var times: int;
			
			edic["DTSTART"] = dtstart;
			edic["DTEND"] = dtend;
			edic["DTSTAMP"] = dtstamp;
			edic["UID"] = uid;
			edic["SUMMARY"] = summary;
			
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
					other = parseDaily(edic, p);
				} else if (p["FREQ"] == "MONTHLY") {
					other = parseMonthly(edic, p);
				} else if (p["FREQ"] == "WEEKLY") {
					other = parseWeekly(edic, p);
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
				if (dts["VALUE"] && dts["VALUE"] == "DATE") {
					var days: int = dtend.getTime() - dtstart.getTime();
					days /= 24 * 60 * 60 * 1000;
					for (i = 0; i < days; ++i) {
						event = new VEvent(edic);
						event._uid 			= uid+"_"+i;
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
		
		private static function monthlyDate(from: Date, only: Array, skip: int, n: int): Date {
			if (n == 0) {
				return from;
			}
			
			only.sort();
			
			var offset: int = 0;
			for (var i: int = 0; i < only.length; ++i) {
				if (new Date(from.fullYear, from.month, only[i], 
					from.hours, from.minutes, from.seconds).getTime() < from.getTime())
					offset++;
			}
			n += offset;
			
			var times: int = n / only.length;
			var left: int = n - (times * only.length);
			
			var d: Date = new Date(from.fullYear, 
				from.month + times * skip,
				only[left]);
			return d;
		}
		
		private static function weeklyDate(from: Date, only: Array, skip: int, n: int): Date {
			if (n == 0) {
				return from;
			}
			
			only.sort();
			
			var offset: int = 0;
			for (var i: int = 0; i < only.length; ++i) {
				if (new Date(from.fullYear, from.month,from.date - from.day + only[i], 
					from.hours, from.minutes, from.seconds).getTime() < from.getTime())
					offset++;
			}
			n += offset;
			
			var times: int = n / only.length;
			var left: int = n - (times * only.length);
			
			var d: Date = new Date(from.getTime() + 24 * 60 * 60 * 1000 * (times * skip));
			return new Date(d.fullYear, d.month, d.date - d.day + only[left]);
		}
		
		private static function parseMonthly(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var monthDays: Array = new Array();
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			
			if (p["BYMONTHDAY"])
				for (i = 0; i < p["BYMONTHDAY"][1].length; ++i) 
					monthDays.push(p["BYMONTHDAY"][1][i]);
			else 
				monthDays.push(dtstart.date);
			
			skip = p["INTERVAL"];
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration;
					event._dtstart = monthlyDate(dtstart, monthDays, skip, i); 
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = Math.floor((until.getTime()-dtstart.getTime())/(29*24*60*60*1000) + 1) * (p["BYMONTHDAY"] ? monthDays.length : 1);
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration
					event._dtstart = monthlyDate(dtstart, monthDays, skip, i);
					
					if (event._dtstart.getTime() > until.getTime())
						break;
					
					ret.push(event);
				}
			}
			return ret;
		}
		
		private static function parseWeekly(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var days: Array = new Array();
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			
			if (p["BYDAY"])
				for (i = 0; i < p["BYDAY"][1].length; ++i) 
					days.push(ICalDate.DayToIndex(p["BYDAY"][1][i]));
			else 
				days.push(dtstart.day);
			
			skip = p["INTERVAL"] * 7;
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration;
					event._dtstart = weeklyDate(dtstart, days, skip, i); 
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = Math.floor((until.getTime()-dtstart.getTime())/(7*24*60*60*1000) + 1) * (p["BYDAY"] ? days.length : 1);
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration
					event._dtstart = weeklyDate(dtstart, days, skip, i);
					ret.push(event);
				}
			}
			
			return ret;
		}
		
		private static function parseDaily(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				skip = p["INTERVAL"];
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration;
					event._dtstart = new Date(dtstart.fullYear, dtstart.month, dtstart.date + i*skip);
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = (until.getTime()-dtstart.getTime())/(24*60*60*1000) + 1;
				skip = p["INTERVAL"];
				for (i = 0; i < times; ++i) {
					event = new VEvent(edic);
					event._uid = edic["UID"]+"_"+i;
					event._duration = duration
					event._dtstart = new Date(dtstart.fullYear, dtstart.month, dtstart.date + i*skip)
					ret.push(event);
				}
			}
			
			return ret;
		}
		
		public function toString(): String {
			return _uid+"--"+_dtstart + ";" + _dtend + "("+_duration+")";
		}
	}
}