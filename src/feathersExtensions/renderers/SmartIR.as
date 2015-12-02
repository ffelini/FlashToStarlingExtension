package feathersExtensions.renderers
{
import feathers.controls.List;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.core.ITextRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.controls.SmartList;
import feathersExtensions.controls.text.HTMLLabel;
import feathersExtensions.groups.SmartLayoutGroup;
import feathersExtensions.layout.SmartAnchorLayoutData;
import feathersExtensions.utils.LayoutUtils;

import mvc.model.ModelEntity;

import starling.display.DisplayObject;
import starling.events.TouchEvent;

public class SmartIR extends DefaultListItemRenderer
	{
		public function SmartIR()
		{
			super();
			
			isQuickHitAreaEnabled = delayTextureCreationOnScroll = true;
			accessoryGap = Number.POSITIVE_INFINITY;
			//useStateDelayTimer = false;
			labelFunction = defaultLabelFunc;
		}
		protected function defaultLabelFunc(item:Object):String
		{
			return item && item.hasOwnProperty(labelField) ? item[labelField] : item+"";
		}
		override protected function initialize():void
		{
			super.initialize();
			initLayout();
			initChildren();
		}
		protected function initLayout():void
		{
			padding = 10;
			horizontalAlign = HORIZONTAL_ALIGN_LEFT;
			verticalAlign = VERTICAL_ALIGN_MIDDLE;
		}
		protected function initChildren():void
		{
			
		}
		public function set isHTMLLabel(value:Boolean):void
		{
			labelFactory = value ? htmlLabelFactory : null;
		}
		protected var htmlLabelRenderer:HTMLLabel;
		protected function htmlLabelFactory():ITextRenderer
		{
			if(htmlLabelRenderer) return htmlLabelRenderer;
			htmlLabelRenderer = new HTMLLabel();
			return htmlLabelRenderer;
		}
		public function set isHtmlAccessoryLabel(value:Boolean):void
		{
			accessoryLabelFactory = value ? htmlLabelFactory : null;
		}
		override public function set data(value:Object):void
		{
			if(_data) addDataChangeHandler(_data,false);
			
			super.data = value;
			
			addDataChangeHandler(_data,true);
		}
		protected function addDataChangeHandler(obj:Object,add:Boolean):void
		{
			if(obj is ModelEntity)
			{
				if(add) (obj as ModelEntity).addOnChangeCallback(onDataChange);
				else (obj as ModelEntity).removeOnChangeCallback(onDataChange);
			}
		}
		protected function onDataChange(obj:Object,property:String):void
		{
			invalidate(INVALIDATION_FLAG_DATA);
		}
		override public function validate():void
		{
			super.validate();
			validateSize();
		}
		protected var _smarList:SmartList;
		override public function set owner(value:List):void
		{
			super.owner = value;
			if(_owner) setupLayout();
			_smarList = value as SmartList;
		}
		protected function setupLayout():void
		{
			
		}
		public function get smartLayoutData():SmartAnchorLayoutData
		{
			return layoutData as SmartAnchorLayoutData || (owner is SmartList ? (owner as SmartList).smartItemLayoutData : null);
		}
		public var selectionSizeFactor:Number = 1;
		override public function set isSelected(value:Boolean):void
		{
			super.isSelected = value;
		}
		override protected function button_touchHandler(e:TouchEvent):void
		{
			super.button_touchHandler(e);
		}
		override protected function accessory_touchHandler(event:TouchEvent):void
		{
			super.accessory_touchHandler(event);
			if(owner && owner is SmartList) (owner as SmartList).disableAppDrawers(accessoryTouchPointID>=0,true);
		}
		protected var autoSize:Boolean = true;
		protected function validateSize():void
		{
			if(autoSize && owner)
			{
				var w:Number;
				var h:Number;
				if(!smartLayoutData || (smartLayoutData.percentWidth<=0 && smartLayoutData.percentHeight<=0) || 
										(isNaN(smartLayoutData.percentWidth) && isNaN(smartLayoutData.percentHeight)))
				{
					if(SmartLayoutGroup.fitItemToLayout(this,owner.layout)) true;
					else 
					{
						w = owner.layout is HorizontalLayout ? width : owner.width; 
						h = owner.layout is VerticalLayout ? height : owner.height;
					}
				}
				else if(smartLayoutData)
				{
					if(smartLayoutData.percentWidth>0 && owner.width>0) w = LayoutUtils.validateSize(smartLayoutData.percentWidth/100 * owner.width,smartLayoutData.maxWidth,smartLayoutData.minWidth);					
					if(smartLayoutData.percentHeight>0 && owner.height>0) h = LayoutUtils.validateSize(smartLayoutData.percentHeight/100 * owner.height,smartLayoutData.maxHeight,smartLayoutData.minHeight);
				}
				
				w = isSelected && owner.layout is HorizontalLayout ? w*selectionSizeFactor : w;
				h = isSelected && owner.layout is VerticalLayout ? h*selectionSizeFactor : h;
				
				setSize(w,h);				
			}
		}
		public function forceCommitData():void
		{
			if(this._itemHasLabel)
			{
				this._label = this.itemToLabel(this._data);
				//we don't need to invalidate because the label setter
				//uses the same data invalidation flag that triggered this
				//call to commitData(), so we're already properly invalid.
			}
			if(this._itemHasIcon)
			{
				const newIcon:DisplayObject = this.itemToIcon(this._data);
				this.replaceIcon(newIcon);
			}
			if(this._itemHasAccessory)
			{
				const newAccessory:DisplayObject = this.itemToAccessory(this._data);
				this.replaceAccessory(newAccessory);
			}
		}
	}
}