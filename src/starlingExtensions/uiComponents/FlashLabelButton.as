package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;

import starling.display.DisplayObject;
import starling.text.TextField;

import starlingExtensions.decorators.DecoratorManger;
import starlingExtensions.decorators.Decorator_Button;
import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IClonable;

public class FlashLabelButton extends FlashSprite_Mirror implements IClonable
	{
		public var btn:DisplayObject;
		public var labelField:TextField;
		
		public function FlashLabelButton(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		override public function createChildren():void
		{
			super.createChildren();
			labelField = getChildByName("labelField") as TextField;
			btn = getChildByName("btn");
			
			btnColor = _btnColor;
			
			enabled = true;
		}
		protected var _btnColor:uint=0;
		public function set btnColor(value:uint):void
		{
			_btnColor = value;
			if(btn) processChildColor(btn,-1,value);
		}
		public function get btnColor():uint
		{
			return _btnColor;
		}
		protected var _label:String;
		public function set label(value:String):void
		{
			_label = value;
			if(!labelField) return;
			
			labelField.text = value;	
		}
		public function get label():String
		{
			return _label;
		}
		public function set enabled(value:Boolean):void
		{
			touchable = value;
			DecoratorManger.decorate(Decorator_Button,this,value);
			alpha = value ? 1 : 0.5;
		}
		public function get enabled():Boolean
		{
			return touchable;
		}
		override public function clone():DisplayObject
		{
			var c:FlashLabelButton = new FlashLabelButton(mirror,rootMirror);			
			c.label = _label;
			c.enabled = enabled;
			c._created = _created;
			return c;
		}
	}
}