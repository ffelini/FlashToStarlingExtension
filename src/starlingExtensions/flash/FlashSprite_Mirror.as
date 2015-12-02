package starlingExtensions.flash
{
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import haxePort.managers.interfaces.IResetable;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirror;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashSpriteMirror;

import starling.animation.Juggler;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.QuadBatch;
import starling.display.Sprite;
import starling.events.TouchEvent;

import starlingExtensions.batch.TextFieldBatchEntity;
import starlingExtensions.flash.animation.FlashMovieClip_Mirror;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.interfaces.IJugglerAnimator;
import starlingExtensions.utils.DisplayUtils;

import utils.ObjUtil;
import utils.log;

/**
	 * Basic class used to convert Flash sprite instances in Starling sprite instances.
	 * If you want to write your own components you will have to extend this class.
	 * 
	 * Basic template
	 * public class UI_Header extends FlashSprite_Mirror
	 *	{
	 * 		protected var cashField:CountingField;
	 * 		protected var coinsField:CountingField;
	 * 		protected var livesField:CountingField;
	 * 		
	 * 		protected var flashMirror:Header;
	 * 
	 * 		public function UI_Header(_mirror:flash.display.DisplayObjectContainer,_rootMirror:FlashDisplay_Mirror)
	 * 		{
	 * 			super(_mirror, _rootMirror);
	 * 			flashMirror = _mirror as Header;
	 * 			addEventListener(TouchEvent.TOUCH,onBtnTouch);
	 * 		}
	 * 		override public function createChildren():void
	 * 		{
	 * 			super.createChildren();
	 *
	 * 			cashField = rootMirror.getMirror(flashMirror.cashField) as CountingField;
	 * 			coinsField = rootMirror.getMirror(flashMirror.coinsField) as CountingField;
	 * 			livesField = rootMirror.getMirror(flashMirror.livesField) as CountingField;
	 * 		}	
	 *	}
	 * @author peak
	 * 
	 */	
	public class FlashSprite_Mirror extends TextFieldBatchEntity implements IFlashSpriteMirror,IClonable,IResetable,IJugglerAnimator
	{
		public static var DEBUG:Boolean = false;
		
		public var mirror:flash.display.DisplayObjectContainer;
		public var rootMirror:FlashDisplay_Mirror
		
		public var autoFlatten:Boolean = false;
		
		public var scaleToCoordinateSystem:Boolean = false;
		public var centrateToCoordinateSystem:Boolean = false;
		
		public function FlashSprite_Mirror(_mirror:flash.display.DisplayObjectContainer=null,_rootMirror:FlashDisplay_Mirror=null)
		{
			super();
			updateMirror(_mirror,_rootMirror);
			scaleToCoordinateSystem = _rootMirror ? _rootMirror.scaleToCoordinateSystem : scaleToCoordinateSystem;
			centrateToCoordinateSystem = _rootMirror ? _rootMirror.centrateToCoordinateSystem : centrateToCoordinateSystem;
		}
		public function updateMirror(_mirror:flash.display.DisplayObjectContainer=null,_rootMirror:FlashDisplay_Mirror=null):void
		{	
			mirror = _mirror;
			rootMirror = _rootMirror;
			
			textFieldsBatch = rootMirror ? rootMirror.textfieldsBatchSprite : null;
			batchableTextFields = rootMirror ? rootMirror.batchTextFields : false;
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(value) validateChildrenCreation();
			
			if(_created)
			{
				if(!value)
				{
					FlashMovieClip_Mirror.processAllMovieClips(this,"pause");
				}
				else
				{
					FlashMovieClip_Mirror.processAllMovieClips(this,"resume");
				}
			}
		}
		override public function get hasVisibleArea():Boolean
		{
			validateChildrenCreation();
			
			return super.hasVisibleArea;
		}
		// CHILDREN CREATION WORFLOW
		public function fastGetChildAt(index:int):DisplayObject
		{
			return super.getChildAt(index);
		}
		override public function getChildAt(index:int):DisplayObject
		{
			var c:DisplayObject = super.getChildAt(index);
			if(c is IFlashMirror) (c as IFlashMirror).validateChildrenCreation();
			validateChildrenCreation();
			return c;
		}
		override public function getChildByName(name:String):DisplayObject
		{
			var c:DisplayObject = super.getChildByName(name);
			if(c is IFlashMirror) (c as IFlashMirror).validateChildrenCreation();
			validateChildrenCreation();
			return c;
		}
		protected var _creationComplete:Boolean = false;
		public function validateChildrenCreation():void
		{
			if(!_created && rootMirror && rootMirror.created) 
			{
				createChildren();
				_creationComplete = true;
			}
		}
		public static function validateHierarchyChildrenCreation(container:starling.display.DisplayObjectContainer):void
		{
			if(!container) return;
			
			var numChildren:int = container.numChildren;
			var child:DisplayObject;
			
			for(var i:int=0;i<numChildren;i++)
			{
				child = container.getChildAt(i);
				
				if(child is IFlashMirror) (child as IFlashMirror).validateChildrenCreation();
				
				if(child is starling.display.DisplayObjectContainer) validateHierarchyChildrenCreation(child as starling.display.DisplayObjectContainer);
			}
		}
		protected var _created:Boolean = false;
		public function createChildren():void
		{
			_created = true;
			ObjUtil.cloneFields(mirror,this,"autoFlatten");
			
			if(DEBUG) log(this,"createChildren",mirror,autoFlatten,numChildren);
			
			if(autoFlatten) autoFlattenCheck();
			
			trackBoundsChange = true;
			//dispatchEvents = broadcastEvents = true;
		}
		public function get juggler():Juggler
		{
			return rootMirror ? rootMirror.juggler : null;
		}
		public function getMirror(_mirror:*):*
		{
			return rootMirror ? rootMirror.getMirror(_mirror) : null;
		}
		public function getMirrorRect(_mirror:*):Rectangle
		{
			return rootMirror ? rootMirror.getMirrorRect(_mirror) : null;
		}
		protected function updateBatching(sprite:Sprite,_batchbleFlag:Boolean):void
		{
			var numBatches:int = mFlattenedContents ? mFlattenedContents.length : 0;
			
			for (var i:int=0; i<numBatches; ++i)
			{
				var quadBatch:QuadBatch = mFlattenedContents[i];
				quadBatch.batchable = _batchbleFlag;
			}
		}
		override public function set batchableTextFields(value:Boolean):void
		{
			super.batchableTextFields = value;
			updateBatching(this,_batchable);
		}
		protected function autoFlattenCheck():void
		{
			if(autoFlatten && numChildren>24) flatten();
		}
		override public function flatten():void
		{
			if(isFlattened) return;
			super.flatten();
			if(DEBUG) log(this,"flatten");
		}
		override public function unflatten():void
		{
			if(!isFlattened) return;
			super.unflatten();
			if(DEBUG) log(this,"unflatten");
		}
		public function get created():Boolean
		{
			return _created;
		}
		public function get_created():Boolean
		{
			return _created;
		}
		public function reset():void
		{
		}
		override public function clone():DisplayObject
		{
			var c:FlashSprite_Mirror = new FlashSprite_Mirror(mirror,rootMirror);
			return c;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			registerMirrorChild(child,index);
			
			processChildColor(child,_color);
			if(!_touchChildren) processTouchChildren(child,index);
			
			super.addChildAt(child, index);
			
			if(autoFlatten) autoFlattenCheck();
			
			return child
		}
		override public function set touchable(value:Boolean):void
		{
			super.touchable = value;
			
			if(value) addEventListener(TouchEvent.TOUCH,onTouch);
			else removeEventListener(TouchEvent.TOUCH,onTouch);
		}
		protected function onTouch(e:TouchEvent):void
		{
			
		}
		protected var _touchChildren:Boolean = true;
		public function set touchChildren(value:Boolean):void
		{
			_touchChildren = value;
			DisplayUtils.forEachChild(this,processTouchChildren);
		}
		public function get touchChildren():Boolean
		{
			return _touchChildren;
		}
		protected function processTouchChildren(child:DisplayObject,childIndex:int=-1):void
		{
			child.touchable = _touchChildren ? true : childIndex==0;
		}
		protected var mirrorChilds:Array = [];
		protected function registerMirrorChild(child:DisplayObject,i:int=-1):void
		{
			if(mirrorChilds.indexOf(child)<0) 
			{
				i<0 ? mirrorChilds.push(child) : mirrorChilds[i] = child;
			}
		}
		public function getMirrorChildAt(i:int):*
		{
			return mirrorChilds[i];
		}
		public function adChildAt(child:*, index:int):void
		{
			addChildAt(child as DisplayObject,index);
		}
		public function adChild(child:*):void
		{
			addChild(child);
		}
		public function getChildAtIndex(index:int):*
		{
			return getChildAtIndex(index);
		}
		public function numChildrens():int
		{
			return numChildren;
		}
	}
}