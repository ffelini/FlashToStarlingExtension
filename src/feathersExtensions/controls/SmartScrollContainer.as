package feathersExtensions.controls
{
import feathers.controls.ScrollContainer;
import feathers.controls.Scroller;
import feathers.layout.HorizontalLayout;
import feathers.layout.TiledColumnsLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.utils.LayoutUtils;

import mvc.controller.AbstractController;
import mvc.view.interfaces.IAbstractView;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.TouchEvent;

public class SmartScrollContainer extends ScrollContainer implements IAbstractView
	{
		public function SmartScrollContainer(_initChildren:Boolean=false)
		{
			super();
			hasElasticEdges = false;
			scrollBarDisplayMode = SCROLL_BAR_DISPLAY_MODE_NONE;
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
		protected function onTouch(e:TouchEvent):void
		{
			
		}
		protected var _controller:AbstractController;
		public function setController(value:AbstractController):void
		{
			_controller = value;
			
			var _numChildren:Number = numChildren;
			var child:IAbstractView;
			for(var i:int = 0;i<_numChildren;i++)
			{
				child = getChildAt(i) as IAbstractView;
				if(child) child.setController(_controller);
			}
		}
		public function onModelUpdated():void
		{
			
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is IAbstractView)
			{
				(child as IAbstractView).setController(_controller);
			}
			return super.addChildAt(child, index);
		}
		public function addChildren(...childrens):void
		{
			for each(var child:DisplayObject in childrens)
			{
				if(child) addChild(child);
			}
		}
		protected var smartScoller:Scroller;
		public function set smartScrollingTarget(value:Scroller):void
		{
			smartScoller = value;
			smartScoller.hasElasticEdges = false;
			activateSmartScrollingTarget(false);
		}
		protected var lastVScrollPosition:Number;
		protected var lastHScrollPosition:Number;
		override protected function draw():void
		{
			super.draw();
			if(smartScoller)
			{			
				if(_layout is VerticalLayout || _layout is TiledRowsLayout)
				{
					if(lastVScrollPosition<_verticalScrollPosition && _verticalScrollPosition>=maxVerticalScrollPosition) activateSmartScrollingTarget(true);
				}
				if(_layout is HorizontalLayout || _layout is TiledColumnsLayout)
				{
					if(lastHScrollPosition<_horizontalScrollPosition && _horizontalScrollPosition>=maxHorizontalScrollPosition) activateSmartScrollingTarget(true);
				}
			}
			lastVScrollPosition = _verticalScrollPosition;
			lastHScrollPosition = _horizontalScrollPosition;
		}
		override protected function scroller_touchHandler(event:TouchEvent):void
		{
			//if(!scrollingIsActive) return;
			super.scroller_touchHandler(event);
			//trace("SmartScrollContainer.scroller_touchHandler(event)");
			
		}
		override protected function stage_touchHandler(event:TouchEvent):void
		{
			//if(!scrollingIsActive) return;
			super.stage_touchHandler(event);
			//trace("SmartScrollContainer.stage_touchHandler(event)");
			
		}
		protected var scrollingIsActive:Boolean = true;
		protected function activateSmartScrollingTarget(active:Boolean,startScrolling:Boolean=false):void
		{
			if(!smartScoller) return;
			
			//smartScoller.touchable = active;
			LayoutUtils.updateScrolling(smartScoller,active,false);
			LayoutUtils.updateScrolling(this,!active,false);
			scrollingIsActive = !active;

			if(active)
			{
				smartScoller.addEventListener(Event.SCROLL,onSmartScrollerEvt);
			}
			else
			{
				smartScoller.removeEventListener(Event.SCROLL,onSmartScrollerEvt);
			}
		}
		protected var lastSmartScrollerVScrollPosition:Number;
		protected var lastSmartScrollerHScrollPosition:Number;
		protected function onSmartScrollerEvt(e:Event):void
		{
			if(_layout is VerticalLayout || _layout is TiledRowsLayout)
			{
				if(lastSmartScrollerVScrollPosition>smartScoller.verticalScrollPosition && smartScoller.verticalScrollPosition<=0) activateSmartScrollingTarget(false,true);
			}
			if(_layout is HorizontalLayout || _layout is TiledColumnsLayout)
			{
				if(lastSmartScrollerHScrollPosition>smartScoller.horizontalScrollPosition && smartScoller.horizontalScrollPosition<=0) activateSmartScrollingTarget(false,true);
			}
			lastSmartScrollerVScrollPosition = smartScoller.verticalScrollPosition;
			lastSmartScrollerHScrollPosition = smartScoller.horizontalScrollPosition;
		}
		override public function validate():void
		{
			super.validate();
			
			if(smartScoller) 
			{
				if(layout is VerticalLayout || layout is TiledRowsLayout) smartScoller.height = height;
				if(layout is HorizontalLayout || layout is TiledColumnsLayout) smartScoller.width = width;
			}
			if(!isInitialized) return;
			
			validateSize();
		}
		protected function validateSize():void
		{
		}
	}
}