package starlingExtensions.flash.textureAtlas
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;

import managers.Handlers;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.RenderTexture;
import starling.textures.Texture;

import starlingExtensions.textureutils.Textures;
import starlingExtensions.utils.DisplayUtils;

public class StarlingAtlas_Dynamic extends FlashAtlas_Dynamic
	{
		protected var starlingAtlas:Sprite = new Sprite();
		
		public function StarlingAtlas_Dynamic()
		{
			super();
			continueOnFull = false;
			
			initRenderTexture();
			
			debug = debugAtlas = true;
		}
		protected var renderTexture:RenderTexture;
		override public function resetDescriptor():AtlasDescriptor
		{
			super.resetDescriptor();
			return descriptor;
		}
		protected function initRenderTexture():void
		{
			renderTexture = new RenderTexture(descriptor.bestWidth,descriptor.bestHeight,true,-1);
			renderTexture.root.onRestore = onTextureRestore;
			(descriptor.atlas as TextureAtlas_Dynamic).texture = renderTexture;
		}
		override public function addRegion(obj:flash.display.DisplayObject, name:String, _updateAtlas:Boolean=true, includeAllMovieClipFrames:Boolean=true,maxSizeRect:Rectangle=null,bmdProcessHandler:Function=null):SubtextureRegion
		{
			return super.addRegion(obj, name, true, includeAllMovieClipFrames,maxSizeRect,bmdProcessHandler);
		}
		protected var subtextureStalingObj:starling.display.DisplayObject;
		override public function addSubTexture(descriptor:AtlasDescriptor, obj:flash.display.DisplayObject, name:String="",onAtlasIsFullCall:Boolean = true):SubtextureRegion
		{
			var subtexture:SubtextureRegion = super.addSubTexture(descriptor, obj, name);
			if(subtexture) {
				var objTexture:Texture = prepareRegionTexture(subtextureObj);

				if(objTexture)
				{
					subtextureStalingObj = new Image(objTexture);

					var subtextureObjRect:Rectangle = subtextureObj.getBounds(this);
					DisplayUtils.setBounds(subtextureStalingObj,subtextureObjRect);

					renderTexture.draw(subtextureStalingObj);
					if(descriptor.atlas is TextureAtlas_Dynamic) (descriptor.atlas as TextureAtlas_Dynamic).concretTexture.base = renderTexture.base;

					starlingRegionsByFlashInstance[subtextureObj] = subtextureStalingObj;
					starlingAtlas.addChild(subtextureStalingObj);

					objTexture.dispose();

					if(debugAtlas) drawAtlas(descriptor, getAtlasToDrawRect(descriptor));
				}
			} else {
				if(subtextureObj.parent==this) subtextureObj.parent.removeChild(subtextureObj);

				subtextureStalingObj.removeFromParent();
				if(requireUpdate) updateAtlas(true);

				if(onFullHandler!=null) {
					var subTextureName:String = setCurentOject(obj);
					Handlers.functionCall(onFullHandler,subtextureObj,subTextureName);
				}
			}
			return subtexture;
		}
		protected function prepareRegionTexture(subtextureFlashObj:flash.display.DisplayObject):Texture
		{
			var bmd:BitmapData;
			var objTexture:Texture;
			
			if(subtextureFlashObj is Bitmap) 
			{
				bmd = (subtextureFlashObj as Bitmap).bitmapData;
				
				if(objTexture) objTexture.root.uploadBitmapData(bmd);
				else objTexture = Texture.fromBitmapData(bmd,false,true,subtextureObj.width<bmd.width ? subtextureObj.width/bmd.width : 1);
			}
			else
			{
				bmd = Textures.rasterize(subtextureFlashObj,drawWithQuality ? drawQuality : "");
				
				if(objTexture) objTexture.root.uploadBitmapData(bmd);
				else objTexture = Texture.fromBitmapData(bmd,false,true);
				
				// we dispose bitmapData of only rasterized display objects
				bmd.dispose();
			}
			if(objTexture) objTexture.root.onRestore = null;
			
			return objTexture;
		}
		protected var starlingRegionsByFlashInstance:Dictionary = new Dictionary();
		protected function onTextureRestore():void
		{
			var starlingObj:Image;
			
			for(var flashObj:* in starlingRegionsByFlashInstance)
			{
				starlingObj = starlingRegionsByFlashInstance[flashObj];
				
				starlingObj.texture = prepareRegionTexture(flashObj as flash.display.DisplayObject);
			}
			
			initRenderTexture();
			
			renderTexture.draw(starlingAtlas);
			if(descriptor.atlas) (descriptor.atlas as TextureAtlas_Dynamic).concretTexture.base = renderTexture.base;
			
			for(var flashObj:* in starlingRegionsByFlashInstance)
			{
				starlingObj = starlingRegionsByFlashInstance[flashObj];
				
				starlingObj.texture.dispose();
			}
		}
		override public function updateAtlas(forceUpdating:Boolean=false):void
		{
			//super.updateAtlas(true);
		}
		override public function createTextureAtlass(descriptor:AtlasDescriptor):haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic
		{
			//if(atlas.texture==helpTexture) atlas.texture = renderTexture;
			
			if(debugAtlas) drawAtlas(descriptor, getAtlasToDrawRect(descriptor));
			
			return descriptor.atlas;
		}
		
	}
}