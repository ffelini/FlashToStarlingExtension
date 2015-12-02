package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;

import starling.display.DisplayObject;

import starlingExtensions.decorators.DecoratorManger;
import starlingExtensions.decorators.Decorator_DropShadow;
import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

public class ShadowSprite extends FlashSprite_Mirror
	{
		public function ShadowSprite(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		protected var skin:SmartImage;
		override public function createChildren():void
		{
			super.createChildren();
			skin = getChildAt(0) as SmartImage;
		}
		protected var _shadowSize:Number = 1;
		public function set shadowSize(value:Number):void
		{
			_shadowSize = value;
			if(!created) return;
			DecoratorManger.decorate(Decorator_DropShadow,skin,true,0,_shadowColor,_shadowSize,_shadowDistance,_shadowAngle);
		}
		public function get shadowSize():Number
		{
			return _shadowSize;
		}
		protected var _shadowDistance:Number = 0;
		public function set shadowDistance(value:Number):void
		{
			_shadowDistance = value;
			if(!created) return;
			DecoratorManger.decorate(Decorator_DropShadow,skin,true,0,_shadowColor,_shadowSize,_shadowDistance,_shadowAngle);
		}
		public function get shadowDistance():Number
		{
			return _shadowDistance;
		}
		protected var _shadowAngle:Number = 0;
		public function set shadowAngle(value:Number):void
		{
			_shadowAngle = value;
			if(!created) return;
			DecoratorManger.decorate(Decorator_DropShadow,skin,true,0,_shadowColor,_shadowSize,_shadowDistance,_shadowAngle);
		}
		public function get shadowAngle():Number
		{
			return _shadowAngle;
		}
		protected var _shadowColor:uint = 0xFFFFFF;
		public function set shadowColor(value:uint):void
		{
			_shadowColor = value;
			if(!created) return;
			DecoratorManger.decorate(Decorator_DropShadow,skin,true,0,_shadowColor,_shadowSize,_shadowDistance,_shadowAngle);
		}
		public function get shadowColor():uint
		{
			return _shadowColor;
		}
		override public function clone():DisplayObject
		{
			var c:ShadowSprite = new ShadowSprite(mirror,rootMirror);
			return c;
		}
	}
}