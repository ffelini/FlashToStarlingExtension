package starlingExtensions.uiComponents
{
import flash.events.TimerEvent;
import flash.utils.Timer;

import starlingExtensions.interfaces.IClonable;

[Event(name="complete", type="starling.events.Event")]
	
	public class CounterField extends SmartTextField implements IClonable
	{
		public var timer:Timer = new Timer(1000,1);
		
		public var from:int = 3;
		public var to:int = 0;
		
		public var autoStart:Boolean = true;
		
		public var autoRemoveFromStage:Boolean = true;
				
		public function CounterField(width:int, height:int, text:String, fontName:String="Verdana", fontSize:Number=12, color:uint=0x0, bold:Boolean=false)
		{
			super(width,height,text,fontName,fontSize,color,bold);
		}
		public function start(_from:int=3,_to:int=0,timeStep:Number=1000):void
		{
			from = _from;
			to = _to;
			
			timer.delay = timeStep;
			timer.repeatCount = Math.abs(_from-to);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			
			timer.reset();
			timer.start();		 
		}
		public function stop():void
		{
			timer.stop();
		}
		protected function onTimer(e:TimerEvent):void
		{
			text = minuteString + " : " + secondString;
			
			if(e.type==TimerEvent.TIMER_COMPLETE || currentCount==from) onTimerComplete();
		}
		protected function onTimerComplete():void
		{
			_currentCount = 0;
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
			timer.removeEventListener(TimerEvent.TIMER,onTimer);	
			
			timer.stop();
			
			dispatchEventWith("complete");
		}
		public function setTime(minute:Number,second:Number):void
		{
			
		}
		public function get minute():Number
		{
			return from/60 - Math.ceil(currentCount/60);
		}
		public function get second():Number
		{
			return currentCount%60==0 ? 0 : 60 - (currentCount%60);
		}
		public function get minuteString():String
		{
			return minute>=10 ? minute+"" : "0"+minute;
		}
		public function get secondString():String
		{
			return second>=10 ? second+"" : "0"+second;
		}
		public function get totalSeconds():Number
		{
			return from - currentCount;
		}
		protected var _currentCount:int = 0;
		public function set currentCount(value:int):void
		{
			_currentCount = value;
		}
		public function get currentCount():int
		{
			return timer.currentCount + _currentCount;
		}
		/*override public function clone():DisplayObject
		{
			var c:CounterField = new CounterField(width,height,text,fontName,fontSize,color,bold);
			
			return c;
		}*/
	}
}