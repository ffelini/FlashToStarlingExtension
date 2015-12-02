package starlingExtensions.containers.layouts
{
import flash.geom.Rectangle;

import starling.display.DisplayObject;

import starlingExtensions.uiComponents.IItemRenderer;

public class HLayout extends Layout
	{
		public function HLayout(_columnWidth:Number=100)
		{
			super();
			columnWidth = _columnWidth;
		}
		override public function layoutItem(ir:IItemRenderer,index:int):void
		{
			(ir as DisplayObject).x = index>0 ? index*(columnWidth+gap)+paddingLeft : paddingLeft;
			(ir as DisplayObject).y = paddingTop;
			
			super.layoutItem(ir,index);
		}
		override public function isRectInView(rect:Rectangle):Boolean
		{
			itemsViewPort.width = viewPort.width+(columnWidth*outOfViewColumns);
			return super.isRectInView(rect);
		}
		override public function getBounds(numItems:int):Rectangle
		{
			layoutBounds.setEmpty();
			var _x:Number;
			var _y:Number;
			
			for(var index:int=0;index<numItems;index++)
			{
				_x = index>0 ? index*(columnWidth+gap) : paddingLeft;
				_y = paddingTop;
				
				layoutBounds.x = _x<layoutBounds.x ? _x : layoutBounds.x;
				layoutBounds.y = _y<layoutBounds.y ? _y : layoutBounds.y;
				layoutBounds.width = _x + columnWidth > layoutBounds.width ? _x + columnWidth : layoutBounds.width;
				layoutBounds.height  = _y + rowHeight > layoutBounds.height ? _y + rowHeight : layoutBounds.height;
			}
			
			return layoutBounds;
		}
		
	}
}