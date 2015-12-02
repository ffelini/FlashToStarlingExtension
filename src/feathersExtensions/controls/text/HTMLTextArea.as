package feathersExtensions.controls.text
{
import feathers.controls.text.TextFieldTextEditor;

public class HTMLTextArea extends TextFieldTextEditor
	{
		public function HTMLTextArea()
		{
			super();
		}
		override protected function initialize():void
		{
			super.initialize();
			isHTML = embedFonts = wordWrap = true;
			//textField.autoSize = TextFieldAutoSize.LEFT;
		}
	}
}