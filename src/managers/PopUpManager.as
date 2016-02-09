package managers
{
import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import gameComponents.PopUp;

import starling.core.Starling;
import starling.display.DisplayObject;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IActivable;

public class PopUpManager extends FlashSprite_Mirror
	{
		protected var _currentPopUp:DisplayObject;
		
		public var openedInstances:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		protected var popUpInstances:Dictionary = new Dictionary();
		
		public function PopUpManager(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror,_rootMirror);
			inst = this;
			super.visible = false;
			
			scaleToCoordinateSystem = centrateToCoordinateSystem = true;
		}
		protected var hideAllPopupsWhenInvisible:Boolean = true;
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if(hideAllPopupsWhenInvisible && !visible)
			{
				var _numChildren:int = numChildren;
				var child:DisplayObject;
				
				for(var i:int=0;i<_numChildren;i++)
				{
					child = getChildAt(i);
					if(child is PopUp) child.visible = false; 
				}
			}
		}
		private static var inst:PopUpManager;
		public static function setInstance(value:PopUpManager):void
		{
			inst = value;
			if(inst)  Handlers.call(setInstance);
		}
		public static function getInstance():PopUpManager
		{
			return inst;
		}
		public function get haveModalPopUps():Boolean
		{
			return visible;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is PopUp)
			{
				registerPopUpInstance(child);
				child.visible = false;
			}
			
			return super.addChildAt(child, index);
		}
		public function set currentPopUp(value:DisplayObject):void
		{
			_currentPopUp = value;
		}
		public function get currentPopUp():DisplayObject
		{
			return _currentPopUp;
		}
		protected var _currentPopUpClass:Class;
		public function set currentPopUpClass(popUpClass:Class):void
		{
			_currentPopUpClass = popUpClass;
		}
		public function get currentPopUpClass():Class
		{
			return _currentPopUpClass;
		}
		public static function openPopUp(popUpClass:Class,closeCurent:Boolean=false,newInstance:Boolean=false):DisplayObject
		{
			if(!popUpClass) return null;
			
			var inst:PopUpManager = getInstance();
			if(!inst) return null;
			
			if(inst.currentPopUpClass==popUpClass && inst.currentPopUp) return inst.currentPopUp;
			
			if(inst.currentPopUp && !closeCurent) inst.openedInstances.push(inst.currentPopUp);
			closePopUp(inst.currentPopUp,true,false,false);
			
			inst.currentPopUpClass = popUpClass;			
			return addPopUp(inst.getInstanceByClass(popUpClass, newInstance));
		}
		protected static function addPopUp(popUp:DisplayObject):DisplayObject
		{
			if(!popUp) return null;
			
			var inst:PopUpManager = getInstance();
			
			popUp.visible = inst.visible = true;
			inst.currentPopUp = popUp;
			
			return popUp;
		}
		public static function closeCurentPopUp(checkPopUpCloseEnabled:Boolean=false):DisplayObject
		{
			if(!getInstance() || ! getInstance().currentPopUp) return null;
			
			var popUp:PopUp = getInstance().currentPopUp as PopUp;
			if(!checkPopUpCloseEnabled || (checkPopUpCloseEnabled && popUp.closeEnabled)) closePopUp(popUp);
			
			return popUp;
		}
		public static function closePopUp(popUp:DisplayObject,deactivate:Boolean=true,openPrecedent:Boolean=false,clearHistory:Boolean=true):void
		{
			if(!popUp || !popUp.parent) return;
			
			Starling.juggler.removeTweens(popUp); 
			if(popUp is IActivable) (popUp as IActivable).activate(false);
			
			var inst:PopUpManager = popUp.parent as PopUpManager;
			inst.currentPopUp = null;
			popUp.visible = false;
			
			if (openPrecedent) openPopUp(inst.popUpInstances[inst.openedInstances.pop()]);
			else if(clearHistory) inst.openedInstances.length = 0;
			
			if(!inst.currentPopUp) inst.visible = false;
		}
		protected function getInstanceByClass(popUpClass:Class,newInstance:Boolean=false):DisplayObject
		{
			var className:String = getQualifiedClassName(popUpClass).split("::")[1];
			try{
				var _inst:DisplayObject = (newInstance ? new popUpClass() : (popUpInstances[popUpClass] ? popUpInstances[popUpClass] :
				popUpInstances[className] ? popUpInstances[className] : new popUpClass())) as DisplayObject;
			}
			catch(e:Error){ return null };
			
			popUpInstances[popUpClass] = _inst;
			popUpInstances[_inst] = popUpClass;
			registerPopUpInstance(_inst);
			
			return _inst;
		}
		public function registerPopUpInstance(_inst:DisplayObject):void
		{
			var className:String = getQualifiedClassName(_inst).split("::")[1];
			inst.popUpInstances[className] = _inst;			
		}
	}
}