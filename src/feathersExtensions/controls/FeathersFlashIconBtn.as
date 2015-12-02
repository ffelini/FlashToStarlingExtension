package feathersExtensions.controls
{
import feathers.controls.Button;

import starling.display.DisplayObject;

import starlingExtensions.textureutils.Textures;

public class FeathersFlashIconBtn extends Button
	{
		protected var downFrame:int = 1;
		protected var upFrame:int = 2;
		protected var disabledFrame:int = 0;
		
		protected var flashIconClass:Class;
		
		public function FeathersFlashIconBtn(flashIconClass:Class)
		{
			super();
			
			this.flashIconClass = flashIconClass;
			stateToIconFunction = stateToIconFunc;
		}		
		protected function stateToIconFunc(target:Button, state:Object, oldIcon:DisplayObject = null):DisplayObject
		{
			if(!oldIcon) oldIcon = new FeathersImage_Remote();
			
			(oldIcon as FeathersImage_Remote).img.texture = Textures.fromMCClass(flashIconClass,true,true,state==STATE_UP ? upFrame : downFrame);
			(oldIcon as FeathersImage_Remote).setSize(width*0.9,height*0.9);
			
			return oldIcon;
		}
		override public function validate():void
		{
			super.validate();
		}
	}
}