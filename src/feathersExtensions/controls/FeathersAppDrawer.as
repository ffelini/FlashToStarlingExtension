package feathersExtensions.controls
{
import feathers.controls.Drawers;
import feathers.layout.TiledColumnsLayout;
import feathers.system.DeviceCapabilities;

import feathersExtensions.interfaces.IPausable;

import managers.Handlers;

import mvc.controller.events.AppMessage;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class FeathersAppDrawer extends Drawers
	{
		public static const ACTIVATE_DRAWERS:String = "updateDrawers";
		
		public static const TOGGLE_LEFT:String = "toggleLeft";
		public static const TOGGLE_RIGHT:String = "toggleRight";
		public static const TOGGLE_TOP:String = "toggleTop";
		public static const TOGGLE_BOTTOM:String = "toggBottom";
		
		public function FeathersAppDrawer(content:DisplayObject=null)
		{
			super(content);
			
			topDrawerDockMode = DOCK_MODE_LANDSCAPE;
			leftDrawerDockMode = DOCK_MODE_LANDSCAPE;
			
			openGesture = OPEN_GESTURE_DRAG_CONTENT;
			openGestureEdgeSize = DeviceCapabilities.screenInchesX(Starling.current.nativeStage)*0.25;
			minimumDragDistance =  DeviceCapabilities.screenInchesX(Starling.current.nativeStage)*0.1;
			
			autoSizeMode = AUTO_SIZE_MODE_CONTENT;
			clipDrawers = true;
			
			Handlers.add(AppMessage,false,onAppMessage);
			Handlers.add(TOGGLE_LEFT,false,onAppMessage);
			Handlers.add(TOGGLE_RIGHT,false,onAppMessage);
			Handlers.add(TOGGLE_TOP,false,onAppMessage);
			Handlers.add(TOGGLE_BOTTOM,false,onAppMessage);
		}
		override protected function openOrCloseTween_onUpdate():void
		{
			super.openOrCloseTween_onUpdate();
			if(content is IPausable && !(content as IPausable).paused) if(!isBottomDrawerOpen && !isLeftDrawerOpen && !isTopDrawerOpen && !isRightDrawerOpen) (content as IPausable).pause(true);
		}
		override protected function topDrawerOpenOrCloseTween_onComplete():void
		{
			super.topDrawerOpenOrCloseTween_onComplete();
			if(content is IPausable && (content as IPausable).paused) if(!isBottomDrawerOpen && !isLeftDrawerOpen && !isTopDrawerOpen && !isRightDrawerOpen) (content as IPausable).pause(false);
		}
		override protected function bottomDrawerOpenOrCloseTween_onComplete():void
		{
			super.bottomDrawerOpenOrCloseTween_onComplete();
			if(content is IPausable && (content as IPausable).paused) if(!isBottomDrawerOpen && !isLeftDrawerOpen && !isTopDrawerOpen && !isRightDrawerOpen) (content as IPausable).pause(false);
		}
		override protected function leftDrawerOpenOrCloseTween_onComplete():void
		{
			super.leftDrawerOpenOrCloseTween_onComplete();
			if(content is IPausable && (content as IPausable).paused) if(!isBottomDrawerOpen && !isLeftDrawerOpen && !isTopDrawerOpen && !isRightDrawerOpen) (content as IPausable).pause(false);
		}
		override protected function rightDrawerOpenOrCloseTween_onComplete():void
		{
			super.rightDrawerOpenOrCloseTween_onComplete();
			if(content is IPausable && (content as IPausable).paused) if(!isBottomDrawerOpen && !isLeftDrawerOpen && !isTopDrawerOpen && !isRightDrawerOpen) (content as IPausable).pause(false);
		}
		protected function initDrawers():void
		{
			
		}
		override public function validate():void
		{
			super.validate();
			setSize(Starling.current.nativeStage.fullScreenWidth,Starling.current.nativeStage.fullScreenHeight);
		}
		override protected function initialize():void
		{
			super.initialize();
			setSize(stage.stageWidth,stage.stageHeight);
		}
		private function onAppMessage(evtType:String,parameters:Array):void
		{
			//log(this,"onAppMessage",evtType,parameters);
			switch(evtType)
			{
				case AppMessage.VIEW_OPENED:
				{
					reset();
					break;
				}
				case ACTIVATE_DRAWERS:
				{
					if(!parameters[1]) activateDrawers(parameters[0]);
					else
					{
						if(parameters[1] == TiledColumnsLayout.PAGING_VERTICAL)
						{
							activateBottomDrawer(parameters[0]);
							activateTopDrawer(parameters[0]);
						}
						if(parameters[1] == TiledColumnsLayout.PAGING_HORIZONTAL)
						{
							activateLeftDrawer(parameters[0]);
							activateRigthDrawer(parameters[0]);
						}
					}
					break;
				}
				case TOGGLE_LEFT:
				{
					toggleLeftDrawer();
					break;
				}
				case TOGGLE_RIGHT:
				{
					toggleRightDrawer();
					break;
				}
				case TOGGLE_TOP:
				{
					toggleTopDrawer();
					break;
				}
				case TOGGLE_BOTTOM:
				{
					toggleBottomDrawer();
					break;
				}
			}
		}
		protected function reset():void
		{
			if(this.isTopDrawerOpen)
			{
				this._isTopDrawerOpen = false;
				this.openOrCloseTopDrawer();
			}
			else if(this.isRightDrawerOpen)
			{
				this._isRightDrawerOpen = false;
				this.openOrCloseRightDrawer();
			}
			else if(this.isBottomDrawerOpen)
			{
				this._isBottomDrawerOpen = false;
				this.openOrCloseBottomDrawer();
			}
			else if(this.isLeftDrawerOpen)
			{
				this._isLeftDrawerOpen = false;
				this.openOrCloseLeftDrawer();
			}
		}
		public var handleExclusiveTouches:Boolean = true;
		override protected function exclusiveTouch_changeHandler(event:Event, touchID:int):void
		{
			if(handleExclusiveTouches) super.exclusiveTouch_changeHandler(event, touchID);
		}
		public function activateDrawers(activate:Boolean=false):void
		{
			activateLeftDrawer(activate);
			activateRigthDrawer(activate);
			activateTopDrawer(activate);
			activateBottomDrawer(activate);
		}
		public function activateLeftDrawer(activate:Boolean=false):void
		{
			leftDrawer = activate ? leftDrawer : null;
		}
		public function activateRigthDrawer(activate:Boolean=false):void
		{
			rightDrawer = activate ? rightDrawer : null;
		}
		public function activateTopDrawer(activate:Boolean=false):void
		{
			topDrawer = activate ? topDrawer : null;
		}
		public function activateBottomDrawer(activate:Boolean=false):void
		{
			bottomDrawer = activate ? bottomDrawer : null;
		}
	}
}