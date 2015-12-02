package starlingExtensions.uiComponents.renderers
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxePort.managers.interfaces.IResetable;

import managers.Handlers;

import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.text.TextField;

import starlingExtensions.containers.layouts.HLayout;
import starlingExtensions.containers.layouts.TileLayout;
import starlingExtensions.containers.layouts.VLayout;
import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IActivable;
import starlingExtensions.interfaces.ITouchable;
import starlingExtensions.uiComponents.IItemRenderer;
import starlingExtensions.uiComponents.List;
import starlingExtensions.uiComponents.SkinnableList;
import starlingExtensions.utils.DisplayUtils;
import starlingExtensions.utils.TouchUtils;

public class FlashSkinableIR extends FlashSprite_Mirror implements IItemRenderer,IActivable,IResetable,ITouchable
	{
		public var bSkin:DisplayObject;
		public var tSkin:DisplayObject;
		
		public function FlashSkinableIR(_mirror:DisplayObjectContainer, _rootMirror:FlashDisplay_Mirror)
		{
			super(_mirror, _rootMirror);
			visible = false;
		}
		override public function createChildren():void
		{
			super.createChildren();
			bSkin = getChildByName("bSkin");
			tSkin = getChildByName("tSkin");
		}
		
		protected var _data:Object; 
		public function set data(value:Object):void
		{
			_data = value;
			if(labelField) labelField.text = Handlers.functionCall(labelFunction)+"";
		}
		protected var _dataComplete:Boolean = false;
		protected function setData():void
		{
			_dataComplete = true;
		}
		public function get data():Object
		{
			return _data;
		}
		protected var _selected:Boolean = false;
		public function set selected(value:Boolean):void
		{
			_selected = value;
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		protected var _list:List;
		public function set list(value:List):void
		{
			reset();
			_list = value;
			if(_list is SkinnableList && (_list as SkinnableList).skin!=this) skin = (_list as SkinnableList).skin;
		}
		public function get list():List
		{
			return _list;
		}
		public function updateLayout():void
		{
			
		}
		protected var _skin:FlashSkinableIR;
		public function set skin(value:FlashSkinableIR):void
		{
			_skin = value;
			DisplayUtils.useTextures(_skin.bSkin,bSkin);
			DisplayUtils.useTextures(_skin.tSkin,tSkin);
		}
		public function get index():int
		{
			return _list ? _list.itemRenderers.indexOf(this) : (parent ? parent.getChildIndex(this) : -1);
		}
		public function get isOwIndex():Boolean
		{
			var i:int = index;
			return (i/2 - int(i/2)) > 0
		}
		override public function get hasVisibleArea():Boolean
		{
			_inView = inView;
			
			if(_list && visible!=_inView) _list.updateItemsInView(this,_inView);
			
			visible = _inView;
			
			if(!_data) return _inView;
			
			if(isListSleeping || !isListLazy)
			{
				if(_inView && !_dataComplete) setData();
				if(visible!=_active) activate(visible);
			}
			
			if(_inView && _active && _list && _list.usePositionEffect) positionEffect();
			
			return _inView;
		}
		protected function get isListSleeping():Boolean
		{
			return !_list || (_list && _list.touchChildren);
		}
		protected function get isListLazy():Boolean
		{
			return _list && _list.lazyRendering;
		}
		protected static var rect:Rectangle = new Rectangle();
		protected var _inView:Boolean = false;
		public function get inView():Boolean
		{ 
			if(_list && _list.clipRect) return _list.layout.isRectInView(getListBounds(rect));			
			return true;
		}
		protected function getListBounds(rect:Rectangle):Rectangle
		{
			if(!rect) rect = new Rectangle();
			
			if(_list)
			{
				rect.x = x + parent.x;
				rect.y = y + parent.y;
				rect.width = fastWidth;
				rect.height = fastHeight;
			}
			
			return rect;
		}
		protected function get fastWidth():Number
		{
			return _list && _list.layout ? _list.layout.columnWidth*parent.scaleX : width;
		}
		protected function get fastHeight():Number
		{
			return _list && _list.layout ? _list.layout.rowHeight*parent.scaleY : width;
		}
		protected var _active:Boolean = false;
		public function activate(value:Boolean):void
		{
			if(value==_active) return;
			
			_active = value;
			touchable = _active;
		}
		public function get active():Boolean
		{
			return _active;
		}
		public var labelFunction:Function;
		public function get labelField():TextField
		{
			return null;
		}
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			if(_list && _list.touchChildren && clicked(e)) 
			{
				_list.selectedItem = this;
			}
		}
		public function clicked(e:TouchEvent,target:DisplayObject=null):Touch
		{
			if(_list && !_list.touchChildren) return null;
			
			return TouchUtils.clicked(target ? target : this,e); 
		}
		override public function reset():void
		{
			super.reset();
			super.visible = false;
			alpha = 1;

			_active = false;
			
			_data = null;
			_list = null;
			_dataComplete = false;
		}
		private static var p:Point = new Point();
		private static var p2:Point = new Point();	
		protected function positionEffect():void
		{
			if(!_list) return;
			
			rect = getListBounds(rect);
			p.x = _list.clipRect.x + _list.clipRect.width/2;
			p.y = _list.clipRect.y + _list.clipRect.height/2;
			
			p2.x = rect.x+rect.width/2;
			p2.y = rect.y+rect.height/2;
			
			var d:Number = Point.distance(p,p2);
			var f:Number = 1 - ((1 - _list.effectMinValue) * (d/(_list.clipRect.width/2)));		 
			var k:Number = fastWidth/fastHeight;
			
			if(_list.layout is HLayout)
			{
				width = (_list.layout as HLayout).columnWidth*f; 
				height = fastWidth/k;
			}
			if(_list.layout is VLayout)
			{
				height = (_list.layout as VLayout).rowHeight*f;
				width = fastHeight*k;
			}
			if(_list.layout is TileLayout)
			{
				width = (_list.layout as HLayout).columnWidth*f;
				height = (_list.layout as VLayout).rowHeight*f;
			}
		}
	}
}