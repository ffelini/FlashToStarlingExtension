package mvc.view.screen
{
import feathers.system.DeviceCapabilities;

import feathersExtensions.data.SmartListCollection;
import feathersExtensions.interfaces.IPausable;
import feathersExtensions.utils.LayoutUtils;

import managers.interfaces.IStateReceiver;

import mvc.controller.AbstractController;
import mvc.view.controls.SmartPanelScreen;
import mvc.view.interfaces.IAbstractView;
import mvc.view.interfaces.IMenuHolder;

import starling.display.DisplayObject;
import starling.events.TouchEvent;

import starlingExtensions.containers.AdvancedSprite;
import starlingExtensions.interfaces.IActivable;

import utils.log;

public class AbstractFeathersScreen extends SmartPanelScreen implements IActivable,IPausable,IStateReceiver,IMenuHolder
	{
		protected var _controller:AbstractController;
		
		public function AbstractFeathersScreen(controller:AbstractController)
		{
			super();
			_controller = controller;
			
			LayoutUtils.updateScrolling(this,false);
		}
		public var loadingHandler:Function;
		public function loading(value:Boolean):void
		{
			if(loadingHandler!=null) loadingHandler(value);
		}
		public function backButton():Boolean
		{
			return false;
		}
		protected var _menu:SmartListCollection;
		public function get menu():SmartListCollection
		{
			return _menu; 
		}
		public function addChildren(...childrens):void
		{
			for each(var child:DisplayObject in childrens)
			{
				if(child) addChild(child);
			}
		}
		override protected function initialize():void
		{
			super.initialize();
			initChildren();
			childrenComplete = true;
			
			if(visible) activate(true);
			super.setSize(DeviceCapabilities.screenPixelWidth,DeviceCapabilities.screenPixelHeight);
		}
		protected var childrenComplete:Boolean = false;
		protected function initChildren():void
		{
			
		}
		override public function validate():void
		{
			super.validate();
			setSize(AdvancedSprite.coordinateSystemRect.width,AdvancedSprite.coordinateSystemRect.height);
		}
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is IAbstractView)
			{
				(child as IAbstractView).setController(_controller);
			}
			return super.addChildAt(child, index);
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(isInitialized) activate(value);//!value ? activate(value) : TimeOut.setTimeOutFunc(activate,500,true,value);
		}
		protected var _active:Boolean = false;
		public function get active():Boolean
		{
			return _active;
		}
		public function activate(value:Boolean):void
		{
			if(!childrenComplete || value==_active) return;
			
			_active = value;
			if(_active && !_paused) activateUIContent();	
			if(!_active) _paused = false;
		}
		protected function activateUIContent():void
		{
			addListerners(true);
			_paused = false;

			log(this,"activateUIContent");
		}
		protected var _paused:Boolean = false;
		public function pause(value:Boolean):void
		{
			if(!childrenComplete) return;
			
			_paused = value;
			addListerners(!_paused);
			isQuickHitAreaEnabled = paused;
			
			log(this,"pause",this,childrenComplete,_active,paused);
		}
		protected function addListerners(add:Boolean):void
		{
			if(add) addEventListener(TouchEvent.TOUCH,onTouch);
			else removeEventListener(TouchEvent.TOUCH,onTouch);
		}
		public function get paused():Boolean
		{
			return _paused;
		}
		protected function onTouch(e:TouchEvent):void
		{
			
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