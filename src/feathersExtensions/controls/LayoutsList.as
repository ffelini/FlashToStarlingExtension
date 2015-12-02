package feathersExtensions.controls
{
import feathers.core.FeathersControl;

import feathersExtensions.renderers.IconIR;

public class LayoutsList extends SmartList
	{
		public var layoutReceiver:FeathersControl;
		
		public function LayoutsList()
		{
			super();
			itemRendererType = IconIR;
		}
		override protected function onItemSelected():void
		{
			super.onItemSelected();
			
			if(layoutReceiver && layoutReceiver.hasOwnProperty("layout")) layoutReceiver["layout"] = selectedItem;
		}
	}
}