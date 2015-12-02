package starlingExtensions.uiComponents
{
import flash.system.Capabilities;

import starling.display.DisplayObject;
import starling.textures.Texture;

import starlingExtensions.textureutils.Textures;

public class FacebookImage extends Image_Remote
	{
		public static var FB_IMG_WIDTH:Number = Capabilities.screenDPI > 150 ? 64 : 42;
		public static var FB_IMG_HEIGHT:Number = Capabilities.screenDPI > 150 ? 64 : 42;
		
		public function FacebookImage()
		{
			super();
		}
		public static var ERROR_TEXTURE_FLASH_CLASS:Class;
		private static var _ERROR_TEXTURE:Texture;
		public static function get ERROR_TEXTURE():Texture
		{
			if(!_ERROR_TEXTURE) _ERROR_TEXTURE = Textures.fromDOClass(ERROR_TEXTURE_FLASH_CLASS);
			return _ERROR_TEXTURE;
		}
		override protected function updateResultTexture(t:Texture):void
		{
			if(!t) errorTexture = ERROR_TEXTURE;
			super.updateResultTexture(t);
		}
		protected var uid:String;
		public function set userID(value:String):void
		{
			uid = value;
			url = userProfilePictureUrl(uid,FB_IMG_WIDTH,FB_IMG_HEIGHT);
		}
		public function get userID():String
		{
			return uid;
		}
		public function set data(value:Object):void
		{
			uid = (value.hasOwnProperty("uid") ? value.uid : (value.hasOwnProperty("id") ? value.id : (value.hasOwnProperty("userId") ? value.userId : "")))+"";
			url = userProfilePictureUrl(uid,FB_IMG_WIDTH,FB_IMG_HEIGHT);
		}
		override public function clone():DisplayObject
		{
			var c:FacebookImage = new FacebookImage();
			c.errorTexture = errorTexture;
			return c;
		}
		public static var uidValidationFunc:Function;
		public static function userProfilePictureUrl(uid:String,w:Number=64,h:Number=64):String
		{
			if(uidValidationFunc!=null) uid = String(uidValidationFunc(uid));			
			return 'http://graph.facebook.com/' + uid + '/picture?width='+w+'&height='+h;
		}
	}
}