package starlingExtensions.flash.textureAtlas
{
import flash.display.BitmapData;
import flash.display3D.textures.TextureBase;

import starling.textures.ConcreteTexture;

public class ConcreteTexture_Dynamic extends ConcreteTexture
	{
		public function ConcreteTexture_Dynamic(base:TextureBase, format:String, width:int, height:int, mipMapping:Boolean, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean=false, scale:Number=1)
		{
			super(base, format, width, height, mipMapping, premultipliedAlpha, optimizedForRenderTexture, scale);
		}
		public function updateBitmapData(data:BitmapData):void
		{
			mWidth = data.width;
			mHeight = data.height;
			uploadBitmapData(data);
		}
		public function set base(value:TextureBase):void
		{
			mBase = value;
		}
		protected var _isDisposed:Boolean = false;
		override public function dispose():void
		{
			if(_isDisposed) return;
			
			super.dispose();
			_isDisposed = true;
		}
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		public function set scale(value:Number):void
		{
			mScale = value <= 0 ? 1.0 : value;
		}
	}
}