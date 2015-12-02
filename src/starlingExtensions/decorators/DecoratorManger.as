package starlingExtensions.decorators
{
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class DecoratorManger
	{
		public function DecoratorManger()
		{
		}
		private static var decoratorsByClass:Dictionary = new Dictionary();
		public static function getDecorator(decoratorClass:Class):Decorator
		{
			var decorator:Decorator = decoratorsByClass[decoratorClass];
			if(!decorator) 
			{
				decorator = new decoratorClass();
				decoratorsByClass[decoratorClass] = decorator;
			}
			return decorator;
		}
		private static var decoratedObjects:Dictionary = new Dictionary();
		private static var decorationTimeOuts:Dictionary = new Dictionary();
		public static function decorate(decoratorClass:Class,obj:Object,_decorate:Boolean,delay:Number=0,...decoratorParams):Decorator
		{
			if(!decoratorClass || !obj) return null;
			
			var decorator:Decorator = getDecorator(decoratorClass);
			if(_decorate && decorator.decorated(obj) || !_decorate && !decorator.decorated(obj)) return decorator;
			
			if(_decorate && delay>0) decorationTimeOuts[obj] = setTimeout(decorator.decorate,delay,obj,_decorate,decoratorParams);
			else decorator.decorate(obj,_decorate,decoratorParams);
			
			if(_decorate) decoratedObjects[obj] = decoratorClass;
			else 
			{
				if(decorationTimeOuts[obj]) 
				{
					clearTimeout(decorationTimeOuts[obj]);
					decorationTimeOuts[obj];
				}
				delete decoratedObjects[obj];
			}
			
			return decorator;
		}
		public static function setDecoration(from:Object,to:Object):void
		{
			var decoratorClass:Class = decoratedObjects[from];
			if(!decoratorClass) return;
			decorate(decoratorClass,to,true);
		}
	}
}