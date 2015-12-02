package feathersExtensions.controls
{
import feathers.controls.Button;

import feathersExtensions.utils.LayoutUtils;

import managers.interfaces.IStateReceiver;

public class StateList extends SmartList
	{
		public var stateReceiver:IStateReceiver;
		
		public function StateList(stateReceiver:IStateReceiver)
		{
			super();
			this.stateReceiver = stateReceiver;
			itemRendererProperties = {labelField:"name",horizontalAlign:Button.HORIZONTAL_ALIGN_CENTER,useStateDelayTimer:false};
			LayoutUtils.updateScrolling(this,false);
			clipContent = true;
		}
		override protected function onItemSelected():void
		{
			super.onItemSelected();
			if(selectedItem) stateReceiver.state = selectedItem;
		}
	}
}