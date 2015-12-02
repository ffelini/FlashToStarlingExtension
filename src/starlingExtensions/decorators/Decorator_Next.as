package starlingExtensions.decorators
{
	public class Decorator_Next extends Decorator
	{
		public function Decorator_Next()
		{
			super();
		}
		override public function decorate(value:Object, _decorate:Boolean,params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value,_decorate,params);
			
			return _decorated;
		}
	}
}