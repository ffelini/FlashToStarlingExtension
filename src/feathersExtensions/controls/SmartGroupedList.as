package feathersExtensions.controls
{
import feathers.controls.GroupedList;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.data.HierarchicalCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.TiledColumnsLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.layout.SmartAnchorLayoutData;
import feathersExtensions.renderers.SmartGroupedIR;
import feathersExtensions.themes.SmartTheme;

import mvc.controller.events.AppMessage;

import spark.layouts.TileLayout;

import starlingExtensions.interfaces.IActivable;

import utils.TimeOut;

public class SmartGroupedList extends GroupedList implements IActivable
	{
		public var autoToggleSelection:Boolean = true;
		
		public function SmartGroupedList()
		{
			super();
			initLayout();
			
			itemRendererType = SmartGroupedIR;
		}
		override protected function initialize():void
		{
			super.initialize();
		}
		public var smartItemLayoutData:SmartAnchorLayoutData = new SmartAnchorLayoutData();
		protected function initLayout():void
		{
			SmartTheme.validateSmartLayoutData(smartItemLayoutData);
		}
		override public function set layout(value:ILayout):void
		{
			super.layout = value;
			if(value is HorizontalLayout) verticalScrollPolicy = SCROLL_POLICY_OFF;
			if(value is VerticalLayout) horizontalScrollPolicy = SCROLL_POLICY_OFF;
			if(value is TileLayout) verticalScrollPolicy = horizontalScrollPolicy = SCROLL_POLICY_AUTO;
			if(value is TiledRowsLayout) verticalScrollPolicy = SCROLL_POLICY_OFF;
			if(value is TiledColumnsLayout) horizontalScrollPolicy = SCROLL_POLICY_OFF;
		}
		public function set dataProviderSource(value:*):void
		{
			if(!dataProvider) dataProvider = new HierarchicalCollection();
			
			_dataProvider.data = value;
		}
		public function invalidateItemRenderersData():void
		{
			var ir:BaseDefaultItemRenderer;
			for each(var data:Object in _dataProvider.data)
			{
				ir = getItemRenderer(data);
				if(ir) ir.invalidate(INVALIDATION_FLAG_DATA);
			}
		}
		override public function setSelectedLocation(groupIndex:int, itemIndex:int):void
		{
			super.setSelectedLocation(groupIndex,itemIndex);
			
			onItemSelected();
			
			if(autoToggleSelection) TimeOut.setTimeOutFunc(unSelect,100);
		}
		public function unSelect():void
		{
			selectedItem = null;
		}
		public var autoScrollToSelectedItem:Boolean = false;
		protected function onItemSelected():void
		{
			if(autoScrollToSelectedItem) scrollToDisplayIndex(selectedItemIndex,1);
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(isInitialized) activate(value);
		}
		public var disableAppDrawersOnScrolling:Boolean = true;
		override protected function completeScroll():void
		{
			super.completeScroll();
			disableAppDrawers(false);
		}
		override protected function startScroll():void
		{
			super.startScroll();
			disableAppDrawers(true);
		}
		public function disableAppDrawers(disable:Boolean,allDrawers:Boolean=false):void
		{
			if(disableAppDrawersOnScrolling)
			{
				var type:String = layout is HorizontalLayout ? TiledColumnsLayout.PAGING_HORIZONTAL : (layout is VerticalLayout ? TiledColumnsLayout.PAGING_VERTICAL : null);
				AppMessage.message(FeathersAppDrawer.ACTIVATE_DRAWERS,!disable,allDrawers ? null : type);
			}
		}
		protected var _active:Boolean = false;
		public function get active():Boolean
		{
			return _active;
		}
		public function activate(value:Boolean):void
		{
			_active = value;
		}
		public function getItemRenderer(data:Object):BaseDefaultItemRenderer
		{
			var numItems:int = dataViewPort ? dataViewPort.numChildren : 0;
			if(numItems==0) return null;
			
			var ir:BaseDefaultItemRenderer;
			for(var i:int=0;i<numItems;i++)
			{
				ir = dataViewPort.getChildAt(i) as BaseDefaultItemRenderer;
				if(!ir) continue;
				
				if(ir.data==data) return ir;
			}
			return null;
		}
		public function invalidateData():void
		{
			
		}
	}
}