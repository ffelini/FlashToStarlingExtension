package starlingExtensions.uiComponents
{

import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;

import starlingExtensions.abstract.IOptimizedDisplayObject;
import starlingExtensions.interfaces.IClonable;

public class SmartQuad extends Quad implements IClonable,IOptimizedDisplayObject
	{
		public function SmartQuad(width:Number, height:Number, color:uint=0xffffff, premultipliedAlpha:Boolean=true)
		{
			super(width, height, color, premultipliedAlpha);
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
		public function get boundsChanged():Boolean
		{
			return _boundsChanged;
		}
		protected var _boundsChanged:Boolean = false;
		public function resetBoundsChanging():void
		{
			_boundsChanged = false;
		}
		
		// color
		
		protected var _topColor:uint = 0xFFFFFF;
		public function set topColor(c:uint):void
		{
			_topColor = c;
			setVertexColor(0, _topColor);
			setVertexColor(1, _topColor);
		}
		public function get topColor():uint
		{
			return _topColor;
		}
		protected var _bottomColor:uint = 0xFFFFFF;
		public function set bottomColor(c:uint):void
		{
			_bottomColor = c;
			setVertexColor(2, _bottomColor);
			setVertexColor(3, _bottomColor);
		}
		public function get bottomColor():uint
		{
			return _bottomColor;
		}
		protected var _leftColor:uint = 0xFFFFFF;
		public function set leftColor(c:uint):void
		{
			_leftColor = c;
			setVertexColor(0, _leftColor);
			setVertexColor(2, _leftColor);
		}
		public function get leftColor():uint
		{
			return _leftColor;
		}
		protected var _rightColor:uint = 0xFFFFFF;
		public function set rightColor(c:uint):void
		{
			_rightColor = c;
			setVertexColor(1, _rightColor);
			setVertexColor(3, _rightColor);
		}
		public function get rightColor():uint
		{
			return _rightColor;
		}
		
		// alpha
		
		protected var _topAlpha:Number;
		public function set topAlpha(c:Number):void
		{
			_topAlpha = c;
			setVertexAlpha(0, _topAlpha);
			setVertexAlpha(1, _topAlpha);
		}
		public function get topAlpha():Number
		{
			return _topAlpha;
		}
		protected var _bottomAlpha:Number;
		public function set bottomAlpha(c:Number):void
		{
			_bottomAlpha = c;
			setVertexAlpha(2, _bottomAlpha);
			setVertexAlpha(3, _bottomAlpha);
		}
		public function get bottomAlpha():Number
		{
			return _bottomAlpha;
		}
		protected var _leftAlpha:Number;
		public function set leftAlpha(c:Number):void
		{
			_leftAlpha = c;
			setVertexAlpha(0, _leftAlpha);
			setVertexAlpha(2, _leftAlpha);
		}
		public function get leftAlpha():Number
		{
			return _leftAlpha;
		}
		protected var _rightAlpha:Number;
		public function set rightAlpha(c:Number):void
		{
			_rightAlpha = c;
			setVertexAlpha(1, _rightAlpha);
			setVertexAlpha(3, _rightAlpha);
		}
		public function get rightAlpha():Number
		{
			return _rightAlpha;
		}
		
		public function clone():DisplayObject
		{
			var c:SmartQuad = new SmartQuad(width,height,color,premultipliedAlpha);
			return c;
		}
	}
}