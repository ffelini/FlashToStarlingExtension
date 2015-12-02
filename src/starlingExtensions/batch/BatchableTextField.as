package starlingExtensions.batch
{
import starling.core.RenderSupport;
import starling.display.DisplayObject;

import starlingExtensions.interfaces.IClonable;
import starlingExtensions.uiComponents.SmartTextField;

public class BatchableTextField extends SmartTextField implements IClonable
	{
		public function BatchableTextField(width:int, height:int, text:String, fontName:String="Verdana", fontSize:Number=12, color:uint=0x0, bold:Boolean=false)
		{
			super(width, height, text, fontName, fontSize, color, bold);
		}
		override public function get hasVisibleArea():Boolean
		{
			var has:Boolean = alpha != 0.0 && visible && scaleX != 0.0 && scaleY != 0.0;

			if(!has)
			{
				batch = parent as TextFieldBatch;
				
				if(batch) batch.hideTextField(this);
			}
			
			return has
		}
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			alpha = 0;
			border = false;
		}
		override public function clone():DisplayObject
		{
			var c:BatchableTextField = new BatchableTextField(width,height,text,fontName,fontSize,color,bold);
			
			c.autoScale = autoScale;
			c.hAlign = hAlign;
			c.vAlign = vAlign;
			c.touchable = touchable;
			return c;
		}
		
	}
}