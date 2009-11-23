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
	import com.rra.ical.VEvent;

	public class VEventPerformanceTest
	{
		public var iterations:uint = 6;
		public var description:String = "VEvent parsing speed test";
		
		protected var loops:uint = 100;
		
		public function parseSimpleEvent(): void {
			for (var i:uint=0; i<loops; i++) {
				var e: VEvent = VEvent.parse(VEventTest.SIMPLE_EVENT)[0];
			}
		}
		
		public function parseRecurrentEvent(): void {
			for (var i:uint=0; i<loops; i++) {
				var arr: Array = VEvent.parse(VEventTest.REPEATING_COUNT);
			}
		}
	}
}