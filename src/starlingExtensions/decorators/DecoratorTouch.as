package starlingExtensions.decorators
{
import starling.display.DisplayObject;
import starling.events.TouchEvent;

public class DecoratorTouch extends Decorator
	{
		public function DecoratorTouch()
		{
			super();
		}
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value, _decorate, params);
			
			if(_decorated) (value as DisplayObject).addEventListener(TouchEvent.TOUCH,onTouch);
			else (value as DisplayObject).removeEventListener(TouchEvent.TOUCH,onTouch);
			
			return _decorated;
		}
		protected function onTouch(e:TouchEvent):void
		{
			var obj:DisplayObject = e.currentTarget as DisplayObject;
		}
	}
}