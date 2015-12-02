package mvc.view.screen
{
import feathers.controls.ScreenNavigator;

import mvc.controller.AbstractController;
import mvc.view.interfaces.IAbstractView;

import starling.display.DisplayObject;

public class AbstractFeathersScreenNavigator extends ScreenNavigator implements IAbstractView
	{
		public function AbstractFeathersScreenNavigator()
		{
			super();
		}
		protected var _controller:AbstractController;
		public function setController(value:AbstractController):void
		{
			_controller = value;
			
			var _numChildren:Number = numChildren;
			var child:IAbstractView;
			for(var i:int = 0;i<_numChildren;i++)
			{
				child = getChildAt(i) as IAbstractView;
				if(child) child.setController(_controller);
			}
		}
		public function onModelUpdated():void
		{
			
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is IAbstractView)
			{
				(child as IAbstractView).setController(_controller);
			}
			return super.addChildAt(child, index);
		}
		public function setPercentSize(percentWidth:Number,percentHeight:Number):void
		{
			percentWidth = percentWidth>1 ? percentWidth/100 : percentWidth;
			percentHeight = percentHeight>1 ? percentHeight/100 : percentHeight;
			
			setSize(parent.width*percentWidth,parent.height*percentHeight);
		}
	}
}