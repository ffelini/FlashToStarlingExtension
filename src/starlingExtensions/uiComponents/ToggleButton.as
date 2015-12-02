package starlingExtensions.uiComponents
{
import flash.net.registerClassAlias;

import starling.display.Button;
import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

import starlingExtensions.interfaces.IClonable;
import starlingExtensions.utils.TouchUtils;

[Event(name="changed", type="starling.events.Event")]
	public class ToggleButton extends Button implements IClonable
	{
		public var selectedColor:uint = 0xFFFFFF;
		
		/** Creates a button with textures for up- and down-state or text. */
		public function ToggleButton(upState:Texture, text:String="", downState:Texture=null)
		{
			super(upState,text,downState);
			registerClassAlias("ToggleButton",ToggleButton);
		}
		override protected function onTouch(event:TouchEvent):void
		{
			var _mDown:Boolean = mIsDown;
			
			super.onTouch(event);
			
			var touch:Touch = TouchUtils.clicked(this,event);
			if (!mEnabled || touch == null) return;
						
			if (touch && _mDown) selected = !_selected;
		}
		protected var _selected:Boolean = false;
		public function set selected(value:Boolean):void
		{
			if(value==_selected) return;
			
			_selected = value;
			
			resetTexture();
			
			mBackground.color = value && selectedColor!=0xFFFFFF ? selectedColor : 0xFFFFFF;
			
			dispatchEventWith("changed", true);
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		public var updateTextureOnDown:Boolean = true;
		override public function set downState(value:Texture):void
		{
			if(!updateTextureOnDown) return;
			super.downState = value;
			resetTexture();
		}
		public var updateTextureOnUp:Boolean = true;
		override public function set upState(value:Texture):void
		{
			if(!updateTextureOnUp) return;
			super.upState = value;
			resetTexture();
		}
		protected function resetTexture():void
		{
			mBackground.texture = _selected ? mDownState : mUpState;
		}
		public function clone():DisplayObject
		{
			var c:ToggleButton = new ToggleButton(upState,text,downState);
			c.selectedColor = selectedColor;
			c.updateTextureOnDown = updateTextureOnDown;
			c.updateTextureOnUp = updateTextureOnUp;
			return c;
		}
	}
}