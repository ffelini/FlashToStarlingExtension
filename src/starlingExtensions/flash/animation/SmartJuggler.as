package starlingExtensions.flash.animation
{
import flash.utils.getTimer;

import starling.animation.Juggler;

public class SmartJuggler extends Juggler
	{
		public function SmartJuggler()
		{
			super();
		}
		public var isPlaying:Boolean = false;
		public function stop():void
		{
			isPlaying = false;
		}
		public function play():void
		{
			isPlaying = true;
		}
		private var mLastFrameTimestamp:Number;
		public function next():void
		{
			var now:Number = getTimer() / 1000.0;
			var passedTime:Number = now - mLastFrameTimestamp;
			mLastFrameTimestamp = now;
			
			if(!isPlaying) return;
			
			advanceTime(passedTime);
		}
		override public function advanceTime(time:Number):void
		{
			curentPassedTime = time;
			if(!isPlaying) return;
			
			super.advanceTime(time);
		}
		
	}
}