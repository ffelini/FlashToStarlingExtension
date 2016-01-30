package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

public class Slider extends FlashSprite_Mirror
	{
		public static const THUMB_NAME:String = "thumb";
		public static const TRACK_NAME:String = "track";
		
		public function Slider(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		protected var thumb:DisplayObject;
		protected var track:DisplayObject;
		protected var direction:String = "horizontal";
		protected var localBounds:Rectangle;
		protected var thumbBounds:Rectangle;
		override public function createChildren():void
		{
			super.createChildren();
			
			thumb = getChildByName("thumb");
			track = getChildByName("track");
			
			thumbBounds = thumb.getBounds(this,thumbBounds);
			localBounds = getBounds(this);
		}
		protected var isDown:Boolean = false;
		protected var touchP:Point;
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			if(!created || !localBounds) return;
			
			if(e.getTouch(thumb,TouchPhase.BEGAN)) isDown = true;
			else
			{
				var mt:Touch = e.getTouch(this,TouchPhase.MOVED);
				if(mt)
				{
					if(isDown)
					{
						touchP = mt.getMovement(parent,touchP);
						
						if(isHorizontal)
						{
							thumb.x += touchP.x;
							thumbBounds = thumb.getBounds(this,thumbBounds);
						
							if(thumb.x<localBounds.x) thumb.x = localBounds.x + thumb.x - thumbBounds.x;
							if(thumb.x>localBounds.width - thumbBounds.width) thumb.x = localBounds.width - thumbBounds.width + (thumb.x - thumbBounds.x);
						}
						
						if(isVertical) 
						{
							thumb.y += touchP.y;
							thumbBounds = thumb.getBounds(this,thumbBounds);
		
							if(thumb.y<localBounds.y) thumb.y = localBounds.y + thumb.y - thumbBounds.y;
							if(thumb.y>localBounds.height - thumbBounds.width) thumb.y = localBounds.height - thumbBounds.height + (thumb.y - thumbBounds.y);
						}
						if(onChangeHandler!=null) onChangeHandler();
						return;
					}
				}
			}
			if(e.getTouch(this,TouchPhase.ENDED)) isDown = false;
		}
		public function get isHorizontal():Boolean
		{
			return localBounds ? localBounds.width>localBounds.height : false;
		}
		public function get isVertical():Boolean
		{
			return localBounds ? localBounds.height>localBounds.width : false;
		}
		public var onChangeHandler:Function;
		protected var minimum:Number;
		protected var maximum:Number;
		public function get value():Number
		{			
			if(isHorizontal) 
			{
				thumbBounds = thumb.getBounds(this,thumbBounds);
				return maximum * (thumbBounds.x/(localBounds.width - thumbBounds.width));
			}
			if(isVertical)
			{
				thumbBounds = thumb.getBounds(this,thumbBounds);
				return maximum * (thumbBounds.y/(localBounds.height - thumbBounds.height));
			}
			return 0;
		}
		public function setup(_minimum:Number,_maximum:Number,_value:Number):void
		{	
			if(minimum>=maximum) return;
			
			minimum = _minimum;
			maximum = _maximum;
			
			_value = _value<minimum ? minimum : (maximum>maximum ? maximum : _value);
			
			if(isHorizontal) 
			{
				thumbBounds = thumb.getBounds(this,thumbBounds);
				thumb.x = (localBounds.width * (_value/maximum)) - thumbBounds.width - (thumb.x - thumbBounds.x);
			}
			if(isVertical)
			{
				thumbBounds = thumb.getBounds(this,thumbBounds);
				thumb.x = (localBounds.height * (_value/maximum)) - thumbBounds.height - (thumb.y - thumbBounds.y);
			}
		}
	}
}