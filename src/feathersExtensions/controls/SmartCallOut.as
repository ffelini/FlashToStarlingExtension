package feathersExtensions.controls
{
import feathers.controls.Callout;

import starling.events.Event;
import starling.events.TouchEvent;

public class SmartCallOut extends Callout
	{
		public function SmartCallOut()
		{
			super();
		}
		override protected function callout_addedToStageHandler(event:Event):void
		{
			super.callout_addedToStageHandler(event);
			this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		}
	}
}