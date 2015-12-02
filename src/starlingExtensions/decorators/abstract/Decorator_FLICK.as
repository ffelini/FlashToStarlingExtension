package starlingExtensions.decorators.abstract
{
	public class Decorator_FLICK
	{
		private var _min:Number;
		private var _max:Number;
		private var _step:Number;
		private var _fieldName:String;
		
		public function Decorator_FLICK(min:Number,max:Number,step:Number,fieldName:String,target:Object)
		{
			_min = min;
			_max = max;
			_step = step;
			_fieldName = fieldName;
			_target = target;
			_curentValue = _target && _target.hasOwnProperty(_fieldName) ? _target[_fieldName] : 0;
		}
		private var _target:Object;
		public function get target():Object
		{
			return _target;
		}
		
		private var _forwardUpdate:Boolean = false;
		public function get isForwardUpdating():Boolean
		{
			return _forwardUpdate;
		}
		private var _curentValue:Number;
		public function get curentValue():Number
		{
			return _curentValue;
		}
		public function update():void
		{
			_curentValue = _forwardUpdate ? _curentValue + _step : _curentValue - _step;
			
			if(_curentValue>=_max) _forwardUpdate = false;
			if(_curentValue<=_min) _forwardUpdate = true;
			
			if(_target && _target.hasOwnProperty(_fieldName)) _target[_fieldName] = _curentValue;
		}
	}
}