package feathersExtensions.display
{
import feathers.display.Scale3Image;
import feathers.textures.Scale3Textures;

import starling.display.DisplayObject;

import starlingExtensions.interfaces.IClonable;

public class SmartScale3Image extends Scale3Image implements IClonable
	{
		public function SmartScale3Image(textures:Scale3Textures, textureScale:Number=1)
		{
			super(textures, textureScale);
			useSeparateBatch = false;
		}
		public function clone():DisplayObject
		{
			var c:SmartScale3Image = new SmartScale3Image(textures,textureScale);
			return c;
		}
	}
}