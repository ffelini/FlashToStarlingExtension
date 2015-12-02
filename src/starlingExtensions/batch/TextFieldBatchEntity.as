package starlingExtensions.batch
{
import starling.display.DisplayObject;
import starling.text.TextField;

import starlingExtensions.uiComponents.SmartSprite;
import starlingExtensions.uiComponents.SmartTextField;

public class TextFieldBatchEntity extends SmartSprite
	{
		public function TextFieldBatchEntity()
		{
			super();
			resetLastValuesAfterRender = true;
		}
		protected var _batchable:Boolean = false;
		public function set batchableTextFields(value:Boolean):void
		{
			_batchable = value;
			if(_textFieldsBatch) _textFieldsBatch.updateRenderSpriteBatching(this,_batchable);
		}
		public function get batchableTextFields():Boolean
		{
			return _batchable;
		}
		protected var _textFieldsBatch:TextFieldBatch;
		public function set textFieldsBatch(value:TextFieldBatch):void
		{
			_textFieldsBatch = value;
		}
		public function get textFieldsBatch():TextFieldBatch
		{
			return _textFieldsBatch;
		}
		public var textFields:Vector.<SmartTextField> = new Vector.<SmartTextField>();
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is TextField)
			{
				if(_batchable && _textFieldsBatch) _textFieldsBatch.add(child as TextField,false); 
				textFields.push(child);
			}
			super.addChildAt(child, index);
			
			return child;
		}
	}
}