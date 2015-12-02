package starlingExtensions.uiComponents
{
import flash.geom.Matrix;
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

import starlingExtensions.abstract.IOptimizedDisplayObject;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.utils.DisplayUtils;

public class SmartSprite extends Sprite implements IClonable,IOptimizedDisplayObject
	{
		public var trackBoundsChange:Boolean = false;
		
		public function SmartSprite()
		{
			super();
			lastX = lastY = lastPivotX = lastPivotY = lastRotation = lastSkewX = lastSkewY = 0.0;
			lastWidth = _width = lastHeight = _height = 0.0;
			lastScaleX = lastScaleY = 1.0; 
		}
		public var broadcastEvents:Boolean = false;
		override public function broadcastEvent(event:Event):void
		{
			if(!broadcastEvents) return;
			super.broadcastEvent(event);
		}
		override public function broadcastEventWith(type:String, data:Object=null):void
		{
			if(!broadcastEvents) return;
			super.broadcastEventWith(type, data); 
		}
		public var dispatchEvents:Boolean = false;
		override public function dispatchEvent(event:Event):void
		{
			if(!dispatchEvents) return;
			super.dispatchEvent(event);
		}
		override public function dispatchEventWith(type:String, bubbles:Boolean=false, data:Object=null):void
		{
			if(!dispatchEvents) return;
			super.dispatchEventWith(type, bubbles, data);
		}
		protected var _color:uint = 0;
		public function set color(value:uint):void
		{
			_color = value;
			DisplayUtils.forEachChild(this,processChildColor);
		}
		public function get color():uint
		{
			return _color;
		}
		public function processChildColor(child:DisplayObject,childIndex:int,c:uint=0):void
		{
			if(child is TextField) return;
			
			c = c==0 ? _color : c;
			if(child.hasOwnProperty("color") && c!=0) child["color"] = c;			
		}
		protected var lastPivotX:Number;
		override public function set pivotX(value:Number):void
		{
			super.pivotX = value;
			lastPivotX = value;
			
			if(lastPivotX!=value) _boundsChanged = true;
		}
		protected var lastPivotY:Number;
		override public function set pivotY(value:Number):void
		{
			super.pivotY = value;
			lastPivotY = value;
			
			if(lastPivotY!=value) _boundsChanged = true;
		}
		protected var lastRotation:Number;
		override public function set rotation(value:Number):void
		{
			lastRotation = rotation;
			super.rotation = value;
			
			if(lastRotation!=value) _boundsChanged = true;
		}
		protected var lastScaleX:Number;
		override public function set scaleX(value:Number):void
		{
			lastScaleX = scaleX;
			super.scaleX = value;
			
			if(lastScaleX!=value) _boundsChanged = true;
		}
		protected var lastScaleY:Number;
		override public function set scaleY(value:Number):void
		{
			lastScaleY = scaleY;
			super.scaleY = value;
			
			if(lastScaleY!=value) _boundsChanged = true;
		}
		protected var lastSkewX:Number;
		override public function set skewX(value:Number):void
		{
			lastSkewX = skewX;
			super.skewX = value;
			
			if(lastSkewX!=value) _boundsChanged = true;
		}
		protected var lastSkewY:Number;
		override public function set skewY(value:Number):void
		{
			lastSkewY = skewY;
			super.skewY = value;
			
			if(lastSkewY!=value) _boundsChanged = true;
		}
		protected var lastX:Number;
		override public function set x(value:Number):void
		{
			lastX = x;
			super.x = value;
			
			if(_fixedBounds) _fixedBounds.x += value - lastX;
			
			if(lastX!=value) _boundsChanged = true;
		}
		protected var lastY:Number;
		override public function set y(value:Number):void
		{
			lastY = y;
			super.y = value;
			
			if(_fixedBounds) _fixedBounds.y += value - lastY;
			
			if(lastY!=value) _boundsChanged = true;
		}
		public static var helpRect:Rectangle = new Rectangle();
		public function setSize(w:Number,h:Number,boundRect:Rectangle=null):void
		{
			boundRect = boundRect ? boundRect : getBounds(mParent, helpRect);
			
			lastWidth = boundRect.width;
			_width = w;
			if (boundRect.width != 0.0) scaleX = w / (boundRect.width/scaleX);
			if(lastWidth!=w) _boundsChanged = true;
			
			lastHeight = boundRect.height;
			_height = h;
			if (boundRect.height != 0.0) scaleY = h / (boundRect.height/scaleY);
			if(lastHeight!=h) _boundsChanged = true;
		}
		public function increaseSize(widthBy:Number,heightBy:Number,increaseBy:Boolean=false):void
		{
			_fixedBounds = getBounds(mParent, _fixedBounds);
			
			var w:Number = increaseBy ? _fixedBounds.width * widthBy : _fixedBounds.width + widthBy;
			var h:Number = increaseBy ? _fixedBounds.height * heightBy : _fixedBounds.height + heightBy;
			
			lastWidth = _fixedBounds.width;
			_width = w;
			if (_fixedBounds.width != 0.0) scaleX = w / (_fixedBounds.width/scaleX);
			if(lastWidth!=w) _boundsChanged = true;
			
			lastHeight = _fixedBounds.height;
			_height = h;
			if (_fixedBounds.height != 0.0) scaleY = h / (_fixedBounds.height/scaleY);
			if(lastHeight!=h) _boundsChanged = true;
		}
		protected var lastWidth:Number;
		protected var _width:Number;
		override public function set width(value:Number):void
		{
			lastWidth = _width;
			_width = value;
			super.width = value;
			
			if(lastWidth!=value) _boundsChanged = true;
		}
		protected var lastHeight:Number;
		protected var _height:Number;
		override public function set height(value:Number):void
		{
			lastHeight = _height;
			_height = value;
			super.height = value;
			
			if(lastHeight!=value) _boundsChanged = true;
		}
		override public function set transformationMatrix(matrix:Matrix):void
		{
			if(trackBoundsChange)
			{
				lastWidth = _width;
				lastHeight = _height;
				lastScaleX = scaleX;
				lastScaleY = scaleY;
				lastRotation = rotation;
			}
			
			super.transformationMatrix = matrix;
			
			if(trackBoundsChange)
			{
				_fixedBounds = getBounds(parent,_fixedBounds);
				_width = _fixedBounds.width;
				_height = _fixedBounds.height;
				
				if(lastWidth!=_width || lastHeight!=_height || lastScaleX!=scaleX || lastScaleY!=scaleY || lastX!=x || lastY!=y || lastSkewX!=skewX || lastSkewY!=skewY || lastPivotX!=pivotX || lastPivotY!=pivotY || lastRotation!=rotation)
					_boundsChanged = true;
			}
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(trackBoundsChange)
			{
				lastWidth = _width;
				lastHeight = _height;
			}
			
			super.addChildAt(child, index);
			
			if(trackBoundsChange)
			{	
				_fixedBounds = getBounds(parent,_fixedBounds);
				_width = _fixedBounds.width;
				_height = _fixedBounds.height;
				
				if(lastHeight!=_height) _boundsChanged = true;
				if(lastWidth!=_width) _boundsChanged = true;
			}
			
			return child; 
		}
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			if(trackBoundsChange)
			{
				lastWidth = _width;
				lastHeight = _height;
			}

			var child:DisplayObject = super.removeChildAt(index, dispose);
			
			if(trackBoundsChange)
			{	
				_fixedBounds = getBounds(parent,_fixedBounds);
				_width = _fixedBounds.width;
				_height = _fixedBounds.height;
				
				if(lastHeight!=_height) _boundsChanged = true;
				if(lastWidth!=_width) _boundsChanged = true;
			}
			
			return child;
		}
		protected var _fixedBounds:Rectangle;
		public function fixBounds():void
		{
			_fixedBounds = getBounds(parent,_fixedBounds);
		}
		public function get fixedBouds():Rectangle
		{
			return _fixedBounds;
		}
		public function get boundsChanged():Boolean
		{
			return _boundsChanged;
		}
		protected var _boundsChanged:Boolean = false;
		public function resetBoundsChanging():void
		{
			_boundsChanged = false;
		}
		public var resetLastValuesAfterRender:Boolean = true;
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if(resetLastValuesAfterRender) resetBoundsChanging();
		}
		public function clone():DisplayObject
		{
			var c:SmartSprite = new SmartSprite();
			return c;
		}
	}
}