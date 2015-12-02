package starlingExtensions.uiComponents.renderers
{
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import managers.Handlers;
import managers.ObjPool;

import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.uiComponents.Image_Remote;
import starlingExtensions.utils.TouchUtils;

public class FlashImageIR extends FlashSkinableIR
	{
		/**
		 * if value == -1 then image is placed inside the item renderer (default index position)
		 * if value == 0 then image si placed in the list dataGroup contaienr zero index
		 * if value == 1 then image is placed in the list dataGroup container highest index 
		 */		
		public var dataGroupImgIndex:int = -1;
		protected var imgClass:Class = Image_Remote;
		
		public var img:Image_Remote;
		public var imgBorder:DisplayObject;
		
		public function FlashImageIR(_mirror:DisplayObjectContainer, _rootMirror:FlashDisplay_Mirror)
		{
			super(_mirror, _rootMirror);
		}
		override protected function positionEffect():void
		{
			super.positionEffect();
			
			if(dataGroupImgIndex!=-1 && _list && _list.dataGroup) img.updateRect(imgBorder ? imgBorder.getBounds(_list.dataGroup,imgRect) : null);
			else img.fitRect = imgBorder ? imgBorder.getBounds(this,imgRect) : null;		
		}
		override public function activate(value:Boolean):void
		{
			if(value==_active) return;
			
			super.activate(value);
			
			if(value) updateImage();			
			else resetImg();
		}
		override public function set touchable(value:Boolean):void
		{
			super.touchable = value;
			if(img) img.touchable = value;
		}
		public var useObjPoolImg:Boolean = true;
		protected var imgRect:Rectangle = new Rectangle();
		protected var imgIndex:int = 0;
		protected function updateImage():void
		{
			if(useObjPoolImg) img = ObjPool.inst.get(imgClass,true) as Image_Remote;
			else if(!img) img = new imgClass() as Image_Remote;
			
			Handlers.remove(img.refreshSource,onImageSourceComplete);
			
			if(dataGroupImgIndex!=-1 && _list && _list.dataGroup)
			{
				img.updateRect(imgBorder ? imgBorder.getBounds(_list.dataGroup,imgRect) : null);
				if(_list && img.parent!=_list.dataGroup)
				{
					if(dataGroupImgIndex==0) _list.dataGroup.addChildAt(img,0);
					if(dataGroupImgIndex>0) _list.dataGroup.addChild(img);	
				}
			}
			else 
			{
				img.updateRect(imgBorder ? imgBorder.getBounds(this,imgRect) : null);		
				if(!img.fitRect) img.x = img.y = 0;
				addChildAt(img,imgIndex);
			}	
			
			if(img.parent!=this) img.addEventListener(TouchEvent.TOUCH,onTouch);
			Handlers.add(img.refreshSource,true,onImageSourceComplete);	
			
			img.fitStageRect = imgBorder ? imgBorder.getBounds(stage,img.fitStageRect) : null;
			img.touchable = touchable;
		}
		protected function onImageSourceComplete():void
		{
		}
		override public function updateLayout():void
		{
			super.updateLayout();
			if(img && dataGroupImgIndex!=-1) 
			{
				img.updateRect(imgBorder ? imgBorder.getBounds(_list.dataGroup,imgRect) : null);
			}
		}
		override public function clicked(e:TouchEvent,target:DisplayObject=null):Touch
		{
			if(_list && !isListSleeping) return null;
			
			var t:Touch = super.clicked(e,target);
			if(!t && img && img.parent!=this) return TouchUtils.clicked(img,e);
			return t;
		}
		protected function resetImg():void
		{
			if(!img) return;
			Handlers.remove(img.refreshSource,onImageSourceComplete);
			img.removeEventListener(TouchEvent.TOUCH,onTouch);
			img.fitRect = null;
			img.fitScale = 0.85;
			
			if(useObjPoolImg) ObjPool.inst.add(img,imgClass);
		}
		override public function reset():void
		{
			resetImg();
			if(useObjPoolImg) img = null;
			//dataGroupImgIndex = -1;
			super.reset();
		}		
		override public function removeFromParent(dispose:Boolean=false):void
		{
			super.removeFromParent(dispose);
			if(img && img.parent!=this) img.removeFromParent();
		}
		override public function clone():DisplayObject
		{
			var c:FlashImageIR = new FlashImageIR(mirror,rootMirror); 
			c.dataGroupImgIndex = dataGroupImgIndex;
			c._created = _created;
			return c;
		}
		
	}
}