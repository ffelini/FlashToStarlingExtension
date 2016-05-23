/**
 * Created by valera on 28.04.2016.
 */
package starlingExtensions.utils {
import flash.utils.getTimer;

public class Counter {
    public function Counter() {
    }

    protected var _step:int = 1;
    protected var _value:int = 0;
    protected var _currentValue:Number = 0;
    protected var _stepDelay:Number = 500;
    protected var _debug:Boolean = false;
    public function setValue(value:int,step:int=1,stepDelay:Number=10,maxSteps:int=100,debug:Boolean=false):void
    {
        _debug = debug
        _step = value>=_value ? Math.abs(step) : -Math.abs(step);

        if(_step<0) _step = (_value - value)/step<maxSteps ? _step : Math.round((_value-value)/maxSteps);
        else _step = (value - _value)/step<maxSteps ? _step : Math.round((value-_value)/maxSteps);

        _stepDelay = stepDelay;
        _value = value;
    }
    private var lastChangeTime:Number = 0;
    public function update():Boolean
    {
        if(_currentValue==_value) return false;

        var t:Number = getTimer();

        if(_debug) trace("CountingField.render(support, parentAlpha)",t,lastChangeTime,_currentValue,_step,(_step>0 && _currentValue<_value) , (_step<0 && _currentValue>_value));

        if(t-lastChangeTime<_stepDelay || t==lastChangeTime) return false;
        else lastChangeTime = t;

        if((_step>0 && _currentValue<_value) || (_step<0 && _currentValue>_value))
        {
            _currentValue+=_step;
        }
        else
        {
            _currentValue = _value;
        }
        return true;
    }
    public function get currentValue():Number {
        return _currentValue;
    }
}
}
