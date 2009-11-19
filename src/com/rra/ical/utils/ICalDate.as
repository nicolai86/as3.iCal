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
	import com.rra.ical.VUtils;

	public class ICalDate
	{
		public static function DaysInMonth(d: Date): int {
			return new Date(d.fullYear, d.month+1, 0).date;
		}
		
		public static function DayToIndex(str: String): int {
			var ind: int = 0;
			
			if (str == "MO") ind = 1;
			else if (str == "TU") ind = 2;
			else if (str == "WE") ind = 3;
			else if (str == "TH") ind = 4;
			else if (str == "FR") ind = 5;
			else if (str == "SA") ind = 6;
			else if (str == "SU") ind = 0;
			
			return ind;
		}
		
		public static function parse_recurrence(rrule: String): Dictionary {
			var dic: Dictionary = new Dictionary();
			
			var entries: Array = rrule.split(";");
			for (var i: int = 0; i < entries.length; ++i) {
				var part: String = entries[i];
				var ess: Array = part.split("=");
				var name: String = StringUtil.trim(ess[0]);
				var value: String= StringUtil.trim(ess[1]);
				
				if (name == "UNTIL") {
					dic[name] = VUtils.parseIso8601(value);
				} else if (name.indexOf("BY") != -1) {
					dic[name] = [value, value.split(",")];
				} else {
					dic[name] = value;
				}
			}
			
			return dic;
		}
	}
}