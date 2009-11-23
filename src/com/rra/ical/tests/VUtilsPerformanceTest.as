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
package com.rra.ical.tests
{
	import com.rra.ical.utils.VUtils;
	
	import flash.utils.Dictionary;

	/**
	 * Simple performance test cases to be run with gskinners PerformanceTest class
	 */
	public class VUtilsPerformanceTest
	{
		public var iterations:uint = 6;
		public var description:String = "VUtils speed test";
		
		protected var loops:uint = 100;
		
		public function getAllProperties(): void {
			for (var i:uint=0; i<loops; i++) {
				var props: Dictionary = VUtils.allProperties(VEventTest.SIMPLE_EVENT);
			}
		}
		
		public function getAllPropertiesSimple(): void {
			for (var i:uint=0; i<loops; i++) {
				var dtend: Dictionary = VUtils.getValue("DTEND", VEventTest.SIMPLE_EVENT);
				var dtstart: Dictionary = VUtils.getValue("DTSTART", VEventTest.SIMPLE_EVENT);
				var dtstamp: Dictionary = VUtils.getValue("DTSTAMP", VEventTest.SIMPLE_EVENT);
				var location: Dictionary = VUtils.getValue("LOCATION:", VEventTest.SIMPLE_EVENT);
				var description: Dictionary = VUtils.getValue("DESCRIPTION:", VEventTest.SIMPLE_EVENT);
				var summary: Dictionary = VUtils.getValue("SUMMARY", VEventTest.SIMPLE_EVENT);
				var rrule: Dictionary = VUtils.getValue("RRULE", VEventTest.SIMPLE_EVENT);
				var url: Dictionary = VUtils.getValue("URL", VEventTest.SIMPLE_EVENT);
				var uid: Dictionary = VUtils.getValue("UID", VEventTest.SIMPLE_EVENT);
			}
		}
		
		public function getSingleProperty(): void {
			for (var i:uint=0; i<loops; i++) {
				var prop: Dictionary = VUtils.getValue("DTSTART", VEventTest.SIMPLE_EVENT);
			}
		}
	}
}