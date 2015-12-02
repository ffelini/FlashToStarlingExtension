package managers
{
import flash.utils.Dictionary;

public class DataManager extends Dictionary
	{
		public function DataManager()
		{
		}
		private static var _inst:DataManager;
		public static function get inst():DataManager
		{
			if(_inst) return _inst;
			_inst = new DataManager();
			
			return _inst;
		}
		public function setCurentData(dataHolder:Object,value:Object):void
		{
			if(!dataHolder) return;
			this[dataHolder] = value;
		}
		public function getCurentData(dataHolder:Object):Object
		{
			return this[dataHolder];
		}
	}
}