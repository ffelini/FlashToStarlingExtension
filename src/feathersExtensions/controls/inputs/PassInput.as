package feathersExtensions.controls.inputs
{
import feathers.controls.Callout;
import feathers.controls.Label;

import flash.text.SoftKeyboardType;

import mx.events.ValidationResultEvent;
import mx.validators.StringValidator;

import starling.events.Event;

import utils.TimeOut;

public class PassInput extends SmartTextInput
	{
		
		public var enableValidation:Boolean = true;
		public var realTimeValidation:Boolean;
		
		public var passHideDelay:Number = 400;
		public var showPassOnInput:Boolean = false;
		
		public function PassInput()
		{
			super();
			displayAsPassword = true;
			
			textEditorProperties.softKeyboardType = SoftKeyboardType.DEFAULT;
		}
		override protected function textEditor_focusInHandler(event:Event):void
		{
			super.textEditor_focusInHandler(event);
			if(callOut) callOut.close();
		}
		override protected function textEditor_focusOutHandler(event:Event):void
		{
			super.textEditor_focusOutHandler(event);
			if(enableValidation) TimeOut.setTimeOutFunc(validatePassword,500);
		}
		override protected function textEditor_changeHandler(event:Event):void
		{
			super.textEditor_changeHandler(event);
			
			if(showPassOnInput) 
			{
				displayAsPassword = false;
				TimeOut.setTimeOutFunc(showPassword,passHideDelay,true,false);
			}
			if(realTimeValidation) validatePassword();
		}
		protected function showPassword(display:Boolean):void
		{
			displayAsPassword = !display;
		}
		protected var passValidator:StringValidator;
		protected var validationLabel:Label;
		protected var callOut:Callout;
		public function validatePassword(maxLength:int=100,minLength:int=1):Boolean
		{
			if(!enableValidation) return true;
			
			if(!passValidator)
			{
				passValidator = new StringValidator();
			}
			passValidator.maxLength = maxLength;
			passValidator.minLength = minLength;
			
			try{
				var evt:ValidationResultEvent = passValidator.validate(text);
				if(evt.message=="") return true;
			}catch(e:Error){
				return true;
			}
			
			if(!validationLabel) validationLabel = new Label();
			validationLabel.text = evt.message;
			
			callOut = Callout.show(validationLabel,this,Callout.DIRECTION_UP,false);
			callOut.disposeContent = false;
			callOut.disposeOnSelfClose = false;
			callOut.closeOnTouchBeganOutside = true;
			
			return false;
		}
	}
}