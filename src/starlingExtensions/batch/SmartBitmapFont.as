package starlingExtensions.batch
{
import flash.display.BitmapData;

import starling.text.BitmapFont;
import starling.textures.Texture;

public class SmartBitmapFont extends BitmapFont
	{
		protected var bmdClass:Class;
		
		public function SmartBitmapFont(fontBmpClass:Class, fontXml:XML=null)
		{
			bmdClass = fontBmpClass;
			
			var fontBmd:BitmapData = BitmapData(new bmdClass());
			var texture:Texture = Texture.fromBitmapData(fontBmd,false);
			
			texture.root.onRestore = function():void
			{
				fontBmd = BitmapData(new bmdClass());
				texture.root.uploadBitmapData(fontBmd);
				fontBmd.dispose();
			}
			
			fontBmd.dispose();
			
			super(texture, fontXml);
		}
	}
}