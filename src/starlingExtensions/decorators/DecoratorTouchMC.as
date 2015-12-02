package starlingExtensions.decorators
{
import starling.events.Touch;
import starling.events.TouchEvent;

import starlingExtensions.flash.animation.FlashMovieClip_Mirror;
import starlingExtensions.utils.TouchUtils;

import utils.Utils;

public class DecoratorTouchMC extends DecoratorTouch
	{
		public function DecoratorTouchMC()
		{
			super();
		}
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			if(!value || !(value is FlashMovieClip_Mirror)) return false;  
			return super.decorate(value, _decorate, params);
		}
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			var mc:FlashMovieClip_Mirror = e.currentTarget as FlashMovieClip_Mirror;
			var touch:Touch = TouchUtils.clicked(mc,e);
			
			if(touch) 
			{
				if(decorationParams[mc]) mc.gotoAndPlay(decorationParams[mc][0]);
				else mc.gotoAndPlay(Utils.randRange(mc.currentFrame,mc.numFrames));
			}
		}
	}
}