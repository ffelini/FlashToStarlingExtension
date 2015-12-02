package starlingExtensions.uiComponents
{

import feathers.controls.text.BitmapFontTextRenderer;
import feathers.controls.text.StageTextTextEditor;
import feathers.core.ITextEditor;
import feathers.text.BitmapFontTextFormat;

import feathersExtensions.controls.inputs.SmartTextInput;

import managers.Handlers;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;

import starlingExtensions.batch.TextFieldBatch;
import starlingExtensions.batch.TextFieldBatchEntity;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.utils.DisplayUtils;

import utils.ObjUtil;

public class SmartTextField extends TextField implements IClonable
	{
		public static var DEBUG:Boolean = true;
		
		public function SmartTextField(width:int, height:int, text:String, fontName:String="Verdana", fontSize:Number=12, color:uint=0x0, bold:Boolean=false)
		{
			lastX = lastY = lastPivotX = lastPivotY = lastRotation = lastSkewX =lastSkewY = 0.0;
			lastScaleX = lastScaleY = 1.0;
			
			_width = width;
			_height = height;
			
			super(width, height, text, fontName, fontSize, color, bold);
			batchable = mText.length<15;
		}
		public var dispatchEvents:Boolean = false;
		override public function dispatchEvent(event:Event):void
		{
			if(!dispatchEvents) return;
			super.dispatchEvent(event);
		}
		override public function dispatchEventWith(type:String, bubbles:Boolean=false, data:Object=null):void
		{
			if(!dispatchEvents) return;
			super.dispatchEventWith(type, bubbles, data);
		}
		override public function redraw():void
		{
			if(super.hasVisibleArea) super.redraw();
		}
		protected var _isInput:Boolean = false;
		public var input:SmartTextInput;
		public var promptTextFormat:BitmapFontTextFormat;
		public function set isInput(value:Boolean):void
		{
			if(_isInput==value) return;
			
			_isInput = value;
			if(_isInput)
			{
				if(!input) input = new SmartTextInput();
				input.isEditable = true;
				input.text = text;
				
				DisplayUtils.setBounds(input,bounds);
				parent.addChildAt(input,parent.getChildIndex(this));
				
				input.addEventListener(Event.CHANGE,onInputChage);
				addEventListener(TouchEvent.TOUCH,onFocusTouch);
				
				input.textEditorFactory = function():ITextEditor { return new StageTextTextEditor() }
				//input.textEditorProperties.textFormat = new TextFormat(fontName,fontSize,color,bold,italic,underline,null,null,hAlign);
				//input.textEditorProperties.embedFonts = true;
				
				input.textEditorProperties.fontFamily = fontName;
				input.textEditorProperties.fontSize = fontSize;
				input.textEditorProperties.color = color;
				input.textEditorProperties.textAlign = hAlign;
				//input.textEditorProperties.isEmbedded = true;
				//input.textEditorProperties.bold = bold;
				//input.textEditorProperties.italic = italic;
				//input.textEditorProperties.underline = underline;
				
				input.promptFactory = function():BitmapFontTextRenderer { return new BitmapFontTextRenderer(); }
				
				if(!promptTextFormat) promptTextFormat = new BitmapFontTextFormat(fontName,fontSize,0x666666,hAlign);
				input.promptProperties.textFormat = promptTextFormat;
			}
			else if(input)
			{
				input.removeFromParent();
				input.removeEventListener(Event.CHANGE,onInputChage);
				removeEventListener(TouchEvent.TOUCH,onFocusTouch);
			}
			visible = _isInput ? 0 : 1;
		}
		public function get isInput():Boolean
		{
			return _isInput;
		}
		public function setFocus():void
		{
			if(input && _isInput) input.setFocus();
		}
		public function hideFocus():void
		{
			if(input && _isInput) input.hideFocus();
		}
		public var inputChangeHandler:Function;
		private function onInputChage():void
		{
			text = input.text;
			Handlers.functionCall(inputChangeHandler,this);
		}
		private function onFocusTouch():void
		{
			input.setFocus();
		}
		public var mirror:TextField;
		public var mirrorPropertiesToClone:Array = ["text"];
		protected var batchEntity:TextFieldBatchEntity;
		protected var batch:TextFieldBatch;
		override public function get hasVisibleArea():Boolean
		{
			if(mirror) ObjUtil.cloneFields(mirror,this,"text");
			if(mVisible && mScaleX != 0.0 && mScaleY != 0.0)
			{
				batchEntity = mParent as TextFieldBatchEntity;
				batch = batchEntity && batchEntity.batchableTextFields ? batchEntity.textFieldsBatch : null;
					
				if(batch) batch.renderTextField(this);
			}
			return super.hasVisibleArea;
		}
		override public function set text(value:String):void
		{
			if(value==mText) return;
			super.text = value;
			batchable = mText.length<15;
			
			if(_isInput && input) input.text = text;
		}
		override public function set batchable(value:Boolean):void
		{
			if(value==mBatchable) return;
			super.batchable = value;
		}
		protected var _height:Number;
		protected var lastHeight:Number;
		override public function set height(value:Number):void
		{
			if(value==mHitArea.height) return;
			
			lastHeight = _height;
			_height = value;
			super.height = value;
			
			if(lastHeight!=value) _boundsChanged = true;
		}
		protected var _width:Number;
		protected var lastWidth:Number;
		override public function set width(value:Number):void
		{
			if(value==mHitArea.width) return;
			lastWidth = _width;
			_width = value;
			super.width = value;
			
			if(lastWidth!=value) _boundsChanged = true;
		}
		override public function get height():Number
		{
			return _height*scaleY;
		}
		override public function get width():Number
		{
			return _width*scaleX;
		}
		protected var lastPivotX:Number;
		override public function set pivotX(value:Number):void
		{
			super.pivotX = value;
			lastPivotX = value;
			
			if(lastPivotX!=value) _boundsChanged = true;
		}
		protected var lastPivotY:Number;
		override public function set pivotY(value:Number):void
		{
			super.pivotY = value;
			lastPivotY = value;
			
			if(lastPivotY!=value) _boundsChanged = true;
		}
		protected var lastRotation:Number;
		override public function set rotation(value:Number):void
		{
			lastRotation = rotation;
			super.rotation = value;
			
			if(lastRotation!=value) _boundsChanged = true;
		}
		protected var lastScaleX:Number;
		override public function set scaleX(value:Number):void
		{
			lastScaleX = scaleX;
			super.scaleX = value;
			
			if(lastScaleX!=value) _boundsChanged = true;
		}
		protected var lastScaleY:Number;
		override public function set scaleY(value:Number):void
		{
			lastScaleY = scaleY;
			super.scaleY = value;
			
			if(lastScaleY!=value) _boundsChanged = true;
		}
		protected var lastSkewX:Number;
		override public function set skewX(value:Number):void
		{
			lastSkewX = skewX;
			super.skewX = value;
			
			if(lastSkewX!=value) _boundsChanged = true;
		}
		protected var lastSkewY:Number;
		override public function set skewY(value:Number):void
		{
			lastSkewY = skewY;
			super.skewY = value;
			
			if(lastSkewY!=value) _boundsChanged = true;
		}
		protected var lastX:Number;
		override public function set x(value:Number):void
		{
			lastX = x;
			super.x = value;
			
			if(lastX!=value) _boundsChanged = true;
		}
		protected var lastY:Number;
		override public function set y(value:Number):void
		{
			lastY = y;
			super.y = value;
			
			if(lastY!=value) _boundsChanged = true;
		}
		public function get globalBoundsChanged():Boolean
		{
			if(_boundsChanged) 
			{
				resetBoundsChanging();
				return true;
			}
			
			var _parent:DisplayObjectContainer = parent;
			
			while(_parent)
			{
				if(_parent is SmartSprite && (_parent as SmartSprite).boundsChanged) 
					return true;
				
				_parent = _parent.parent;
				
				if(!_parent || _parent==stage) break;
			}
			
			return false;
		}
		protected var _boundsChanged:Boolean = false;
		public function get boundsChanged():Boolean
		{
			return _boundsChanged;
		}
		public function resetBoundsChanging():void
		{
			_boundsChanged = false;
		}
		public function get requireRedraw():Boolean
		{
			return mRequiresRedraw;
		}
		public function clone():DisplayObject
		{
			var c:SmartTextField = new SmartTextField(width,height,text,fontName,fontSize,color,bold);
			
			c.autoScale = autoScale;
			c.hAlign = hAlign;
			c.vAlign = vAlign;
			c.touchable = touchable;
			return c;
		}
		
	}
}