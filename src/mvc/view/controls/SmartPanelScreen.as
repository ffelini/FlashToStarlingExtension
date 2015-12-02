package mvc.view.controls
{
import feathers.controls.PanelScreen;

import feathersExtensions.groups.SmartLayoutGroup;

public class SmartPanelScreen extends PanelScreen
	{
		public function SmartPanelScreen()
		{
			super();
			layout = SmartLayoutGroup.getVLayout(null,-1,0);
			clipContent = false;
		}
		public function get bodyHeight():Number
		{			
			trace("SmartPanelScreen.bodyHeight()",this,this.parent,_viewPort ? _viewPort.clipRect + "/"+_viewPort.height : null);
			
			/*if(_viewPort && _viewPort.clipRect) return _viewPort.clipRect.height;
			if(_viewPort) return _viewPort.height;*/
			
			var fhHeight:Number;
			var fhWidth:Number;
			
			fhHeight = header ? header.height : 0;
			fhHeight += footer ? footer.height : 0;
			return height - fhHeight;
		}
		public function get bodyWidth():Number
		{
			/*if(_viewPort && _viewPort.clipRect) return _viewPort.clipRect.width;
			if(_viewPort) return _viewPort.width;*/
			
			var fhHeight:Number;
			var fhWidth:Number;
			
			fhWidth = header ? header.width : 0;
			fhWidth += footer ? footer.width : 0;
			return width - fhWidth;
		}
	}
}