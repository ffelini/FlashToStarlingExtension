package managers
{
import flash.utils.Dictionary;

public class Handlers
	{
		private static var handlersByKey:Dictionary = new Dictionary();
		private static var singleCallHandlers:Dictionary = new Dictionary();
		private static var parametersByHandler:Dictionary = new Dictionary();
		
		public function Handlers()
		{
		}
		public static function add(key:*,singleCall:Boolean,handler:Function,...parameters):void
		{
			if(!key || handler==null) return;
			
			var handlers:Vector.<Function> = getHandlers(key);
			if(handlers.indexOf(handler)<0) handlers.push(handler);
			if(singleCall) singleCallHandlers[handler] = handler;
			
			if(parameters && parameters.length>0) parametersByHandler[handler] = parameters;
		}
		public static function remove(key:*,handler:Function):void
		{
			if(!key || handler==null) return;
			
			var handlers:Vector.<Function> = getHandlers(key);
			var i:int = handlers ? handlers.indexOf(handler) : -1;
			if(i>=0) handlers.splice(i,1);
		}
		public static function removeByKey(key:*):void
		{
			if(!key) return;
			
			var handlers:Vector.<Function> = getHandlers(key);
			for each(var func:Function in handlers)
			{
				if(singleCallHandlers[func])
				{
					delete singleCallHandlers[func];
					delete parametersByHandler[func];
				}
			}
			if(handlers) handlers.length = 0;
		}
		private static function getHandlers(key:*):Vector.<Function>
		{
			var handlers:Vector.<Function> = handlersByKey[key];
			if(handlers) return handlers;
			
			handlers = new Vector.<Function>();
			handlersByKey[key] = handlers;
			return handlers;
		}
		public static function call(key:*,...parameters):void
		{
			var handlers:Vector.<Function> = getHandlers(key);
			var numHandlers:int = handlers.length;
			var func:Function;
			for(var i:int=numHandlers-1;i>=0;i--)
			{
				func = handlers[i];
				
				var functionCallParams:Array = parametersByHandler[func] ? parametersByHandler[func] : parameters;
				functionCallParams = [func].concat(functionCallParams);
				
				functionCall.apply(null,functionCallParams);
				
				if(singleCallHandlers[func])
				{
					delete singleCallHandlers[func];
					delete parametersByHandler[func];
					handlers.splice(i,1);
				}
			}
		}
		public static function functionCall(func:Function,...parameters):*
		{
			if(func==null) return;
			
			var params:Array = parameters.splice(0,func.length);
			if(params.length<func.length) params[func.length-1] = null;
			
			return func.apply(null,params);
		}
	}
}