package starlingExtensions.flash
{
import flash.display.DisplayObjectContainer;

import starling.display.DisplayObject;

public class FlashViewStack extends FlashSprite_Mirror
	{
		public function FlashViewStack(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			child.visible = false;
			return super.addChildAt(child, index);
		}
		protected var _selectedIndex:int;
		public function set selectedIndex(value:int):void
		{
			value = value<0 ? 0 : value;
			selectedChild = value<numChildren ? getChildAt(value) : null;
		}
		protected var _selectedChild:DisplayObject;
		public function set selectedChild(value:DisplayObject):void
		{
			if(!value || !value.parent==this) return;
			
			if(_selectedChild) _selectedChild.visible = false;
			
			_selectedChild = value;
			
			_selectedChild.visible = true;
			
			_selectedIndex = getChildIndex(value);
		}
		override public function clone():DisplayObject
		{
			var c:FlashViewStack = new FlashViewStack(mirror,rootMirror);
			c._created = _created;
			return c;
		}
		
	}
}