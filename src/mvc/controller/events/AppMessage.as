package mvc.controller.events
{
import managers.Handlers;

import starling.core.starling_internal;
import starling.events.EventDispatcher;

use namespace starling_internal;

	public class AppMessage extends EventDispatcher
	{
		public static const LOG_IN_WITH_FACEBOOK:String = "logInWithFB";
		public static const LOG_IN:String = "logIn";
		public static const LOG_OUT:String = "logOut";
		public static const LOGED_IN:String = "logedIn";
		public static const LOGED_OUT:String = "logedOut";
		
		public static const KEY_BACK:String = "keyBack";
		public static const UPDATE_STATE:String = "updateState";
		
		/**
		 * params[0] view object
		 * params[1] view data 
		 */		
		public static const VIEW_OPEN:String = "viewOpen";
		public static const VIEW_OPENED:String = "viewOPENED";
		
		public static const POPUP_OPEN:String = "popupOpen";
		
		public function AppMessage()
		{
			super();
			_inst = this;
		}
		
		public static function message(eventType:String, ...parameters):void
		{
			Handlers.call(AppMessage,eventType,parameters);
		}
		protected static var _inst:AppMessage;
		public static function get inst():AppMessage
		{
			if(_inst) return _inst;
			
			_inst = new AppMessage();
			return _inst;
		}
	}
}