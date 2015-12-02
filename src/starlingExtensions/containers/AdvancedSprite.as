package starlingExtensions.containers 
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.utils.DisplayUtils;
import starlingExtensions.utils.RectangleUtil;

/**
	 * A class that allows you to use relative to relativeRect value size position. Relative positions are calculated in percents
	 * @author peak
	 */
	public class AdvancedSprite extends TouchContainer 
	{
		public var paddingLeft:Number = 0;
		public var paddingRight:Number = 0;
		public var paddingTop:Number = 0;
		public var paddingBottom:Number = 0;
		
		private static var _coordinateSystemRect:Rectangle;			
		public static function get coordinateSystemRect():Rectangle {
			if(_coordinateSystemRect==null) {
				_coordinateSystemRect = new Rectangle();
				//_coordinateSystemRect.width = Starling.current.nativeStage.fullScreenWidth;
				//_coordinateSystemRect.height = Starling.current.nativeStage.fullScreenHeight;
				_coordinateSystemRect.width = Starling.current.nativeStage.stageWidth;
				_coordinateSystemRect.height = Starling.current.nativeStage.stageHeight;
			}
			return _coordinateSystemRect;
		}
		
		private static var instances:Vector.<AdvancedSprite> = new Vector.<AdvancedSprite>();
		private static var numInstances:int = 0;
		
		public var autoLayout:Boolean = true;
		public var autoSaveLayout:Boolean = true;

		/**
		 * if true then all content is scaled to the screen size by filling it totally 
		 */		
		public var scaleToCoordinateSystem:Boolean = false;
		/**
		 * if true the content ins centrated to screen 
		 */		
		public var centrateToCoordinateSystem:Boolean = false;
		/**
		 * if true children are scaled using relative positions 
		 */		
		public var scaleChildren:Boolean = true;
		/**
		 * if true all positions are saved relative to relativeRect instance
		 */		
		public var useRelativePositions:Boolean = true; 
		/**
		 * a rectangle instance that is used as a tempalte for relative positions calulations 
		 */		
		public var relativeRect:Rectangle = new Rectangle(0,0,1536,2048);
		
		public var autoLayoutOnStageResize:Boolean = false;
		 
		public function AdvancedSprite() 
		{
			super();
			
			dragRect = coordinateSystemRect;
			
			instances.push(this);
			numInstances ++;
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage); 
			if(autoLayoutOnStageResize) Starling.current.stage.addEventListener(Event.RESIZE, onStageResize); 
		}
		protected static function onStageResize(e:Event):void 
		{
			var inst:AdvancedSprite;
			for (var i:int = numInstances-1; i >=0; i--)
			{
				inst = instances[i];
				inst.updateLayout(coordinateSystemRect); 
			}
		}
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			updateLayoutData();
		}
		protected function updateLayoutData():void
		{	
			if(autoSaveLayout && !scaleToCoordinateSystem) saveLayout(relativeRect,scaleChildren,useRelativePositions); 
			if(autoLayout) updateLayout(null);
		}
		/**
		 * stores objects relative positions which will be used on layoutUpdate in case if auytoLayout==true
		 */
		protected var objectsPositions:Dictionary = new Dictionary();
		protected function saveLayout(_relativeRect:Rectangle,_scale:Boolean=true,_relativePosition:Boolean=true):void
		{
			var _numChildren:int = numChildren;
			var child:DisplayObject;
			
			for (var i:int = _numChildren - 1; i >= 0; i--)
			{
				child = getChildAt(i);
				
				if(child is FlashSprite_Mirror && (child as FlashSprite_Mirror).scaleToCoordinateSystem) continue;
				
				saveObjectPosition(child,_relativeRect,_scale,_relativePosition);
				
				if(child is AdvancedSprite) (child as AdvancedSprite).saveLayout(_relativeRect);
			}
		}
		protected function saveObjectPosition(child:DisplayObject,_relativeRect:Rectangle,_scale:Boolean=false,isRelative:Boolean=true):void
		{
			childRect = child.getBounds(this,childRect);
			
			var position:DisplayObjectPosition = objectsPositions[child];
			if (!position)
			{
				position = new DisplayObjectPosition();
				objectsPositions[child] = position;
			}	
			//trace("AdvancedSprite.saveObjectPosition(child, coordinateSystemRect, _scale)",child.name,childRect,_relativeRect);
			
			if(isRelative)
			{
				position.update(_relativeRect, childRect, _scale, childRect.x / _relativeRect.width, (_relativeRect.width - (childRect.x + childRect.width)) / _relativeRect.width,
									childRect.y/_relativeRect.height, (_relativeRect.height - (childRect.y+childRect.height))/_relativeRect.height);
			}
			else
			{
				position.update(_relativeRect, childRect, _scale, childRect.x, _relativeRect.width - (childRect.x + childRect.width),
								childRect.y, _relativeRect.height - (childRect.y+childRect.height));	
			}
			position.isRelative = isRelative;
		}
		protected function updateLayout(_coordinateSystemRect:Rectangle = null):void   
		{
			if(!_coordinateSystemRect) _coordinateSystemRect = coordinateSystemRect;
			
			if(scaleToCoordinateSystem) RectangleUtil.scaleToContent(this,_coordinateSystemRect,centrateToCoordinateSystem);
			else
			{
				var _numChildren:int = numChildren;
				var child:DisplayObject;
				
				//trace("AdvancedSprite.updateLayout(_layoutCoordinateSystem, _scaleChildren)",coordinateSystemRect);
				
				for (var i:int = _numChildren - 1; i >= 0; i--)
				{
					child = getChildAt(i);

					if(child is FlashSprite_Mirror && (child as FlashSprite_Mirror).scaleToCoordinateSystem) 
						RectangleUtil.scaleToContent(child,_coordinateSystemRect,(child as FlashSprite_Mirror).centrateToCoordinateSystem);
					else
					{
						if (child is AdvancedSprite) (child as AdvancedSprite).updateLayout();
					
						var p:DisplayObjectPosition = objectsPositions[child];
						if (p) updateObjectPosition(child, _coordinateSystemRect, p.relativeRect, p.originalRect,p.isRelative, p.scale, p.left, p.right, p.top, p.bottom, p.horizontalCententer, p.verticalCenter);
						
						if(child is FlashSprite_Mirror && (child as FlashSprite_Mirror).centrateToCoordinateSystem) DisplayUtils.centrateToContent(child,_coordinateSystemRect);
					}
				}
			}
			updateDragValues();
		}
		private var childRect:Rectangle;
		protected function updateObjectPosition(child:DisplayObject, _coordinateSystemRect:Rectangle, _relativeRect:Rectangle, _originalRect:Rectangle, isRelative:Boolean=true, _scale:Boolean = false, 
											l:Number=0.00001, r:Number=0.00001, t:Number=0.00001, b:Number=0.00001, hc:Number=0.00001, vc:Number=0.00001):void
		{
			var position:DisplayObjectPosition = objectsPositions[child];
			if (!position)
			{
				position = new DisplayObjectPosition();
				objectsPositions[child] = position;
			}	
			position.update(_relativeRect,_originalRect, _scale, l, r, t, b, hc, vc);
			
			childRect = child.getBounds(child.parent,childRect);
			var childOffsetX:Number = childRect.x - child.x;
			var childOffsetY:Number = childRect.y - child.y;
			
			//trace("updateObjectPosition",l,r,t,b);
			// transforming values to relative for one way position and scale calculation, for easier maintaining
			l = isRelative ? l : l/_coordinateSystemRect.width;
			r = isRelative ? r : r/_coordinateSystemRect.width;
			t = isRelative ? t : t/_coordinateSystemRect.height;
			b = isRelative ? b : b/_coordinateSystemRect.height;
			 
			// verifying if fixed -> relative transformations ar unproper and transfering them to proper relative
			if(l+r>1) 
			{
				l = childRect.x / _relativeRect.width;
				r = (_relativeRect.width - (childRect.x + childRect.width)) / _relativeRect.width;
			}
			if(t+b>1)
			{
				t = childRect.y / _relativeRect.height;
				b = (_relativeRect.height - (childRect.y+childRect.height))/_relativeRect.height;
			} 
			
			//trace("updateObjectPosition",l,r,t,b, "\n"); 
			
			child.x = (!_scale && l!=DisplayObjectPosition.IGNORE_VALUE && r!=DisplayObjectPosition.IGNORE_VALUE) ? 
						(l<0.5 ? _coordinateSystemRect.width*l : (_coordinateSystemRect.width - (_coordinateSystemRect.width * r)) - childRect.width) : 
						(l!=DisplayObjectPosition.IGNORE_VALUE ? _coordinateSystemRect.width*l : (_coordinateSystemRect.width - (_coordinateSystemRect.width * r)) - childRect.width);
			
			child.y = (!_scale && t!=DisplayObjectPosition.IGNORE_VALUE && b!=DisplayObjectPosition.IGNORE_VALUE) ? 
						(t<0.5 ? _coordinateSystemRect.height*t : (_coordinateSystemRect.height - (_coordinateSystemRect.height * b)) - childRect.height) : 
						(t!=DisplayObjectPosition.IGNORE_VALUE ? _coordinateSystemRect.height*t : (_coordinateSystemRect.height - (_coordinateSystemRect.height * b)) - childRect.height);
			
			if (_scale) 
			{  
				var w:Number;
				var h:Number;
				// order of size update is important because is considered proportion between w/h of the coordinate system
				if(_coordinateSystemRect.width<_coordinateSystemRect.height)
				{
					w = (_coordinateSystemRect.width - (_coordinateSystemRect.width * r)) - child.x;
					h = w/(_originalRect.width/_originalRect.height);
				}
				else
				{
					h = (_coordinateSystemRect.height - (_coordinateSystemRect.height * b)) - child.y; 
					w = h/(_originalRect.height/_originalRect.width);
				}
				
				childOffsetX *= w/childRect.width;
				childOffsetY *= h/childRect.height;
				
				child.scaleX = w/(childRect.width/child.scaleX);
				child.scaleY = h/(childRect.height/child.scaleY);
				
				// updatind position choosing most logic value between sides alignment
				child.x = (l!=DisplayObjectPosition.IGNORE_VALUE && r!=DisplayObjectPosition.IGNORE_VALUE) ? 
					(l<0.5 ? _coordinateSystemRect.width*l : (_coordinateSystemRect.width - (_coordinateSystemRect.width * r)) - w) : 
					(l!=DisplayObjectPosition.IGNORE_VALUE ? _coordinateSystemRect.width*l : (_coordinateSystemRect.width - (_coordinateSystemRect.width * r)) - w);
				
				child.y = (t!=DisplayObjectPosition.IGNORE_VALUE && b!=DisplayObjectPosition.IGNORE_VALUE) ? 
					(t<0.5 ? _coordinateSystemRect.height*t : (_coordinateSystemRect.height - (_coordinateSystemRect.height * b)) - h) : 
					(t!=DisplayObjectPosition.IGNORE_VALUE ? _coordinateSystemRect.height*t : (_coordinateSystemRect.height - (_coordinateSystemRect.height * b)) - h);
				
			}
			
			// considering child pivotX,pivotY
			child.x -= childOffsetX;
			child.y -= childOffsetY;
		}
		public static function forEachChild(sprite:Sprite, func:Function, ...parameters):void
		{
			var _numChildren:int = sprite.numChildren;
			var child:DisplayObject;
			
			var _parameters:Array = parameters.concat();
			_parameters.unshift(null);
			
			for (var i:int = _numChildren - 1; i >= 0; i--)
			{
				child = sprite.getChildAt(i);
				_parameters[0] = child;
				
				func.apply(child, _parameters);
			}
		}
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			if(!_enabled) return;
			super.render(support,parentAlpha);
		}
		protected var _enabled:Boolean = true;
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}

import flash.geom.Rectangle;

class DisplayObjectPosition
{
	public var left:Number;
	public var right:Number;
	public var top:Number;
	public var bottom:Number;
	
	public var percentWidth:Number;
	public var percentHeight:Number;
	
	public var horizontalCententer:Number;
	public var verticalCenter:Number;
	
	public var scale:Boolean = false;
	
	public var originalRect:Rectangle;
	public var relativeRect:Rectangle;
	
	public var isRelative:Boolean = true;
	
	public static const IGNORE_VALUE:Number = 0.00001;
	
	public function DisplayObjectPosition()
	{
		
	}
	public function update(_relativeRect:Rectangle,_originalRect:Rectangle,_scale:Boolean=false,l:Number=0.00001, r:Number=0.00001, t:Number=0.00001, b:Number=0.00001, hc:Number=0.00001, vc:Number=0.00001):void
	{
		relativeRect = _relativeRect;
		originalRect = _originalRect;
		scale = _scale;
		left = l; 
		right = r;
		top = t;
		bottom = b;
		
		horizontalCententer = hc;
		verticalCenter = vc;
		
		//trace("DisplayObjectPosition.update(_scale, l, r, t, b, hc, vc)",this);
		
	}
	public function toString():String
	{
		return "l-"+left+", "+"r-"+right+", "+"t-"+top+", "+"b-"+bottom+", "+"hc-"+horizontalCententer+", "+"vc-"+verticalCenter;
	}
}