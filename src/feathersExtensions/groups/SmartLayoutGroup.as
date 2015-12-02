package feathersExtensions.groups
{
import feathers.controls.LayoutGroup;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.TiledColumnsLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.controls.FeathersAppDrawer;
import feathersExtensions.data.SmartListCollection;
import feathersExtensions.layout.SmartAnchorLayout;

import managers.interfaces.IStateReceiver;

import mvc.controller.events.AppMessage;
import mvc.view.interfaces.IMenuHolder;

import starling.display.DisplayObject;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starlingExtensions.interfaces.IActivable;

public class SmartLayoutGroup extends LayoutGroup implements IActivable,IStateReceiver,IMenuHolder
	{
		public function SmartLayoutGroup(_initChildren:Boolean=false)
		{
			super();
			clipContent = false;			
			width = height = 100;
			
			if(_initChildren) 
			{
				initChildren();
				childrenComplete = true;
			}
		}
		override protected function initialize():void
		{
			super.initialize();
			if(!childrenComplete) 
			{
				initChildren();
				childrenComplete = true;
			}
			validateSize();
			
			if(visible) activate(visible);
		}
		protected var childrenComplete:Boolean = false;
		protected function initChildren():void
		{
		}
		override public function validate():void
		{
			super.validate();
			if(!isInitialized) return;
			
			validateSize();
		}
		public function setPercentSize(percentWidth:Number,percentHeight:Number):void
		{
			percentWidth = percentWidth>1 ? percentWidth/100 : percentWidth;
			percentHeight = percentHeight>1 ? percentHeight/100 : percentHeight;
			
			if(parent is LayoutViewPort)
			{
				var pw:Number = (parent as LayoutViewPort).visibleWidth;
				var ph:Number = (parent as LayoutViewPort).visibleHeight;
			}
			else 
			{
				pw = parent.width;
				ph = parent.height;
			}
			setSize(pw*percentWidth,ph*percentHeight);
		}
		protected function validateSize():void
		{
		}
		public function addChildren(...childrens):void
		{
			for each(var child:DisplayObject in childrens)
			{
				if(child) addChild(child);
			}
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
		public static function getHLayout(hLayout:HorizontalLayout=null,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
										  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):HorizontalLayout
		{
			hLayout = hLayout ? hLayout : new HorizontalLayout();
			
			hLayout.verticalAlign = vintToAlign(va);
			hLayout.horizontalAlign = hintToAlign(ha);
			hLayout.gap = gap;
			hLayout.padding = padding;
			hLayout.manageVisibility = manageVisibility;
			hLayout.useVirtualLayout = useVirtualLayout;
			hLayout.typicalItemWidth = typicalItemWidth;
			hLayout.typicalItemHeight = typicalItemHeight;
			
			return hLayout;
		}
		public static function getVLayout(vLayout:VerticalLayout=null,va:int=0,ha:int=0,gap:Number=0,padding:Number=0,useVirtualLayout:Boolean=true,manageVisibility:Boolean=true,
										  typicalItemWidth:Number=-1,typicalItemHeight:Number=-1):VerticalLayout
		{
			vLayout = vLayout ? vLayout : new VerticalLayout();
			
			vLayout.verticalAlign = vintToAlign(va);
			vLayout.horizontalAlign = hintToAlign(ha);
			vLayout.gap = gap;
			vLayout.padding = padding;
			vLayout.manageVisibility = manageVisibility;
			vLayout.useVirtualLayout = useVirtualLayout;
			vLayout.typicalItemWidth = typicalItemWidth;
			vLayout.typicalItemHeight = typicalItemHeight;
			return vLayout;
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
		public function get hLayout():HorizontalLayout
		{
			return _layout as HorizontalLayout;
		}
		public function get vLayout():VerticalLayout
		{
			return _layout as VerticalLayout;
		}
		public function get aLayout():AnchorLayout
		{
			return _layout as AnchorLayout;
		}
		public function get saLayout():SmartAnchorLayout
		{
			return _layout as SmartAnchorLayout;
		}
		
		// INTERFACES IMPLEMENTATIONS
		
		protected var _active:Boolean = false;
		public function get active():Boolean
		{
			return _active;
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			activate(value);
		}
		public function activate(value:Boolean):void
		{
			_active = value;
			if(value) addEventListener(TouchEvent.TOUCH,onTouch);
			else removeEventListener(TouchEvent.TOUCH,onTouch);
		}
		public var disableAppDrawersOnScrolling:Boolean = false;
		public function disableAppDrawers(disable:Boolean,allDrawers:Boolean=false):void
		{
			if(disableAppDrawersOnScrolling)
			{
				var type:String = layout is HorizontalLayout ? TiledColumnsLayout.PAGING_HORIZONTAL : (layout is VerticalLayout ? TiledColumnsLayout.PAGING_VERTICAL : null);
				AppMessage.message(FeathersAppDrawer.ACTIVATE_DRAWERS,!disable,allDrawers ? null : type);
			}
		}
		protected function onTouch(e:TouchEvent):void
		{
			if(disableAppDrawersOnScrolling)
			{
				if(e.getTouch(this,TouchPhase.BEGAN)) disableAppDrawers(true,true);
				if(e.getTouch(this,TouchPhase.ENDED)) disableAppDrawers(false,true);
			}
		}
		protected var _menu:SmartListCollection;
		public function get menu():SmartListCollection
		{
			return _menu; 
		}
		protected var _state:Object;
		public function set state(value:Object):void
		{
			_state = value;
		}
		public function get state():Object
		{
			return _state;
		}
		public function get stateName():String
		{
			return _state+"";
		}
		public function includeInState(obj:DisplayObject,state:*):void
		{
			
		}
		public function excludeFromState(obj:DisplayObject,state:*):void
		{
			
		}
	}
}