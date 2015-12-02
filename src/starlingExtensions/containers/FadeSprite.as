package starlingExtensions.containers
{
import flash.display.DisplayObjectContainer;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

public class FadeSprite extends FlashSprite_Mirror
	{
		public function FadeSprite(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		private var isShowing:Boolean = false;
		private var alphaStep:Number = 0.05;
		public function show(_alphaStep:Number=0.05):void
		{
			alphaStep = _alphaStep;
			alpha = 0;
			isShowing = visible = true;
			fadeInComplete = false;
		}
		public function hide(_alphaStep:Number=0.05):void
		{
			alphaStep = _alphaStep;
			alpha = 1;
			isShowing = touchable = fadeOutComplete = false;
		}
		override public function get hasVisibleArea():Boolean
		{
			var has:Boolean = super.hasVisibleArea;
			
			if(has)
			{
				if(isShowing)
				{
					if(!fadeInComplete)
					{
						if(alpha<1) alpha += alphaStep;
						else 
						{
							touchable = true;
							onFadedInComplete();
						}
					}
				}
				else if(!fadeOutComplete);
				{
					if(alpha>0) alpha -= alphaStep;
					else 
					{
						visible = false;
						onFadeOutComplete();
					}
				}
			}
			return has;
		}
		private var fadeOutComplete:Boolean = false;
		protected function onFadeOutComplete():void
		{
			fadeOutComplete = true;
		}
		private var fadeInComplete:Boolean = false;
		protected function onFadedInComplete():void
		{
			fadeInComplete = true;
		}
	}
}