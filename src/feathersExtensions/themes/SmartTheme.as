/*
 Copyright (c) 2012 Josh Tynjala

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
package feathersExtensions.themes
{
import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.List;
import feathers.controls.NumericStepper;
import feathers.controls.PageIndicator;
import feathers.controls.Panel;
import feathers.controls.PanelScreen;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.Screen;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollText;
import feathers.controls.Scroller;
import feathers.controls.SimpleScrollBar;
import feathers.controls.Slider;
import feathers.controls.TabBar;
import feathers.controls.TextInput;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleSwitch;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.popups.VerticalCenteredPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.StageTextTextEditor;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.PopUpManager;
import feathers.display.Scale3Image;
import feathers.display.Scale9Image;
import feathers.display.TiledImage;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;
import feathers.skins.SmartDisplayObjectStateValueSelector;
import feathers.skins.StandardIcons;
import feathers.system.DeviceCapabilities;
import feathers.textures.Scale3Textures;
import feathers.textures.Scale9Textures;

import feathersExtensions.layout.SmartAnchorLayout;
import feathersExtensions.layout.SmartAnchorLayoutData;
import feathersExtensions.skins.TiledImageStateValueSelector;
import feathersExtensions.utils.LayoutUtils;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Proxy;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

import starlingExtensions.textureutils.Textures;

import utils.log;

public class SmartTheme extends FeathersTheme_Dynamic
	{
		[Embed(source="/tools/assets/images/metalworks.xml",mimeType="application/octet-stream")]
		protected static const ATLAS_XML:Class;

		protected static const PRIMARY_BACKGROUND_COLOR:uint = 0x4a4137;
		protected static const LIGHT_TEXT_COLOR:uint = 0xe5e5e5;
		protected static const DARK_TEXT_COLOR:uint = 0x1a1816;
		protected static const SELECTED_TEXT_COLOR:uint = 0xff9900;
		protected static const DISABLED_TEXT_COLOR:uint = 0x8a8a8a;
		protected static const DARK_DISABLED_TEXT_COLOR:uint = 0x383430;
		protected static const LIST_BACKGROUND_COLOR:uint = 0x383430;
		protected static const TAB_BACKGROUND_COLOR:uint = 0x1a1816;
		protected static const TAB_DISABLED_BACKGROUND_COLOR:uint = 0x292624;
		protected static const MODAL_OVERLAY_COLOR:uint = 0x1a1816;
		protected static const GROUPED_LIST_HEADER_BACKGROUND_COLOR:uint = 0x2e2a26;
		protected static const GROUPED_LIST_FOOTER_BACKGROUND_COLOR:uint = 0x2e2a26;

		protected static const ORIGINAL_DPI_IPHONE_RETINA:int = 326;
		protected static const ORIGINAL_DPI_IPAD_RETINA:int = 264;

		protected static const DEFAULT_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 22, 22);
		protected static var BUTTON_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 50, 50);
		protected static const BUTTON_SELECTED_SCALE9_GRID:Rectangle = new Rectangle(8, 8, 44, 44);
		protected static const BACK_BUTTON_SCALE3_REGION1:Number = 24;
		protected static const BACK_BUTTON_SCALE3_REGION2:Number = 6;
		protected static const FORWARD_BUTTON_SCALE3_REGION1:Number = 6;
		protected static const FORWARD_BUTTON_SCALE3_REGION2:Number = 6;
		protected static const ITEM_RENDERER_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 2, 82);
		protected static const INSET_ITEM_RENDERER_FIRST_SCALE9_GRID:Rectangle = new Rectangle(13, 13, 3, 70);
		protected static const INSET_ITEM_RENDERER_LAST_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 3, 75);
		protected static const INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID:Rectangle = new Rectangle(13, 13, 3, 62);
		protected static const TAB_SCALE9_GRID:Rectangle = new Rectangle(19, 19, 50, 50);
		protected static const SCROLL_BAR_THUMB_REGION1:int = 5;
		protected static const SCROLL_BAR_THUMB_REGION2:int = 14;

		public static const COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER:String = "metal-works-mobile-picker-list-item-renderer";
		public static const COMPONENT_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "metal-works-mobile-alert-button-group-button";

		protected static function textRendererFactory():TextFieldTextRenderer
		{
			return new TextFieldTextRenderer();
		}

		protected static function textEditorFactory():StageTextTextEditor
		{
			return new StageTextTextEditor();
		}

		protected static function stepperTextEditorFactory():TextFieldTextEditor
		{
			return new TextFieldTextEditor();
		}

		protected static function popUpOverlayFactory():DisplayObject
		{
			const quad:Quad = new Quad(100, 100, MODAL_OVERLAY_COLOR);
			quad.alpha = 0.75;
			return quad;
		}

		public function SmartTheme(container:DisplayObjectContainer = null, scaleToDPI:Boolean = true)
		{
			if(!container)
			{
				container = Starling.current.stage;
			}
			super(container)
			_scaleToDPI = scaleToDPI;
			initialize();
		}

		protected var _originalDPI:int;

		public function get originalDPI():int
		{
			return _originalDPI;
		}

		protected var _scaleToDPI:Boolean;

		public function get scaleToDPI():Boolean
		{
			return _scaleToDPI;
		}
		
		public static const DARK_GREEN:uint = 0x187106;
		public static const DARK_BROWN:uint = 0x714D06;
		public static const GREEN_BLUE:uint = 0x209DB1;
		public static const YELLOW:uint = 0xFFE066;
		public static const YELLOW_FONT:uint = 0xECC420;
		public static const WHITE:uint = 0xFFFFFF;
		public static const DARK_GRAY:uint = 0x72757A;
		public static const DARKNESS_GRAY:uint = 0x333333;
		public static const WHITE_GRAY:uint = 0xEBEBEB;
		public static const LIGHT_GRAY:uint = 0xE1E1E1;
		public static const MIDDLE_GRAY:uint = 0x999999;
		public static const GRAY:uint = 0xCCCCCC;
		public static const LIGHT_YELLOW:uint = 0xF8FFA2;
		public static const WHITE_YELLOW:uint = 0xFFFEA9;
		public static const BLACK:uint = 0;
		public static const DARK_BLUE:uint = 0x008A94;
		
		public static var headerTextFormat:TextFormat;

		public static var smallUIDarkTextFormat:TextFormat;
		public static var smallUILightTextFormat:TextFormat;
		public static var smallUISelectedTextFormat:TextFormat;
		public static var smallUILightDisabledTextFormat:TextFormat;
		public static var smallUIDarkDisabledTextFormat:TextFormat;

		public static var largeUIDarkTextFormat:TextFormat;
		public static var largeUILightTextFormat:TextFormat;
		public static var largeUISelectedTextFormat:TextFormat;
		public static var largeUIDisabledTextFormat:TextFormat;

		public static var largeDarkTextFormat:TextFormat;
		public static var largeLightTextFormat:TextFormat;
		public static var largeDisabledTextFormat:TextFormat;

		public static var smallDarkTextFormat:TextFormat;
		public static var smallLightTextFormat:TextFormat;
		public static var smallDisabledTextFormat:TextFormat;
		public static var smallLightTextFormatCentered:TextFormat;

		protected var atlas:TextureAtlas;
		protected var atlasBitmapData:BitmapData;
		protected var headerBackgroundSkinTexture:Texture;
		protected var backgroundSkinTextures:Scale9Textures;
		protected var backgroundInsetSkinTextures:Scale9Textures;
		protected var backgroundDisabledSkinTextures:Scale9Textures;
		protected var backgroundFocusedSkinTextures:Scale9Textures;
		protected var buttonUpSkinTextures:Scale9Textures;
		protected var buttonDownSkinTextures:Scale9Textures;
		protected var buttonDisabledSkinTextures:Scale9Textures;
		protected var buttonSelectedUpSkinTextures:Scale9Textures;
		protected var buttonSelectedDisabledSkinTextures:Scale9Textures;
		protected var buttonCallToActionUpSkinTextures:Scale9Textures;
		protected var buttonCallToActionDownSkinTextures:Scale9Textures;
		protected var buttonQuietUpSkinTextures:Scale9Textures;
		protected var buttonQuietDownSkinTextures:Scale9Textures;
		protected var buttonDangerUpSkinTextures:Scale9Textures;
		protected var buttonDangerDownSkinTextures:Scale9Textures;
		protected var buttonBackUpSkinTextures:Scale3Textures;
		protected var buttonBackDownSkinTextures:Scale3Textures;
		protected var buttonBackDisabledSkinTextures:Scale3Textures;
		protected var buttonForwardUpSkinTextures:Scale3Textures;
		protected var buttonForwardDownSkinTextures:Scale3Textures;
		protected var buttonForwardDisabledSkinTextures:Scale3Textures;
		protected var pickerListButtonIconTexture:Texture;
		protected var tabDownSkinTextures:Scale9Textures;
		protected var tabSelectedSkinTextures:Scale9Textures;
		protected var tabSelectedDisabledSkinTextures:Scale9Textures;
		protected var pickerListItemSelectedIconTexture:Texture;
		protected var radioUpIconTexture:Texture;
		protected var radioDownIconTexture:Texture;
		protected var radioDisabledIconTexture:Texture;
		protected var radioSelectedUpIconTexture:Texture;
		protected var radioSelectedDownIconTexture:Texture;
		protected var radioSelectedDisabledIconTexture:Texture;
		protected var checkUpIconTexture:Texture;
		protected var checkDownIconTexture:Texture;
		protected var checkDisabledIconTexture:Texture;
		protected var checkSelectedUpIconTexture:Texture;
		protected var checkSelectedDownIconTexture:Texture;
		protected var checkSelectedDisabledIconTexture:Texture;
		protected var pageIndicatorNormalSkinTexture:Texture;
		protected var pageIndicatorSelectedSkinTexture:Texture;
		protected var itemRendererUpSkinTextures:Scale9Textures;
		protected var itemRendererSelectedSkinTextures:Scale9Textures;
		protected var insetItemRendererFirstUpSkinTextures:Scale9Textures;
		protected var insetItemRendererFirstSelectedSkinTextures:Scale9Textures;
		protected var insetItemRendererLastUpSkinTextures:Scale9Textures;
		protected var insetItemRendererLastSelectedSkinTextures:Scale9Textures;
		protected var insetItemRendererSingleUpSkinTextures:Scale9Textures;
		protected var insetItemRendererSingleSelectedSkinTextures:Scale9Textures;
		protected var backgroundPopUpSkinTextures:Scale9Textures;
		protected var calloutTopArrowSkinTexture:Texture;
		protected var calloutRightArrowSkinTexture:Texture;
		protected var calloutBottomArrowSkinTexture:Texture;
		protected var calloutLeftArrowSkinTexture:Texture;
		protected var verticalScrollBarThumbSkinTextures:Scale3Textures;
		protected var horizontalScrollBarThumbSkinTextures:Scale3Textures;
		protected var searchIconTexture:Texture;

		override public function dispose():void
		{
			if(root)
			{
				root.removeEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
			}
			if(atlas)
			{
				atlas.dispose();
				atlas = null;
			}
			if(atlasBitmapData)
			{
				atlasBitmapData.dispose();
				atlasBitmapData = null;
			}
			super.dispose();
		}

		protected function initializeRoot():void
		{
			if(root != root.stage)
			{
				return;
			}

			root.stage.color = PRIMARY_BACKGROUND_COLOR;
			Starling.current.nativeStage.color = PRIMARY_BACKGROUND_COLOR;
		}
		protected function initializeAtlas():void
		{
		}
		protected function properFontSize(fontSize:Number):Number
		{
			return Math.round(fontSize*scaleFont);
		}
		public static function setFlatBackgroundInitializer(group:FeathersControl,color:uint):void
		{
			if(hasBackgroundToSet(group)) setBackgroundSkin(group,new Quad(88*scaleDPI, 88*scaleDPI, color));
		}
		public static function setTiledBackgroundSkin(value:FeathersControl,backgroundFlashClass:Class,texturePadding:Number=95):void
		{
			if(hasBackgroundToSet(value)) setBackgroundSkin(value,new TiledImage(Textures.fromDOClass(backgroundFlashClass,true,true,texturePadding),scaleDPI>1 ? scaleDPI : 1));
		}
		public static function setBackgroundSkin(value:FeathersControl,background:DisplayObject):void
		{
			if(hasBackgroundToSet(value)) value["backgroundSkin"] = background;
		}
		public static function hasBackgroundToSet(value:FeathersControl):Boolean
		{
			return value && value.hasOwnProperty("backgroundSkin")
		}
		public static function setTiledStateValueSelector(renderer:Button,defaultFlashTextureClass:Class,selectedFlashClass:Class):void
		{
			const skinSelector:TiledImageStateValueSelector  = new TiledImageStateValueSelector();
			skinSelector.defaultValue = Textures.fromDOClass(defaultFlashTextureClass,true,true,95);
			skinSelector.defaultSelectedValue = Textures.fromDOClass(selectedFlashClass,true,true,95);
			skinSelector.setValueForState(skinSelector.defaultSelectedValue, Button.STATE_DOWN, false);
			
			skinSelector.imageProperties =
			{
			width: 88 * scaleDPI,
			height: 88 * scaleDPI,
			textureScale: scaleDPI>1 ? scaleDPI : 1
			};
			
			renderer.stateToSkinFunction = skinSelector.updateValue;
		}
		public static function setTF(textControl:Object,tf:TextFormat):void
		{
			if(textControl.hasOwnProperty("textRendererProperties") && textControl["textRendererProperties"] is Proxy) 
			{
				textControl["textRendererProperties"]["textFormat"] = tf;
				textControl["textRendererProperties"]["embedFonts"] = true;
			}
			else if(textControl is Proxy)
			{
				textControl["textFormat"] = tf;
				textControl["embedFonts"] = true;
			}
		}
		public static function validateControlSize(control:FeathersControl,width:Number,height:Number,templatePercentsWidth:Number,templatePercentsHeight:Number):void
		{
			var w:Number = width;
			var h:Number = height;
			
			var ow:Number = !isNaN(templatePercentsWidth) ? templateStageW * templatePercentsWidth/100 : w;
			var oh:Number = !isNaN(templatePercentsHeight) ? templateStageH * templatePercentsHeight/100 : h;
			
			var scaleFactor:Number = scaleTemplateDPI;
			
			if(!isNaN(templatePercentsWidth)) w = LayoutUtils.validateSize(w,scaleFactor>1 ? ow*scaleFactor : ow,scaleFactor>1 ? ow : ow*scaleFactor); 
			if(!isNaN(templatePercentsHeight)) h = LayoutUtils.validateSize(h,scaleFactor>1 ? oh*scaleFactor : oh,scaleFactor>1 ? oh : oh*scaleFactor); 
			
			control.setSize(w,h);
		}
		public static function validateSize(value:Number,max:Number=NaN,min:Number=NaN):Number
		{
			return LayoutUtils.validateSize(value*scaleTemplateDPI,max*scaleTemplateDPI,min*scaleTemplateDPI);
			//return LayoutUtils.validateSize(value,max,min);
		}
		public static function validateSmartLayoutData(smartItemLayoutData:SmartAnchorLayoutData):void
		{
			smartItemLayoutData.maxWidth *= scaleTemplateDPI;
			smartItemLayoutData.minWidth *= scaleTemplateDPI;
			smartItemLayoutData.maxHeight *= scaleTemplateDPI;
			smartItemLayoutData.minHeight *= scaleTemplateDPI;
		}
		public function itemRendererCommonInitializer(renderer:BaseDefaultItemRenderer,defaultValue:Object,downValue:Object,defaultTF:TextFormat,selectedTF:TextFormat):void
		{
			buttonCommonInitializer(renderer,defaultValue,downValue,defaultTF,selectedTF);
			
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * scaleDPI;
			renderer.paddingLeft = 32 * scaleDPI;
			renderer.paddingRight = 24 * scaleDPI;
			renderer.gap = 20 * scaleDPI;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * scaleDPI;
			
			renderer.accessoryLoaderFactory = imageLoaderFactory;
			renderer.iconLoaderFactory = imageLoaderFactory;
		}
		public function buttonCommonInitializer(button:Button,defaultValue:Object,downValue:Object,defaultTF:TextFormat,selectedTF:TextFormat):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			if(defaultValue) skinSelector.defaultValue = defaultValue;
			if(downValue)
			{
				skinSelector.defaultSelectedValue = downValue;
				skinSelector.setValueForState(downValue, Button.STATE_DOWN, false);
				skinSelector.setValueForState(downValue, Button.STATE_DISABLED, false);
				skinSelector.setValueForState(downValue, Button.STATE_DISABLED, true);
				skinSelector.displayObjectProperties =
				{
					width: 60 * scaleDPI,
					height: 60 * scaleDPI,
					textureScale: scaleDPI
				};
			}
			if(defaultValue || downValue) button.stateToSkinFunction = skinSelector.updateValue;
			
			if(defaultTF)
			{
				setTF(button.defaultLabelProperties,defaultTF);
			}
			if(selectedTF)
			{
				setTF(button.downLabelProperties,selectedTF);
				setTF(button.disabledLabelProperties,selectedTF);
			}
			
			button.paddingTop = button.paddingBottom = 8 * scaleDPI;
			button.paddingLeft = button.paddingRight = 16 * scaleDPI;
			button.gap = 12 * scaleDPI;
			button.minWidth = button.minHeight = 60 * scaleDPI;
			button.minTouchWidth = button.minTouchHeight = 88 * scaleDPI;
		}
		public static var scaleDPI:Number = 1;
		public static var scaleTemplateDPI:Number = 1;
		public static var scaleTemplateStage:Number = 1;
		public static var scaleFont:Number = 1;
		
		public static var isTablet:Boolean = false;

		public static var regularFontNames:String = "SourceSansPro";
		public static var semiboldFontNames:String = "SourceSansProSemibold";

		public static var templateDPI:Number = 252;
		public static var templateStageW:Number = 480;
		public static var templateStageH:Number = 762;
		protected function initialize():void
		{
			const _scaledDPI:int = DeviceCapabilities.dpi / Starling.contentScaleFactor;
			_originalDPI = _scaledDPI;
			isTablet = DeviceCapabilities.isTablet(Starling.current.nativeStage);
			
			if(_scaleToDPI)
			{
				if(isTablet)
				{
					_originalDPI = ORIGINAL_DPI_IPAD_RETINA;
				}
				else
				{
					_originalDPI = ORIGINAL_DPI_IPHONE_RETINA;
				}
			}

			scaleDPI = _scaledDPI / _originalDPI;

			var isBiggerScreen:Boolean = templateStageW<Starling.current.nativeStage.stageWidth;
			scaleTemplateDPI = DeviceCapabilities.dpi/templateDPI;
			scaleFont = scaleTemplateDPI;
			scaleTemplateStage = Starling.current.nativeStage.stageWidth/templateStageW;
			scaleFont = isBiggerScreen && isTablet && scaleTemplateDPI>1 ? scaleTemplateDPI*scaleDPI : scaleDPI; 
			scaleTemplateDPI = isBiggerScreen && isTablet && scaleTemplateDPI>1 ? scaleTemplateDPI*scaleDPI : scaleTemplateDPI;
			
			SmartAnchorLayout.templateStageW = templateStageW;
			SmartAnchorLayout.templateStageH = templateStageH;
			
			log(Capabilities,"Capabilities.screenDPI",Capabilities.screenDPI);
			log(Capabilities,"Capabilities.screenResolutionX",Capabilities.screenResolutionX);
			log(Capabilities,"Capabilities.screenResolutionY",Capabilities.screenResolutionY);
			log(this,"Starling.current.nativeStage.width",Starling.current.nativeStage.width);
			log(this,"Starling.current.nativeStage.height",Starling.current.nativeStage.height);
			log(this,"Starling.current.nativeStage.stageWidth",Starling.current.nativeStage.stageWidth);
			log(this,"Starling.current.nativeStage.stageHeight",Starling.current.nativeStage.stageHeight);
			log(this,"Starling.multitouchEnabled",Starling.multitouchEnabled);
			log(this,"Starling.current.antiAliasing",Starling.current.antiAliasing);
			log(this,"Starling.current.enableErrorChecking",Starling.current.enableErrorChecking);
			log(this,"Starling.supportHighResolutions",Starling.current.supportHighResolutions);
			log(this,"Starling.multitouchEnabled",Starling.multitouchEnabled);
			log(this,"Starling.contentScaleFactor",Starling.contentScaleFactor);
			log(this,"DeviceCapabilities.dpi",DeviceCapabilities.dpi);
			log(this,"DeviceCapabilities.screenPixelHeight",DeviceCapabilities.screenPixelHeight);
			log(this,"DeviceCapabilities.screenPixelWidth",DeviceCapabilities.screenPixelWidth);
			log(this,"_scaledDPI",_scaledDPI);
			log(this,"_originalDPI",_originalDPI);
			log(this,"scaleDPI",scaleDPI);
			log(this,"templateStageW",templateStageW);
			log(this,"templateStageH",templateStageH);
			log(this,"isBiggerScreen",isBiggerScreen);
			log(this,"templateDPI",templateDPI);
			log(this,"scaleTemplateStage",scaleTemplateStage);
			log(this,"scaleFont",scaleFont);
			log(this,"scaleTemplateDPI",scaleTemplateDPI);
			
			FeathersControl.defaultTextRendererFactory = textRendererFactory;
			FeathersControl.defaultTextEditorFactory = textEditorFactory;

			headerTextFormat = new TextFormat(semiboldFontNames, properFontSize(36), LIGHT_TEXT_COLOR, true);

			smallUIDarkTextFormat = new TextFormat(semiboldFontNames, properFontSize(24), DARK_TEXT_COLOR, true);
			smallUILightTextFormat = new TextFormat(semiboldFontNames, properFontSize(24), LIGHT_TEXT_COLOR, true);
			smallUISelectedTextFormat = new TextFormat(semiboldFontNames, properFontSize(24), SELECTED_TEXT_COLOR, true);
			smallUILightDisabledTextFormat = new TextFormat(semiboldFontNames, properFontSize(24), DISABLED_TEXT_COLOR, true);
			smallUIDarkDisabledTextFormat = new TextFormat(semiboldFontNames, properFontSize(24), DARK_DISABLED_TEXT_COLOR, true);

			largeUIDarkTextFormat = new TextFormat(semiboldFontNames, properFontSize(28), DARK_TEXT_COLOR, true);
			largeUILightTextFormat = new TextFormat(semiboldFontNames, properFontSize(28), LIGHT_TEXT_COLOR, true);
			largeUISelectedTextFormat = new TextFormat(semiboldFontNames, properFontSize(28), SELECTED_TEXT_COLOR, true);
			largeUIDisabledTextFormat = new TextFormat(semiboldFontNames, properFontSize(28), DISABLED_TEXT_COLOR, true);

			smallDarkTextFormat = new TextFormat(regularFontNames, properFontSize(24), DARK_TEXT_COLOR);
			smallLightTextFormat = new TextFormat(regularFontNames, properFontSize(24), LIGHT_TEXT_COLOR);
			smallDisabledTextFormat = new TextFormat(regularFontNames, properFontSize(24), DISABLED_TEXT_COLOR);
			smallLightTextFormatCentered = new TextFormat(regularFontNames, properFontSize(24), LIGHT_TEXT_COLOR, null, null, null, null, null, TextFormatAlign.CENTER);

			largeDarkTextFormat = new TextFormat(regularFontNames, properFontSize(28), DARK_TEXT_COLOR);
			largeLightTextFormat = new TextFormat(regularFontNames, properFontSize(28), LIGHT_TEXT_COLOR);
			largeDisabledTextFormat = new TextFormat(regularFontNames, properFontSize(28), DISABLED_TEXT_COLOR);

			PopUpManager.overlayFactory = popUpOverlayFactory;
			Callout.stagePaddingTop = Callout.stagePaddingRight = Callout.stagePaddingBottom =
				Callout.stagePaddingLeft = 16 * scaleDPI;

			initializeAtlas();

			const backgroundSkinTexture:Texture = atlas.getTexture("background-skin");
			const backgroundInsetSkinTexture:Texture = atlas.getTexture("background-inset-skin");
			const backgroundDownSkinTexture:Texture = atlas.getTexture("background-down-skin");
			const backgroundDisabledSkinTexture:Texture = atlas.getTexture("background-disabled-skin");
			const backgroundFocusedSkinTexture:Texture = atlas.getTexture("background-focused-skin");
			const backgroundPopUpSkinTexture:Texture = atlas.getTexture("background-popup-skin");

			backgroundSkinTextures = new Scale9Textures(backgroundSkinTexture, DEFAULT_SCALE9_GRID);
			backgroundInsetSkinTextures = new Scale9Textures(backgroundInsetSkinTexture, DEFAULT_SCALE9_GRID);
			backgroundDisabledSkinTextures = new Scale9Textures(backgroundDisabledSkinTexture, DEFAULT_SCALE9_GRID);
			backgroundFocusedSkinTextures = new Scale9Textures(backgroundFocusedSkinTexture, DEFAULT_SCALE9_GRID);
			backgroundPopUpSkinTextures = new Scale9Textures(backgroundPopUpSkinTexture, DEFAULT_SCALE9_GRID);

			buttonUpSkinTextures = new Scale9Textures(atlas.getTexture("button-up-skin"), BUTTON_SCALE9_GRID);
			buttonDownSkinTextures = new Scale9Textures(atlas.getTexture("button-down-skin"), BUTTON_SCALE9_GRID);
			buttonDisabledSkinTextures = new Scale9Textures(atlas.getTexture("button-disabled-skin"), BUTTON_SCALE9_GRID);
			buttonSelectedUpSkinTextures = new Scale9Textures(atlas.getTexture("button-selected-up-skin"), BUTTON_SELECTED_SCALE9_GRID);
			buttonSelectedDisabledSkinTextures = new Scale9Textures(atlas.getTexture("button-selected-disabled-skin"), BUTTON_SELECTED_SCALE9_GRID);
			buttonCallToActionUpSkinTextures = new Scale9Textures(atlas.getTexture("button-call-to-action-up-skin"), BUTTON_SCALE9_GRID);
			buttonCallToActionDownSkinTextures = new Scale9Textures(atlas.getTexture("button-call-to-action-down-skin"), BUTTON_SCALE9_GRID);
			buttonQuietUpSkinTextures = new Scale9Textures(atlas.getTexture("button-quiet-up-skin"), BUTTON_SCALE9_GRID);
			buttonQuietDownSkinTextures = new Scale9Textures(atlas.getTexture("button-quiet-down-skin"), BUTTON_SCALE9_GRID);
			buttonDangerUpSkinTextures = new Scale9Textures(atlas.getTexture("button-danger-up-skin"), BUTTON_SCALE9_GRID);
			buttonDangerDownSkinTextures = new Scale9Textures(atlas.getTexture("button-danger-down-skin"), BUTTON_SCALE9_GRID);
			buttonBackUpSkinTextures = new Scale3Textures(atlas.getTexture("button-back-up-skin"), BACK_BUTTON_SCALE3_REGION1, BACK_BUTTON_SCALE3_REGION2);
			buttonBackDownSkinTextures = new Scale3Textures(atlas.getTexture("button-back-down-skin"), BACK_BUTTON_SCALE3_REGION1, BACK_BUTTON_SCALE3_REGION2);
			buttonBackDisabledSkinTextures = new Scale3Textures(atlas.getTexture("button-back-disabled-skin"), BACK_BUTTON_SCALE3_REGION1, BACK_BUTTON_SCALE3_REGION2);
			buttonForwardUpSkinTextures = new Scale3Textures(atlas.getTexture("button-forward-up-skin"), FORWARD_BUTTON_SCALE3_REGION1, FORWARD_BUTTON_SCALE3_REGION2);
			buttonForwardDownSkinTextures = new Scale3Textures(atlas.getTexture("button-forward-down-skin"), FORWARD_BUTTON_SCALE3_REGION1, FORWARD_BUTTON_SCALE3_REGION2);
			buttonForwardDisabledSkinTextures = new Scale3Textures(atlas.getTexture("button-forward-disabled-skin"), FORWARD_BUTTON_SCALE3_REGION1, FORWARD_BUTTON_SCALE3_REGION2);

			tabDownSkinTextures = new Scale9Textures(atlas.getTexture("tab-down-skin"), TAB_SCALE9_GRID);
			tabSelectedSkinTextures = new Scale9Textures(atlas.getTexture("tab-selected-skin"), TAB_SCALE9_GRID);
			tabSelectedDisabledSkinTextures = new Scale9Textures(atlas.getTexture("tab-selected-disabled-skin"), TAB_SCALE9_GRID);

			pickerListButtonIconTexture = atlas.getTexture("picker-list-icon");
			pickerListItemSelectedIconTexture = atlas.getTexture("picker-list-item-selected-icon");

			radioUpIconTexture = backgroundSkinTexture;
			radioDownIconTexture = backgroundDownSkinTexture;
			radioDisabledIconTexture = backgroundDisabledSkinTexture;
			radioSelectedUpIconTexture = atlas.getTexture("radio-selected-up-icon");
			radioSelectedDownIconTexture = atlas.getTexture("radio-selected-down-icon");
			radioSelectedDisabledIconTexture = atlas.getTexture("radio-selected-disabled-icon");

			checkUpIconTexture = backgroundSkinTexture;
			checkDownIconTexture = backgroundDownSkinTexture;
			checkDisabledIconTexture = backgroundDisabledSkinTexture;
			checkSelectedUpIconTexture = atlas.getTexture("check-selected-up-icon");
			checkSelectedDownIconTexture = atlas.getTexture("check-selected-down-icon");
			checkSelectedDisabledIconTexture = atlas.getTexture("check-selected-disabled-icon");

			pageIndicatorSelectedSkinTexture = atlas.getTexture("page-indicator-selected-skin");
			pageIndicatorNormalSkinTexture = atlas.getTexture("page-indicator-normal-skin");

			searchIconTexture = atlas.getTexture("search-icon");

			itemRendererUpSkinTextures = new Scale9Textures(atlas.getTexture("list-item-up-skin"), ITEM_RENDERER_SCALE9_GRID);
			itemRendererSelectedSkinTextures = new Scale9Textures(atlas.getTexture("list-item-selected-skin"), ITEM_RENDERER_SCALE9_GRID);
			insetItemRendererFirstUpSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-first-up-skin"), INSET_ITEM_RENDERER_FIRST_SCALE9_GRID);
			insetItemRendererFirstSelectedSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-first-selected-skin"), INSET_ITEM_RENDERER_FIRST_SCALE9_GRID);
			insetItemRendererLastUpSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-last-up-skin"), INSET_ITEM_RENDERER_LAST_SCALE9_GRID);
			insetItemRendererLastSelectedSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-last-selected-skin"), INSET_ITEM_RENDERER_LAST_SCALE9_GRID);
			insetItemRendererSingleUpSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-single-up-skin"), INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID);
			insetItemRendererSingleSelectedSkinTextures = new Scale9Textures(atlas.getTexture("list-inset-item-single-selected-skin"), INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID);

			headerBackgroundSkinTexture = atlas.getTexture("header-background-skin");

			calloutTopArrowSkinTexture = atlas.getTexture("callout-arrow-top-skin");
			calloutRightArrowSkinTexture = atlas.getTexture("callout-arrow-right-skin");
			calloutBottomArrowSkinTexture = atlas.getTexture("callout-arrow-bottom-skin");
			calloutLeftArrowSkinTexture = atlas.getTexture("callout-arrow-left-skin");

			horizontalScrollBarThumbSkinTextures = new Scale3Textures(atlas.getTexture("horizontal-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			verticalScrollBarThumbSkinTextures = new Scale3Textures(atlas.getTexture("vertical-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_VERTICAL);

			StandardIcons.listDrillDownAccessoryTexture = atlas.getTexture("list-accessory-drill-down-icon");

			if(root.stage)
			{
				initializeRoot();
			}
			else
			{
				root.addEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
			}

			setInitializerForClassAndSubclasses(Screen, screenInitializer);
			setInitializerForClassAndSubclasses(PanelScreen, panelScreenInitializer);
			setInitializerForClass(Label, labelInitializer);
			setInitializerForClass(TextFieldTextRenderer, itemRendererAccessoryLabelInitializer, BaseDefaultItemRenderer.DEFAULT_CHILD_NAME_ACCESSORY_LABEL);
			setInitializerForClass(TextFieldTextRenderer, alertMessageInitializer, Alert.DEFAULT_CHILD_NAME_MESSAGE);
			setInitializerForClass(ScrollText, scrollTextInitializer);
			setInitializerForClass(Button, buttonInitializer);
			setInitializerForClass(ToggleButton, buttonInitializer);
			setInitializerForClass(Button, callToActionButtonInitializer, Button.ALTERNATE_NAME_CALL_TO_ACTION_BUTTON);
			setInitializerForClass(Button, quietButtonInitializer, Button.ALTERNATE_NAME_QUIET_BUTTON);
			setInitializerForClass(Button, dangerButtonInitializer, Button.ALTERNATE_NAME_DANGER_BUTTON);
			setInitializerForClass(Button, backButtonInitializer, Button.ALTERNATE_NAME_BACK_BUTTON);
			setInitializerForClass(Button, forwardButtonInitializer, Button.ALTERNATE_NAME_FORWARD_BUTTON);
			setInitializerForClass(Button, buttonGroupButtonInitializer, ButtonGroup.DEFAULT_CHILD_NAME_BUTTON);
			setInitializerForClass(Button, alertButtonGroupButtonInitializer, COMPONENT_NAME_ALERT_BUTTON_GROUP_BUTTON);
			setInitializerForClass(Button, simpleButtonInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_THUMB);
			setInitializerForClass(Button, simpleButtonInitializer, Slider.DEFAULT_CHILD_NAME_THUMB);
			setInitializerForClass(Button, pickerListButtonInitializer, PickerList.DEFAULT_CHILD_NAME_BUTTON);
			setInitializerForClass(Button, tabInitializer, TabBar.DEFAULT_CHILD_NAME_TAB);
			setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MINIMUM_TRACK);
			setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MAXIMUM_TRACK);
			setInitializerForClass(Button, toggleSwitchTrackInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_ON_TRACK);
			setInitializerForClass(Button, nothingInitializer, SimpleScrollBar.DEFAULT_CHILD_NAME_THUMB);
			setInitializerForClass(ButtonGroup, buttonGroupInitializer);
			setInitializerForClass(ButtonGroup, alertButtonGroupInitializer, Alert.DEFAULT_CHILD_NAME_BUTTON_GROUP);
			setInitializerForClass(DefaultListItemRenderer, itemRendererInitializer);
			setInitializerForClass(DefaultListItemRenderer, pickerListItemRendererInitializer, COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, itemRendererInitializer);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetMiddleItemRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetFirstItemRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_FIRST_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetLastItemRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_LAST_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetSingleItemRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_SINGLE_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, headerRendererInitializer);
			setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, footerRendererInitializer, GroupedList.DEFAULT_CHILD_NAME_FOOTER_RENDERER);
			setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, insetHeaderRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_HEADER_RENDERER);
			setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, insetFooterRendererInitializer, GroupedList.ALTERNATE_CHILD_NAME_INSET_FOOTER_RENDERER);
			setInitializerForClass(Radio, radioInitializer);
			setInitializerForClass(Check, checkInitializer);
			setInitializerForClass(Slider, sliderInitializer);
			setInitializerForClass(ToggleSwitch, toggleSwitchInitializer);
			setInitializerForClass(NumericStepper, numericStepperInitializer);
			setInitializerForClass(TextInput, textInputInitializer);
			setInitializerForClass(TextInput, searchTextInputInitializer, TextInput.ALTERNATE_NAME_SEARCH_TEXT_INPUT);
			setInitializerForClass(TextInput, numericStepperTextInputInitializer, NumericStepper.DEFAULT_CHILD_NAME_TEXT_INPUT);
			setInitializerForClass(PageIndicator, pageIndicatorInitializer);
			setInitializerForClass(ProgressBar, progressBarInitializer);
			setInitializerForClass(PickerList, pickerListInitializer);
			setInitializerForClass(Header, headerInitializer);
			setInitializerForClass(Header, headerWithoutBackgroundInitializer, Panel.DEFAULT_CHILD_NAME_HEADER);
			setInitializerForClass(Header, headerWithoutBackgroundInitializer, Alert.DEFAULT_CHILD_NAME_HEADER);
			setInitializerForClass(Callout, calloutInitializer);
			setInitializerForClass(SimpleScrollBar, horizontalScrollBarInitializer, Scroller.DEFAULT_CHILD_NAME_HORIZONTAL_SCROLL_BAR);
			setInitializerForClass(SimpleScrollBar, verticalScrollBarInitializer, Scroller.DEFAULT_CHILD_NAME_VERTICAL_SCROLL_BAR);
			setInitializerForClass(List, listInitializer);
			setInitializerForClass(GroupedList, groupedListInitializer);
			setInitializerForClass(GroupedList, insetGroupedListInitializer, GroupedList.ALTERNATE_NAME_INSET_GROUPED_LIST);
			setInitializerForClass(Panel, panelInitializer);
			setInitializerForClass(Alert, alertInitializer);
			setInitializerForClass(ScrollContainer, scrollContainerToolbarInitializer, ScrollContainer.ALTERNATE_NAME_TOOLBAR);
		}

		protected function pageIndicatorNormalSymbolFactory():DisplayObject
		{
			const symbol:ImageLoader = new ImageLoader();
			symbol.source = pageIndicatorNormalSkinTexture;
			symbol.textureScale = scaleDPI;
			return symbol;
		}

		protected function pageIndicatorSelectedSymbolFactory():DisplayObject
		{
			const symbol:ImageLoader = new ImageLoader();
			symbol.source = pageIndicatorSelectedSkinTexture;
			symbol.textureScale = scaleDPI;
			return symbol;
		}

		protected function imageLoaderFactory():ImageLoader
		{
			const image:ImageLoader = new ImageLoader();
			image.textureScale = scaleDPI;
			return image;
		}

		protected function nothingInitializer(target:DisplayObject):void {}

		protected function screenInitializer(screen:Screen):void
		{
			screen.originalDPI = _originalDPI;
		}

		protected function panelScreenInitializer(screen:PanelScreen):void
		{
			screen.originalDPI = _originalDPI;
		}

		protected function simpleButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonUpSkinTextures;
			skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;

			button.minWidth = button.minHeight = 60 * scaleDPI;
			button.minTouchWidth = button.minTouchHeight = 88 * scaleDPI;
		}

		protected function labelInitializer(label:Label):void
		{
			label.textRendererProperties.textFormat = smallLightTextFormatCentered;
			label.textRendererProperties.embedFonts = true;
		}

		protected function itemRendererAccessoryLabelInitializer(renderer:TextFieldTextRenderer):void
		{
			renderer.textFormat = smallLightTextFormat;
			renderer.embedFonts = true;
		}

		protected function alertMessageInitializer(renderer:TextFieldTextRenderer):void
		{
			renderer.wordWrap = true;
			renderer.textFormat = smallLightTextFormat;
			renderer.embedFonts = true;
		}

		protected function scrollTextInitializer(text:ScrollText):void
		{
			text.textFormat = smallLightTextFormat;
			text.embedFonts = true;
			text.paddingTop = text.paddingBottom = text.paddingLeft = 32 * scaleDPI;
			text.paddingRight = 36 * scaleDPI;
		}

		protected function baseButtonInitializer(button:Button):void
		{
			button.defaultLabelProperties.textFormat = smallUIDarkTextFormat;
			button.defaultLabelProperties.embedFonts = true;
			button.disabledLabelProperties.textFormat = smallUIDarkDisabledTextFormat;
			button.disabledLabelProperties.embedFonts = true;

			button.paddingTop = button.paddingBottom = 8 * scaleDPI;
			button.paddingLeft = button.paddingRight = 16 * scaleDPI;
			button.gap = 12 * scaleDPI;
			button.minWidth = button.minHeight = 60 * scaleDPI;
			button.minTouchWidth = button.minTouchHeight = 88 * scaleDPI;
		}
		protected function buttonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonUpSkinTextures;
			skinSelector.defaultSelectedValue = buttonSelectedUpSkinTextures;
			skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.setValueForState(buttonSelectedDisabledSkinTextures, Button.STATE_DISABLED, true);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
		}

		protected function callToActionButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonCallToActionUpSkinTextures;
			skinSelector.setValueForState(buttonCallToActionDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
		}

		protected function quietButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonQuietUpSkinTextures;
			skinSelector.setValueForState(buttonQuietDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
		}

		protected function dangerButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonDangerUpSkinTextures;
			skinSelector.setValueForState(buttonDangerDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
		}

		protected function backButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonBackUpSkinTextures;
			skinSelector.setValueForState(buttonBackDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonBackDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
			button.paddingLeft = 28 * scaleDPI;
		}

		protected function forwardButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonForwardUpSkinTextures;
			skinSelector.setValueForState(buttonForwardDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonForwardDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 60 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;
			baseButtonInitializer(button);
			button.paddingRight = 28 * scaleDPI;
		}

		protected function buttonGroupButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonUpSkinTextures;
			skinSelector.defaultSelectedValue = buttonSelectedUpSkinTextures;
			skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.setValueForState(buttonSelectedDisabledSkinTextures, Button.STATE_DISABLED, true);
			skinSelector.displayObjectProperties =
			{
				width: 76 * scaleDPI,
				height: 76 * scaleDPI,
				textureScale: scaleDPI
			};
			button.stateToSkinFunction = skinSelector.updateValue;

			button.defaultLabelProperties.textFormat = largeUIDarkTextFormat;
			button.defaultLabelProperties.embedFonts = true;
			button.disabledLabelProperties.textFormat = largeUIDisabledTextFormat;
			button.disabledLabelProperties.embedFonts = true;

			button.paddingTop = button.paddingBottom = 8 * scaleDPI;
			button.paddingLeft = button.paddingRight = 16 * scaleDPI;
			button.gap = 12 * scaleDPI;
			button.minWidth = button.minHeight = 76 * scaleDPI;
			button.minTouchWidth = button.minTouchHeight = 88 * scaleDPI;
		}

		protected function alertButtonGroupButtonInitializer(button:Button):void
		{
			buttonInitializer(button);
		}

		protected function pickerListButtonInitializer(button:Button):void
		{
			buttonInitializer(button);

			const defaultIcon:ImageLoader = new ImageLoader();
			defaultIcon.source = pickerListButtonIconTexture;
			defaultIcon.textureScale = scaleDPI;
			defaultIcon.snapToPixels = true;
			button.defaultIcon = defaultIcon;

			button.gap = Number.POSITIVE_INFINITY;
			button.iconPosition = Button.ICON_POSITION_RIGHT;
		}

		protected function toggleSwitchTrackInitializer(track:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = backgroundSkinTextures;
			skinSelector.setValueForState(backgroundDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				width: 140 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			track.stateToSkinFunction = skinSelector.updateValue;
		}

		protected function tabInitializer(tab:Button):void
		{
			const defaultSkin:Quad = new Quad(88 * scaleDPI, 88 * scaleDPI, TAB_BACKGROUND_COLOR);
			tab.defaultSkin = defaultSkin;

			const downSkin:Scale9Image = new Scale9Image(tabDownSkinTextures, scaleDPI);
			tab.downSkin = downSkin;

			const defaultSelectedSkin:Scale9Image = new Scale9Image(tabSelectedSkinTextures, scaleDPI);

			const disabledSkin:Quad = new Quad(88 * scaleDPI, 88 * scaleDPI, TAB_DISABLED_BACKGROUND_COLOR);
			tab.disabledSkin = disabledSkin;

			const selectedDisabledSkin:Scale9Image = new Scale9Image(tabSelectedDisabledSkinTextures, scaleDPI);

			tab.defaultLabelProperties.textFormat = smallUILightTextFormat;
			tab.defaultLabelProperties.embedFonts = true;
			tab.disabledLabelProperties.textFormat = smallUIDarkDisabledTextFormat;
			tab.disabledLabelProperties.embedFonts = true;

			tab.paddingTop = tab.paddingBottom = 8 * scaleDPI;
			tab.paddingLeft = tab.paddingRight = 16 * scaleDPI;
			tab.gap = 12 * scaleDPI;
			tab.minWidth = tab.minHeight = 88 * scaleDPI;
			tab.minTouchWidth = tab.minTouchHeight = 88 * scaleDPI;
		}

		protected function buttonGroupInitializer(group:ButtonGroup):void
		{
			group.minWidth = 560 * scaleDPI;
			group.gap = 18 * scaleDPI;
		}

		protected function alertButtonGroupInitializer(group:ButtonGroup):void
		{
			group.direction = ButtonGroup.DIRECTION_HORIZONTAL;
			group.gap = 12 * scaleDPI;
			group.paddingTop = 12 * scaleDPI;
			group.paddingRight = 12 * scaleDPI;
			group.paddingBottom = 12 * scaleDPI;
			group.paddingLeft = 12 * scaleDPI;
			group.customButtonName = COMPONENT_NAME_ALERT_BUTTON_GROUP_BUTTON;
		}

		protected function itemRendererInitializer(renderer:BaseDefaultItemRenderer):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = itemRendererUpSkinTextures;
			skinSelector.defaultSelectedValue = itemRendererSelectedSkinTextures;
			skinSelector.setValueForState(itemRendererSelectedSkinTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties =
			{
				width: 88 * scaleDPI,
				height: 88 * scaleDPI,
				textureScale: scaleDPI
			};
			renderer.stateToSkinFunction = skinSelector.updateValue;

			renderer.defaultLabelProperties.textFormat = largeLightTextFormat;
			renderer.defaultLabelProperties.embedFonts = true;
			renderer.downLabelProperties.textFormat = largeDarkTextFormat;
			renderer.downLabelProperties.embedFonts = true;
			renderer.defaultSelectedLabelProperties.textFormat = largeDarkTextFormat;
			renderer.defaultSelectedLabelProperties.embedFonts = true;

			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * scaleDPI;
			renderer.paddingLeft = 32 * scaleDPI;
			renderer.paddingRight = 24 * scaleDPI;
			renderer.gap = 20 * scaleDPI;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * scaleDPI;

			renderer.accessoryLoaderFactory = imageLoaderFactory;
			renderer.iconLoaderFactory = imageLoaderFactory;
		}

		protected function pickerListItemRendererInitializer(renderer:BaseDefaultItemRenderer):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = itemRendererUpSkinTextures;
			skinSelector.setValueForState(itemRendererSelectedSkinTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties =
			{
				width: 88 * scaleDPI,
				height: 88 * scaleDPI,
				textureScale: scaleDPI
			};
			renderer.stateToSkinFunction = skinSelector.updateValue;

			const defaultSelectedIcon:Image = new Image(pickerListItemSelectedIconTexture);
			defaultSelectedIcon.scaleX = defaultSelectedIcon.scaleY = scaleDPI;
			renderer.defaultSelectedIcon = defaultSelectedIcon;

			const defaultIcon:Quad = new Quad(defaultSelectedIcon.width, defaultSelectedIcon.height, 0xff00ff);
			defaultIcon.alpha = 0;
			renderer.defaultIcon = defaultIcon;

			renderer.defaultLabelProperties.textFormat = largeLightTextFormat;
			renderer.defaultLabelProperties.embedFonts = true;
			renderer.downLabelProperties.textFormat = largeDarkTextFormat;
			renderer.downLabelProperties.embedFonts = true;

			renderer.itemHasIcon = false;
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * scaleDPI;
			renderer.paddingLeft = 32 * scaleDPI;
			renderer.paddingRight = 24 * scaleDPI;
			renderer.gap = Number.POSITIVE_INFINITY;
			renderer.iconPosition = Button.ICON_POSITION_RIGHT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * scaleDPI;
		}

		protected function insetItemRendererInitializer(renderer:DefaultGroupedListItemRenderer, defaultSkinTextures:Scale9Textures, selectedAndDownSkinTextures:Scale9Textures):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = defaultSkinTextures;
			skinSelector.defaultSelectedValue = selectedAndDownSkinTextures;
			skinSelector.setValueForState(selectedAndDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties =
			{
				width: 88 * scaleDPI,
				height: 88 * scaleDPI,
				textureScale: scaleDPI
			};
			renderer.stateToSkinFunction = skinSelector.updateValue;

			renderer.defaultLabelProperties.textFormat = largeLightTextFormat;
			renderer.defaultLabelProperties.embedFonts = true;
			renderer.downLabelProperties.textFormat = largeDarkTextFormat;
			renderer.downLabelProperties.embedFonts = true;
			renderer.defaultSelectedLabelProperties.textFormat = largeDarkTextFormat;
			renderer.defaultSelectedLabelProperties.embedFonts = true;

			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * scaleDPI;
			renderer.paddingLeft = 32 * scaleDPI;
			renderer.paddingRight = 24 * scaleDPI;
			renderer.gap = 20 * scaleDPI;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * scaleDPI;

			renderer.accessoryLoaderFactory = imageLoaderFactory;
			renderer.iconLoaderFactory = imageLoaderFactory;
		}

		protected function insetMiddleItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			insetItemRendererInitializer(renderer, itemRendererUpSkinTextures, itemRendererSelectedSkinTextures);
		}

		protected function insetFirstItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			insetItemRendererInitializer(renderer, insetItemRendererFirstUpSkinTextures, insetItemRendererFirstSelectedSkinTextures);
		}

		protected function insetLastItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			insetItemRendererInitializer(renderer, insetItemRendererLastUpSkinTextures, insetItemRendererLastSelectedSkinTextures);
		}

		protected function insetSingleItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			insetItemRendererInitializer(renderer, insetItemRendererSingleUpSkinTextures, insetItemRendererSingleSelectedSkinTextures);
		}

		protected function headerRendererInitializer(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
		{
			const defaultSkin:Quad = new Quad(44 * scaleDPI, 44 * scaleDPI, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
			renderer.backgroundSkin = defaultSkin;

			renderer.horizontalAlign = DefaultGroupedListHeaderOrFooterRenderer.HORIZONTAL_ALIGN_LEFT;
			renderer.contentLabelProperties.textFormat = smallUILightTextFormat;
			renderer.contentLabelProperties.embedFonts = true;
			renderer.paddingTop = renderer.paddingBottom = 4 * scaleDPI;
			renderer.paddingLeft = renderer.paddingRight = 16 * scaleDPI;
			renderer.minWidth = renderer.minHeight = 44 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 44 * scaleDPI;

			renderer.contentLoaderFactory = imageLoaderFactory;
		}

		protected function footerRendererInitializer(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
		{
			const defaultSkin:Quad = new Quad(44 * scaleDPI, 44 * scaleDPI, GROUPED_LIST_FOOTER_BACKGROUND_COLOR);
			renderer.backgroundSkin = defaultSkin;

			renderer.horizontalAlign = DefaultGroupedListHeaderOrFooterRenderer.HORIZONTAL_ALIGN_CENTER;
			renderer.contentLabelProperties.textFormat = smallLightTextFormat;
			renderer.contentLabelProperties.embedFonts = true;
			renderer.paddingTop = renderer.paddingBottom = 4 * scaleDPI;
			renderer.paddingLeft = renderer.paddingRight = 16 * scaleDPI;
			renderer.minWidth = renderer.minHeight = 44 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 44 * scaleDPI;

			renderer.contentLoaderFactory = imageLoaderFactory;
		}

		protected function insetHeaderRendererInitializer(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
		{
			const defaultSkin:Quad = new Quad(66 * scaleDPI, 66 * scaleDPI, 0xff00ff);
			defaultSkin.alpha = 0;
			renderer.backgroundSkin = defaultSkin;

			renderer.horizontalAlign = DefaultGroupedListHeaderOrFooterRenderer.HORIZONTAL_ALIGN_LEFT;
			renderer.contentLabelProperties.textFormat = smallUILightTextFormat;
			renderer.contentLabelProperties.embedFonts = true;
			renderer.paddingTop = renderer.paddingBottom = 4 * scaleDPI;
			renderer.paddingLeft = renderer.paddingRight = 32 * scaleDPI;
			renderer.minWidth = renderer.minHeight = 66 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 44 * scaleDPI;

			renderer.contentLoaderFactory = imageLoaderFactory;
		}

		protected function insetFooterRendererInitializer(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
		{
			const defaultSkin:Quad = new Quad(66 * scaleDPI, 66 * scaleDPI, 0xff00ff);
			defaultSkin.alpha = 0;
			renderer.backgroundSkin = defaultSkin;

			renderer.horizontalAlign = DefaultGroupedListHeaderOrFooterRenderer.HORIZONTAL_ALIGN_CENTER;
			renderer.contentLabelProperties.textFormat = smallLightTextFormat;
			renderer.contentLabelProperties.embedFonts = true;
			renderer.paddingTop = renderer.paddingBottom = 4 * scaleDPI;
			renderer.paddingLeft = renderer.paddingRight = 32 * scaleDPI;
			renderer.minWidth = renderer.minHeight = 66 * scaleDPI;
			renderer.minTouchWidth = renderer.minTouchHeight = 44 * scaleDPI;

			renderer.contentLoaderFactory = imageLoaderFactory;
		}

		protected function radioInitializer(radio:Radio):void
		{
			const iconSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			iconSelector.defaultValue = radioUpIconTexture;
			iconSelector.defaultSelectedValue = radioSelectedUpIconTexture;
			iconSelector.setValueForState(radioDownIconTexture, Button.STATE_DOWN, false);
			iconSelector.setValueForState(radioDisabledIconTexture, Button.STATE_DISABLED, false);
			iconSelector.setValueForState(radioSelectedDownIconTexture, Button.STATE_DOWN, true);
			iconSelector.setValueForState(radioSelectedDisabledIconTexture, Button.STATE_DISABLED, true);
			iconSelector.displayObjectProperties =
			{
				scaleX: scaleDPI,
				scaleY: scaleDPI
			};
			radio.stateToIconFunction = iconSelector.updateValue;

			radio.defaultLabelProperties.textFormat = smallUILightTextFormat;
			radio.defaultLabelProperties.embedFonts = true;
			radio.disabledLabelProperties.textFormat = smallUILightDisabledTextFormat;
			radio.disabledLabelProperties.embedFonts = true;
			radio.selectedDisabledLabelProperties.textFormat = smallUILightDisabledTextFormat;
			radio.selectedDisabledLabelProperties.embedFonts = true;

			radio.gap = 8 * scaleDPI;
			radio.minTouchWidth = radio.minTouchHeight = 88 * scaleDPI;
		}

		protected function checkInitializer(check:Check):void
		{
			const iconSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			iconSelector.defaultValue = checkUpIconTexture;
			iconSelector.defaultSelectedValue = checkSelectedUpIconTexture;
			iconSelector.setValueForState(checkDownIconTexture, Button.STATE_DOWN, false);
			iconSelector.setValueForState(checkDisabledIconTexture, Button.STATE_DISABLED, false);
			iconSelector.setValueForState(checkSelectedDownIconTexture, Button.STATE_DOWN, true);
			iconSelector.setValueForState(checkSelectedDisabledIconTexture, Button.STATE_DISABLED, true);
			iconSelector.displayObjectProperties =
			{
				scaleX: scaleDPI,
				scaleY: scaleDPI
			};
			check.stateToIconFunction = iconSelector.updateValue;

			check.defaultLabelProperties.textFormat = smallUILightTextFormat;
			check.defaultLabelProperties.embedFonts = true;
			check.disabledLabelProperties.textFormat = smallUILightDisabledTextFormat;
			check.disabledLabelProperties.embedFonts = true;
			check.selectedDisabledLabelProperties.textFormat = smallUILightDisabledTextFormat;
			check.selectedDisabledLabelProperties.embedFonts = true;

			check.gap = 8 * scaleDPI;
			check.minTouchWidth = check.minTouchHeight = 88 * scaleDPI;
		}

		protected function sliderInitializer(slider:Slider):void
		{
			slider.trackLayoutMode = Slider.TRACK_LAYOUT_MODE_MIN_MAX;

			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = backgroundSkinTextures;
			skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.setValueForState(backgroundDisabledSkinTextures, Button.STATE_DISABLED, false);
			skinSelector.displayObjectProperties =
			{
				textureScale: scaleDPI
			};
			if(slider.direction == Slider.DIRECTION_VERTICAL)
			{
				skinSelector.displayObjectProperties.width = 60 * scaleDPI;
				skinSelector.displayObjectProperties.height = 210 * scaleDPI;
			}
			else
			{
				skinSelector.displayObjectProperties.width = 210 * scaleDPI;
				skinSelector.displayObjectProperties.height = 60 * scaleDPI;
			}
			slider.minimumTrackProperties.stateToSkinFunction = skinSelector.updateValue;
			slider.maximumTrackProperties.stateToSkinFunction = skinSelector.updateValue;
		}

		protected function toggleSwitchInitializer(toggle:ToggleSwitch):void
		{
			toggle.trackLayoutMode = ToggleSwitch.TRACK_LAYOUT_MODE_SINGLE;

			toggle.defaultLabelProperties.textFormat = smallUILightTextFormat;
			toggle.defaultLabelProperties.embedFonts = true;
			toggle.onLabelProperties.textFormat = smallUISelectedTextFormat;
			toggle.onLabelProperties.embedFonts = true;
		}

		protected function numericStepperInitializer(stepper:NumericStepper):void
		{
			stepper.buttonLayoutMode = NumericStepper.BUTTON_LAYOUT_MODE_SPLIT_HORIZONTAL;
			stepper.incrementButtonLabel = "+";
			stepper.decrementButtonLabel = "-";
		}

		protected function horizontalScrollBarInitializer(scrollBar:SimpleScrollBar):void
		{
			scrollBar.direction = SimpleScrollBar.DIRECTION_HORIZONTAL;
			const defaultSkin:Scale3Image = new Scale3Image(horizontalScrollBarThumbSkinTextures, scaleDPI);
			defaultSkin.width = 10 * scaleDPI;
			scrollBar.thumbProperties.defaultSkin = defaultSkin;
			scrollBar.paddingRight = scrollBar.paddingBottom = scrollBar.paddingLeft = 4 * scaleDPI;
		}

		protected function verticalScrollBarInitializer(scrollBar:SimpleScrollBar):void
		{
			scrollBar.direction = SimpleScrollBar.DIRECTION_VERTICAL;
			const defaultSkin:Scale3Image = new Scale3Image(verticalScrollBarThumbSkinTextures, scaleDPI);
			defaultSkin.height = 10 * scaleDPI;
			scrollBar.thumbProperties.defaultSkin = defaultSkin;
			scrollBar.paddingTop = scrollBar.paddingRight = scrollBar.paddingBottom = 4 * scaleDPI;
		}

		protected function baseTextInputInitializer(input:TextInput):void
		{
			var skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = backgroundInsetSkinTextures;
			skinSelector.setValueForState(backgroundDisabledSkinTextures, TextInput.STATE_DISABLED);
			skinSelector.setValueForState(backgroundFocusedSkinTextures, TextInput.STATE_FOCUSED);
			skinSelector.displayObjectProperties =
			{
				width: 264 * scaleDPI,
				height: 60 * scaleDPI,
				textureScale: scaleDPI
			};
			input.stateToSkinFunction = skinSelector.updateValue;

			input.minWidth = input.minHeight = 60 * scaleDPI;
			input.minTouchWidth = input.minTouchHeight = 88 * scaleDPI;
			input.gap = 12 * scaleDPI;
			input.paddingTop = 12 * scaleDPI;
			input.paddingBottom = 10 * scaleDPI;
			input.paddingLeft = input.paddingRight = 14 * scaleDPI;
			input.textEditorProperties.fontFamily = "Helvetica";
			input.textEditorProperties.fontSize = 24 * scaleDPI;
			input.textEditorProperties.color = LIGHT_TEXT_COLOR;

			input.promptProperties.textFormat = smallLightTextFormat;
			input.promptProperties.embedFonts = true;
		}

		protected function textInputInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input);
		}

		protected function searchTextInputInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input);

			var searchIcon:ImageLoader = new ImageLoader();
			searchIcon.source = searchIconTexture;
			searchIcon.snapToPixels = true;
			input.defaultIcon = searchIcon;
		}

		protected function numericStepperTextInputInitializer(input:TextInput):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundSkinTextures, scaleDPI);
			backgroundSkin.width = 60 * scaleDPI;
			backgroundSkin.height = 60 * scaleDPI;
			input.backgroundSkin = backgroundSkin;

			const backgroundDisabledSkin:Scale9Image = new Scale9Image(backgroundDisabledSkinTextures, scaleDPI);
			backgroundDisabledSkin.width = 60 * scaleDPI;
			backgroundDisabledSkin.height = 60 * scaleDPI;
			input.backgroundDisabledSkin = backgroundDisabledSkin;

			const backgroundFocusedSkin:Scale9Image = new Scale9Image(backgroundFocusedSkinTextures, scaleDPI);
			backgroundFocusedSkin.width = 60 * scaleDPI;
			backgroundFocusedSkin.height = 60 * scaleDPI;
			input.backgroundFocusedSkin = backgroundFocusedSkin;

			input.minWidth = input.minHeight = 60 * scaleDPI;
			input.minTouchWidth = input.minTouchHeight = 88 * scaleDPI;
			input.gap = 12 * scaleDPI;
			input.paddingTop = 12 * scaleDPI;
			input.paddingBottom = 10 * scaleDPI;
			input.paddingLeft = input.paddingRight = 14 * scaleDPI;
			input.isEditable = false;
			input.textEditorFactory = stepperTextEditorFactory;
			input.textEditorProperties.textFormat = smallLightTextFormatCentered;
			input.textEditorProperties.embedFonts = true;
		}

		protected function pageIndicatorInitializer(pageIndicator:PageIndicator):void
		{
			pageIndicator.normalSymbolFactory = pageIndicatorNormalSymbolFactory;
			pageIndicator.selectedSymbolFactory = pageIndicatorSelectedSymbolFactory;
			pageIndicator.gap = 10 * scaleDPI;
			pageIndicator.paddingTop = pageIndicator.paddingRight = pageIndicator.paddingBottom =
				pageIndicator.paddingLeft = 6 * scaleDPI;
			pageIndicator.minTouchWidth = pageIndicator.minTouchHeight = 44 * scaleDPI;
		}

		protected function progressBarInitializer(progress:ProgressBar):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundSkinTextures, scaleDPI);
			backgroundSkin.width = 240 * scaleDPI;
			backgroundSkin.height = 22 * scaleDPI;
			progress.backgroundSkin = backgroundSkin;

			const backgroundDisabledSkin:Scale9Image = new Scale9Image(backgroundDisabledSkinTextures, scaleDPI);
			backgroundDisabledSkin.width = 240 * scaleDPI;
			backgroundDisabledSkin.height = 22 * scaleDPI;
			progress.backgroundDisabledSkin = backgroundDisabledSkin;

			const fillSkin:Scale9Image = new Scale9Image(buttonUpSkinTextures, scaleDPI);
			fillSkin.width = 8 * scaleDPI;
			fillSkin.height = 22 * scaleDPI;
			progress.fillSkin = fillSkin;

			const fillDisabledSkin:Scale9Image = new Scale9Image(buttonDisabledSkinTextures, scaleDPI);
			fillDisabledSkin.width = 8 * scaleDPI;
			fillDisabledSkin.height = 22 * scaleDPI;
			progress.fillDisabledSkin = fillDisabledSkin;
		}

		protected function headerInitializer(header:Header):void
		{
			header.minWidth = 88 * scaleDPI;
			header.minHeight = 88 * scaleDPI;
			header.paddingTop = header.paddingRight = header.paddingBottom =
				header.paddingLeft = 14 * scaleDPI;
			header.gap = 8 * scaleDPI;
			header.titleGap = 12 * scaleDPI;

			const backgroundSkin:TiledImage = new TiledImage(headerBackgroundSkinTexture, scaleDPI);
			backgroundSkin.width = backgroundSkin.height = 88 * scaleDPI;
			header.backgroundSkin = backgroundSkin;
			header.titleProperties.textFormat = headerTextFormat;
			header.titleProperties.embedFonts = true;
		}

		protected function headerWithoutBackgroundInitializer(header:Header):void
		{
			header.minWidth = 88 * scaleDPI;
			header.minHeight = 88 * scaleDPI;
			header.paddingTop = header.paddingBottom = 14 * scaleDPI;
			header.paddingLeft = header.paddingRight = 18 * scaleDPI;

			header.titleProperties.textFormat = headerTextFormat;
			header.titleProperties.embedFonts = true;
		}

		protected function pickerListInitializer(list:PickerList):void
		{
			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				list.popUpContentManager = new CalloutPopUpContentManager();
			}
			else
			{
				const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
				centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
					centerStage.marginLeft = 24 * scaleDPI;
				list.popUpContentManager = centerStage;
			}

			const layout:VerticalLayout = new VerticalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_BOTTOM;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			layout.useVirtualLayout = true;
			layout.gap = 0;
			layout.paddingTop = layout.paddingRight = layout.paddingBottom =
				layout.paddingLeft = 0;
			list.listProperties.layout = layout;
			list.listProperties.verticalScrollPolicy = List.SCROLL_POLICY_ON;

			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				list.listProperties.minWidth = 560 * scaleDPI;
				list.listProperties.maxHeight = 528 * scaleDPI;
			}
			else
			{
				const backgroundSkin:Scale9Image = new Scale9Image(backgroundSkinTextures, scaleDPI);
				backgroundSkin.width = 20 * scaleDPI;
				backgroundSkin.height = 20 * scaleDPI;
				list.listProperties.backgroundSkin = backgroundSkin;
				list.listProperties.paddingTop = list.listProperties.paddingRight =
					list.listProperties.paddingBottom = list.listProperties.paddingLeft = 8 * scaleDPI;
			}

			list.listProperties.itemRendererName = COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER;
		}

		protected function calloutInitializer(callout:Callout):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundPopUpSkinTextures, scaleDPI);
			backgroundSkin.height = 88 * scaleDPI;
			callout.backgroundSkin = backgroundSkin;

			const topArrowSkin:Image = new Image(calloutTopArrowSkinTexture);
			topArrowSkin.scaleX = topArrowSkin.scaleY = scaleDPI;
			callout.topArrowSkin = topArrowSkin;

			const rightArrowSkin:Image = new Image(calloutRightArrowSkinTexture);
			rightArrowSkin.scaleX = rightArrowSkin.scaleY = scaleDPI;
			callout.rightArrowSkin = rightArrowSkin;

			const bottomArrowSkin:Image = new Image(calloutBottomArrowSkinTexture);
			bottomArrowSkin.scaleX = bottomArrowSkin.scaleY = scaleDPI;
			callout.bottomArrowSkin = bottomArrowSkin;

			const leftArrowSkin:Image = new Image(calloutLeftArrowSkinTexture);
			leftArrowSkin.scaleX = leftArrowSkin.scaleY = scaleDPI;
			callout.leftArrowSkin = leftArrowSkin;

			callout.padding = 8 * scaleDPI;
		}

		protected function panelInitializer(panel:Panel):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundPopUpSkinTextures, scaleDPI);
			panel.backgroundSkin = backgroundSkin;

			panel.paddingTop = 0;
			panel.paddingRight = 8 * scaleDPI;
			panel.paddingBottom = 8 * scaleDPI;
			panel.paddingLeft = 8 * scaleDPI;
		}

		protected function alertInitializer(alert:Alert):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundPopUpSkinTextures, scaleDPI);
			alert.backgroundSkin = backgroundSkin;

			alert.paddingTop = 0;
			alert.paddingRight = 16 * scaleDPI;
			alert.paddingBottom = 16 * scaleDPI;
			alert.paddingLeft = 16 * scaleDPI;
			alert.maxWidth = alert.maxHeight = 560 * scaleDPI;
		}

		protected function listInitializer(list:List):void
		{
			const backgroundSkin:Quad = new Quad(88 * scaleDPI, 88 * scaleDPI, LIST_BACKGROUND_COLOR);
			list.backgroundSkin = backgroundSkin;
		}

		protected function groupedListInitializer(list:GroupedList):void
		{
			const backgroundSkin:Quad = new Quad(88 * scaleDPI, 88 * scaleDPI, LIST_BACKGROUND_COLOR);
			list.backgroundSkin = backgroundSkin;
		}

		protected function scrollContainerToolbarInitializer(container:ScrollContainer):void
		{
			if(!container.layout)
			{
				const layout:HorizontalLayout = new HorizontalLayout();
				layout.paddingTop = layout.paddingRight = layout.paddingBottom =
					layout.paddingLeft = 14 * scaleDPI;
				layout.gap = 8 * scaleDPI;
				container.layout = layout;
			}
			container.minWidth = 88 * scaleDPI;
			container.minHeight = 88 * scaleDPI;

			const backgroundSkin:TiledImage = new TiledImage(headerBackgroundSkinTexture, scaleDPI);
			backgroundSkin.width = backgroundSkin.height = 88 * scaleDPI;
			container.backgroundSkin = backgroundSkin;
		}

		protected function insetGroupedListInitializer(list:GroupedList):void
		{
			list.itemRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_ITEM_RENDERER;
			list.firstItemRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_FIRST_ITEM_RENDERER;
			list.lastItemRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_LAST_ITEM_RENDERER;
			list.singleItemRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_SINGLE_ITEM_RENDERER;
			list.headerRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_HEADER_RENDERER;
			list.footerRendererName = GroupedList.ALTERNATE_CHILD_NAME_INSET_FOOTER_RENDERER;

			const layout:VerticalLayout = new VerticalLayout();
			layout.useVirtualLayout = true;
			layout.padding = 18 * scaleDPI;
			layout.gap = 0;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout.manageVisibility = true;
			list.layout = layout;
		}

		protected function root_addedToStageHandler(event:Event):void
		{
			initializeRoot();
		}

	}
}
