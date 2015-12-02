package starlingExtensions.flash.textureAtlas
{
import flash.display.DisplayObject;

import starling.textures.Texture;

public class ManagerAtlas_Dynamic
	{
		public function ManagerAtlas_Dynamic()
		{
			
		}
		private static var instances:Vector.<FlashAtlas_Dynamic>;
		private static function getAtlas(obj:Object):FlashAtlas_Dynamic
		{
			if(!obj) return null;
			var subTextures:Vector.<Texture>;
			for each(var atlas:FlashAtlas_Dynamic in instances)
			{
				if(obj is String && atlas.getSubtexture(obj+"")) return atlas;
				else 
				{
					subTextures = atlas.getSubtexturesForObj(obj as DisplayObject,subTextures) as Vector.<Texture>;
					if(subTextures && subTextures.length>0) return atlas;
				}
			}
			return null;
		}
		private static var curent:FlashAtlas_Dynamic;
		public static function getInstance(obj:Object=null,instClass:Class=null, forceInstantiation:Boolean=false):FlashAtlas_Dynamic
		{
			if(!forceInstantiation){
				var atlasForObj:FlashAtlas_Dynamic = getAtlas(obj);
				if(atlasForObj) return atlasForObj;
			}
			
			if(!curent || forceInstantiation)
			{
				curent = instClass ? new instClass() : new StarlingAtlas_Dynamic();
				if(!instances) instances = new Vector.<FlashAtlas_Dynamic>();
				instances.push(curent);
			}
			if(curent.descriptor.isFull)
			{
				curent = null;
				return getInstance(obj,instClass);
			}
			curent.onFullHandler = onFullAtlasHandler;
			return curent;
		}
		protected static function onFullAtlasHandler(subtextureObj:DisplayObject,subTextureName:String):void
		{
			getInstance().addRegion(subtextureObj,subTextureName);  
		}
		public static function updateAtlasses():void
		{
			for each(var atlas:FlashAtlas_Dynamic in instances)
			{
				if(atlas.requireUpdate) atlas.updateAtlas(true);
			}
		}
	}
}