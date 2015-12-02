package starlingExtensions.uiComponents
{
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.net.registerClassAlias;

import managers.Handlers;
import managers.net.ManagerNetConnection;
import managers.resourceManager.IResource;
import managers.resourceManager.ManagerRemoteResource;

import starling.display.DisplayObject;
import starling.textures.ConcreteTexture;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.utils.ScaleMode;

import starlingExtensions.interfaces.IActivable;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.utils.RectangleUtil;

public class Image_Remote extends SmartImage implements IResource,IActivable,IClonable
	{
		private static var _DEFAULT_TEXTURE:Texture;
		public static function get DEFAULT_TEXTURE():Texture {
			if(!_DEFAULT_TEXTURE) {
				_DEFAULT_TEXTURE = Texture.fromColor(2,2);
			}
			return _DEFAULT_TEXTURE;
		}
		
		public var autoDispose:Boolean = false;
		
		public function Image_Remote()
		{
			super(DEFAULT_TEXTURE);
			registerClassAlias("Image_Remote",Image_Remote);
			color = 0xffffff;
		}
		protected var _url:String = "";
		public function set url(value:String):void
		{
			if(value==_url && !disposed) 
			{
				texture = texture;
				visible = _url!="";
				return;
			}
			ManagerRemoteResource.removeFromWaitStack(_url,this);
			
			_url = value;
			visible = false;
			refreshSource(_url);
		}
		public function get url():String
		{
			return _url;
		}
		protected var _created:Boolean = false;
		public var errorTexture:Texture;
		public var useOwnTexture:Boolean = false;
		public var bmdProcessHandler:Function;
		public function refreshSource(_url:String,refreshWaitStack:Boolean=false):void
		{
			var source:* = ManagerRemoteResource.getResource(_url); 
			var bmd:BitmapData = source as BitmapData;
			
			if(useOwnTexture)
			{
				if(bmd)
				{
					disposeTexture();
					var scale:Number = 1;
					if(fitStageRect && bmd.width+bmd.height>fitStageRect.width+fitStageRect.height)  
					{
						RectangleUtil.helpRect.setEmpty();
						RectangleUtil.helpRect.width = bmd.width;
						RectangleUtil.helpRect.height = bmd.height;
						RectangleUtil.helpRect = RectangleUtil.fit(RectangleUtil.helpRect,fitStageRect,ScaleMode.SHOW_ALL,false,RectangleUtil.helpRect);
						scale = RectangleUtil.helpRect.width<bmd.width ? RectangleUtil.helpRect.width/bmd.width : 1;
					}
					texture = Texture.fromBitmapData(bmd,false,false,scale); 
				}
				else 
				{
					if(source==ManagerRemoteResource.ERROR) updateResultTexture(null);
					else if(source!=ManagerRemoteResource.LOADING)
					{
						ManagerRemoteResource.addToWaitStack(_url,this);
						ManagerRemoteResource.loadResource(_url,false,fitStageRect,bmdProcessHandler);  
					}
				}
			}
			else
			{	
				var t:Texture = ManagerRemoteResource.getTexture(_url,autoDispose);
				
				if(t || source==ManagerRemoteResource.ERROR) updateResultTexture(t);
				else
				{
					if(!bmd && source!=ManagerRemoteResource.LOADING && source!=ManagerRemoteResource.ERROR) 
					{
						ManagerRemoteResource.addToWaitStack(_url,this);
						ManagerRemoteResource.loadResource(_url,true,fitStageRect,bmdProcessHandler);
					}
				}
			}
			_active = true;
			
			if(t is SubTexture) autoDispose = false;
			if(t is ConcreteTexture) autoDispose = true;
		}
		protected function updateResultTexture(t:Texture):void
		{
			texture = t ? t : (errorTexture ? errorTexture : DEFAULT_TEXTURE);
			
			if(texture==errorTexture) 
				Handlers.add(ManagerNetConnection.monitorNetConnection,true,updateConnection);
		}
		private function updateConnection():void
		{
			ManagerRemoteResource.addToWaitStack(_url,this);
			ManagerRemoteResource.loadResource(_url,true,fitStageRect,bmdProcessHandler);
		}
		/**
		 * this rectangle is used to fit image content when loading complete 
		 */		
		public var fitRect:Rectangle;
		/**
		 * stage rectangle to fit the image content. This size is used for adding image content in to the global dynamic atlas. 
		 */		
		public var fitStageRect:Rectangle;
		/**
		 * scale factor according to fitRect size 
		 */		
		public var fitScale:Number = 0.85;
		public function updateRect(_fitRect:Rectangle=null):void
		{
			fitRect = _fitRect ? _fitRect : fitRect;
			
			if(!fitRect) readjustSize();
			else RectangleUtil.scaleToContent(this,fitRect,true,fitScale,fitRect);
		}
		public function updateFitRect(x:Number,y:Number,w:Number,h:Number):void
		{
			if(!fitRect) fitRect = new Rectangle();
			fitRect.x = x;
			fitRect.y = y;
			fitRect.width = w;
			fitRect.height = h;
			updateRect(fitRect);
		}
		protected var _active:Boolean = false;
		public function get active():Boolean
		{
			return _active;
		}
		public function activate(value:Boolean):void
		{
			if(value==_active) return;
			
			if(texture)
			{
				if(!value) 
				{
					if(autoDispose) disposeTexture(); 
					visible = false;
				}
				else refreshSource(url);
			}			
			_active = value;
		}
		override public function set texture(value:Texture):void
		{
			if(mTexture==value) 
			{
				if(!visible) visible = true;
				return;
			}
			
			if(autoDispose) disposeTexture();
			
			super.texture = value;
			disposed = Boolean(value==null);
			
			if(!disposed)
			{
				readjustSize();			
				updateRect();
				visible = true;
				Handlers.call(refreshSource);
			}
		}
		public var disposed:Boolean = false;
		public function disposeTexture():void
		{
			if(texture && texture!=errorTexture && texture!=DEFAULT_TEXTURE) 
			{
				texture.dispose();  
				disposed = true;
			}
		}
		override public function clone():DisplayObject
		{
			var c:Image_Remote = new Image_Remote();
			c.errorTexture = errorTexture;
			return c;
		}
		public function toString():String
		{
			return Image_Remote + " url - " + url;
		}
		/*override public function set smoothing(value:String):void
		{
			//super.smoothing = value;
		}
		override public function set alpha(value:Number):void
		{
			//super.alpha = value;
		}
		override public function set color(value:uint):void
		{
			//super.color = value;
		}
		override public function set blendMode(value:String):void
		{
			//super.blendMode = value;
		}
		override public function set filter(value:FragmentFilter):void
		{
			//super.filter = value;
		}*/
		
		
	}
}