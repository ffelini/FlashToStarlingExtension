package starlingExtensions.batch
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.core.RenderSupport;
import starling.display.Sprite;
import starling.text.TextField;

import starlingExtensions.uiComponents.SmartTextField;

public class TextFieldBatch extends Sprite
	{
		public static var DEBUG:Boolean = false;
		
		public function TextFieldBatch()
		{
			super();
			
			touchable = false;
		}
		protected var fieldsBySource:Dictionary = new Dictionary()
		public function add(value:TextField,createClone:Boolean=true):BatchableTextField
		{
			if(!value) return null;
			
			var cloneField:BatchableTextField = fieldsBySource[value];
			if(cloneField) return cloneField;

			value.alpha = value.parent is TextFieldBatchEntity ? ((value.parent as TextFieldBatchEntity).batchableTextFields ? 0 : value.alpha) : 0; 
			
			if(!createClone) return cloneField;
			
			cloneField = new BatchableTextField(100,100,value.text,value.fontName,value.fontSize,value.color,value.bold);
			
			fieldsBySource[value] = cloneField;
			
			cloneField.alpha = 0;
			
			return cloneField;
		}
		public function remove(value:TextField):void
		{
			
		}
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			// removind hidden fields from batch. they will be ignored on next rendering
			for(var i:int=0;i<numHiddenFields;i++)
			{
				hiddenFields[i].removeFromParent();
			}
			hiddenFields.length = numHiddenFields = 0;
			
		}
		protected var hiddenFields:Vector.<BatchableTextField> = new Vector.<BatchableTextField>();
		protected var numHiddenFields:int;
		public function hideTextField(field:BatchableTextField):void
		{
			if(field && field.parent==this)
			{
				hiddenFields.push(field);
				numHiddenFields++;
			}
		}
		
		private var sourceIsRendering:Boolean = false;
		private var curentField:BatchableTextField;
		private var helpRect:Rectangle;
		[Inline]
		public function renderTextField(curentSource:SmartTextField):void
		{
			curentSource.alpha = 0;
			
			curentField = fieldsBySource[curentSource];
			
			if(!curentField) curentField = add(curentSource);
			
			if(!curentField) return;
			
			if(curentField.parent!=this) addChild(curentField);
			
			if(curentSource.globalBoundsChanged)
			{
				helpRect = curentSource.getBounds(this,helpRect);
				
				curentField.x = Math.round(helpRect.x);
				curentField.y = Math.round(helpRect.y);
				curentField.width = Math.round(helpRect.width);
				curentField.height = Math.round(helpRect.height);
				
				curentField.border = curentSource.border || DEBUG;
			}
			
			curentField.hAlign = curentSource.hAlign;
			curentField.vAlign = curentSource.vAlign;
			curentField.color = curentSource.color;
			curentField.fontName = curentSource.fontName;
			curentField.fontSize = curentSource.fontSize;
			curentField.bold = curentSource.bold;
			curentField.kerning = curentSource.kerning;
			curentField.underline = curentSource.underline;
			curentField.italic = curentSource.italic;
			
			curentField.autoSize = curentSource.autoSize;
			curentField.autoScale = curentSource.autoScale;
			
			curentField.text = curentSource.text;
			curentField.batchable = curentSource.batchable;
			
			curentField.alpha = 1;
		}
		private var curentSource:SmartTextField;
		public function renderSprite(sprite:TextFieldBatchEntity):void
		{
			if(!visible || !parent) return;
			
			var numSources:int = sprite.textFields.length;
			
			for(var i:int=0;i<numSources;i++)
			{
				curentSource = sprite.textFields[i];
				sourceIsRendering = curentSource.visible && curentSource.scaleX != 0.0 && curentSource.scaleY != 0.0;
				
				if(sourceIsRendering) renderTextField(curentSource);
			}
		}
		public function updateRenderSpriteBatching(sprite:TextFieldBatchEntity,batchable:Boolean):void
		{
			var numSources:int = sprite.textFields.length;
			for(var i:int=0;i<numSources;i++)
			{
				curentSource = sprite.textFields[i];
				curentField = fieldsBySource[curentSource];
				
				curentSource.alpha = batchable ? 0 : 1;
			}
		}
		public function get ignoreExporting():Boolean
		{
			return true;
		}
	}
}