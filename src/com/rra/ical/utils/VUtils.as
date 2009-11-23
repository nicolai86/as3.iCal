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
package com.rra.ical.utils
{
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	
	import flash.utils.Dictionary;
	
	import com.rra.ical.VEvent;

	public class VUtils
	{
		public static var DEFAULT_PROPERTIES: Array = ["DTEND", "DTSTAMP", "DTSTART",
			"UID", "SUMMARY", "LOCATION", "URL"];
		
		public static function parseIso8601(str: String): Date {
			var dateArr: Array = [str.substr(0, 4), str.substr(4,2), str.substr(6, 2)];
			var timeArr: Array = [str.substr(9, 2), str.substr(11, 2), str.substr(13, 2)];
			return DateUtil.parseW3CDTF(dateArr.join("-") + "T" + timeArr.join(":") + "Z");
		}
		
		public static function allProperties(content: String): Dictionary {
			var reg: RegExp = new RegExp('([A-Z]+)(;[^=]*=[^;:\n]*)*:([^\n]*)','g');
			var dic: Dictionary = new Dictionary();
			var pDic: Dictionary;
			
			for (var i: int = 0; i < DEFAULT_PROPERTIES.length; ++i) {
				pDic = new Dictionary();
				pDic[0] = "";
				dic[DEFAULT_PROPERTIES[i]] = pDic;
			}
			
			var matches: Array = null;
			while( (matches = reg.exec(content)) != null ) {
				var property: String = StringUtil.trim(matches[1]);
				var value: String = StringUtil.trim(matches[3]);
				
				if (dic[property])
					pDic = dic[property];
				else
					pDic = new Dictionary();
				pDic[0] = value;
				
				var tab_params: String;
				if (StringUtil.stringHasValue(matches[2])){ 
					var params: Array = matches[2].substr(1).split(';');
					var pair: Array;
					var code: String='';
					for(var k: uint =0;k<params.length;k++){
						pair = params[k].split('=');
						if(!pair[1]) 
							pair[1]=pair[0];
						pDic[pair[0].replace(/-/,'')] = pair[1];
					}
				}
				dic[property] = pDic;
			}
			return dic;
		}
		
		public static function getValue(property: String, content: String): Dictionary {
			var reg: RegExp = new RegExp('('+property+')(;[^=]*=[^;:\n]*)*:([^\n]*)','g');
			var dic: Dictionary = new Dictionary();
			var matches: Array = reg.exec(content);
			if (matches) {
				var value: String = matches[3];
				dic[0] = StringUtil.trim(value);
				
				var tab_params: String;
				
				if (StringUtil.stringHasValue(matches[2])){ 
					var params: Array =matches[2].substr(1).split(';');
					var pair: Array;
					var code: String='';
					for(var k: uint =0;k<params.length;k++){
						pair = params[k].split('=');
						if(!pair[1]) 
							pair[1]=pair[0];
						dic[pair[0].replace(/-/,'')] = pair[1];
					}
				}
				return dic;
			}
			return dic;
		}
		
		public static function parseMonthly(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var monthDays: Array = new Array();
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			edic["DURATION"] = duration;
			
			if (p["BYMONTHDAY"])
				for (i = 0; i < p["BYMONTHDAY"][1].length; ++i) 
					monthDays.push(p["BYMONTHDAY"][1][i]);
			else 
				monthDays.push(dtstart.date);
			
			skip = p["INTERVAL"];
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = monthlyDate(dtstart, monthDays, skip, i);
					event = new VEvent(edic, i);
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = Math.floor((until.getTime()-dtstart.getTime())/(29*24*60*60*1000) + 1) * (p["BYMONTHDAY"] ? monthDays.length : 1);
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = monthlyDate(dtstart, monthDays, skip, i);
					event = new VEvent(edic, i);
					
					if (event.dtstart.getTime() > until.getTime())
						break;
					
					ret.push(event);
				}
			}
			
			// restore old dtstart date
			edic["DTSTART"] = dtstart;
			return ret;
		}
		
		public static function parseWeekly(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var days: Array = new Array();
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			edic["DURATION"] = duration;
			
			if (p["BYDAY"])
				for (i = 0; i < p["BYDAY"][1].length; ++i) 
					days.push(ICalDate.DayToIndex(p["BYDAY"][1][i]));
			else 
				days.push(dtstart.day);
			
			skip = p["INTERVAL"] * 7;
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = weeklyDate(dtstart, days, skip, i); 
					event = new VEvent(edic, i);
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = Math.floor((until.getTime()-dtstart.getTime())/(7*24*60*60*1000) + 1) * (p["BYDAY"] ? days.length : 1);
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = weeklyDate(dtstart, days, skip, i); 
					event = new VEvent(edic, i);
					ret.push(event);
				}
			}
			
			// restore old dtstart
			edic["DTSTART"] = dtstart;
			return ret;
		}
		
		public static function parseDaily(edic: Dictionary, p: Dictionary): Array {
			var ret: Array = new Array();
			var times: int;
			var dtstart: Date = edic["DTSTART"];
			var until: Date;
			var skip: int;
			var i: int;
			var event: VEvent;
			var duration: int = (edic["DTEND"].getTime() - dtstart.getTime()) / (1000 * 60);
			edic["DURATION"] = duration;
			
			if (p["COUNT"]) {
				times = parseInt(p["COUNT"]);
				skip = p["INTERVAL"];
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = new Date(dtstart.fullYear, dtstart.month, dtstart.date + i*skip);
					event = new VEvent(edic, i);
					ret.push(event);
				}	
			} else if (p["UNTIL"]) {
				until = p["UNTIL"];
				times = (until.getTime()-dtstart.getTime())/(24*60*60*1000) + 1;
				skip = p["INTERVAL"];
				for (i = 0; i < times; ++i) {
					edic["DTSTART"] = new Date(dtstart.fullYear, dtstart.month, dtstart.date + i*skip);
					event = new VEvent(edic, i);
					ret.push(event);
				}
			}

			// restore old dtstart
			edic["DTSTART"] = dtstart;
			return ret;
		}
		
		public static function monthlyDate(from: Date, only: Array, skip: int, n: int): Date {
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
		
		public static function weeklyDate(from: Date, only: Array, skip: int, n: int): Date {
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
	}
}