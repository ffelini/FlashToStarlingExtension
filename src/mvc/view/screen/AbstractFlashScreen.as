package mvc.view.screen
{
import mvc.controller.AbstractController;
import mvc.view.interfaces.IAbstractView;

import starling.display.DisplayObject;

import starlingExtensions.flash.FlashDisplay_Mirror;

public class AbstractFlashScreen extends FlashDisplay_Mirror
	{
		protected var _controller:AbstractController;
		
		public function AbstractFlashScreen(controller:AbstractController)
		{
			super();
			_controller = controller;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is IAbstractView)
			{
				(child as IAbstractView).setController(_controller);
			}
			return super.addChildAt(child, index);
		}
	}
}