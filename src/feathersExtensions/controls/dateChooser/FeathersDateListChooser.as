package feathersExtensions.controls.dateChooser
{
import feathersExtensions.controls.SmartList;
import feathersExtensions.groups.SmartLayoutGroup;
import feathersExtensions.groups.SmartLayoutGroupSkinnable;

import utils.Range;

public class FeathersDateListChooser extends SmartLayoutGroupSkinnable
	{
		public static var months:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
		public static var years:Array = [];
		public static var days:Array = [];
		
		public var dayList:SmartList = new SmartList();
		public var monthList:SmartList = new SmartList();
		public var yearList:SmartList = new SmartList();
		
		public function FeathersDateListChooser(fromYear:int=1900)
		{
			super();
			
			setupProviders(fromYear);
			
			layout = SmartLayoutGroup.getHLayout(hLayout,0,0,0.8);
		}
		protected function setupProviders(fromYear:int=1900):void
		{
			var date:Date = new Date();
			var curentYear:int = date.fullYear;
			var curentDay:int = date.day;
			
			Range.fillMassive(years,fromYear,curentYear);
			Range.fillMassive(days,1,31);
		}
		public var itemRendererType:Class;
		override protected function initChildren():void
		{
			super.initChildren();
			
			dayList.itemRendererType = monthList.itemRendererType = yearList.itemRendererType = itemRendererType ? itemRendererType : FeathersDateListIR;
				
			dayList.autoScrollToSelectedItem = monthList.autoScrollToSelectedItem = yearList.autoScrollToSelectedItem = true;
			dayList.autoToggleSelection = monthList.autoToggleSelection = yearList.autoToggleSelection = false;
			
			dayList.layout = SmartLayoutGroup.getVLayout();
			monthList.layout = SmartLayoutGroup.getVLayout();
			yearList.layout = SmartLayoutGroup.getVLayout();

			dayList.smartItemLayoutData.percentHeight = monthList.smartItemLayoutData.percentHeight = yearList.smartItemLayoutData.percentHeight = 10;
			dayList.smartItemLayoutData.percentWidth = monthList.smartItemLayoutData.percentWidth = yearList.smartItemLayoutData.percentWidth = 100;

			dayList.dataProviderSource = days;
			monthList.dataProviderSource = months;
			yearList.dataProviderSource = years;
			
			addChildren(dayList,monthList,yearList);
			
			date = _date;
		}
		public function set day(value:int):void
		{
			if(dayList) dayList.selectedItem = value;
		}
		public function get day():int
		{
			return dayList ? int(dayList.selectedItem) : 0;
		}
		public function set dayString(value:String):void
		{
			day = value.charAt(0)=="0" ? parseInt(value.substr(1)) : parseInt(value); 
		}
		public function get dayString():String
		{
			var dayInt:int = day;
			if(dayInt<10) return "0"+dayInt;
			return dayInt+"";
		}
		public function set monthString(value:String):void
		{
			if(monthList) monthList.selectedItem = value;
		}
		public function get monthString():String
		{
			return monthList ? String(monthList.selectedItem) : "No month selected";
		}
		public function set monthIndex(value:int):void
		{
			if(monthList) monthList.selectedIndex = value-1;
		}
		public function get monthIndex():int
		{
			return monthList ? monthList.selectedIndex +1 : 0;
		}
		public function set monthNumber(value:String):void
		{
			monthIndex = value.charAt(0)=="0" ? parseInt(value.substr(1)) : parseInt(value); 
		}
		public function get monthNumber():String
		{
			var month:int = monthIndex;
			if(monthIndex<10) return "0"+monthIndex;
			return month+"";
		}
		public function set year(value:*):void
		{
			if(yearList) yearList.selectedItem = value is String ? parseInt(value) : value;
		}
		public function get year():int
		{
			return yearList ? int(yearList.selectedItem) : 0;
		}
		public function get dateString():String
		{
			return day + " " + monthString + " " + year;
		}
		public function get date():String
		{
			return year+"-"+dayString+"-"+monthNumber;
		}
		protected var _date:*;
		public function set date(value:*):void
		{
			if(!value) return;
			
			_date = value;
			if(_date is String)
			{
				var splits:Array = String(_date).split("-");
				if(splits && splits.length==3)
				{
					year = splits[0];
					dayString = splits[1];
					monthNumber = splits[2];
				}
			}
			else if(_date is Date) 
			{
				day = (_date as Date).day;
				monthIndex = (_date as Date).month;
				year = (_date as Date).fullYear;
			}
		}
		override protected function validateSize():void
		{
			super.validateSize();
			
			dayList.setSize(width*0.2,height);
			monthList.setSize(width*0.5,height);
			yearList.setSize(width*0.3,height);
		}
		
	}
}