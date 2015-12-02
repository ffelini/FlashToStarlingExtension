package starlingExtensions.decorators
{
import flash.utils.Dictionary;

public class Decorator
	{
		public var enableMultipleDecoration:Boolean = false;
		
		public function Decorator()
		{
		}
		protected var objects:Vector.<Object> = new Vector.<Object>();
		protected var decorationParams:Dictionary = new Dictionary();
		public function decorate(value:Object,_decorate:Boolean,params:Array=null):Boolean
		{
			var i:int = objects.indexOf(value);
			
			if(_decorate)
			{
				if(i<0) objects.push(value);
				if(params) decorationParams[value] = params;
				return i<0 || enableMultipleDecoration;
			}
			else
			{
				if(i>=0) objects.splice(i,1);
				delete decorationParams[value];
				return i>=0;
			}
			return false
		}
		
		public function getDecorationParamAt(obj:Object, position:int,defaultValue:*):* {
			return decorationParams[obj]!=null && decorationParams[obj][position]!=null ? decorationParams[obj][position] : defaultValue;
		}
		
		public function decorated(value:Object):Boolean
		{
			return objects.indexOf(value)>=0;
		}
	}
}