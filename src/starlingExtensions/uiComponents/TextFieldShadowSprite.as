package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;

import starling.core.RenderSupport;
import starling.text.TextField;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

public class TextFieldShadowSprite extends FlashSprite_Mirror
	{
		public function TextFieldShadowSprite(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		public var field:TextField;
		public var shadowField:TextField;
		override public function createChildren():void
		{
			super.createChildren();
			shadowField = getChildAt(0) as TextField;
			field = getChildAt(1) as TextField;
		}
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			if(field && shadowField) shadowField.text = field.text;
		}
		
	}
}