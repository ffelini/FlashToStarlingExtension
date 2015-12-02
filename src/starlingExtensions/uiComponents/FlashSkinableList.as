package starlingExtensions.uiComponents
{
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import starling.display.DisplayObject;

import starlingExtensions.containers.layouts.HLayout;
import starlingExtensions.containers.layouts.Layout;
import starlingExtensions.containers.layouts.TileLayout;
import starlingExtensions.containers.layouts.VLayout;
import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashHint;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.uiComponents.renderers.FlashSkinableIR;
import starlingExtensions.utils.DisplayUtils;

public class FlashSkinableList extends FlashSprite_Mirror
	{
		public var beginMask:DisplayObject;
		public var endMask:DisplayObject;
		
		public var showMask:Boolean = true;
		public var showBeginMask:Boolean = true;
		public var showEndMask:Boolean = true;
		
		public var background:DisplayObject;
		
		public var irSkin:FlashSkinableIR;
		
		public var itemHint:FlashHint;
		
		public var list:SkinnableList = new SkinnableList(); 
		
		public function FlashSkinableList(_mirror:DisplayObjectContainer, _rootMirror:FlashDisplay_Mirror)
		{
			super(_mirror, _rootMirror);
			visible = false;
		}
		override public function createChildren():void
		{
			super.createChildren();
			
			beginMask = getChildByName("beginMask");
			endMask = getChildByName("endMask");
			background = getChildByName("background");
			if(beginMask) beginMask.visible = beginMask.touchable = false;
			if(endMask) endMask.visible = endMask.touchable = false; 
			
			irSkin = getChildByName("irSkin") as FlashSkinableIR;
			(irSkin as DisplayObject).removeFromParent();
			
			itemHint = getChildByName("itemHint") as FlashHint;
			if(itemHint)
			{
				itemHint.removeFromParent();
				itemHint.visible = false;
			}
			
			list.hint = itemHint;
			if(irSkin && !list.parent)
			{
				list.skin = irSkin;
				list.clipRect = getBounds(this);
				list.setupHandler = setup;
				
				addChild(list);
				if(beginMask) addChild(beginMask);
				if(endMask) addChild(endMask);
			}
			if(itemHint) addChild(itemHint);
		}
		public function getIRAt(index:int):FlashSkinableIR
		{
			return list.getIRAt(index);
		}		
		public function get numIRInView():int
		{
			return list.numIRInView;
		}
		protected var _setupHandler:Function;
		public function set setupHandler(value:Function):void
		{
			_setupHandler = value;
		}
		/**
		 * sets the list layout and updates layout rowHeight and columnWidth by the irSkin size automatically 
		 * @param value
		 * 
		 */		
		public function set layout(value:Layout):void
		{
			list.layout = value;
			
			value.columnWidth = (irSkin as DisplayObject).width;
			value.rowHeight = (irSkin as DisplayObject).height;
			
			invalidateLayout();
		}
		public function get layout():Layout
		{
			return list.layout;
		}
		private var br:Rectangle;
		private var er:Rectangle;
		public function invalidateLayout():void
		{
			br = beginMask ? beginMask.getBounds(this,br) : null;
			er = endMask ? endMask.getBounds(this,er) : null;
			
			if(list.layout is HLayout || (list.layout is TileLayout && (list.layout as TileLayout).type==TileLayout.TYPE_HORIZONTAL)) paddingLayout(br ? br.width/2 : 0,er ? er.width/2 : 0,0,0);
			if(list.layout is VLayout || (list.layout is TileLayout && (list.layout as TileLayout).type==TileLayout.TYPE_VERTICAL)) paddingLayout(0,0,br ? br.height/2 : 0,er ? er.height/2 : 0);			
		}
		public function paddingLayout(pL:Number,pR:Number,pT:Number,pB:Number):void
		{
			list.paddingLayout(pL,pR,pT,pB);
			updateBackground();
		}
		public var readjustBackground:Boolean = true;
		protected function updateBackground():void 
		{
			if(readjustBackground && background && list && list.clipRect) 
			{
				addChildAt(background,0);
				DisplayUtils.setBounds(background,list.clipRect);
			}
		}
		protected function setup():void
		{
			visible = list.itemRenderers.length>0;
			if(beginMask) beginMask.visible = showMask && showBeginMask && list.draggable;
			if(endMask) endMask.visible = showMask && showEndMask && list.draggable;
			
			if(_setupHandler!=null) _setupHandler();
		}
		public function set dataProvider(value:*):void
		{
			list.dataProvider = value;
			visible = list.itemRenderers.length>0;
		}
		public function get dataProvider():*
		{
			return list.dataProvider;
		}
	}
}