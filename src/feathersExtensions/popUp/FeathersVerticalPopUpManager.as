package feathersExtensions.popUp
{
import feathers.controls.popups.VerticalCenteredPopUpContentManager;
import feathers.core.FeathersControl;

import managers.Handlers;
import managers.ObjPool;

import starling.display.DisplayObject;

public class FeathersVerticalPopUpManager extends VerticalCenteredPopUpContentManager
	{
		public function FeathersVerticalPopUpManager()
		{
			super();
		}
		private static var _inst:FeathersVerticalPopUpManager;
		public static function get inst():FeathersVerticalPopUpManager
		{
			if(!_inst) _inst = new FeathersVerticalPopUpManager();
			return _inst;
		}
		public function openPopup(contentClass:Class,w:Number,h:Number,closeHandler:Function=null):DisplayObject
		{
			var inst:DisplayObject = ObjPool.inst.get(contentClass) as DisplayObject;
			if(inst is FeathersControl) (inst as FeathersControl).setSize(w,h);
			else
			{
				inst.width = w;
				inst.height = h;
			}
			open(inst,null);
			
			Handlers.add(inst,true,closeHandler);
			
			return inst;
		}
		override public function close():void
		{
			ObjPool.inst.add(content,null);
			Handlers.call(content);
			
			super.close();
		}
		public function get curentPopUp():DisplayObject
		{
			return content;
		}
	}
}