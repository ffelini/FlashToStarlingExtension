package starlingExtensions.containers
{
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starlingExtensions.abstract.IOptimizedDisplayObject;
import starlingExtensions.utils.RectangleUtil;
import starlingExtensions.utils.TweenUtils;

import utils.TimeOut;
import utils.Utils;

public class TouchContainer extends Sprite
	{
		public var touchTarget:DisplayObject;
		public var touchEventsListener:DisplayObject;
		
		private var lastTouchable:Boolean;
		
		public function TouchContainer()
		{
			super();
			touchTarget = touchEventsListener = this;
		}
		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			touchable = value==0 ? false : lastTouchable;
		}
		
		override public function set touchable(value:Boolean):void
		{
			lastTouchable = mTouchable;
			super.touchable = value;
			
			if(value) addEventListener(TouchEvent.TOUCH,onTouch);
			else removeEventListener(TouchEvent.TOUCH,onTouch);
		}
		protected function onTouch(e:TouchEvent):void
		{
			
		}
		private function addMultiTouchListener(add:Boolean):void
		{
			if(add) touchEventsListener.addEventListener(TouchEvent.TOUCH,onMultiTouch);
			else if(!_draggable && !_zoomable && !_slideScrollable) touchEventsListener.removeEventListener(TouchEvent.TOUCH,onMultiTouch);
		}
		protected var _draggable:Boolean = false;
		protected var _zoomable:Boolean = false;
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
			addMultiTouchListener(_draggable); 
		}
		public function get draggable():Boolean
		{
			return _draggable;
		}
		public var zoomDistance:Number = 25;
		public var doubleTapZoom:Boolean = false;
		public function set zoomable(value:Boolean):void
		{
			_zoomable = value;
			addMultiTouchListener(_zoomable);
		}
		protected var _slideScrollable:Boolean = false;
		public var hSlides:int = 0;
		public var vSlides:int = 0;
		public function set slideScrollable(value:Boolean):void
		{
			_slideScrollable = value;
			addMultiTouchListener(_slideScrollable);
		}
		public function get slideScrollable():Boolean
		{
			return _slideScrollable;
		}
		protected var _touchChildren:Boolean = true;
		public function get touchChildren():Boolean
		{
			return _touchChildren && !zooming && !moving;
		}
		/**
		 * the minimum offset for horizontal position change required to ignore touch children 
		 */		
		public var touchIgnoreHorizontalMinimum:Number = 0;		
		/**
		 * the minimum offset for vertical position change required to ignore touch children 
		 */		
		public var touchIgnoreVerticalMinimum:Number = 0;
		protected var movedHorizontal:Number;
		protected var movedVertical:Number;
		protected function activateTouching(value:Boolean):void
		{
			_touchChildren = value;
		}
		public var dragSpeed:Number = 0.15;
		public var stopMovingOnTouch:Boolean = true;
		protected var touchP:Point = new Point();
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var touchSpeed:Number;
		protected var moveTween:Tween;
		protected var touches:Vector.<Touch>;
		protected function onMultiTouch(e:TouchEvent):void
		{
			var standTouch:Touch = e.getTouch(touchEventsListener,TouchPhase.STATIONARY);
			if(standTouch) 
			{
				activateTouching(true);
				return;
			}
			
			var et:Touch = e.getTouch(touchEventsListener,TouchPhase.ENDED);
			
			if(et) movedHorizontal = movedVertical = 0;
			
			if(et && et.tapCount==2 && doubleTapZoom) 
			{
				zoom(0,0,true);
				return;
			}
			if(e.getTouch(touchEventsListener,TouchPhase.BEGAN))
			{
				activateTouching(true);
				if((!zooming && stopMovingOnTouch) || (zooming && controlZoom))
				{
					touchSpeed = 0;
					Starling.juggler.removeTweens(touchTarget);
				}
				updateDragValues(false);
			}
			
			if(touches) touches.length = 0;
			touches = _zoomable ? e.getTouches(touchTarget,TouchPhase.MOVED,touches) : null;
			var mt:Touch = _draggable || curentZoom>1 ? e.getTouch(touchEventsListener,TouchPhase.MOVED) : null;

			if(mt) mt.getMovement(parent,touchP);
			
			if(touches && touches.length>1) processTouchZoom(touches);
			else if((mt || et) && moveEnabled && (Math.abs(touchP.x)>1 || Math.abs(touchP.y)>1))
			{
				if(mt) touchSpeed = Utils.getDistance(mt.globalX,mt.globalY,mt.previousGlobalX,mt.previousGlobalY);
				
				_x = touchTarget.x + touchP.x;
				_y = touchTarget.y + touchP.y;
				
				if(et && touchSpeed>2)
				{
					_x += (touchSpeed*dragSpeed)*touchP.x;
					_y += (touchSpeed*dragSpeed)*touchP.y;
				}
				
				if(_slideScrollable)
				{
					_x = touchTarget.x + (touchP.x > 0 ? targetBounds.width/hSlides : -targetBounds.width/hSlides);
					_y = touchTarget.y + (touchP.y > 0 ? targetBounds.height/vSlides : -targetBounds.height/vSlides);
					mt = null;
				}
				if(_x < minDragX) _x = minDragX;
				if(_y < minDragY) _y = minDragY;
				if(_x>maxDragX) _x = maxDragX;
				if(_y>maxDragY) _y = maxDragY;
				
				if(mt)
				{
					movedHorizontal += Math.abs(_x - touchTarget.x);
					movedVertical += Math.abs(_y - touchTarget.y);
					
					touchTarget.x = _x;
					touchTarget.y = _y;
					onPositionUpdate();
				}
				else if(et && touchSpeed>2)
				{
					moveTween = TweenUtils.add(touchTarget,{"x": _x, "y": _y},Transitions.EASE_OUT,dragSpeed*100/touchSpeed,false);
					moveTween.onUpdate = onPositionUpdate;
					Starling.juggler.add(moveTween);
				}
				if(mt)
				{
					if(touchIgnoreHorizontalMinimum==0 || movedHorizontal>=touchIgnoreHorizontalMinimum) activateTouching(false);
					if(touchIgnoreVerticalMinimum==0 || movedVertical>=touchIgnoreVerticalMinimum) activateTouching(false);					
				}
			}
			
			if(et) 
			{
				lastTouchesDist = 0;
				TimeOut.setTimeOutFunc(activateTouching,10,true,true);
			}
		}
		protected function onPositionUpdate():void
		{
			
		}
		public function get zoomed():Boolean
		{
			return _zoomable && Math.round(width)>Math.round(minW) && Math.round(height)>Math.round(minH);
		}
		protected function get moveEnabled():Boolean
		{
			return zoomed && !zooming;
		}
		protected function get slideEnabled():Boolean
		{
			return _slideScrollable && !moving;
		}
		protected var curentZoom:Number = 1;
		protected var maxZoom:Number = 2;
		protected var minZoom:Number = 1;
		protected var centrateZooming:Boolean = true;
		protected var lastTouchesDist:Number = 0;
		protected var zoomDuration:Number = 1;
		protected var controlZoom:Boolean = true;
		protected var zoomTween:Tween;
		protected function processTouchZoom(touches:Vector.<Touch>):void
		{	
			var d:Number = lastTouchesDist;
			lastTouchesDist = Point.distance(touches[0].getLocation(parent),touches[1].getLocation(parent));
			d = d==0 ? 0 : lastTouchesDist - d;
			
			var _w:Number;
			var _h:Number;
			
			if(Math.abs(d)<zoomDistance) return;
			activateTouching(false);
			
			if(!controlZoom)
			{
				_w = d>0 ? minW*maxZoom : minW;
				_h = _w / sizeRaport;
				zoom(_w,_h);
				return;
			}
			_w = touchTarget.width + (d * (1+sizeRaport*2));
			_h = _w / sizeRaport;
			
			if(_w/minW>maxZoom) 
			{
				_w = minW*maxZoom;
				_h = _w/sizeRaport;
			}
			
			if(_w<minW) _w = minW;
			if(_h<minH) _h = minH;
			
			if(touchTarget is IOptimizedDisplayObject) (touchTarget as IOptimizedDisplayObject).setSize(_w,_h);
			else
			{
				touchTarget.width = _w;
				touchTarget.height = _h;
			}
			
			onSizeUpdate();
		}
		protected function zoom(_w:Number,_h:Number,toggle:Boolean=false,animate:Boolean=true):void
		{
			if(zooming) return;
			if(toggle)
			{
				_w = Math.round(Math.round(width)>minW ? minW : minW*maxZoom);
				_h = _w/sizeRaport;
			}
			if(animate)
			{
				activateTouching(controlZoom);
			
				zoomTween = TweenUtils.add(touchTarget,{"width":_w,"height":_h},Transitions.EASE_OUT,zoomDuration,false,true);				
				if(centrateZooming) 
				{
					var lastX:Number = touchTarget.x;
					var lastY:Number = touchTarget.y;
					
					touchTarget.width = _w;
					touchTarget.height = _h;
					
					RectangleUtil.centrateToContent(touchTarget,dragRect);
					zoomTween.animate("x",touchTarget.x);
					zoomTween.animate("y",touchTarget.y);
					
					touchTarget.x = lastX;
					touchTarget.y = lastY;
					touchTarget.width = targetBounds.width;
					touchTarget.height = targetBounds.height;
				}
				
				zoomTween.onComplete = onZoomComplete;
				zoomTween.onUpdate = onSizeUpdate;
				Starling.juggler.add(zoomTween);
			}
			else
			{
				if(touchTarget is IOptimizedDisplayObject) (touchTarget as IOptimizedDisplayObject).setSize(_w,_h);
				else
				{
					touchTarget.width = _w;
					touchTarget.height = _h;
				}
				onSizeUpdate();
			}
		}
		public function zoomIn(animate:Boolean=true):void
		{
			zoom(minW*maxZoom,(minW*maxZoom)/sizeRaport,false,animate);
		}
		public function zoomOut(animate:Boolean=true):void
		{
			zoom(minW,minH,false,animate);
		}
		public function get zooming():Boolean
		{
			return Starling.juggler.contains(zoomTween);
		}
		public function get moving():Boolean
		{
			return Starling.juggler.contains(moveTween);
		}
		protected function onSizeUpdate():void
		{
			updateDragValues(false);		
			curentZoom = targetBounds.width/minW;
		}
		protected function onZoomComplete():void
		{
			activateTouching(true);
			updateDragValues(false);
		}
		protected var targetBounds:Rectangle;
		protected var minDragX:Number;
		protected var minDragY:Number;
		protected var maxDragX:Number;
		protected var maxDragY:Number;
		protected var minW:Number;
		protected var minH:Number;
		protected var sizeRaport:Number;
		public var dragRect:Rectangle;
		protected function updateDragValues(updateMinSize:Boolean=true):void
		{
			targetBounds = touchTarget.getBounds(touchTarget.parent,targetBounds);
			minDragX = dragRect.width - targetBounds.width;
			minDragY = dragRect.height - targetBounds.height;
			maxDragX = dragRect.x;
			maxDragY = dragRect.y;
			
			//trace("TouchContainer.updateDragValues(updateMinSize)",touchTarget,touchTarget.parent,(touchTarget as DisplayObjectContainer).numChildren,targetBounds,dragRect);
			
			if(updateMinSize)
			{
				minW = targetBounds.width;
				minH = targetBounds.height;
				sizeRaport = minW/minH;
			}
		}
	}
}