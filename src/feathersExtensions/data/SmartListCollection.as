package feathersExtensions.data
{
import feathers.data.ListCollection;

import flash.utils.Dictionary;

public class SmartListCollection extends ListCollection
	{
		protected var itemsByKey:Dictionary = new Dictionary();
		
		public var itemRegistrationKeys:Array;
		
		public function SmartListCollection(data:Object=null,itemRegistrationKeys:Array=null)
		{
			this.itemRegistrationKeys = itemRegistrationKeys;
			super(data);
		}
		override public function set data(value:Object):void
		{
			super.data = value;
			for each(var item:Object in value)
			{
				registerItem(item);
			}
		}
		override public function addItemAt(item:Object, index:int):void
		{
			super.addItemAt(item, index);
			
			registerItem(item);
		}
		protected function registerItem(item:Object):void
		{
			for each(var key:* in itemRegistrationKeys)
			{
				if(!itemsByKey[key]) itemsByKey[key] = new Dictionary();
				if(item.hasOwnProperty(key)) itemsByKey[key][item[key]] = item;
			}
		}
		override public function removeItemAt(index:int):Object
		{
			var item:Object = super.removeItemAt(index);
			for each(var key:* in itemRegistrationKeys)
			{
				if(item.hasOwnProperty(key)) delete itemsByKey[key][item[key]];
			}
			return item;
		}
		override public function removeAll():void
		{
			super.removeAll();
			for each(var key:* in itemRegistrationKeys)
			{
				delete itemsByKey[key];
			}
		}
		public function toggle(item:Object):void
		{
			var i:int = getItemIndex(item);
			if(i<0) addItem(item);
			else removeItemAt(i);
		}
		public function getItemByKey(key:String,value:*):Object
		{
			return itemsByKey[key] ? itemsByKey[key][value] : null;
		}
	}
}