package feathersExtensions.controls
{
import feathers.controls.Radio;
import feathers.core.ToggleGroup;

import mvc.view.components.AbstractLayoutGroup;

public class FeathersRadioGroup extends AbstractLayoutGroup
	{
		public var group:ToggleGroup = new ToggleGroup();
		
		protected var radios:Array = [];
		
		public var labelField
		
		public function FeathersRadioGroup()
		{
			super();
		}
		public function set dataProvider(value:*):void
		{
			removeChildren();
			
			var i:int = 0;
			for each(var obj:Object in value)
			{
				var r:Radio = radios[i] ? radios[i] : new Radio();
				
				r.toggleGroup = group;
				radios[i] = r;
				i++;
			}
		}
	}
}