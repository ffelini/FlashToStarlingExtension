package feathersExtensions.controls
{
import feathers.controls.Label;
import feathers.core.FeathersControl;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.utils.LayoutUtils;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import managers.Handlers;

import mvc.view.components.AbstractLayoutGroupSkinnable;

public class FormItem extends AbstractLayoutGroupSkinnable
	{
		public function FormItem(_initChildren:Boolean=false)
		{
			super(_initChildren);
		}
		public var contentFactory:Function;
		public var itemContent:FeathersControl;
		protected var labelField:Label;
		override protected function initChildren():void
		{
			super.initChildren();
			layout = LayoutUtils.getHLayout(hLayout);
			
			labelField = new Label();
			labelField.textRendererProperties.textFormat = new TextFormat(null,15,0xFFFFFF,true,null,null,null,null,TextFormatAlign.LEFT);
			label = _label;
			
			itemContent = Handlers.functionCall(contentFactory);
			
			addChild(labelField);
			if(itemContent) addChild(itemContent);
		}
		override public function set layout(value:ILayout):void
		{
			super.layout = value;
		}
		protected var _label:String;
		public function set label(value:String):void
		{
			_label = value;
			if(labelField) 
			{
				labelField.text = value;
				validateSize();
			}
		}
		public function get label():String
		{
			return labelField ? labelField.text : _label;
		}
		override protected function validateSize():void
		{
			super.validateSize();
			
			if(itemContent) 
			{
				if(layout is HorizontalLayout) itemContent.setSize(width - labelField.width - (layout as HorizontalLayout).gap,height);
				else if(layout is VerticalLayout) itemContent.setSize(width,height - labelField.height - (layout as VerticalLayout).gap); 
			}
		}
	}
}