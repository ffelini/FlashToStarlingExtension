package gameComponents.layers
{
import flash.display.DisplayObjectContainer;

import gameComponents.PopUp;
import managers.PopUpManager;
import starling.display.DisplayObject;
import starling.events.TouchEvent;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.interfaces.IActivable;

public class PopUpLayerBase extends PopUpManager
	{
		public function PopUpLayerBase(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(mirror,_rootMirror);
		}
		override public function set currentPopUp(value:DisplayObject):void
		{					
			closeOnClickOut = value && (value as PopUp).closeEnabled;
			
			super.currentPopUp = value;	
			
			updateBackground(_currentPopUp!=null);
			
			animatePopUp(_currentPopUp);	
		}
		protected function updateConnection(connected:Boolean):void
		{
			
		}
		protected function updateBackground(show:Boolean):void
		{
			
		}
		protected function animatePopUp(popUp:DisplayObject, add:Boolean=true):void
		{
			touchable = false;
		}
		protected function popUpAnimationEndHandler(popUp:DisplayObject):void
		{
			if(popUp is IActivable) (popUp as IActivable).activate(true);
			touchable = true;
		}
		protected var _closeOnClickOut:Boolean = false; 
		public function set closeOnClickOut(value:Boolean):void
		{
			_closeOnClickOut = value;
			if(_closeOnClickOut) addEventListener(TouchEvent.TOUCH,onTouchOut);
			else removeEventListener(TouchEvent.TOUCH,onTouchOut);
		}
		protected function onTouchOut(e:TouchEvent):void
		{
		}
		public function onFbLogIn():void
		{
			(currentPopUp as PopUp).updateUI();
		}
		public function onFbLogOut():void
		{
			(currentPopUp as PopUp).updateUI();
		}
	}
}