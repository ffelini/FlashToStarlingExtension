package starlingExtensions.containers
{
import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.display.Quad;

import starlingExtensions.uiComponents.SmartSprite;

public class Scroller extends TouchContainer
	{
		public var dataGroup:SmartSprite = new SmartSprite();
		protected var background:Quad = new Quad(2,2);
		
		public function Scroller()
		{
			super();
			background.alpha = 0;
			super.addChildAt(dataGroup,0);
			super.addChildAt(background,0);
			touchTarget = dataGroup;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var child:DisplayObject = dataGroup.addChild(child);
			dataGroupContentChange();
			return child;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var child:DisplayObject = dataGroup.addChildAt(child, index);
			dataGroupContentChange();
			return child;
		}
		override public function contains(child:DisplayObject):Boolean
		{
			return dataGroup.contains(child);
		}
		override public function getChildAt(index:int):DisplayObject
		{
			return dataGroup.getChildAt(index);
		}
		override public function getChildByName(name:String):DisplayObject
		{
			return dataGroup.getChildByName(name);
		}
		override public function getChildIndex(child:DisplayObject):int
		{
			return dataGroup.getChildIndex(child);
		}
		override public function get numChildren():int
		{
			return dataGroup.numChildren;
		}
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			var child:DisplayObject = dataGroup.removeChild(child, dispose);
			dataGroupContentChange();
			return child;
		}
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			var child:DisplayObject = dataGroup.removeChildAt(index, dispose);
			dataGroupContentChange();
			return child;
		}
		override public function removeChildren(beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false):void
		{
			dataGroup.removeChildren(beginIndex, endIndex, dispose);
			dataGroupContentChange();
		}
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			dataGroup.setChildIndex(child, index);
		}
		override public function sortChildren(compareFunction:Function):void
		{
			dataGroup.sortChildren(compareFunction);
		}
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			dataGroup.swapChildren(child1, child2);
		}
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			dataGroup.swapChildrenAt(index1, index2);
		}
		protected function dataGroupContentChange():void
		{
			_dataGroupRect = dataGroupRect;			
			draggable = _clipRect ? _dataGroupRect.width>_clipRect.width || _dataGroupRect.height>_clipRect.height : false;
		}
		override protected function activateTouching(value:Boolean):void
		{
			super.activateTouching(value);
			dataGroup.touchable = value;
		}
		override protected function get moveEnabled():Boolean
		{
			return _draggable;
		}
		protected var _clipRect:Rectangle;
		protected var _clipRectOriginal:Rectangle;
		override public function set clipRect(value:Rectangle):void
		{
			super.clipRect = value;
			if (value) 
			{
				if (_clipRect == null) _clipRect = value.clone();
				else _clipRect.setTo(value.x, value.y, value.width, value.height);
			}
			else _clipRect = null;
			
			if(background && _clipRect) 
			{
				background.x = _clipRect.x;
				background.y = _clipRect.y;
				background.width = _clipRect.width;
				background.height = _clipRect.height;
			}
			
			dragRect = _clipRect;
			_clipRectOriginal = _clipRect.clone();
		}
		public function paddingLayout(pL:Number,pR:Number,pT:Number,pB:Number):void
		{
			_clipRect.x = _clipRectOriginal.x + pL;
			_clipRect.y = _clipRectOriginal.y + pT;
			_clipRect.width = _clipRectOriginal.width - pR - pL;
			_clipRect.height = _clipRectOriginal.height - pB - pT;
			super.clipRect = _clipRect;
		}
		protected var _dataGroupRect:Rectangle;
		public function get dataGroupRect():Rectangle
		{
			_dataGroupRect = dataGroup.getBounds(this,_dataGroupRect);
			return _dataGroupRect;
		}
	}
}