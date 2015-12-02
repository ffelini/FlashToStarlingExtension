package starlingExtensions.decorators
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import managers.Handlers;
import managers.sound.ManagerSound;

import starling.display.BlendMode;
import starling.display.Button;
import starling.display.DisplayObject;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starlingExtensions.animation.TweenExtension;
import starlingExtensions.utils.DisplayUtils;

import utils.ObjUtil;

public class Decorator_Button extends Decorator
	{
		protected var originalRects:Dictionary = new Dictionary();
		protected var originalColors:Dictionary = new Dictionary();
		
		public function Decorator_Button()
		{
			super();
		}
		private static var downImagesByObj:Dictionary = new Dictionary();
		public static function makeSelectionLighter(obj:DisplayObject,rootObj:DisplayObject,down:Boolean, selectionAlpha=0.9):void
		{
			var cloneObj:DisplayObject = downImagesByObj[obj];
			if(down) {
				if(!cloneObj) {
					cloneObj = DisplayUtils.cloneDO(obj);
					cloneObj.blendMode = BlendMode.SCREEN;
					cloneObj.alpha = selectionAlpha;
					obj.parent.addChildAt(cloneObj, obj.parent.getChildIndex(obj)+1);
					downImagesByObj[obj] = cloneObj;
				}
			}
			
			if(cloneObj) {
				cloneObj.visible = down;
			}
		}
		
		public static function decorateInstance(instance:Object, _decorate:Boolean, selectionColor:uint, resizeWBy:Number, resizeHBy:Number, 
												onSelectionUpdate:Function=null, sound:*=null):void {
			DecoratorManger.decorate(Decorator_Button, instance, _decorate, 0, 
				null, null, null, selectionColor, resizeWBy, resizeHBy, onSelectionUpdate, sound, 0.9);
		}
		override public function decorate(value:Object,_decorate:Boolean,params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value,_decorate,params);			
			
			if(_decorate) 
			{
				originalRects[value] = (value as DisplayObject).getBounds((value as DisplayObject).parent,originalRects[value]);
			}
			else delete originalColors[value];
			
			value.touchable = _decorate;
			addListeners(_decorated,value);
			return _decorated;
		}
		protected function addListeners(add:Boolean,value:Object):void
		{
			value.removeEventListener(TouchEvent.TOUCH,onTouch);
			if(add) value.addEventListener(TouchEvent.TOUCH,onTouch);
		}
		private var selections:Dictionary;
		public function setSelected(obj:DisplayObject,value:Boolean):void
		{
			if(!selections) selections = new Dictionary();
			if(value) selections[obj] = obj;
			else delete selections[obj];
		}
		public function getSelected(obj:DisplayObject):Boolean
		{
			return selections[obj];
		}
		private function onTouch(e:TouchEvent):void
		{
			var obj:DisplayObject = e.currentTarget as DisplayObject;
			if(e.getTouch(obj,TouchPhase.BEGAN)) 
			{
				updateState(obj,true);
				if(!ObjUtil.isExtensionOf(e.currentTarget,Button)) updateSelection(e.target as DisplayObject,obj,true);
			}
			if(e.getTouch(obj,TouchPhase.ENDED))
			{
				updateState(obj,false);
				if(!ObjUtil.isExtensionOf(e.currentTarget,Button)) updateSelection(e.target as DisplayObject,obj,false);
			}
		}
		protected function updateState(obj:DisplayObject,down:Boolean):void
		{
			if(down) TweenExtension.updateTweens(obj,!down);
			
			//alphaMode(obj,down);
			zoomMode(obj,down && zoomOutTouch);
			
			if(!down) TweenExtension.updateTweens(obj,!down);
		}
		protected function alphaMode(obj:DisplayObject,down:Boolean):void
		{
			obj.alpha = down ? 0.7 : 1;
		}
		protected var resizeWBy:Number = 0.1; 
		protected var resizeHBy:Number = 0.1;
		protected var zoomOutTouch:Boolean = true; 
		protected function zoomMode(obj:DisplayObject,down:Boolean):void
		{
			var wBy:Number = getDecorationParamAt(obj,4, resizeWBy);
			var hBy:Number = getDecorationParamAt(obj,5, resizeHBy);
			var rect:Rectangle = originalRects[obj];
			var wDif:Number = Math.round(rect.width*wBy);
			var hDif:Number = Math.round(rect.height*hBy);
			
			obj.scaleX += down ? -wBy : wBy;
			obj.scaleY += down ? -hBy : hBy;
			
			if(obj.pivotX==0 && obj.pivotY==0) {				
				obj.x += down ? wDif/2 : -wDif/2;
				obj.y += down ? hDif/2 : -hDif/2;
			}
			
		}
		protected var selectionColor:uint = 0x666666;
		protected function updateSelection(obj:DisplayObject,rootObj:DisplayObject,down:Boolean):void
		{
			var _selectionColor:uint = getDecorationParamAt(rootObj, 3, selectionColor);
				
			if(obj && obj.hasOwnProperty("color")) 
			{
				if(down && !originalColors[obj]) originalColors[obj] = obj["color"];
				obj["color"] = down ? _selectionColor : (originalColors[obj] ? originalColors[obj] : 0xFFFFFF);
				var onSelectionUpdate:Function = getDecorationParamAt(rootObj, 6, null);
				var selectionAlpha:Number = getDecorationParamAt(rootObj, 8, 0.9);
				Handlers.functionCall(onSelectionUpdate, obj, rootObj, down, selectionAlpha);
				
				if(down && getDecorationParamAt(rootObj, 7, null)) {
					ManagerSound.playSound(getDecorationParamAt(rootObj, 7, null));
				}
			}
		}
	}
}