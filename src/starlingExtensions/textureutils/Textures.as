package starlingExtensions.textureutils
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import managers.ObjPool;

import starling.textures.Texture;
import starling.utils.getNextPowerOfTwo;

import starlingExtensions.flash.textureAtlas.ManagerAtlas_Dynamic;

public class Textures
	{
		protected static var texturesByKey:Dictionary = new Dictionary();
		public function Textures()
		{
		}
		public static function rasterize(obj:DisplayObject,drawQuality:String="",usePowerOfTwoSize:Boolean=false,boundsTargetCoordinateSpace:DisplayObject=null):BitmapData
		{
			if(!boundsTargetCoordinateSpace) boundsTargetCoordinateSpace = obj.parent ? obj.parent : obj;
			
			var objRect:Rectangle = obj.getBounds(boundsTargetCoordinateSpace);
			
			var _bData:BitmapData = new BitmapData(usePowerOfTwoSize ? getNextPowerOfTwo(objRect.width) : objRect.width, usePowerOfTwoSize ? getNextPowerOfTwo(objRect.height) : objRect.height, true, 0); 
			var _mat:Matrix = obj.transform.matrix; 
			_mat.translate(-objRect.x, -objRect.y);
			
			if(drawQuality!="") _bData.drawWithQuality(obj, _mat,null,null,null,true,drawQuality); 
			else _bData.draw(obj, _mat,null,null,null,true);
			
			return _bData;
		}
		public static function fromDisplayObject(obj:DisplayObject,useDynamicAtlas:Boolean=true,updateDynamicAtlas:Boolean=true,extrusionFactor:Number=100):starling.textures.Texture
		{
			if(!obj) return null;
			var t:starling.textures.Texture = texturesByKey[obj];
			if(t) return t;
			
			if(!useDynamicAtlas)
			{
				var bmd:BitmapData = rasterize(obj);
				t = starling.textures.Texture.fromBitmapData(bmd,false);
				bmd.dispose();
			}
			else
			{
				t = ManagerAtlas_Dynamic.getInstance(obj).getSubtextureForObj(obj,null,null,extrusionFactor);
				if(!t) 
				{
					ManagerAtlas_Dynamic.getInstance(obj).addRegion(obj,"",updateDynamicAtlas);
					t = ManagerAtlas_Dynamic.getInstance(obj).getSubtextureForObj(obj,null,null,extrusionFactor);
				}
			}
			texturesByKey[obj] = t;
			
			return t;
		}
		public static function fromColor(color:uint,alpha:Number=1,useDynamicAtlas:Boolean=true,width:Number=2,height:Number=2):starling.textures.Texture
		{
			var t:starling.textures.Texture = texturesByKey[color];
			if(!t) 
			{
				if(useDynamicAtlas)
				{
					t = ManagerAtlas_Dynamic.getInstance(color).getSubtexture(color+"") as starling.textures.Texture;
					if(!t)
					{
						ManagerAtlas_Dynamic.getInstance(color).addBitmapDataRegion(new BitmapData(width,height,true,color),color+"",alpha);
						t = ManagerAtlas_Dynamic.getInstance(color).getSubtexture(color+"") as starling.textures.Texture;
					}
				}
				else t = starling.textures.Texture.fromColor(width,height,color);
				
				texturesByKey[color] = t;
			}
			return t;
		}
		public static function fromDOClass(doClass:Class,useDynamicAtlas:Boolean=true,updateDynamicAtlas:Boolean=true,extrusionFactor:Number=100):starling.textures.Texture
		{
			if(!doClass) return null;
			var t:starling.textures.Texture = texturesByKey[doClass];
			if(!t) 
			{
				var _do:DisplayObject = ObjPool.inst.get(doClass) as DisplayObject;
				ObjPool.inst.add(_do,doClass);
				t = fromDisplayObject(_do,useDynamicAtlas,updateDynamicAtlas,extrusionFactor);
			}
			
			return t;
		}
		public static function fromMCClass(doClass:Class,useDynamicAtlas:Boolean=true,updateDynamicAtlas:Boolean=true,frame:int=0):starling.textures.Texture
		{
			if(!doClass) return null;
			var t:starling.textures.Texture = texturesByKey[doClass];
			if(!t) 
			{
				var _do:MovieClip = ObjPool.inst.get(doClass) as MovieClip;
				ObjPool.inst.add(_do,doClass);
				t = fromMovieClip(_do,useDynamicAtlas,updateDynamicAtlas,frame);
			}
			
			return t;
		}
		private static var textures:Vector.<starling.textures.Texture>;
		public static function fromMovieClip(obj:MovieClip,useDynamicAtlas:Boolean=true,updateDynamicAtlas:Boolean=true,frame:int=0):starling.textures.Texture
		{
			if(!obj) return null;
			var t:starling.textures.Texture;
			
			if(!useDynamicAtlas)
			{
				var bmd:BitmapData = rasterize(obj);
				t = starling.textures.Texture.fromBitmapData(bmd,false);
				bmd.dispose();
			}
			else
			{
				textures = ManagerAtlas_Dynamic.getInstance(obj).getSubtexturesForObj(obj,textures) as Vector.<starling.textures.Texture>;
				if(!textures || textures.length==0) 
				{
					ManagerAtlas_Dynamic.getInstance(obj).addRegion(obj,"",updateDynamicAtlas);
					textures = ManagerAtlas_Dynamic.getInstance(obj).getSubtexturesForObj(obj,textures) as Vector.<starling.textures.Texture>;
				}
				t = textures && textures.length>0 && frame<textures.length ? textures[frame] : textures[0];
			}
			
			return t;
		}
		public static function fromObj(obj:*,useDynamicAtlas:Boolean=true,updateDynamicAtlas:Boolean=true,texturePadding:Number=100):starling.textures.Texture
		{
			var t:starling.textures.Texture = texturesByKey[obj];
			if(!t) t = fromDisplayObject(obj is Class ? new obj() : obj,useDynamicAtlas,updateDynamicAtlas,texturePadding);
			
			return t;
		}
		public static function uploadFromBitmapData(base:*,bmd:BitmapData):void
		{
			if(!base || !bmd) return;
			
			if(flash.display3D.textures.Texture(base)) 
				flash.display3D.textures.Texture(base).uploadFromBitmapData(bmd);
		}
	}
}