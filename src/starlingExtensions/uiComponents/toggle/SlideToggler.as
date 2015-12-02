package starlingExtensions.uiComponents.toggle
{
import flash.display.DisplayObjectContainer;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.text.TextField;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.utils.TouchUtils;
import starlingExtensions.utils.TweenUtils;

public class SlideToggler extends FlashSprite_Mirror
	{
		protected var viewPort:DisplayObject;
		protected var dataGroup:Sprite;
		
		public var reverse:Boolean = false;
		public var isSlider:Boolean = false;
		
		public function SlideToggler(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		override public function createChildren():void
		{
			super.createChildren();
			dataGroup = getChildByName("dataGroup") as Sprite;
			
			viewPort = getChildByName("viewPort");
			viewPort.visible = false;
			
			clipRect = viewPort.getBounds(this);
			
			on = true;
		}
		public function get onLabelField():TextField
		{
			return dataGroup.getChildByName("onLabelField") as TextField;
		}
		public function get offLabelField():TextField
		{
			return dataGroup.getChildByName("offLabelField") as TextField;
		}
		protected var _on:Boolean = false;
		public function set on(value:Boolean):void
		{
			_on = value;
			
			touchable = false;
			
			var properties:Object = {"x":_on ? 0 : -clipRect.width};
			
			var t:Tween = TweenUtils.add(dataGroup,properties,Transitions.EASE_IN,0.2,false);
			t.onComplete = onTransitionComplete;
			Starling.juggler.add(t);
		}
		public function get on():Boolean
		{
			return _on;
		}
		protected function onTransitionComplete():void
		{
			touchable = true;
		}
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			
			if(TouchUtils.clicked(this,e)) on = !_on;
		}
	}
}