package feathersExtensions.controls
{
import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.controls.Slider;

import reflection.model.AbstractPublicAPI;

public class SliderPropValue extends Slider
	{
		public var propertyToSlide:String;
		
		public function SliderPropValue()
		{
			super();
		}
		protected var _apiHolder:AbstractPublicAPI;
		public function set apiHolder(value:AbstractPublicAPI):void
		{
			_apiHolder = value;
		}
		protected static var callOutLabel:Label;
		protected var callOut:Callout;
		protected var _showCallOut:Boolean = true;
		public function set showCallOut(value:Boolean):void
		{
			_showCallOut = value;
		}
		override public function set value(newValue:Number):void
		{
			super.value = newValue;
			
			if(_apiHolder) _apiHolder.setApiValue(propertyToSlide,targetPropValue);
			
			if(callOut) callOut.close(false);
			
			if(!callOutLabel) callOutLabel = new Label();
			callOutLabel.text = targetPropValue+"";
			
			callOut = Callout.show(callOutLabel,thumb, Callout.DIRECTION_UP,false,callOut ? callOutFactory : null);
			callOutLabel.textRendererProperties.wordWrap = false;
			callOut.disposeContent = false;
			callOut.disposeOnSelfClose = false;
		}
		protected function callOutFactory():Callout
		{
			return callOut;
		}
		public function get targetPropValue():Object
		{
			var possibleValues:Vector.<Object> = _apiHolder.getValues(propertyToSlide);
			return possibleValues && possibleValues[int(value)] ? possibleValues[int(value)] : value;
		}
	}
}