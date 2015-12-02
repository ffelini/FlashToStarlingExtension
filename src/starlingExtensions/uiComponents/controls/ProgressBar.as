package starlingExtensions.uiComponents.controls
{
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;

/**
	 * Visual progress is simulated using a clipping rectangle. Size of the clipping rect is calculated depend on progress.
	 * Position is calculated depend on direction and orientation; 
	 * @author peak
	 * 
	 */	
	public class ProgressBar extends FlashSprite_Mirror
	{
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		public static const DIRECTION_VERTICAL:String = "vertical";
		public static const ORIENTATION_LEFT_TO_RIGHT:String = "ltr";
		public static const ORIENTATION_RIGHT_TO_LEFT:String = "rtl";
		public static const ORIENTATION_UP_TO_DOWN:String = "utd";
		public static const ORIENTATION_DOWN_TO_UP:String = "dtu";
		
		public function ProgressBar(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		protected var defaultBounds:Rectangle;
		override public function createChildren():void
		{
			super.createChildren();
			defaultBounds = bounds;
		}
		protected var _progress:Number;
		public function set progress(value:Number):void
		{
			_progress = value;
			
			var _clipRect:Rectangle = clipRect ? clipRect : defaultBounds.clone();
			
			if(_direction==DIRECTION_HORIZONTAL)
			{
				_clipRect.height = defaultBounds.height;
				_clipRect.width = defaultBounds.width*value;
				_clipRect.x = _orientation==ORIENTATION_LEFT_TO_RIGHT ? 0 : defaultBounds.width - _clipRect.width;
				_clipRect.y = 0;
			}
			else 
			{
				_clipRect.width = defaultBounds.width;
				_clipRect.height = defaultBounds.height*value;
				_clipRect.x = 0;
				_clipRect.y = _orientation==ORIENTATION_UP_TO_DOWN ? 0 : defaultBounds.height - _clipRect.height;
				
			}
			clipRect = _clipRect;	
		}
		public function get progress():Number
		{
			return _progress;
		}
		protected var _direction:String = "horizontal";
		public function set direction(value:String):void
		{
			_direction = value;
			
			progress = _progress;
		}
		public function get direction():String
		{
			return _direction;
		}
		protected var _orientation:String = "ltr";
		public function set orientation(value:String):void
		{
			_orientation = value;
			
			progress = _progress;
		}
		public function get orientation():String
		{
			return _orientation;
		}
	}
}