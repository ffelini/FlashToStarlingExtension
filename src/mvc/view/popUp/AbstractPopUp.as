package mvc.view.popUp
{
import feathers.controls.Alert;

import feathersExtensions.popUp.FeathersVerticalPopUpManager;

public class AbstractPopUp extends Alert
	{
		public function AbstractPopUp()
		{
			super(); 
		}
		protected function close():void
		{
			FeathersVerticalPopUpManager.inst.close();
		}
	}
}