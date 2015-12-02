package feathersExtensions.display
{
import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import starling.display.DisplayObject;

import starlingExtensions.interfaces.IClonable;

public class SmartScale9Image extends Scale9Image implements IClonable
	{
		public function SmartScale9Image(textures:Scale9Textures, textureScale:Number=1)
		{
			super(textures, textureScale);
			useSeparateBatch = false;
		}
		public function clone():DisplayObject
		{
			var c:SmartScale9Image = new SmartScale9Image(textures,textureScale);
			return c;
		}
	}
}