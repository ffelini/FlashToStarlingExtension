package feathersExtensions.controls.inputs
{
import feathers.controls.TextInput;

import starling.events.Event;

public class SmartTextInput extends TextInput
	{
		public function SmartTextInput()
		{
			super();
		}
		public var enterHandler:Function;
		override protected function textEditor_enterHandler(event:Event):void
		{
			super.textEditor_enterHandler(event);
			if(enterHandler!=null) enterHandler(this);
		}
	}
}