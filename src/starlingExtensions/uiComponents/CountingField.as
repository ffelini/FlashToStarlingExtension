package starlingExtensions.uiComponents {
import starling.core.RenderSupport;
import starling.display.DisplayObject;

import starlingExtensions.interfaces.IClonable;
import starlingExtensions.utils.Counter;

public class CountingField extends SmartTextField implements IClonable {
    private var counter:Counter = new Counter();

    public function CountingField(width:int, height:int, text:String, fontName:String = "Verdana", fontSize:Number = 12, color:uint = 0x0, bold:Boolean = false) {
        super(width, height, text, fontName, fontSize, color, bold);
    }

    public function setValue(value:int, step:int = 1, stepDelay:Number = 10, maxSteps:int = 100, debug:Boolean = false):void {
        counter.setValue(value, step, stepDelay, maxSteps, debug);
    }

    override public function render(support:RenderSupport, parentAlpha:Number):void {
        super.render(support, parentAlpha);
        if(counter.update()) {
            super.text = counter.currentValue + "";
        }
    }

    override public function clone():DisplayObject {
        var c:CountingField = new CountingField(width, height, text, fontName, fontSize, color, bold);

        return c;
    }
}
}