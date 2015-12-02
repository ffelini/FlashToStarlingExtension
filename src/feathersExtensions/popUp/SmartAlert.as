package feathersExtensions.popUp
{
import feathers.controls.Alert;
import feathers.core.PopUpManager;
import feathers.data.ListCollection;

import managers.Handlers;

import starling.display.DisplayObject;
import starling.events.Event;

public class SmartAlert extends Alert
	{
		public static const YES_DATA:Object = { label: "OK" };
		public static const NO_DATA:Object = { label: "CANCEL" };
		public static const YES_NO_COLLECTION:ListCollection = new ListCollection([YES_DATA,NO_DATA]);
		public static const YES_COLLECTION:ListCollection = new ListCollection([YES_DATA]);
		public static const NO_COLLECTION:ListCollection = new ListCollection([NO_DATA]);
		
		public var eventsHandler:Function;
		public var data:Object;
		
		public var content:DisplayObject;
		
		public function SmartAlert()
		{
			super();
		}
		public static function defaultAlertFactory():Alert
		{
			return new SmartAlert();
		}
		public function addContent(content:DisplayObject):void
		{
			this.content = content;
			if(this.content)
			{
				addChild(this.content);
				setSize(content.width+content.width*0.05,content.height + footer.height + header.height);
				content.height = height - footer.height - header.height - 30;
			}
		}
		public static function show(message:String, title:String = null, content:DisplayObject=null,buttons:ListCollection = null,
									 isModal:Boolean = true, isCentered:Boolean = true,
									 customAlertFactory:Function = null, data:Object=null,eventsHandler:Function=null):SmartAlert
		{
			customAlertFactory = customAlertFactory!=null ? customAlertFactory : defaultAlertFactory;
			
			var alert:SmartAlert = Alert.show(message,title,buttons,null,isModal,isCentered,customAlertFactory,null) as SmartAlert;
			alert.eventsHandler = eventsHandler;
			alert.data = data;
			alert.addContent(content);
			
			if(isCentered) PopUpManager.centerPopUp(alert);
			
			return alert;
		}
		override protected function buttonsFooter_triggeredHandler(event:Event, data:Object):void
		{
			if(content) content.removeFromParent();
			content = null;
			
			super.buttonsFooter_triggeredHandler(event, data);
			Handlers.functionCall(eventsHandler,this,data);
		}
	}
}