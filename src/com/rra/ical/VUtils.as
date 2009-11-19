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
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	
	import flash.utils.Dictionary;

	public class VUtils
	{
		public function VUtils()
		{
		}
		
		public static function parseIso8601(str: String): Date {
			var dateArr: Array = [str.substr(0, 4), str.substr(4,2), str.substr(6, 2)];
			var timeArr: Array = [str.substr(9, 2), str.substr(11, 2), str.substr(13, 2)];
			return DateUtil.parseW3CDTF(dateArr.join("-") + "T" + timeArr.join(":") + "Z");
		}
		
		public static function allProperties(content: String): Dictionary {
			var reg: RegExp = new RegExp('([A-Z]+)(;[^=]*=[^;:\n]*)*:([^\n]*)','g');
			var dic: Dictionary = new Dictionary();
			var matches: Array = null;
			while( (matches = reg.exec(content)) != null ) {
				var pDic: Dictionary = new Dictionary();
				var property: String = StringUtil.trim(matches[1]);
				var value: String = StringUtil.trim(matches[3]);
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
	}
}