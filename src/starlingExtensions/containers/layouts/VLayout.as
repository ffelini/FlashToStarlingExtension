package starlingExtensions.containers.layouts
{
import flash.geom.Rectangle;

import starling.display.DisplayObject;

import starlingExtensions.uiComponents.IItemRenderer;

public class VLayout extends Layout
	{
		public function VLayout(_rowHeight:Number=100)
		{
			super();
			rowHeight = _rowHeight;
		}
		override public function layoutItem(ir:IItemRenderer,index:int):void
		{
			(ir as DisplayObject).x = paddingLeft;
			(ir as DisplayObject).y = index>0 ? index*(rowHeight+gap)+paddingTop : paddingTop;
			
			super.layoutItem(ir,index);
		}
		override public function isRectInView(rect:Rectangle):Boolean
		{
			itemsViewPort.height = viewPort.height + (rowHeight*outOfViewRows);
			return super.isRectInView(rect);
		}
		override public function getBounds(numItems:int):Rectangle
		{
			layoutBounds.setEmpty();
			var _x:Number;
			var _y:Number;
			
			for(var index:int=0;index<numItems;index++)
			{
				_x = paddingLeft;
				_y = index>0 ? index*(rowHeight+gap) : paddingTop;
				
				layoutBounds.x = _x<layoutBounds.x ? _x : layoutBounds.x;
				layoutBounds.y = _y<layoutBounds.y ? _y : layoutBounds.y;
				layoutBounds.width = _x + columnWidth > layoutBounds.width ? _x + columnWidth : layoutBounds.width;
				layoutBounds.height  = _y + rowHeight > layoutBounds.height ? _y + rowHeight : layoutBounds.height;
			}
			
			return layoutBounds;
		}
		
	}
}