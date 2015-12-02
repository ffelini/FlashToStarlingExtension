package mvc.view.components
{
import feathersExtensions.groups.SmartLayoutGroup;

import mvc.controller.AbstractController;
import mvc.view.interfaces.IAbstractView;

import starling.display.DisplayObject;

public class AbstractLayoutGroup extends SmartLayoutGroup implements IAbstractView
	{
		public function AbstractLayoutGroup(_initChildren:Boolean=false)
		{
			super(_initChildren);
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
	}
}