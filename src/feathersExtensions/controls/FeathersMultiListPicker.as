package feathersExtensions.controls
{
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.groups.SmartLayoutGroupSkinnable;

import mvc.view.screen.AbstractMenuItem;

import starling.display.DisplayObject;
import starling.events.Event;

public class FeathersMultiListPicker extends SmartLayoutGroupSkinnable
	{
		public var lists:Array = [];
		
		public function FeathersMultiListPicker()
		{
			super();
			addList();
		}
		protected function addList():SmartList
		{
			var list:SmartList = lists[numChildren] ? lists[numChildren] : getList();
			lists[numChildren] = list;
			
			super.addChildAt(list,numChildren);
			numLists = numChildren;
			
			list.autoToggleSelection = false;
			list.addEventListener(Event.CHANGE,onItemSelected);
			
			return list;
		}
		protected var numLists:int = 0;
		protected function removeLists(startIndex:int):void
		{
			//try{
				super.removeChildren(startIndex);
				numLists = lists.length-startIndex;
			//}catch(e:Error){}
		}
		protected var curentList:SmartList;
		protected function onItemSelected(e:Event):void
		{
			curentList = e.target as SmartList;
			var menuItem:AbstractMenuItem = curentList.selectedItem as AbstractMenuItem;
			if(!menuItem) return;
			
			var i:int = lists.indexOf(curentList);
			
			if(i==numLists-1)
			{
				if(menuItem.menu) addList().dataProvider = menuItem.menu;
			}
			else
			{
				if(!menuItem.menu) removeLists(getChildIndex(curentList)+1);
			}
			validateSize();
		}
		public function set dataProvider(value:ListCollection):void
		{
			(lists[0] as SmartList).dataProvider = value;
		}
		protected function getList():SmartList
		{
			return new SmartList();
		}
		public function get rootList():SmartList
		{
			return lists[0];
		}
		protected var itemW:Number;
		protected var itemH:Number;
		override public function setSize(width:Number, height:Number):void
		{
			itemH = height;
			itemW = width;
			
			super.setSize(width, height);
		}
		override protected function validateSize():void
		{
			super.validateSize();
			
			var list:SmartList;
			for(var i:int=0;i<numLists;i++)
			{
				list = lists[i];
				if(layout is VerticalLayout) list.setSize(itemW,itemH);
				if(layout is HorizontalLayout) list.setSize(itemH,itemW);
			}
			if(layout is VerticalLayout) height = itemH*numLists;
			if(layout is HorizontalLayout) width = itemW*numLists;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return null;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return null;
		}
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			return null;
		}
		override public function removeChildren(beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false):void
		{
		}
	}
}