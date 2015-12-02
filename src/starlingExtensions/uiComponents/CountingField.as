package starlingExtensions.uiComponents
{
import flash.utils.getTimer;

import starling.core.RenderSupport;
import starling.display.DisplayObject;

import starlingExtensions.interfaces.IClonable;

public class CountingField extends SmartTextField implements IClonable
	{
		public function CountingField(width:int, height:int, text:String, fontName:String="Verdana", fontSize:Number=12, color:uint=0x0, bold:Boolean=false)
		{
			super(width, height, text, fontName, fontSize, color, bold);
		}
		
		protected var _step:int = 1;
		protected var _value:int = 0;
		protected var _curentValue:Number = 0;
		protected var _stepDelay:Number = 500;
		protected var _debug:Boolean = false;
		public function setValue(value:int,step:int=1,stepDelay:Number=10,maxSteps:int=100,debug:Boolean=false):void
		{
			if(value==_value) 
			{
				super.text = value+"";
				return;
			}
			
			_debug = debug
			_step = value>=_value ? Math.abs(step) : -Math.abs(step);
			
			if(_step<0) _step = (_value - value)/step<maxSteps ? _step : Math.round((_value-value)/maxSteps);
			else _step = (value - _value)/step<maxSteps ? _step : Math.round((value-_value)/maxSteps);
			
			_stepDelay = stepDelay;
			_value = value;
		}
		private var lastChangeTime:Number = 0;
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha); 
			if(_curentValue==_value) return;
			
			var t:Number = getTimer();
			
			if(_debug) trace("CountingField.render(support, parentAlpha)",t,lastChangeTime,_curentValue,_step,(_step>0 && _curentValue<_value) , (_step<0 && _curentValue>_value));
			
			if(t-lastChangeTime<_stepDelay || t==lastChangeTime) return;
			else lastChangeTime = t;
			
			if((_step>0 && _curentValue<_value) || (_step<0 && _curentValue>_value))
			{
				_curentValue+=_step;
				super.text = _curentValue+"";
			}
			else
			{
				super.text = _value+"";
				_curentValue = _value;
			}
		}
		override public function clone():DisplayObject
		{
			var c:CountingField = new CountingField(width,height,text,fontName,fontSize,color,bold);
			
			return c;
		}
	}
}