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
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import com.rra.ical.utils.VUtils;

	public class VCalendar extends EventDispatcher
	{
		private static var log: ILogger = Log.getLogger("com.rra.ical.VCalendar");
		
		private var _version: String;
		private var _prodId: String;
		
		private var _events: Array;
		public function get Events(): Array { return _events; }
		
		public function VCalendar() {
			_events = new Array();
		}
		
		public function load(path: String): void {
			if (path.indexOf("http:") != -1) 
				loadRemote(new URLRequest( path ));
			else if (path.indexOf("file:") != -1)  
				loadLocal(new File(path.substr(7)));
			else
				log.debug("Unsupported location: " + path);
		}
		
		protected function loadRemote(req: URLRequest): void {
			var ldr: URLLoader = new URLLoader();
			ldr.addEventListener(Event.COMPLETE, onComplete);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, onError);
			ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			ldr.load(req);
		}
		
		protected function loadLocal(f: File): void {
			if (!f.exists) {
				this.dispatchEvent(
					new ErrorEvent(ErrorEvent.ERROR, false, false, "File not found: " + f.nativePath));
			} else {
				var fs: FileStream = new FileStream();
				fs.open(f, FileMode.READ);
				parse(fs.readMultiByte(f.size, File.systemCharset));
				fs.close();
			}
		}
		
		private function onError(e: Event): void {
			log.error(e.toString(), e);
			
			this.dispatchEvent(e);
		}
		
		private function onComplete(event: Event): void {
			parse((event.currentTarget as URLLoader).data);
		}
		
		protected function parse(ics: String): void {
			_version = VUtils.getValue('VERSION', ics)[0];
			_prodId = VUtils.getValue('PRODID', ics)[0];
			
			var matches: Array = ics.match(/BEGIN:VEVENT(\r?\n[^B].*)+/g);
			var i: uint;
			
			if( matches ) {
				for(i = 0; i < matches.length; ++i) {
					var _es: Array = VEvent.parse(matches[i]);
					for (var j: int = 0; j < _es.length; ++j) 
						_events.push( _es[j] );
				}
			}
			log.debug("Calendar parsed; " + _events.length + " events.");
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
	}
}