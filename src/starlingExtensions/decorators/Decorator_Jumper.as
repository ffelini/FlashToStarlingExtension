package starlingExtensions.decorators
{
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.display.DisplayObject;

import starlingExtensions.utils.TweenUtils;

public class Decorator_Jumper extends Decorator
	{
		public function Decorator_Jumper()
		{
			super();
		}
		protected var defaultValues:Dictionary = new Dictionary();
		override public function decorate(value:Object, _decorate:Boolean,params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value, _decorate,params);
			
			if(_decorate)
			{
				defaultValues[value] = value.y;
				jump(value as DisplayObject,params && !isNaN(params[1]) ? params[1] : 0);
			}
			else
			{
				TweenUtils.removeTweens(value);
				value.y = defaultValues[value];
			}
			
			return _decorated;
		}
		private var delay:Number = 1500;
		protected function jump(obj:DisplayObject,_delay:Number=0):void
		{
			if(!decorated(obj)) return;
			if(_delay>0) 
			{
				setTimeout(jump,_delay,obj,0);
				return;
			}
			var dist:Number = decorationParams[obj] && !isNaN(decorationParams[obj][0]) ? decorationParams[obj][0] : 60;
			var t:Tween = TweenUtils.add(obj,{"y":obj.y-dist},Transitions.EASE_OUT,0.3,false);
			t.onComplete = onUpComplete;
			t.onCompleteArgs = [obj];
			TweenUtils.play(t);
		}
		protected function onUpComplete(obj:DisplayObject):void
		{
			var dist:Number = decorationParams[obj] && !isNaN(decorationParams[obj][0]) ? decorationParams[obj][0] : 60;
			var t:Tween = TweenUtils.add(obj,{"y":obj.y+dist},Transitions.EASE_OUT_BOUNCE,0.8,false);
			t.onComplete = jump;
			t.onCompleteArgs = [obj,delay];
			TweenUtils.play(t);
		}
		
	}
}