package mvc.model
{
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import mvc.controller.AbstractController;

public class AppAction extends ModelEntity
	{
		public static const TOGGLE:String = "toggle";
		public static const TOGGLE_ADDING:String = "toggleAdding";
		public static const ADD:String = "add";
		public static const REMOVE:String = "remove";
		public static const BLOCK:String = "block";
		public static const UNBLOCK:String = "unblock";
		
		public static const OPEN:String = "open";
		public static const CLOSE:String = "close";
		public static const CANCEL:String = "cancel";
		
		public static const UPDATE:String = "update";
		public static const SEND:String = "send";
		
		public var name:String;
		public var description:String;
		public var type:String;
		public var controller:AbstractController;
		public var handler:Function;
		public var data:Object;
		
		public var iconFlashClass:Class;
		public var iconUrl:String = "";
		
		/**
		 * internal flag that indicates that this action is available for use. 
		 */		
		public var enabled:Boolean = true;
		
		public function AppAction(type:String="",controller:AbstractController=null,iconFlashClass:Class=null,handler:Function=null,data:Object=null)
		{
			super();
			this.type = type;
			this.iconFlashClass = iconFlashClass;
			this.controller = controller;
			this.handler = handler;
			this.data = data;
			
			registerAppAction(this);
			
		}
		private static const actionsByID:Dictionary = new Dictionary();
		private static function registerAppAction(action:AppAction):void
		{
			var actionClass:String = getQualifiedClassName(action);
			var actions:Vector.<AppAction> = actionsByID[actionClass+"_"+action.type+"_"+action.data];
			if(!actions)
			{
				actions = new Vector.<AppAction>();
				actionsByID[actionClass+"_"+action.type+"_"+action.data] = actions;
			}
			var i:int = actions.indexOf(action);
			if(i<0) actions.push(action);
		}
		public static function getAction(actionClass:Class,type:String,data:Object):Vector.<AppAction>
		{
			return actionsByID[getQualifiedClassName(actionClass)+"_"+type+"_"+data];
		}
		public static function enableAction(actionClass:Class,actionType:String,data:Object,enable:Boolean):void
		{
			var actions:Vector.<AppAction> = getAction(actionClass,actionType,data);
			for each(var action:AppAction in actions)
			{
				if(action) action.enabled = enable;
			}
		}
	}
}