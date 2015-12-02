package feathersExtensions.controls.inputs
{
import feathers.controls.Callout;
import feathers.controls.Label;

import flash.text.SoftKeyboardType;

import mx.events.ValidationResultEvent;
import mx.validators.EmailValidator;

import starling.events.Event;

import utils.TimeOut;

public class MailInput extends SmartTextInput
	{
		public var enableValidation:Boolean;
		public var realTimeValidation:Boolean;
		
		public function MailInput(enableValidation:Boolean=true,realTimeValidation:Boolean=false)
		{
			super();
			
			this.enableValidation = enableValidation;
			this.realTimeValidation = realTimeValidation;
			
			textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
		}
		override protected function textEditor_focusInHandler(event:Event):void
		{
			super.textEditor_focusInHandler(event);
			if(callOut) callOut.close();
		}
		override protected function textEditor_focusOutHandler(event:Event):void
		{
			super.textEditor_focusOutHandler(event);
			if(enableValidation) TimeOut.setTimeOutFunc(validateEmail,500);
		}
		override protected function textEditor_changeHandler(event:Event):void
		{
			super.textEditor_changeHandler(event);
			if(realTimeValidation) validateEmail();
		}
		protected static var emailValidator:EmailValidator;
		protected static var validationLabel:Label;
		protected static var callOut:Callout;
		public function validateEmail():Boolean
		{
			if(!enableValidation) return true;
			
			if(!emailValidator) emailValidator = new EmailValidator();
			
			try{
				var evt:ValidationResultEvent = emailValidator.validate(text);
				if(evt.message=="") return true;
			}catch(e:Error){
				return true;
			}
			
			if(!validationLabel) validationLabel = new Label();
			validationLabel.text = evt.message;
			
			callOut = Callout.show(validationLabel,this,Callout.DIRECTION_UP,true);
			callOut.disposeContent = false;
			callOut.disposeOnSelfClose = false;
			callOut.closeOnTouchBeganOutside = true;
			
			return false;
		}
	}
}