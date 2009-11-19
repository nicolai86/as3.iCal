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
	import flexunit.framework.Assert;
	
	import com.rra.ical.VEvent;

	public class VEventTest
	{
		private static var SAMPLE_EVENT: String = "BEGIN:VEVENT\n\nTRANSP:OPAQUE"+
			"\n\nDTEND;TZID=Europe/Berlin:20090904T160000" +
			"\n\nUID:5773E02F-173F-4907-91E4-6EB79E7CDBAE" +
			"\n\nDTSTAMP:20091006T223146Z" +
			"\n\nLOCATION:" +
			"\n\nDESCRIPTION:" +
			"\n\nSTATUS:CONFIRMED" +
			"\n\nSEQUENCE:6" +
			"\n\nSUMMARY:Test Summary" +
			"\n\nDTSTART;TZID=Europe/Berlin:20090904T103000" +
			"\n\nCREATED:20090923T082044Z" +
			"\n\nEND:VEVENT";
		
		private static var REPEATING_ON_DATE: String = "BEGIN:VEVENT" +
			"\n\nCREATED:20091027T122238Z" +
			"\n\nUID:0C6D1C8B-033A-44FF-91EF-41F8B4356782" +
			"\n\nDTEND;TZID=Europe/Berlin:20091027T073000" +
			"\n\nRRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20091104T225959Z" +
			"\n\nTRANSP:OPAQUE" +
			"\n\nSUMMARY:Weekly OnDate" +
			"\n\nDTSTART;TZID=Europe/Berlin:20091027T063000" +
			"\n\nDTSTAMP:20091027T122310Z" +
			"\n\nSEQUENCE:6" +
			"\n\nEND:VEVENT";
		
		private static var REPEATING_FOREVER: String = "BEGIN:VEVENT" +
			"\n\nCREATED:20091027T122315Z" +
			"\n\nUID:903B96C1-F46C-4F65-8AD1-1EF5616DA03F" +
			"\n\nDTEND;TZID=Europe/Berlin:20091027T050000" +
			"\n\nRRULE:FREQ=WEEKLY;INTERVAL=1" +
			"\n\nTRANSP:OPAQUE" +
			"\n\nSUMMARY:Weekly Never" +
			"\n\nDTSTART;TZID=Europe/Berlin:20091027T044500" +
			"\n\nDTSTAMP:20091027T122324Z" +
			"\n\nSEQUENCE:3" +
			"\n\nEND:VEVENT" +
			"\n\nEND:VCALENDAR";
		
		private static var REPEATING_COUNT: String = "BEGIN:VEVENT" +
			"\n\nCREATED:20091027T122125Z" +
			"\n\nUID:4D046357-86FE-45C0-8A67-1AC50D952A5B" +
			"\n\nDTEND;TZID=Europe/Berlin:20091027T061500" +
			"\n\nRRULE:FREQ=WEEKLY;INTERVAL=1;COUNT=2" +
			"\n\nTRANSP:OPAQUE" +
			"\n\nSUMMARY:Weekly Times" +
			"\n\nDTSTART;TZID=Europe/Berlin:20091027T051500" +
			"\n\nDTSTAMP:20091027T122236Z" +
			"\n\nSEQUENCE:7" +
			"\n\nEND:VEVENT";
		
		private static var ALL_DAY_EVENT: String = "BEGIN:VEVENT" +
			"\n\nCREATED:20091020T225538Z" +
			"\n\nUID:C40A2B58-B8EC-4CC3-A26B-8033BDAA6D09" +
			"\n\nDTEND;VALUE=DATE:20091029" +
			"\n\nTRANSP:TRANSPARENT" +
			"\n\nSUMMARY:Simon" +
			"\n\nDTSTART;VALUE=DATE:20091025" +
			"\n\nDTSTAMP:20091025T213631Z" +
			"\n\nLOCATION:Bonn" +
			"\n\nSEQUENCE:6" +
			"\n\nEND:VEVENT";
		
		[Test]
		public function testParseAllDayVEvent(): void {
			var es: Array = VEvent.parse(ALL_DAY_EVENT);
			Assert.assertEquals(4, es.length);
			Assert.assertEquals(24 * 60, es[0].Duration);
		}
		
		[Test]
		public function testParseVEvent():void
		{
			var e: VEvent = VEvent.parse(SAMPLE_EVENT)[0] as VEvent;
			Assert.assertEquals(e.Duration, 5 * 60 + 30);
			Assert.assertEquals(e.Summary, "Test Summary");
			Assert.assertEquals(e.UID, "5773E02F-173F-4907-91E4-6EB79E7CDBAE");
		}
	}
}