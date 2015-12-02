package feathersExtensions.renderers
{
import feathers.controls.Button;
import feathers.controls.ImageLoader;

import feathersExtensions.controls.FeathersImage_Remote;

import mvc.model.AppAction;
import mvc.view.screen.AbstractMenuItem;

import starling.display.DisplayObject;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

import starlingExtensions.textureutils.Textures;

public class IconIR extends SmartIR
	{
		public var iconPercentWidth:Number = 100;
		public var iconPercentHeight:Number = 100;
		
		public function IconIR()
		{
			super();
			
			itemHasLabel = false;
			iconSourceFunction = iconSourceFunc;
			labelField = "name";
			useStateDelayTimer = false;
			stateToIconFunction = stateToIconFunc;
		}
		protected function stateToIconFunc(target:Button, state:Object, oldIcon:DisplayObject = null):DisplayObject
		{
			if(currentIcon) return currentIcon;
			else return new ImageLoader();
		}
		override protected function initLayout():void
		{
			super.initLayout();
			horizontalAlign = HORIZONTAL_ALIGN_CENTER;
			verticalAlign = VERTICAL_ALIGN_MIDDLE;
		}
		public function get imageUrl():String
		{
			return menu ? menu.iconUrl : (action ? action.iconUrl : data+"");
		}
		public function get iconFlashClass():Class
		{
			return menu ? menu.iconFlashClass : (action ? action.iconFlashClass : null);
		}
		protected function get action():AppAction
		{
			return data as AppAction;
		}
		protected function get menu():AbstractMenuItem
		{
			return data as AbstractMenuItem;
		}
		override public function set data(value:Object):void
		{
			super.data = value;
			if(!value) return;
			
			if(imageIcon) imageIcon.url = imageUrl;
			if(currentIcon) (currentIcon as ImageLoader).source = iconSourceFunc(data);
		}
		override public function set isEnabled(value:Boolean):void
		{
			super.isEnabled = value;
			if(imageIcon) imageIcon.alpha = value ? 1 : 0.7;
			if(currentIcon) currentIcon.alpha = value ? 1 : 0.7;
		}
		protected var imageIcon:FeathersImage_Remote;
		protected function getImageIcon(url:String):FeathersImage_Remote
		{
			if(!imageIcon) imageIcon = new FeathersImage_Remote();
			imageIcon.url = url;
			return imageIcon;
		}
		protected var selectedIconFrame:int = 1;
		protected var upIconFrame:int = 2;
		protected var disableIconFrame:int = 0;
		protected function iconSourceFunc(data:Object):Texture
		{
			var frame:int = _isSelected ? selectedIconFrame : (_isEnabled ? upIconFrame : disableIconFrame);
			
			if(iconFlashClass) return Textures.fromMCClass(iconFlashClass,true,true,frame);
			return Textures.fromColor(0xFFFFFF);
		}
		protected function get iconTexture():Texture
		{
			return imageIcon ? imageIcon.img.texture : (currentIcon ? (currentIcon as ImageLoader).source as Texture : null);
		}
		override protected function button_touchHandler(e:TouchEvent):void
		{
			super.button_touchHandler(e);
			invalidate(INVALIDATION_FLAG_SELECTED);
			
			if(e.getTouch(this,TouchPhase.BEGAN)) drawSelection(true);
		}
		override public function set isSelected(value:Boolean):void
		{
			super.isSelected = value;
			drawSelection(_isSelected);
		}
		public static const defaultSelectionColor:uint = 0x666666;
		public var selectionColor = defaultSelectionColor;
		protected function drawSelection(selected:Boolean):void
		{
			if(imageIcon) imageIcon.img.color = selected ? selectionColor : 0xFFFFFF;
			if(currentIcon) (currentIcon as ImageLoader).color = selected ? selectionColor : 0xFFFFFF;
		}
		override protected function itemToIcon(item:Object):DisplayObject
		{
			if(currentIcon) return currentIcon;

			if(iconFlashClass) return super.itemToIcon(item) as ImageLoader;
			
			if(imageUrl!="") return getImageIcon(imageUrl);
			
			return super.itemToIcon(item)
		}
		override protected function validateSize():void
		{
			super.validateSize();
			if(currentIcon) (currentIcon as ImageLoader).setSize(this.width*(iconPercentWidth/100),this.height*(iconPercentHeight/100));
			if(imageIcon) imageIcon.setSize(this.width*(iconPercentWidth/100),this.height*(iconPercentHeight/100));
		}
	}
}