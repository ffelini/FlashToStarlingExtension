package starlingExtensions.containers
{
import flash.system.Capabilities;
import flash.system.System;
import flash.utils.Dictionary;

import managers.interfaces.ILoader;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.interfaces.IActivable;
import starlingExtensions.utils.TweenUtils;

import utils.TimeOut;

public class ViewStack extends Sprite implements IActivable,ILoader
	{
		public static var DEBUG:Boolean = Capabilities.isDebugger;
		
		public var sequenceFade:Boolean = true;
		
		public var transitionDuration:Number = 0.4;
		
		public var fadeFullScreen:Boolean = true;
		
		public function ViewStack()
		{
			super();
		}
		protected function instantiateChild(childClass:Class):DisplayObject
		{
			return new childClass();
		}
		private var children:Dictionary = new Dictionary();
		protected function getChildByClass(childClass:Class):DisplayObject
		{
			if(!childClass) return null;
			
			var child:DisplayObject = children[childClass];
			if(child) return child;
			
			child = instantiateChild(childClass);
			children[childClass] = child;
			
			return child;
		}
		public var selectedChildClass:Class;
		public function selectByClass(childClass:Class):DisplayObject
		{
			var child:DisplayObject = getChildByClass(childClass);
			selectChild(child);
			selectedChildClass = childClass;
			return child;
		}
		public function showByClass(childClass:Class):DisplayObject
		{
			var child:DisplayObject = getChildByClass(childClass);
			addChild(child);
			selectedChildClass = childClass;
			child.visible = true;
			return child;
		}
		protected var fadeQuad:Quad;
		protected function initFadeQuad():void
		{
			if(!fadeQuad) fadeQuad = new Quad(AdvancedSprite.coordinateSystemRect.width,AdvancedSprite.coordinateSystemRect.height,0);
			fadeQuad.width = fadeFullScreen ? AdvancedSprite.coordinateSystemRect.width : width;
			fadeQuad.height = fadeFullScreen ? AdvancedSprite.coordinateSystemRect.height : height;
			fadeQuad.x = fadeQuad.y = 0;
			
			addChild(fadeQuad);
		}
		public var iLoaderInstance:ILoader;
		public var affectStageTouchable:Boolean = true;
		public function loading(value:Boolean=true,processID:Object=null):void
		{
			if(iLoaderInstance) iLoaderInstance.loading(value,processID);
		}
		protected function updateTouches(activate:Boolean):void
		{
			touchable = activate;
			if(selectedChild) selectedChild.touchable = activate;
			if(affectStageTouchable && stage) stage.touchable = activate;
		}
		public var lastChild:DisplayObject;
		public var selectedChild:DisplayObject;
		public function selectChild(value:DisplayObject):void
		{
			if(!value || value==selectedChild) return;
			
			updateTouches(false);
			
			lastChild = selectedChild;
			if(lastChild) 
			{
				lastChild.touchable = false;
				if(!history) history = new Vector.<DisplayObject>();
				history.push(lastChild);
			}
			if(lastChild) lastChild.touchable = false;
			
			selectedChild = value;
			
			if(lastChild && sequenceFade) animateChildSelection(lastChild,false);
			else animateChildSelection(selectedChild,true);
			
			selectedIndex = getChildIndex(selectedChild);
		}
		protected function animateChildSelection(child:DisplayObject,show:Boolean):void
		{
			if(!child) return;
			
			initFadeQuad(); 
			fadeQuad.alpha = transitionDuration>0 ? (show ? 1 : 0) : (show ? 0 : 1);
			
			if(show) child.visible = true;	
			else if(child is FlashDisplay_Mirror) (child as FlashDisplay_Mirror).activateJuggler(false); 
			
			if(transitionDuration>0) fadeChild(child,show);
			else onFadeComplete(child);
		}
		protected function fadeChild(child:DisplayObject,show:Boolean):void
		{
			fadeQuad.visible = true;
			var tween:Tween = TweenUtils.add(fadeQuad,{"alpha":show ? 0 : 1}, show ? Transitions.EASE_IN : Transitions.EASE_OUT, transitionDuration, false);
			tween.onComplete = onFadeComplete;
			tween.onCompleteArgs = [child];
			
			Starling.juggler.add(tween);	
		}
		private static var lastMemory:Number;
		protected var childrenShowDelay:Number = 50;
		protected function onFadeComplete(child:DisplayObject):void
		{
			fadeQuad.visible = fadeQuad.alpha>0; 
			loading(fadeQuad.visible,selectedChild);
			
			if(fadeQuad.visible) 
			{
				lastMemory = System.privateMemory;
				child.visible = false;
				
				if(sequenceFade)
				{
					if(child is IActivable)
					{
						if(!(child as IActivable).active && checkMem()) TimeOut.setTimeOutFunc(animateChildSelection,childrenShowDelay,true,selectedChild,true);
						else child.addEventListener(Event.ENTER_FRAME,waitMemoryRelease);
					}
					else TimeOut.setTimeOutFunc(animateChildSelection,childrenShowDelay,true,selectedChild,true);
				}
			}
			updateTouches(!fadeQuad.visible);
		}
		protected function waitMemoryRelease(e:Event):void
		{
			if(checkMem())
			{
				e.target.removeEventListener(Event.ENTER_FRAME,waitMemoryRelease);
				TimeOut.setTimeOutFunc(animateChildSelection,childrenShowDelay,true,selectedChild,true);
			}
		}
		public var waitMemRelease:Boolean = false;
		private function checkMem():Boolean
		{
			if(DEBUG) trace("ViewStack.checkMem(child)",Boolean(!waitMemRelease || (waitMemRelease && System.privateMemory<lastMemory)),
				" lastMemory - "+lastMemory,System.privateMemory);
			
			return !waitMemRelease || (waitMemRelease && System.privateMemory<lastMemory);
		}
		protected var history:Vector.<DisplayObject>;		
		public function back():void
		{
			if(!history) return;
			selectChild(history.pop());
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			child.visible = child.touchable = false;
			return super.addChild(child);
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			child.visible = child.touchable = false;
			return super.addChildAt(child, index);
		}
		public var selectedIndex:int;
		public function selectIndex(value:int):void
		{
			if(value<0 || value>numChildren-1) return;
			selectChild(getChildAt(selectedIndex));
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if(selectedChild)
			{
				selectedChild.visible = value;
				if(!value && selectedChild is FlashDisplay_Mirror) 
				{
					(selectedChild as FlashDisplay_Mirror).activate(false);
					(selectedChild as FlashDisplay_Mirror).activateAtlases(false,true);
				}
			}
		}
		public function activate(value:Boolean):void
		{
			_active = value;
			var _numChildren:int = numChildren;
			var child:DisplayObject;
			for(var i:int=0;i<_numChildren;i++)
			{
				child = getChildAt(i);
				if(child.visible && child is IActivable) (child as IActivable).activate(_active);
			}
		}
		protected var _active:Boolean = false;
		public function get active():Boolean
		{
			return _active;
		}
	}
}