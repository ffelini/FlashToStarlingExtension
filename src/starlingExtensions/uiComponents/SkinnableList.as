package starlingExtensions.uiComponents
{
import flash.geom.Matrix;

import starling.display.DisplayObject;

import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IDisplayTarget;
import starlingExtensions.uiComponents.renderers.FlashSkinableIR;
import starlingExtensions.utils.DisplayUtils;

public class SkinnableList extends List
	{
		public var hint:IDisplayTarget;
		
		public function SkinnableList()
		{
			super();
		}
		protected var _skin:FlashSkinableIR;
		protected var _skinTransfMatrix:Matrix;
		public function set skin(value:FlashSkinableIR):void
		{
			_skin = value;
			_skinTransfMatrix = (_skin as DisplayObject).transformationMatrix.clone();
		}
		public function get skin():FlashSkinableIR
		{
			return _skin;
		}
		override public function addItem(data:Object, index:int):IItemRenderer
		{
			if(!filterAddItem(data,index)) return null;
			var ir:IItemRenderer = objPool.get(itemRenderer,false) as IItemRenderer;
			
			if(_skin)
			{
				if(!ir) 
				{
					ir = DisplayUtils.clone(_skin as DisplayObject) as IItemRenderer;
					
					if(ir && _skinTransfMatrix) (ir as DisplayObject).transformationMatrix = _skinTransfMatrix;
					else DisplayUtils.cloneTransformationMatrix(_skin as DisplayObject,ir as DisplayObject);
				}
				else if(ir is FlashSkinableIR) (ir as FlashSkinableIR).skin = _skin as FlashSkinableIR;
			}
			return addIRAt(ir,data,index);
		}
		override public function addIRAt(ir:IItemRenderer, data:Object, i:int):IItemRenderer
		{
			if(ir is FlashSprite_Mirror && _skin) (ir as FlashSprite_Mirror).updateMirror(skin.mirror,skin.rootMirror);
			return super.addIRAt(ir, data, i);
		}
		public var showHintOnSelected:Boolean = true;
		override public function set selectedItem(value:IItemRenderer):void
		{
			if(!selectable) return;
			super.selectedItem = value;
			
			if(showHintOnSelected && hint) hint.target = _selectedItem as DisplayObject;			
		}
	}
}