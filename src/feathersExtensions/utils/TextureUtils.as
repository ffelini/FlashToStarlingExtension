package feathersExtensions.utils
{
import feathers.textures.Scale3Textures;
import feathers.textures.Scale9Textures;

import flash.display.BitmapData;
import flash.display.PNGEncoderOptions;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

import starling.textures.ConcreteTexture;
import starling.textures.Texture;

import starlingExtensions.flash.textureAtlas.ConcreteTexture_Dynamic;
import starlingExtensions.flash.textureAtlas.TextureAtlas_Dynamic;

import utils.log;

public class TextureUtils
	{
		public function TextureUtils()
		{
		}
		public static function scale3Textures(texture:Texture, direction:String="horizontal"):Scale3Textures
		{
			return new Scale3Textures(texture,texture.width/4,texture.width/2,direction);
		}
		public static function scale9Textures(texture:Texture):Scale9Textures
		{
			var rect:Rectangle = new Rectangle(texture.width/4,texture.width/4,texture.width/4,texture.width/4);
			return new Scale9Textures(texture,rect);
		}
		public static function getAtlas(texture:Texture,atlas:TextureAtlasAbstract):TextureAtlas_Dynamic
		{
			return new TextureAtlas_Dynamic(texture,atlas);
		}
		public static function textureFromBmd(atlasBmd:BitmapData,textureScale:Number,onRestore:Function=null):ConcreteTexture_Dynamic
		{
			var t:Texture = TextureAtlas_Dynamic.getAtlasTexture(atlasBmd,textureScale);
			if(t is ConcreteTexture) (t as ConcreteTexture).onRestore = onRestore;
			
			return new ConcreteTexture_Dynamic(t.base,t.format,t.width,t.height,t.mipMapping,t.premultipliedAlpha,false,t.scale);
		}
		public static function saveAtlasPng(path:String,atlasBmd:BitmapData):void
		{
			var t1:int = getTimer();
			var t2:int = getTimer();
			
			var fr:File = File.desktopDirectory.resolvePath(path);
			
			log(TextureUtils,"saveAtlasPng-File.desktopDirectory.resolvePath duratio-"+(getTimer() - t2));
			
			t2 = getTimer();
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(fr,FileMode.WRITE);
			
			log(TextureUtils,"saveAtlasPng-FileStream.openAsync duration-"+(getTimer() - t2));
			
			t2 = getTimer();
			
			var ba:ByteArray = atlasBmd.encode(atlasBmd.rect,new PNGEncoderOptions(true),ba);
			
			log(TextureUtils,"saveAtlasPng-PNGEncoder.encode duration-"+(getTimer() - t2));
			
			outputStream.writeBytes(ba);
			
			t2 = getTimer();
			
			log(TextureUtils,"saveAtlasPng-FileStream.wirteBytes-",(getTimer() - t2));
			
			outputStream.close();
			
			log(TextureUtils,"saveAtlasPng-Saving atlas to file duration-"+(getTimer() - t1));	
		}
	}
}