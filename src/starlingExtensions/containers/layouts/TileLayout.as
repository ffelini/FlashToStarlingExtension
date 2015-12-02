package starlingExtensions.containers.layouts
{
import flash.geom.Rectangle;

import starling.display.DisplayObject;

import starlingExtensions.uiComponents.IItemRenderer;

public class TileLayout extends Layout
	{
		public static const TYPE_VERTICAL:String = "vertical";
		public static const TYPE_HORIZONTAL:String = "horizontal";
		
		public var type:String = TYPE_VERTICAL;
		
		public function TileLayout(_columnWidth:Number=100,_rowHeight:Number=100)
		{
			super();
			columnWidth = _columnWidth;
			rowHeight = _rowHeight;
		}
		protected var row:Number = 0;
		protected var column:Number = 0;
		override public function layoutItem(ir:IItemRenderer,index:int):void
		{
			if(type==TYPE_VERTICAL)
			{
				(ir as DisplayObject).x = lastIR ? (lastIR as DisplayObject).x + columnWidth + gap : paddingLeft;
				(ir as DisplayObject).y = (rowHeight + gap)*row + paddingTop;
			}
			if(type==TYPE_HORIZONTAL)
			{
				(ir as DisplayObject).y = lastIR ? (lastIR as DisplayObject).y + rowHeight + gap : paddingTop;
				(ir as DisplayObject).x = (columnWidth + gap)*column + paddingLeft;
			}
			
			lastIR = ir;
			
			if(type==TYPE_VERTICAL && (ir as DisplayObject).x + columnWidth > viewPort.width)
			{
				row++;
				lastIR = null;
				layoutItem(ir,index);
				return;
			}
			if(type==TYPE_HORIZONTAL && (ir as DisplayObject).y + rowHeight > viewPort.height) 
			{
				column++;
				lastIR = null;
				layoutItem(ir,index);
				return;
			}
			ir.updateLayout();
		}
		override public function clear():void
		{
			super.clear();
			row = column = 0;
		}
		override public function isRectInView(rect:Rectangle):Boolean
		{
			if(type==TYPE_HORIZONTAL) itemsViewPort.width = viewPort.width + (columnWidth*outOfViewColumns);
			if(type==TYPE_VERTICAL) itemsViewPort.height = viewPort.height + (rowHeight*outOfViewRows);
			return super.isRectInView(rect);
		}
		override public function getBounds(numItems:int):Rectangle
		{
			layoutBounds.setEmpty();
			var _x:Number;
			var _y:Number;
			var _lastX:Number;
			var _lastY:Number;
			
			for(var index:int=0;index<numItems;index++)
			{
				if(type==TYPE_VERTICAL)
				{
					_x = _lastX>0 ? _lastX + columnWidth + gap : paddingLeft;
					_y = (rowHeight + gap)*row + paddingTop;
				}
				if(type==TYPE_HORIZONTAL)
				{
					_y = _lastY>0 ? _lastY + rowHeight + gap : paddingTop;
					_x = (columnWidth + gap)*column + paddingLeft;
				}
				
				_lastX = _x;
				_lastY = _y;
				
				if(type==TYPE_VERTICAL && _x + columnWidth > viewPort.width)
				{
					row++;
					_lastX = _lastY = 0;
					index --;
					continue;
				}
				else if(type==TYPE_HORIZONTAL && _y + rowHeight > viewPort.height) 
				{
					column++;
					_lastX = _lastY = 0;
					index --;
					continue;
				}
				
				layoutBounds.x = _x<layoutBounds.x ? _x : layoutBounds.x;
				layoutBounds.y = _y<layoutBounds.y ? _y : layoutBounds.y;
				layoutBounds.width = _x + columnWidth > layoutBounds.width ? _x + columnWidth : layoutBounds.width;
				layoutBounds.height  = _y + rowHeight > layoutBounds.height ? _y + rowHeight : layoutBounds.height;
			}
			
			return layoutBounds;
		}
	}
}