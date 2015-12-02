package starlingExtensions.decorators
{
import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.DisplayObject;

import starlingExtensions.utils.DisplayUtils;
import starlingExtensions.utils.RectangleUtil;

import utils.Utils;

public class Decorator_DropShadow extends Decorator
	{
		public function Decorator_DropShadow()
		{
			super();
		}
		private var helpP:Point;
		protected var shadowsByInstance:Dictionary = new Dictionary();
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			var _decorated:Boolean = super.decorate(value, _decorate, params);
			
			if(_decorate)
			{
				var obj:DisplayObject = value as DisplayObject;
				if(!obj || !obj.parent) return _decorated;
				
				var color:uint = params[0] ? params[0] : 0;
				var size:uint = params[1] ? params[1] : 1.5;
				var distance:uint = params[2] ? params[2] : 10;
				var angle:uint = params[3] ? params[3] : 45;
				
				var shadow:DisplayObject = shadowsByInstance[obj];
				if(!shadow)
				{
					shadow = DisplayUtils.clone(obj);
					shadowsByInstance[obj] = shadow;					
				}
				if(shadow.hasOwnProperty("color")) shadow["color"] = color;
				else if(shadow.hasOwnProperty("setColor")) shadow["setColor"](color);
				
				RectangleUtil.scaleToContent(shadow,obj.getBounds(obj.parent),true,size);
				
				helpP = Utils.nextPoint(shadow.x,shadow.y,distance,angle,helpP);
				
				shadow.x = helpP.x;
				shadow.y = helpP.y;
				
				DisplayUtils.addAbove(shadow,obj);
			}
			else
			{
				if(shadowsByInstance[value]) shadowsByInstance[value].removeFromParent();
			}
			return _decorated;
		}
		
	}
}