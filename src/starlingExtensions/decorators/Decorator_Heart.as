package starlingExtensions.decorators
{
import flash.utils.Dictionary;

import managers.Handlers;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.utils.DisplayUtils;
import starlingExtensions.utils.TweenUtils;

import utils.TimeOut;

public class Decorator_Heart extends Decorator_Button
	{	
		public static const STATE_ZOOM_IN:String = "zoomIn";
		public static const STATE_ZOOM_OUT:String = "zoomOut";
		
		private var pulsesByTarget:Dictionary = new Dictionary();
		
		public function Decorator_Heart()
		{
			super();
			resizeWBy = resizeHBy = 0.1;
			selectionColor = 0xFFFFFF;
		}
		
		public static function makeObjectPulse(value:Object, _pulse:Boolean, pulseDelay:Number, pulses:int, pulseHanldler:Function):void {
			DecoratorManger.decorate(Decorator_Heart, value, _pulse, 500, pulseDelay, pulses, pulseHanldler);
		}
		
		override public function decorate(value:Object, _decorate:Boolean,params:Array=null):Boolean
		{
			var _do:DisplayObject = value as DisplayObject;
			var _decorated:Boolean = super.decorate(value,_decorate,params);			
			if(_decorate) updateZooming(_do,true);
			else
			{
				TweenUtils.removeTweens(_do);
				TimeOut.clearTimeOuts(updateZooming);
				DisplayUtils.setBounds(_do,originalRects[_do]);
			}
			return _decorated;
		}
		override protected function addListeners(add:Boolean, value:Object):void
		{
		}
		protected var duration:Number = 0.5;
		protected function updateZooming(_do:DisplayObject,up:Boolean):void
		{	
			zoomMode(_do,!up);
			var t:Tween = TweenUtils.add(_do,{"x":_do.x,"y":_do.y,"scaleX":_do.scaleX,"scaleY":_do.scaleY},up ? Transitions.EASE_IN : Transitions.EASE_OUT,duration,false);
			zoomMode(_do,up);
			t.onComplete = onZoomComplete;
			t.onCompleteArgs = [_do,!up];
			Starling.juggler.add(t);
		}
		private function onZoomComplete(_do:DisplayObject,up:Boolean):void
		{
			if(!decorated(_do) && up) 
			{
				Starling.juggler.removeTweens(_do);
				return;
			}
			
			if(up && decorationParams[_do]) {
				var pulses:int = pulsesByTarget[_do] ? pulsesByTarget[_do] : -1
				if(pulses<0) {
					pulses = 0;
				}
				pulses ++;
				var delay:Number = getDecorationParamAt(_do, 0, 0);
				var delayPulses:Number = getDecorationParamAt(_do, 0, 1);
				if(delay > 0 && pulses >= delayPulses) {
					TimeOut.setTimeOutFunc(updateZooming, delay, true, _do, up);
					pulses = 0;
				} else {
					updateZooming(_do,up);
				}
				pulsesByTarget[_do] = pulses;
			}
			else { 
				updateZooming(_do,up);
			}
			if(decorationParams[_do]) {
				var zoomStateHandler:Function = getDecorationParamAt(_do, 2, null);
				Handlers.functionCall(zoomStateHandler, up ? STATE_ZOOM_OUT : STATE_ZOOM_IN);
			}
		}
		
		
	}
}