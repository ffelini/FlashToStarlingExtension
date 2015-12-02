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
		/*public static const CONVERT:String = "convert";
		public static const IGNORE_CONVERTING:String = "ignoreConverting";
		
		public var totalConvertDuration:Number;
		public var convertDuration:Number;
		public var createChildrenDuration:Number;
		public var drawAtlasToBmdDuration:Number;
		public var maxRectPackerAlgorithDuration:Number;
		
		public function getConvertionDurations():String
		{
			return "totalConvertDuration-"+totalConvertDuration+" "+
				"convertDuration-"+convertDuration+" "+
				"maxRectPackerAlgorithDuration-"+maxRectPackerAlgorithDuration+" "+
				"drawAtlasToBmdDuration-"+drawAtlasToBmdDuration+" "+
				"createChildrenDuration-"+createChildrenDuration+" ";
		}*/
		
		/**
		 * if true all flash buttons (movie clips with 2 frames - down and up) are converted to images and decorated as simple buttons using Decorator_Button class
		 */		
		//public var economicDecoration:Boolean = true;
		
		public function ConvertDescriptor()
		{
			super();
		}
		/*public function setInstanceState(inst:flash.display.DisplayObject,state:String):void
		{
			this[inst.name + "_state"] = state;
		}
		public function getInstanceState(inst:Object):String
		{
			return this[inst.name + "_state"];
		}
		public function addInstanceMirror(inst:flash.display.DisplayObject,mirror:Object):void
		{
			this[inst] = mirror;
		}
		public function getInstanceMirror(inst:flash.display.DisplayObject):Object
		{
			return this[inst];
		}
		public function getInstanceMirrorClass(inst:*):Class
		{
			return this[inst] ? this[inst] : this[getQualifiedClassName(inst)];
		}*/
		/**
		 * associates a flash instance with a starling class for convertion 
		 * @param inst - flash instance
		 * @param mirrorClass - starling mirror class
		 * 
		 */		
		/*public function addInstanceMirrorClass(inst:flash.display.DisplayObject,mirrorClass:Class):void
		{
			this[inst] = mirrorClass;
		}*/
		/**
		 * 
		 * @param inst - flash class instance
		 * @param mirrorClass - starling mirror class
		 * 
		 */		
		/*public function associateClasses(inst:*,mirrorClass:Class):void
		{
			var instClassName:String = inst is flash.display.DisplayObject || inst is Class ? getQualifiedClassName(inst) : inst+"";
			var mirrorClassName:String = getQualifiedClassName(mirrorClass);
			
			this[instClassName] = mirrorClass; 
			this[mirrorClassName] = inst; 
		}*/
		/**
		 * Ignore instances in the flash mirror hierarchy shoul be placed on top of everything 
		 * @param mirrorClass
		 * 
		 */		
		/*public function ignoreClass(mirrorClass:*):void
		{
			var mirrorClassName:String = mirrorClass is String ? mirrorClass : ObjUtil.getClassName(mirrorClass);
			this["ignore_"+mirrorClassName] = mirrorClass;
		}*/
		/**
		 * Ignore instances in the flash mirror hierarchy shoul be placed on top of everything 
		 * @param mirrorClass
		 * 
		 */	
		/*public function ignore(mirrorClass:*):Boolean
		{
			var mirrorClassName:String = ObjUtil.getClassName(mirrorClass);
			return this["ignore_"+mirrorClassName]!=null;
		}
		public function updatePoolClasses(add:Boolean,...classes):void
		{
			var pool:Vector.<Class> = this["poolClasses"];
			if(!pool)
			{
				pool = new Vector.<Class>();
				this["poolClasses"] = pool;
			}
			var i:int;
			for each(var cl:Class in classes)
			{
				i = pool.indexOf(cl);
				
				if(add) if(i<0) pool.push(cl);
				else if(i>=0) pool.splice(i,1);
			}
		}
		public function getPoolClasses():Vector.<Class>
		{
			return this["poolClasses"]
		}
		public function storeInstance(inst:*,key:*):void
		{
			this[key] = inst;
		}
		public function getInstance(key:*):*
		{
			return this[key];
		}*/
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