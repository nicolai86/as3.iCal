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
	
	import com.rra.ical.utils.VUtils;

	public class VUtilsTest
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
		
		[Test]
		public function testGetValue(): void {
			Assert.assertEquals(VUtils.getValue("UID"    , SAMPLE_EVENT)[0], "5773E02F-173F-4907-91E4-6EB79E7CDBAE");
			Assert.assertEquals(VUtils.getValue("DTSTART", SAMPLE_EVENT)[0], "20090904T103000");
			Assert.assertEquals(VUtils.getValue("DTEND"  , SAMPLE_EVENT)[0], "20090904T160000");
		}
	}
}