package starlingExtensions.flash
{
import flash.display.DisplayObjectContainer;
import flash.utils.setTimeout;

import managers.Handlers;

import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starlingExtensions.decorators.DecoratorManger;
import starlingExtensions.decorators.Decorator_Hint;
import starlingExtensions.interfaces.IDisplayTarget;
import starlingExtensions.interfaces.ITouchable;
import starlingExtensions.utils.TouchUtils;

public class FlashHint extends FlashSprite_Mirror implements IDisplayTarget
	{
		public function FlashHint(_mirror:DisplayObjectContainer, _rootMirror:FlashDisplay_Mirror)
		{
			super(_mirror, _rootMirror);
		}
		protected var _target:DisplayObject;
		public function set target(value:DisplayObject):void
		{		
			_target = value; 
			DecoratorManger.decorate(Decorator_Hint,this,_target!=null);
			
			if(_target) setTimeout(stage.addEventListener,100,TouchEvent.TOUCH,onStageTouch);
			else stage.removeEventListener(TouchEvent.TOUCH,onStageTouch);
			
			visible = _target ? _target.visible : false;
			
			Handlers.call(this,_target);
		}
		private function onStageTouch(e:TouchEvent):void
		{
			var st:Touch = e.getTouch(stage,TouchPhase.ENDED);
			var targetTouch:Touch = _target is ITouchable ? (_target as ITouchable).clicked(e) : TouchUtils.clicked(_target,e);
			if(st && !TouchUtils.clicked(this,e) && !targetTouch) target = null;
		}
		override public function get stage():Stage
		{
			return super.stage ? super.stage : (_target ? _target.stage : null);
		}
		public function get target():DisplayObject
		{
			return _target;
		}
	}
}