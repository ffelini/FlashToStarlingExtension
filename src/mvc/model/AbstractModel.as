package mvc.model
{
import managers.Handlers;

public class AbstractModel
	{
		public var debug:Boolean = true;
		
		public function AbstractModel()
		{
		}
		public function update(key:*):void
		{
			Handlers.call(update,key);
		}
		public function save(key:*,serverStore:Boolean):void
		{
			Handlers.call(save,key,serverStore);
		}
		public function reset(serverStore:Boolean,_save:Boolean=false):void
		{
			if(_save) save(this,serverStore);
		}
	}
}