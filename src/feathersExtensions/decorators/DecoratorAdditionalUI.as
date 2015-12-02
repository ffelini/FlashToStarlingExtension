package feathersExtensions.decorators
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.display.DisplayObject;
import starling.display.Sprite;

import starlingExtensions.decorators.Decorator;
import starlingExtensions.utils.DisplayUtils;

public class DecoratorAdditionalUI extends Decorator
	{
		public function DecoratorAdditionalUI()
		{
			super();
		/**
		 * params[0] - additional UI data
		 * params[1] - additional UI bounds to be set
		 */
		}
		protected var decorationUIs:Dictionary = new Dictionary();
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			var decorated:Boolean = super.decorate(value, _decorate, params);
			
			var decorationTarget:Sprite = value as Sprite;
			var decorationUI:DisplayObject = _decorate ? getDecorationUI(decorationTarget,params[0]) : decorationUIs[decorationTarget];
			
			if(!decorationTarget || !decorationUI) return decorated;
			
			var decorationUIBounds:Rectangle = params[1];
			
			if(_decorate)
			{
				DisplayUtils.setBounds(decorationUI,decorationUIBounds);
				decorationTarget.addChild(decorationUI);
				
				decorationUIs[decorationTarget] = decorationUI;
			}
			else
			{
				if(decorationUI.parent==decorationTarget) decorationUI.removeFromParent();
			}
			return decorated;
		}
		protected function getDecorationUI(decorationTarget:Sprite,data:Object):DisplayObject
		{
			return new Sprite();
		}
		
	}
}