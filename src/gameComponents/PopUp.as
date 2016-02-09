package gameComponents
{
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.utils.setTimeout;

import gameComponents.layers.PopUpLayerBase;

import managers.PopUpManager;
import managers.interfaces.IPopUp;

import starling.animation.Transitions;
import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.text.TextField;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IActivable;
import starlingExtensions.uiComponents.FlashLabelButton;
import starlingExtensions.utils.DisplayUtils;
import starlingExtensions.utils.TouchUtils;
import starlingExtensions.utils.TweenUtils;

import utils.ObjUtil;

public class PopUp extends FlashSprite_Mirror implements IActivable,IPopUp
	{
		public var closeBtn:DisplayObject;
		public var okBtn:FlashLabelButton;
		public var cancelBtn:FlashLabelButton;
		
		public var titleField:TextField;
		
		public var helpRect:DisplayObject;
		public var content:FlashSprite_Mirror;
		
		public var afterCloseFunctionalityDelay:Number = 10;
		
		public function PopUp(_mirror:DisplayObjectContainer, _rootMirror:FlashDisplay_Mirror)
		{
			super(_mirror, _rootMirror);
		}
		public var requireFB:Boolean = false;
		public var requireOnline:Boolean = false;
		public function get reactOnIssues():Boolean
		{
			return requireFB || requireOnline;
		}
		override public function createChildren():void 
		{
			super.createChildren(); 
			
			closeBtn = getChildByName("closeBtn");
			okBtn = getChildByName("okBtn") as FlashLabelButton;
			cancelBtn = getChildByName("cancelBtn") as FlashLabelButton;			
			titleField = getChildByName("titleField") as TextField;
			helpRect = getChildByName("helpRect");
			
			if(closeBtn && closeBtn.parent!=this) addChild(closeBtn);
			resetButtons(true);
			
			if(titleField) titleField.color = 0x795200;
			if(helpRect) helpRect.visible = false;
		}
		protected var _active:Boolean = false;
		public function activate(value:Boolean):void
		{
			resetButtons(true);
			if(value)
			{
				if(okBtn) 
				{
					ObjUtil.cloneFields(getMirrorRect(okBtn),okBtn,"x");  
					okBtn.x += 100;					
					TweenUtils.add(okBtn,{"x":okBtn.x - 100,"alpha":1},Transitions.EASE_IN,0.4);
				}
				if(cancelBtn) 
				{
					ObjUtil.cloneFields(getMirrorRect(cancelBtn),cancelBtn,"x");
					cancelBtn.x -= 100;
					TweenUtils.add(cancelBtn,{"x":cancelBtn.x + 100,"alpha":1},Transitions.EASE_IN,0.4); 
				}
			}
			_active = value;
			touchable = _active;
		}
		public function get active():Boolean
		{
			return _active;
		}
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
//			if(_created && gamePlayMode!=(PopUpLayerBase.gamePlay!=null)) updateUI(PopUpLayerBase.gamePlay);
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
//			if(_created) updateUI(PopUpLayerBase.gamePlay);
		}
		protected var gamePlayMode:Boolean = false;
		public function updateUI(_gamePlayMode:Boolean=false):void
		{
			gamePlayMode = _gamePlayMode;
		}
		protected function resetButtons(remTweens:Boolean):void
		{
			if(okBtn) 
			{
				okBtn.alpha = 0;
				if(remTweens) TweenUtils.removeTweens(okBtn);
			}
			if(cancelBtn)
			{
				cancelBtn.alpha = 0;
				if(remTweens) TweenUtils.removeTweens(cancelBtn);
			}
		}
		public function resetUI():void
		{
			
		}
		public var closeOnFocusOut:Boolean = true;
		public function get closeEnabled():Boolean
		{
			return closeOnFocusOut && closeBtn && closeBtn.visible;
		}
		protected var closeTouch:Touch;
		protected var okTouch:Touch;
		protected var cancelTouch:Touch;
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			closeTouch = TouchUtils.clicked(closeBtn,e);
			okTouch = TouchUtils.clicked(okBtn,e);
			cancelTouch = TouchUtils.clicked(cancelBtn,e);
			
			if(closeTouch || cancelTouch) close(true,true);
		}
		public function outsideTouch(e:TouchEvent):void
		{
			close(false,false);
		}
		public function set background(value:DisplayObject):void
		{
			if(!value) return;
			
			super.addChildAt(value,0);
			DisplayUtils.setBounds(value,getBounds(this,sHelperRect));
			value.visible = true;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(reactOnIssues && child!=closeBtn)
			{
				if(!content) 
				{
					this.content = new FlashSprite_Mirror(null,null);
					super.addChildAt(content,index);
				}
				return content.addChildAt(child,index);
			}
			return super.addChildAt(child, index);
		}
		override public function getChildByName(name:String):DisplayObject
		{
			return super.getChildByName(name) || (content ? content.getChildByName(name) : super.getChildByName(name));
		}
		override public function get width():Number
		{
			return helpRect ? helpRect.width : super.width;
		}
		override public function get height():Number
		{
			return helpRect ? helpRect.height : super.height;
		}
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			return helpRect ? helpRect.getBounds(targetSpace,resultRect) : super.getBounds(targetSpace,resultRect);
		}	
		public var closeHandler:Function;
		public function close(callHandler:Boolean=true,openPrecedent:Boolean=true,clearHistory:Boolean=true):void
		{
			resetButtons(false);
			PopUpManager.closePopUp(this,true,openPrecedent,clearHistory);
			
			if(callHandler && closeHandler!=null) setTimeout(closeHandler,afterCloseFunctionalityDelay);
		}
	}
}