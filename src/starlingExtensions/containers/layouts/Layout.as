package starlingExtensions.containers.layouts
{
import flash.geom.Rectangle;

import starlingExtensions.uiComponents.IItemRenderer;

public class Layout
	{
		public var gap:Number = 5;
		
		public var paddingLeft:Number = 5;
		public var paddingRight:Number = 5;
		public var paddingTop:Number = 5;
		public var paddingBottom:Number = 5;
		
		public var viewPort:Rectangle;
		
		public var horizontalAlign:int = 0;
		public var verticalAlign:int = 0;
		
		public var useVirtualLayout:Boolean = false;
		
		public var columnWidth:Number;
		public var rowHeight:Number;
				
		public function Layout()
		{
		}
		protected var lastIR:IItemRenderer;
		public function layoutItem(ir:IItemRenderer,index:int):void
		{
			ir.updateLayout();
			lastIR = ir;
		}
		public function clear():void
		{
			lastIR = null;
		}
		protected var itemsViewPort:Rectangle;
		public var outOfViewRows:Number = 1;
		public var outOfViewColumns:Number = 1;
		public function setViewPort(rect:Rectangle):void
		{
			viewPort = rect;
			itemsViewPort = viewPort.clone();
		}
		public function isRectInView(rect:Rectangle):Boolean
		{
			return rect.intersects(itemsViewPort);
		}
		protected var layoutBounds:Rectangle = new Rectangle();
		public function getBounds(numItems:int):Rectangle
		{
			return layoutBounds;
		}
	}
}