package mvc.view.screen
{
import feathers.controls.ScreenNavigatorItem;
import feathers.data.ListCollection;

import mvc.controller.AbstractController;

public class AbstractMenuItem extends ScreenNavigatorItem
	{
		public var name:String = "";
		public var description:String = "";
		public var controller:AbstractController;
		public var iconFlashClass:Class;
		public var iconUrl:String = "";
		
		public var menu:ListCollection;
		
		public var handler:Function;
		public var data:Object;
		
		public function AbstractMenuItem(screen:Object,name:String,controller:AbstractController,iconFlashClass:Class,menu:ListCollection=null,description:String="",handler:Function=null,data:Object=null)
		{
			super(screen, events, properties);
			this.name = name;
			this.controller = controller;
			this.iconFlashClass = iconFlashClass;
			this.menu = menu;
			this.description = description;
			this.handler = handler;
			this.data = data;
		}
	}
}