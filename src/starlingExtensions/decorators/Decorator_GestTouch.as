package starlingExtensions.decorators
{
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;

import org.gestouch.core.Gestouch;
import org.gestouch.events.GestureEvent;
import org.gestouch.extensions.starling.StarlingDisplayListAdapter;
import org.gestouch.extensions.starling.StarlingTouchHitTester;
import org.gestouch.gestures.Gesture;
import org.gestouch.gestures.PanGesture;
import org.gestouch.gestures.RotateGesture;
import org.gestouch.gestures.TransformGesture;
import org.gestouch.gestures.ZoomGesture;
import org.gestouch.input.NativeInputAdapter;

import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.interfaces.IDraggable;

public class Decorator_GestTouch extends Decorator
	{
		public function Decorator_GestTouch()
		{
			super();
			
			initGestTouch();
		}
		private static var gestTouchInitialized:Boolean = false;
		private static var starlingHitTester:StarlingTouchHitTester;
		private static function initGestTouch():void
		{
			if(gestTouchInitialized) return;
			
			Gestouch.inputAdapter = new NativeInputAdapter(Starling.current.nativeStage);
			Gestouch.addDisplayListAdapter(DisplayObject, new StarlingDisplayListAdapter());
			
			starlingHitTester = new StarlingTouchHitTester(Starling.current);
			Gestouch.addTouchHitTester(starlingHitTester, -1);
			
			gestTouchInitialized = true;
		}
		protected var gestures:Dictionary = new Dictionary();
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value, _decorate, params);
			
			var gestureClass:Class = params[0];
			var gesturesByTarget:Dictionary = gestures[value];
			if(!gesturesByTarget)
			{
				gesturesByTarget = new Dictionary();
				gestures[value] = gesturesByTarget;
			}
			var gesture:Gesture = gesturesByTarget[gestureClass];
				
			if(_decorate)
			{
				if(!gesture) 
				{
					gesture = new gestureClass(value) as Gesture;
					gesturesByTarget[gestureClass] = gesture;
					toggleGestureListeners(gesture,true);
				}
			}
			else
			{
				if(gesture) 
				{
					toggleGestureListeners(gesture,false);
					gesture.dispose();
					delete gesturesByTarget[gestureClass];
					gesture = null;
				}
			}
			
			return _decorated;
		}
		protected function toggleGestureListeners(getsture:Gesture,add:Boolean):void
		{
			if(add)
			{
				getsture.addEventListener(GestureEvent.GESTURE_BEGAN, onGesture);
				getsture.addEventListener(GestureEvent.GESTURE_ENDED, onGesture);
				getsture.addEventListener(GestureEvent.GESTURE_CHANGED, onGesture);
			}
			else
			{
				getsture.removeEventListener(GestureEvent.GESTURE_BEGAN, onGesture);
				getsture.removeEventListener(GestureEvent.GESTURE_ENDED, onGesture);
				getsture.removeEventListener(GestureEvent.GESTURE_CHANGED, onGesture);
			}
		}
		private var helpP:Point = new Point();
		private var beganGestures:Dictionary = new Dictionary();
		private function onGesture(event:GestureEvent):void
		{
			var gesture:Gesture = event.target as Gesture;
			var obj:DisplayObject = gesture.target as DisplayObject;
			var matrix:Matrix = obj.transformationMatrix;
			var transformPoint:Point = matrix.transformPoint(obj.globalToLocal(gesture.location,helpP));
			
			const pan:PanGesture = event.target as PanGesture;
			if(pan)
			{
				if(event.type==GestureEvent.GESTURE_ENDED) delete beganGestures[PanGesture];
				
				if(!beganGestures[PanGesture] && obj is IDraggable && Starling.current.stage.hitTest(pan.location,true) != (obj as IDraggable).dragger) return;

				if(event.type==GestureEvent.GESTURE_BEGAN) beganGestures[PanGesture] = pan;
				
				if(beganGestures[PanGesture])
				{
					obj.x += pan.offsetX;
					obj.y += pan.offsetY;
				}
				
				/*matrix.translate(pan.offsetX, pan.offsetY);
				obj.transformationMatrix = matrix;*/
			}
			const transform:TransformGesture = event.target as TransformGesture;
			if(transform)
			{
				// Panning
				matrix.translate(transform.offsetX, transform.offsetY);
				obj.transformationMatrix = matrix;
				
				if (transform.scale != 1 || transform.rotation != 0)
				{
					// Scale and rotation.
					matrix.translate(-transformPoint.x, -transformPoint.y);
					matrix.rotate(transform.rotation);
					matrix.scale(transform.scale, transform.scale);
					matrix.translate(transformPoint.x, transformPoint.y);
					
					obj.transformationMatrix = matrix;
				}
			}
			const zoom:ZoomGesture = event.target as ZoomGesture;
			if(zoom)
			{
				matrix.translate(-transformPoint.x, -transformPoint.y);
				matrix.scale(zoom.scaleX, zoom.scaleY);
				matrix.translate(transformPoint.x, transformPoint.y);
				obj.transformationMatrix = matrix;
			}
			const rotate:RotateGesture = event.target as RotateGesture;
			if(rotate)
			{
				matrix.translate(-transformPoint.x, -transformPoint.y);
				matrix.rotate(rotate.rotation);
				matrix.translate(transformPoint.x, transformPoint.y);
				obj.transformationMatrix = matrix;
			}
		}
		
	}
}