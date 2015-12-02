package starlingExtensions.decorators
{
import managers.Handlers;

import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.utils.TweenUtils;

public class Decorator_AnimationSequence extends Decorator
	{
		public function Decorator_AnimationSequence()
		{
			super();
		}
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value, _decorate, params);
			
			if(_decorate && value) nextTween(value);
			
			return _decorated;
		}
		protected function nextTween(value:Object):void
		{
			var objDecorationParams:Array = decorationParams[value];
			var objProps:Object = objDecorationParams ? objDecorationParams[0].shift() : null;
			var twenProps:Object = objDecorationParams ? objDecorationParams[1].shift() : null;
			
			if(!objProps) 
			{
				Handlers.functionCall(objDecorationParams[2]);
				decorate(value,false);
				return;
			}
			
			var t:Tween = TweenUtils.add(value as DisplayObject,objProps,twenProps["transition"],twenProps["duration"],
										twenProps["startDelay"]>0 ? true : false,true,true,twenProps["startDelay"],twenProps["repeat"],false);
			t.onComplete = nextTween;
			t.onCompleteArgs = [value];
			Starling.juggler.add(t);
		}
	}
}