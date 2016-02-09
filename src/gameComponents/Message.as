package gameComponents
{
import flash.utils.setTimeout;

import managers.Handlers;

import starling.core.starling_internal;
import starling.events.EventDispatcher;

use namespace starling_internal;

	public class Message extends EventDispatcher
	{
		public static const DISPLAY_GAME_CONFIG_TOOL:String = "displayGameConfigTool";
		public static const DISPLAY_GAME_LOGS:String = "displayGameLogs";

		public static const SAVE_GAME_CONFIG:String = "saveGameConfig";

		public static const ON_BACK_PRESSED:String = "onBackPressed";

		public static const NEXT_LOCATION:String = "nextLocation";
		public static const FORWARD_LOCATION:String = "forwardLocation";
		
		public static const OPEN_GLOBAL_MAP:String = "openGlobalMap";
		public static const OPEN_LOCAL_MAP:String = "openLocalMap";
		public static const OPEN_INBOX:String = "openInbox";
		
		public static const TOUCH_LEVEL:String = "touchLevel";
		
		public static const INVITE_FRIENDS:String = "inviteFriends";
		
		public static const PLAY_LEVEL:String = "playLevel";
		public static const PLAY_LEVEL_GAME_PLAY:String = "playLevelGamePlay";
		
		public static const GO_TO_MAP:String = "backToMap";
		
		public static const EXIT:String = "exit";
		public static const GIVE_UP:String = "give_up";
		
		public static const FACEBOOK_SESSION:String = "faceBookSession";
		
		public static const LOADING:String = "loading";
		
		public static const SEND_LIFE:String = "sendLife";
		
		public static const OUT_OF_LIFES:String = "outOfLifes";
		
		public static const MAP_UPDATE:String = "mapUpdate";
		
		public static const SOUND_UPDATE:String = "soundUpdate";
		public static const MUCIS_UPDATE:String = "musicUpdate";
		
		public static const BUY_PRODUCT:String = "buyProduct";
		public static const BUY_PRODUCT_TRY:String = "buyProductTry";
		public static const PURCHASE_PRODUCT:String = "purchaseProduct";
		
		public static const USE_PRODUCT:String = "useProduct";
		
		public static const MOTIVATE_FOR_RATING_PASS:String = "motivateForRatingPass";
		public static const MOTIVATE_FOR_LIKE_US:String = "motivateForLikeUs";
		
		public static const UNLOCK_NEXT_LOCATION:String = "unlockNextLocation";
		public static const UNLOCK_NEXT_LOCATION_TRY:String = "unlockNextLocationTry";
		
		public static const PAUSE_GAMEPLAY:String = "pauseGamePlay";
		public static const RESUME_GAMEPLAY:String = "resumeGamePlay";
		
		public static const ALERT:String = "alert";
		
		public function Message()
		{
			super();
			_inst = this;
		}
		
		public static function message(eventType:String, delay:Number=0, ...parameters):void
		{
			if(delay==0) Handlers.call(Message,eventType,parameters);
			else
			{	
				setTimeout(function():void
				{
					Handlers.call(Message,eventType,parameters);
				},delay);
			}
		}
		protected static var _inst:Message;
		public static function get inst():Message
		{
			if(_inst) return _inst;
			
			_inst = new Message();
			return _inst;
		}
	}
}