package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;

import starling.events.TouchEvent;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

public class Wheel extends FlashSprite_Mirror
	{
		public function Wheel(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		override public function createChildren():void
		{
			super.createChildren();
		}
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			
			
		}
	}
}