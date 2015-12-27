package starlingExtensions.flash.movieclipConverter
{
import flash.display.DisplayObject;

import haxePort.starlingExtensions.flash.movieclipConverter.ConvertDescriptor;
import haxePort.starlingExtensions.flash.movieclipConverter.ConvertUtils;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;

import starlingExtensions.uiComponents.FlashLabelButton;

/**
	 * This class is used to describe convertion of flash objects 
	 * @author peak
	 * 
	 */	
	public dynamic class ConvertDescriptor extends haxePort.starlingExtensions.flash.movieclipConverter.ConvertDescriptor
	{
		public function ConvertDescriptor()
		{
			super();
		}
		override public function getObjClassToConvert(obj:DisplayObject):Class
		{
			var cl:Class = super.getObjClassToConvert(obj);
			
			if(cl) return cl;
			
			var objType:String = FlashDisplay_Converter.getFlashObjType(obj);
			
			switch(objType)
			{
				case ConvertUtils.TYPE_FLASH_LABEL_BUTTON:
				{
					cl = FlashLabelButton;
					break;
				}
			}
			return cl;
		}
	}
}