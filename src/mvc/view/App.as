package mvc.view
{
import feathers.core.DisplayListWatcher;

import feathersExtensions.interfaces.IPausable;
import feathersExtensions.themes.SmartTheme;

import flash.system.Capabilities;
import flash.system.System;

import managers.DataManager;
import managers.Handlers;
import managers.interfaces.IStateReceiver;
import managers.resourceManager.ManagerRemoteResource;

import mvc.controller.AbstractController;
import mvc.controller.events.AppMessage;

import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.containers.AdvancedSprite;
import starlingExtensions.containers.ViewStack;
import starlingExtensions.utils.TouchUtils;

import utils.log;

public class App extends ViewStack implements IPausable
	{
		public static var DEBUG:Boolean = Capabilities.isDebugger;
		
		public static var resourceManager:ManagerRemoteResource = new ManagerRemoteResource();
		
		protected var _controller:AbstractController;
		
		public function App(controller:AbstractController)
		{
			super();
			_controller = controller;
			_inst = this;
			transitionDuration = 0.15;
		}
		private static var _inst:App;
		public static function get inst():App
		{
			return _inst;
		}
		protected var initComplete:Boolean = false;
		public function init():void
		{
			if(initComplete) return;
			
			Starling.current.showStatsAt("left","top",1.5);	
			Starling.current.showStats = true;
			
			initTheme();
			
			Handlers.add(AppMessage,false,onMessage);
			Handlers.add(TouchUtils.clicked,false,onClicked);
			
			log(this,"coordinateSystemRect - ",AdvancedSprite.coordinateSystemRect,stage.width,stage.height,Starling.current.nativeStage.stageWidth,Starling.current.nativeStage.stageHeight,
				Starling.current.nativeStage.width,Starling.current.nativeStage.height,Capabilities.screenResolutionX,Capabilities.screenResolutionY);		
			
			setupSounds();
			initComplete = true;
		}
		public var theme:DisplayListWatcher;
		protected function initTheme():void
		{
			theme = new SmartTheme(Starling.current.stage);
		}
		protected function onClicked(target:DisplayObject):void
		{
			
		}
		protected function onFbError(reason:String=""):void
		{
			if(DEBUG) openMessagePopUp("Facebook Error",reason);
			loading(false);
		}
		protected function onLogIn(id:String=""):void
		{
			loading(false);
			Handlers.call(AppMessage.LOGED_IN);
		}
		protected function onLogOut():void
		{
			loading(false);
			Handlers.call(AppMessage.LOGED_OUT);
		}
		protected function facebookInit():void
		{
			
		}
		protected function setupSounds(gameMusic:Class=null,gameplayMusic:Class=null):void
		{
		}
		protected var currentLifeFriend:Object;
		protected function onMessage(evtType:String,parameters:Array):void
		{
			switch(evtType)
			{
				case AppMessage.LOG_IN_WITH_FACEBOOK:
				{
					facebookInit();
					break;
				}
				case AppMessage.VIEW_OPEN:
				{
					if(parameters[0] || parameters[1])
					{
						DataManager.inst.setCurentData(parameters[0],parameters[1]);
					
						if(parameters[0] is Class)	selectByClass(parameters[0] as Class);
						else openUIView(parameters[0],parameters[1]);
					}
					
					break;
				}
				case AppMessage.UPDATE_STATE:
				{
					if(selectedChild is IStateReceiver) (selectedChild as IStateReceiver).state = parameters[0];
					break;
				}
				case AppMessage.KEY_BACK:
				{
					onBackKey();
					break;
				}
				case AppMessage.LOG_OUT:
				{
					logOut();
					break;
				}
			}
		}
		protected function logOut():void
		{
			
		}
		protected function openUIView(viewItem:Object,viewData:Object=null):void
		{
			
		}
		protected function openMessagePopUp(title:String,mess:String):void
		{
			
		}
		protected var _paused:Boolean = false;
		public function pause(value:Boolean):void
		{
			if(selectedChild is IPausable) (selectedChild as IPausable).pause(value);
			_paused = value;
		}
		public function get paused():Boolean
		{
			return _paused;
		}
		override public function selectChild(value:DisplayObject):void
		{
			if(value==selectedChild) Handlers.call(AppMessage,AppMessage.VIEW_OPENED);
			super.selectChild(value);
		}
		override protected function onFadeComplete(child:DisplayObject):void
		{
			super.onFadeComplete(child);
			if(child.visible) Handlers.call(AppMessage,AppMessage.VIEW_OPENED);
		}
		// APP HANDLERS
		public function onBackKey():void
		{
			back();
		}
		protected function onAppActivate():void
		{
			System.resume();
			Starling.current.start();
			Starling.current.nativeStage.frameRate = 60;
			activate(true);
		}
		protected function onAppDeactivate():void
		{
			System.pause();
			Starling.current.stop();
			Starling.current.nativeStage.frameRate = 0;
			activate(false);
		}
		protected function onAppSleep():void
		{
			System.pause();
			Starling.current.nativeStage.frameRate = 0;
		}
		protected function onAppAwake():void
		{
			System.resume();
			Starling.current.nativeStage.frameRate = 60;
		}
		protected function onAppExiting():void
		{
			
		}
		override public function activate(value:Boolean):void
		{
			super.activate(value);
		}
	}
}