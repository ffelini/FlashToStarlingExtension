package starlingExtensions.decorators
{
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.events.Event;

import starlingExtensions.interfaces.IDisplayTarget;
import starlingExtensions.interfaces.IUpdatable;

public class Decorator_Hint extends Decorator
	{
		public function Decorator_Hint()
		{
			super();
		}
		override public function decorate(value:Object, _decorate:Boolean,params:Array=null):Boolean
		{
			if(!(value is IDisplayTarget)) return false;
			var _decorated:Boolean = super.decorate(value, _decorate,params);
			
			if(_decorate) 
			{
				(value as DisplayObject).removeEventListener(Event.ENTER_FRAME,onTargetFrame);
				(value as DisplayObject).addEventListener(Event.ENTER_FRAME,onTargetFrame);
			}
			else
			{
				(value as DisplayObject).removeEventListener(Event.ENTER_FRAME,onTargetFrame);
				(value as DisplayObject).visible = false;
			}
			return _decorated;
		}
		private var targetRect:Rectangle;
		private var targetStageRect:Rectangle;
		private function onTargetFrame(e:Event):void
		{
			var hint:DisplayObject = e.target as DisplayObject;
			var target:DisplayObject = (e.target as IDisplayTarget).target;
			hint.visible = target.visible;
			
			if(!hint.visible || !hint.parent || !target.parent) return;
			
			targetRect = target.getBounds(hint.parent,targetRect);
			var hintRect:Rectangle = hint.getBounds(hint.parent);
			targetStageRect = target.getBounds(target.stage,targetStageRect);
			
			hint.visible = true;
			
			var horizontal:int = targetStageRect.x+targetStageRect.width<target.stage.stageWidth/2 ? -1 : 1;
			var vertical:int = targetStageRect.y+targetStageRect.height<target.stage.stageHeight/2 ? -1 : 1;
			
			hint.x = vertical==0 ? (horizontal==-1 ? targetRect.x-hintRect.width : targetRect.x+targetRect.width) : targetRect.x + targetRect.width/2;
			hint.y = horizontal==0 ? (vertical==-1 ? targetRect.y-hintRect.height : targetRect.y+target.height) : targetRect.y + targetRect.height/2;
			
			hintRect = hint.getBounds(hint.stage);
			
			if(hintRect.x<0) hint.x = hint.parent.globalToLocal(new Point(hintRect.width/2,0)).x;
			if(hintRect.x>hint.stage.stageWidth-hintRect.width) hint.x = hint.parent.globalToLocal(new Point(hint.stage.stageWidth-hintRect.width/2,0)).x;
			
			if(hint is IUpdatable) (hint as IUpdatable).update(targetRect,hintRect,targetStageRect);
		}
	}
}