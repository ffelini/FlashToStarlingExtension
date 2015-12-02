package starlingExtensions.uiComponents
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import managers.Handlers;
import managers.ObjPool;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.containers.Scroller;
import starlingExtensions.containers.layouts.Layout;
import starlingExtensions.interfaces.IActivable;
import starlingExtensions.uiComponents.renderers.FlashSkinableIR;
import starlingExtensions.utils.TweenUtils;

import utils.log;

public class List extends Scroller
	{		
		public static var DEBUG:Boolean = false;
		
		public var itemRenderer:Class;
		public var layout:Layout;
		
		public var data:Object;
		
		public var updateHandler:Function;
		
		public var maxItems:int = -1;
		
		public var usePositionEffect:Boolean = false;	
		public var effectMinValue:Number = 0.5;
		
		public var isLoop:Boolean = false;
		
		public var lazyRendering:Boolean = false;
		public var lazyChildrenCreation:Boolean = true;
		
		public var selections:Dictionary = new Dictionary();
		
		public function List()
		{
			super();
			
			useOwnPool = false;
		}
		protected var ownObjPool:ObjPool;
		protected var objPool:ObjPool;
		public function set useOwnPool(value:Boolean):void
		{
			if(value) 
			{
				objPool = ownObjPool ? ownObjPool : new ObjPool();
				ownObjPool = objPool;
			}
			else objPool = ObjPool.inst;
		}
		protected function clear():void
		{			
			objPool.addInstances(itemRenderers,itemRenderer,true);
			dataGroup.removeChildren();
			dataGroup.x = dataGroup.y = 0;
			_dataProvider = null;
			_dataProviderLength = 0;
			firstItemInVIew = lastItemInView = null;
			_lastAddedItemIndex = -1;
			firstItemInViewIndex = lastItemInViewIndex = -1;
			
			if(touchTarget) TweenUtils.removeTweens(touchTarget);
			
			if(layout) 
			{
				layout.clear();
				layout.setViewPort(_clipRect);
			}
		}
		protected var _dataProvider:*;
		protected var _dataProviderLength:int;
		public function set dataProvider(value:*):void
		{
			clear();
			if(!value) return;
			
			_dataProvider = value is XML ? value.children() : value;
			_dataProviderLength = _dataProvider is XMLList ? _dataProvider.length() : _dataProvider.length;
			
			if(_dataProviderLength==0) return;
			
			autoUpdateLayout = true;
			if(!lazyChildrenCreation)
			{
				for each(var data:Object in _dataProvider)
				{
					addItem(data,_lastAddedItemIndex+1)
				}
			}
			else 
			{
				addItem(_dataProvider[0],0);
				processChildrenCreation = _dataProviderLength>1;
			}
			
			if(DEBUG) log(this,"dataProvider",name,"_dataProviderLength-"+_dataProviderLength,"itemRenderer-"+itemRenderer,"item renderers-"+itemRenderers.length);
		}
		public function get dataProvider():*
		{
			return _dataProvider;
		}
		public var addItemFilterFunc:Function;
		protected function filterAddItem(data:Object,index:int):Boolean
		{
			if(addItemFilterFunc!=null && addItemFilterFunc(data)==false ) return false;
			if(maxItems>0 && index>=maxItems) return false;
			return true;
		}
		public var itemRenderers:Vector.<IItemRenderer> = new Vector.<IItemRenderer>();
		public function addItem(data:Object,index:int):IItemRenderer
		{
			if(!filterAddItem(data,index)) return null;
			return addIRAt(objPool.get(itemRenderer,true) as IItemRenderer,data,index);
		}
		public function addNextItem(data:Object):IItemRenderer
		{
			return addItem(data,dataGroup.numChildren);
		}
		protected var _lastAddedItemIndex:int = -1;
		public function addIRAt(ir:IItemRenderer,data:Object,i:int):IItemRenderer
		{		
			if(itemRenderers.indexOf(ir)<0) itemRenderers.push(ir);
			ir.list = this;
			
			_lastAddedItemIndex = i;
			
			addChild(ir as DisplayObject) as IItemRenderer;
			ir.data = data;
			
			if(layout) 
			{
				layout.layoutItem(ir,i);
				dataGroupContentChange();
			}
			
			updateLayout();
			
			if(DEBUG) log(this,"addIRAt",ir,data,i);
			
			return ir;
		}
		public function getIRAt(index:int):FlashSkinableIR
		{
			return dataGroup.getChildAt(index) as FlashSkinableIR;
		}		
		public function get numIRInView():int
		{
			return dataGroup.numChildren;
		}
		public function removeIR(ir:IItemRenderer,updateDataProvider:Boolean=true):void
		{
			var i:int = itemRenderers.indexOf(ir);
			if(i>=0) itemRenderers.splice(i,1);
			
			(ir as DisplayObject).removeFromParent(false);
			ir.reset();
			
			updateLayout();
			
			if(updateDataProvider)
			{
				if(_dataProvider is Array || _dataProvider is Vector) 
				{
					i = _dataProvider.indexOf(ir.data);
					if(i>=0) _dataProvider.splice(i,1);
				}
				else if(_dataProvider is XML || _dataProvider is XMLList) 
				{
					i = XML(ir.data).childIndex();
					var list:XMLList = _dataProvider is XML ? XML(_dataProvider).children() : (_dataProvider as XMLList);
					delete list[i];
				}
				_dataProviderLength = _dataProvider is XMLList ? _dataProvider.length() : _dataProvider.length;
			}
		}
		protected function updateLayout():void
		{
			if(layout)
			{
				layout.clear();
				for each(var ir:IItemRenderer in itemRenderers)
				{
					layout.layoutItem(ir,itemRenderers.indexOf(ir));
				}
			}
			setup();
		}
		protected function centrateLayout():void
		{
			var _dgRect:Rectangle = dataGroupRect;
			if(layout)
			{
				if(_dgRect.width<_clipRect.width) 
					dataGroup.x = layout.horizontalAlign==0 ? (_clipRect.x+_clipRect.width/2) - _dgRect.width/2 : (layout.horizontalAlign==-1 ? _clipRect.x : _clipRect.width-_dgRect.width);
				else dataGroup.x = _clipRect.x;
				if(_dgRect.height<_clipRect.height) 
					dataGroup.y = layout.verticalAlign==0 ? (_clipRect.y+_clipRect.height/2) - _dgRect.height/2 : (layout.verticalAlign==-1 ? _clipRect.y : _clipRect.height-_dgRect.height);
				else dataGroup.y = _clipRect.y;
			}
		}
		public var setupHandler:Function;
		protected function setup():void
		{
			if(setupHandler!=null) setupHandler();
			if(autoUpdateLayout) centrateLayout();
		}
		override public function get dataGroupRect():Rectangle
		{
			return layout ? layout.getBounds(_dataProviderLength) : super.dataGroupRect;
		}
		override protected function updateDragValues(updateMinSize:Boolean=true):void
		{
			super.updateDragValues(updateMinSize);
			if(targetBounds.width<dragRect.width) maxDragX = dataGroup.x;
			if(targetBounds.height<dragRect.height) maxDragY = dataGroup.y;
		}
		protected var itemsInView:Array = [];
		protected var firstItemInViewIndex:int;
		protected var firstItemInVIew:FlashSkinableIR;
		protected var lastItemInView:FlashSkinableIR;
		protected var lastItemInViewIndex:int;
		public function updateItemsInView(ir:FlashSkinableIR,inView:Boolean):void
		{
			var i:int = itemsInView.indexOf(ir);
			
			if(inView) 
			{
				if(i<0) itemsInView.push(ir);
				
				var irIndex:int = ir.index;
				
				if(firstItemInVIew) firstItemInVIew = irIndex<firstItemInViewIndex ? ir : firstItemInVIew;
				else firstItemInVIew = ir;
				
				if(firstItemInVIew==ir) firstItemInViewIndex = irIndex;
				
				if(lastItemInView) lastItemInView = irIndex>lastItemInView.index ? ir : lastItemInView;
				else lastItemInView = ir;
				
				if(lastItemInView==ir) lastItemInViewIndex = irIndex;
			}
			else 
			{
				if(i>=0) itemsInView.splice(i,1);
				
				if(ir==firstItemInVIew) firstItemInVIew = null;
				if(ir==lastItemInView) lastItemInView = null;
			}
		}
		public var childrenCreationDelayFrames:int = 1;
		protected var childCreationCount:int = 0;
		protected var processChildrenCreation:Boolean = false;
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if(_dataProviderLength>0 && lazyChildrenCreation)
			{
				if(processChildrenCreation)
				{
					childCreationCount++;
					if(childCreationCount>=childrenCreationDelayFrames)
					{
						var ir:FlashSkinableIR = addItem(_dataProvider[_lastAddedItemIndex+1],_lastAddedItemIndex+1) as FlashSkinableIR;
						
						processChildrenCreation = !ir || (_lastAddedItemIndex<_dataProviderLength-1 && ir.inView);
						childCreationCount = 0;
					}
				}
			}
		}
		private var autoUpdateLayout:Boolean = true;
		override protected function onPositionUpdate():void
		{
			super.onPositionUpdate();
			
			if(_dataProviderLength>0 && lazyChildrenCreation && _lastAddedItemIndex<_dataProviderLength-1)
			{
				if(lastItemInView)
				{
					if(lastItemInViewIndex==_lastAddedItemIndex)
					{
						autoUpdateLayout = false;
						processChildrenCreation = true;
					}
					else updateDragValues(false);
				}
			}
		}
		public var selectable:Boolean = false;
		public var toggleSelection:Boolean = false;
		public var allowMultipleSelectionOnSameItem:Boolean = true;
		protected var _selectedItem:IItemRenderer;
		public var selectedItemHandler:Function;
		public function set selectedItem(value:IItemRenderer):void
		{
			if(!selectable) return;
			
			value = _selectedItem==value && toggleSelection ? null : value;
			if(_selectedItem==value && !allowMultipleSelectionOnSameItem) return;
			
			if(_selectedItem) _selectedItem.selected = false;
			_selectedItem = value;
			
			if(!_selectedItem) return;
			
			_selectedItem.selected = true;
			
			Handlers.functionCall(selectedItemHandler,_selectedItem);
		}
		public function get selectedItem():IItemRenderer
		{
			return _selectedItem;
		}
		public function get numItems():int
		{
			return itemRenderers.length;
		}
		protected function setIRPosition(ir:IItemRenderer,x:Number,y:Number):void
		{
			(ir as DisplayObject).x = x;
			(ir as DisplayObject).y = y;
		}
		public function activate(value:Boolean):void
		{
			if(!value) Starling.juggler.removeTweens(dataGroup);
			for each(var ir:IItemRenderer in itemRenderers)
			{
				if(ir is IActivable) (ir as IActivable).activate(value);
			}
		}
		override public function paddingLayout(pL:Number,pR:Number,pT:Number,pB:Number):void
		{
			super.paddingLayout(pL,pR,pT,pB);
			dataGroup.x = _clipRect.x;
			dataGroup.y = _clipRect.y;
			if(autoUpdateLayout) centrateLayout();
		}
		override public function set clipRect(value:Rectangle):void
		{
			super.clipRect = value;
			if(layout) layout.setViewPort(_clipRect);
		}
	}
}