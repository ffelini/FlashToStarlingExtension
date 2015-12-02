package feathersExtensions.popUp
{
import feathers.controls.popups.DropDownPopUpContentManager;

import managers.Handlers;
import managers.ObjPool;

import starling.display.DisplayObject;

public class FeathersDropDownPopUpManager extends DropDownPopUpContentManager
	{
		public function FeathersDropDownPopUpManager()
		{
			super();
		}
		private static var _inst:FeathersDropDownPopUpManager;
		public static function get inst():FeathersDropDownPopUpManager
		{
			if(!_inst) _inst = new FeathersDropDownPopUpManager();
			return _inst;
		}
		public function openPopup(contentClass:Class,w:Number,h:Number,closeHandler:Function=null):DisplayObject
		{
			var inst:DisplayObject = ObjPool.inst.get(contentClass) as DisplayObject;
			inst.width = w;
			inst.height = h;
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