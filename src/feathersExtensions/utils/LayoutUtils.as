package feathersExtensions.utils
{
import feathers.controls.Scroller;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.TiledColumnsLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;

import spark.layouts.TileLayout;

import starling.display.DisplayObject;

public class LayoutUtils
	{
		public function LayoutUtils()
		{
		}
		public static function validateScrollPolicy(control:Object):void
		{
			var layout:Object = control.hasOwnProperty("layout") ? control["layout"] : null;
			if(!layout) return;
			
			if(layout is HorizontalLayout) 
			{
				control.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				control.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			}
			if(layout is VerticalLayout) 
			{
				control.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				control.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			}
			if(layout is TileLayout) control.verticalScrollPolicy = control.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			if(layout is TiledRowsLayout) 
			{
				control.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				control.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			}
			if(layout is TiledColumnsLayout) 
			{
				control.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				control.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			}
		}
		public static function updateScrolling(scroller:Scroller,enable:Boolean,affectClipping:Boolean = true,affectScollBarDisplayMode:Boolean=true):void
		{
			if(affectClipping) scroller.clipContent = enable;
			if(affectScollBarDisplayMode) scroller.scrollBarDisplayMode = enable ? Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT : Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			scroller.horizontalScrollPolicy = enable ? Scroller.SCROLL_POLICY_AUTO : Scroller.SCROLL_POLICY_OFF;
			scroller.verticalScrollPolicy = enable ? Scroller.SCROLL_POLICY_AUTO : Scroller.SCROLL_POLICY_OFF;
		}
		public static function validateSize(value:Number,max:Number=NaN,min:Number=NaN):Number
		{
			if(!isNaN(max)) value = value>max ? max : value;
			if(!isNaN(min)) value = value<min ? min : value;
			
			return value;
		}
		private static function hintToAlign(value:int):String
		{
			if(value>0) return HorizontalLayout.HORIZONTAL_ALIGN_RIGHT;
			if(value<0) return HorizontalLayout.HORIZONTAL_ALIGN_LEFT;			
			if(value==0) return HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			
			return "";
		}
		private static function vintToAlign(value:int):String
		{
			if(value>0) return VerticalLayout.VERTICAL_ALIGN_BOTTOM;
			if(value<0) return VerticalLayout.VERTICAL_ALIGN_TOP;			
			if(value==0) return VerticalLayout.VERTICAL_ALIGN_MIDDLE;	
			
			return "";
		}
		public static function getHLayout(hl:HorizontalLayout=null,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
										  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):HorizontalLayout
		{
			hl = hl ? hl : new HorizontalLayout();
			
			hl.verticalAlign = vintToAlign(va);
			hl.horizontalAlign = hintToAlign(ha);
			hl.gap = gap;
			hl.padding = padding;
			hl.manageVisibility = manageVisibility;
			hl.useVirtualLayout = useVirtualLayout;
			hl.typicalItemWidth = typicalItemWidth;
			hl.typicalItemHeight = typicalItemHeight;
			
			return hl;
		}
		public static function getVLayout(vl:VerticalLayout=null,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
										  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):VerticalLayout
		{
			vl = vl ? vl : new VerticalLayout();
			
			vl.verticalAlign = vintToAlign(va);
			vl.horizontalAlign = hintToAlign(ha);
			vl.gap = gap;
			vl.padding = padding;
			vl.manageVisibility = manageVisibility;
			vl.useVirtualLayout = useVirtualLayout;
			vl.typicalItemWidth = typicalItemWidth;
			vl.typicalItemHeight = typicalItemHeight;
			return vl;
		}
		public static function getTiledRowsLayout(trl:TiledRowsLayout,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
												  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):TiledRowsLayout
		{
			trl = trl ? trl : new TiledRowsLayout();
			
			trl.verticalAlign = vintToAlign(va);
			trl.horizontalAlign = hintToAlign(ha);
			trl.gap = gap;
			trl.padding = padding;
			trl.manageVisibility = manageVisibility;
			trl.useVirtualLayout = useVirtualLayout;
			trl.typicalItemWidth = typicalItemWidth;
			trl.typicalItemHeight = typicalItemHeight;
			
			return trl;
		}
		public static function getTiledColumnsLayout(tcl:TiledColumnsLayout,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
												  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):TiledColumnsLayout
		{
			tcl = tcl ? tcl : new TiledColumnsLayout();
			
			tcl.verticalAlign = vintToAlign(va);
			tcl.horizontalAlign = hintToAlign(ha);
			tcl.gap = gap;
			tcl.padding = padding;
			tcl.manageVisibility = manageVisibility;
			tcl.useVirtualLayout = useVirtualLayout;
			tcl.typicalItemWidth = typicalItemWidth;
			tcl.typicalItemHeight = typicalItemHeight;
			
			return tcl;
		}
		public static function fitItemToLayout(item:DisplayObject,layout:ILayout):Boolean
		{
			if(!item || !layout) return false;
			
			var typicalItemWidth:Number; 
			var typicalItemHeight:Number;
			
			if(layout is HorizontalLayout)
			{
				typicalItemHeight = (layout as HorizontalLayout).typicalItemHeight;
				typicalItemWidth = (layout as HorizontalLayout).typicalItemWidth;
			}
			if(layout is VerticalLayout)
			{
				typicalItemHeight = (layout as VerticalLayout).typicalItemHeight;
				typicalItemWidth = (layout as VerticalLayout).typicalItemWidth;
			}
			if(layout is TiledRowsLayout)
			{
				typicalItemHeight = (layout as TiledRowsLayout).typicalItemHeight;
				typicalItemWidth = (layout as TiledRowsLayout).typicalItemWidth;
			}
			if(layout is TiledColumnsLayout)
			{
				typicalItemHeight = (layout as TiledColumnsLayout).typicalItemHeight;
				typicalItemWidth = (layout as TiledColumnsLayout).typicalItemWidth;
			}
			if(typicalItemWidth<=0) typicalItemWidth = layout is VerticalLayout ? item.parent.width : -1;
			if(typicalItemHeight<=0) typicalItemHeight = layout is HorizontalLayout ? item.parent.height : -1;
			
			item.width = typicalItemWidth>0 ? typicalItemWidth : item.width;
			item.height = typicalItemHeight>0 ? typicalItemHeight : item.height;
			
			return typicalItemWidth>0 && typicalItemHeight>0;
		}
	}
}