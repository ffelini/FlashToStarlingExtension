package mvc.model
{
import flash.utils.Dictionary;

public dynamic class SmartArray extends Array
	{
		protected var itemsByKey:Dictionary = new Dictionary();
		
		public var itemRegistrationKeys:Array;
		
		public function SmartArray()
		{
			length = 0;
			super();
		}
		public function getItemByKey(key:*):Object
		{
			return itemsByKey[key];
		}
		private var lastRandomItem:Object;
		public function getRandomItem(uniqueRandom:Boolean):Object
		{
			var i:int = (Math.floor(Math.random() * ((length-1) - 0 + 1)) + 0);
			
			while(uniqueRandom && lastRandomItem==this[i]) i = (Math.floor(Math.random() * ((length-1) - 0 + 1)) + 0);
			
			lastRandomItem = this[i];
			
			return lastRandomItem;
		}
		public function addAt(index:int):void
		{
			
		}
		public function add(item:Object):void
		{
			if(item && indexOf(item)<0)
			{
				push(item);
				for each(var key:* in itemRegistrationKeys)
				{
					itemsByKey[key] = item;
				}
				if(addHandler!=null) addHandler(length);
			}
		}
		public function remove(item:Object,i:int=-1):void
		{
			var i:int = i>=0 ? i: indexOf(item);
			if(i>=0)
			{
				splice(i,1);
				for each(var key:* in itemRegistrationKeys)
				{
					delete itemsByKey[key];
				}
				if(removeHandler!=null) removeHandler();
			}
		}
		public function toggle(item:Object):void
		{
			var i:int = indexOf(item);
			if(i<0) add(item);
			else remove(item,i);
		}
		public var addHandler:Function;
		public var removeHandler:Function;
		public var resetHandler:Function;
		public var itemUpdateHandler:Function;
		public function updateItem(value:Object,checkIfBelong:Boolean=true):void
		{
			if(!value) return;
			var i:int = indexOf(value);
			if(checkIfBelong && i<0) return;
			
			if(itemUpdateHandler!=null) itemUpdateHandler(i);
		}
		public function reset():void
		{
			length = 0;
			if(resetHandler!=null) resetHandler();
		}
	}
}