package feathersExtensions.controls
{
import feathers.controls.List;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.data.ListCollection;
import feathers.events.CollectionEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.TiledColumnsLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.layout.SmartAnchorLayout;
import feathersExtensions.layout.SmartAnchorLayoutData;
import feathersExtensions.renderers.SmartIR;
import feathersExtensions.themes.SmartTheme;
import feathersExtensions.utils.LayoutUtils;

import mvc.controller.AbstractController;
import mvc.controller.events.AppMessage;
import mvc.view.interfaces.IAbstractView;

import starling.events.Event;

import starlingExtensions.interfaces.IActivable;

import utils.Range;
import utils.TimeOut;

public class SmartList extends List implements IActivable,IAbstractView
	{
		public var autoToggleSelection:Boolean = true;
		
		public function SmartList()
		{
			super();
			initLayout();
			
			itemRendererType = SmartIR;
		}
		override protected function initialize():void
		{
			super.initialize();
		}
		public var smartItemLayoutData:SmartAnchorLayoutData = new SmartAnchorLayoutData();
		protected function initLayout():void
		{
			validateItemLayoutData();
		}
		protected function validateItemLayoutData():void
		{
			SmartTheme.validateSmartLayoutData(smartItemLayoutData);
		}
		override public function set layout(value:ILayout):void
		{
			super.layout = value;
			LayoutUtils.validateScrollPolicy(this);
		}
		override public function set selectedItem(value:Object):void
		{
			if(!_dataProvider) return;
			super.selectedItem = value;
		}
		override public function set selectedIndex(value:int):void
		{
			if(!_dataProvider) return;
			super.selectedIndex = value;
		}
		protected var cacheFirstDataProvider:Boolean = false;
		protected var firstDataProvider:ListCollection;
		override public function set dataProvider(value:ListCollection):void
		{
			if(this._dataProvider)
			{
				this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
				this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			}
			
			super.dataProvider = value;
			
			if(value && cacheFirstDataProvider && !firstDataProvider) firstDataProvider = value;
			
			if(this._dataProvider)
			{
				this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
				this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			}
		}
		public var autoscrollToNewAddedIndex:Boolean = false;
		private function dataProvider_addItemHandler(event:Event, index:int):void
		{
			if(autoscrollToNewAddedIndex) TimeOut.setTimeOutFunc(scrollToDisplayIndex,100,true,index,0.5);
		}
		private function dataProvider_removeItemHandler(event:Event, index:int):void
		{
			
		}
		public function set dataProviderSource(value:*):void
		{
			if(!dataProvider) dataProvider = new ListCollection();
			_dataProvider.data = null;
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
		protected var lastSelectedItem:Object;
		protected var processSelections:Boolean = true;
		override protected function selectedIndices_changeHandler(event:Event):void
		{
			if(!processSelections) return;
			
			lastSelectedItem = selectedItem;
			
			super.selectedIndices_changeHandler(event);
			
			if(selectedItem) 
			{
				onItemSelected();
				if(autoScrollToSelectedItem && !allowMultipleSelection && selectedIndices.length==1) TimeOut.setTimeOutFunc(scrollToDisplayIndex,100,true,selectedIndex,0.5);
				if(_selectionRangeMode)
				{
					_selectionRange = selectionRange;
					processSelections = false;
					selectRange(_selectionRange.from,_selectionRange.to);
					processSelections = true;
				}
				
			}
			else onItemsDeselected();
			
			if(autoToggleSelection) TimeOut.setTimeOutFunc(unSelect,100);
		}
		protected var _selectionRangeMode:Boolean = false;
		public function set selectionRangeMode(value:Boolean):void
		{
			_selectionRangeMode = value;
			allowMultipleSelection = value;
			
			if(!_selectionRange) _selectionRange = new Range(_selectedIndex,_selectedIndex,false);
			
			if(_selectionRange) _selectionRange.update(_selectedIndex,_selectedIndex,false);
			else _selectionRange.update(-1,-1,false);
		}
		public function get selectionRangeMode():Boolean
		{
			return _selectionRangeMode;
		}
		protected var _selectionRange:Range;
		public function get selectionRange():Range
		{
			if(!_selectionRange) _selectionRange = new Range(-1,-1,false);
			var selectedIndexes:Vector.<int> = selectedIndices;
			selectedIndexes.sort(Array.NUMERIC);
			
			_selectionRange.from = selectedIndexes[0];
			_selectionRange.to = selectedIndexes[selectedIndexes.length-1];
			
			return _selectionRange;
		}
		public var selectionRangeColor:uint = 0xCC0000;
		public function selectRange(from:int,to:int):void
		{	
			var _from:Number = from;
			from = from<to ? from : to;
			to = to>from ? to : _from;
			
			var v:Vector.<int> = new Vector.<int>();
			for(var i:int=from;i<=to;i++)
			{
				v.push(i);
			}
			selectedIndices = v; 
		}
		public function unSelect():void
		{
			if(_dataProvider) selectedItem = null;
		}
		public var autoScrollToSelectedItem:Boolean = false;
		protected function onItemSelected():void
		{
			
		}
		protected function onItemsDeselected():void
		{
			
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			activate(value);
		}
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
		public var disableAppDrawersOnScrolling:Boolean = true;
		public function disableAppDrawers(disable:Boolean,allDrawers:Boolean=false):void
		{
			if(disableAppDrawersOnScrolling)
			{
				var type:String = layout is HorizontalLayout ? TiledColumnsLayout.PAGING_HORIZONTAL : (layout is VerticalLayout ? TiledColumnsLayout.PAGING_VERTICAL : null);
				AppMessage.message(FeathersAppDrawer.ACTIVATE_DRAWERS,!disable,allDrawers ? null : type);
			}
		}
		protected var _controller:AbstractController;
		public function setController(value:AbstractController):void
		{
			_controller = value;
		}
		public function getController():AbstractController
		{
			return _controller;
		}
		public function onModelUpdated():void
		{
			
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
		public function get horizontalPositionItemIndex():int
		{
			var ir:BaseDefaultItemRenderer = getItemRenderer(dataProvider.getItemAt(0));
			var i:int = Math.round(horizontalScrollPosition/(ir.width+hLayout.gap));
			return i<0 ? 0 : i;
		}
		public function get verticalPositionItemIndex():int
		{
			var ir:BaseDefaultItemRenderer = getItemRenderer(dataProvider.getItemAt(0));
			var i:int = Math.ceil(verticalScrollPosition/(ir.height+vLayout.gap))
			return i<0 ? 0 : i;
		}
		public function setPercentSize(pWidth:Number,pHeight:Number):void
		{
			pWidth = pWidth>1 ? pWidth/100 : pWidth;
			pHeight = pHeight>1 ? pHeight/100 : pHeight;
			
			setSize(parent.width*pWidth,parent.height*pHeight);
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
	}
}