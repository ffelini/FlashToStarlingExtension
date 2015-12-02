package feathersExtensions.groups
{
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.VerticalLayout;

import feathersExtensions.layout.SmartAnchorLayout;

import starling.display.DisplayObject;

public class SmartLayoutGroupSkinnable extends SmartLayoutGroup
	{
		protected var content:SmartLayoutGroup;
		
		public function SmartLayoutGroupSkinnable(_initChildren:Boolean=false)
		{
			content = new SmartLayoutGroup();
			super(_initChildren);
			super.addChildAt(content,0);
			super.clipContent = false;
			
			super.layout = new SmartAnchorLayout();
		}
		override public function get aLayout():AnchorLayout
		{
			return content.aLayout;
		}
		override public function get hLayout():HorizontalLayout
		{
			return content.hLayout;
		}
		override public function get saLayout():SmartAnchorLayout
		{
			return content.saLayout;
		}
		override public function get vLayout():VerticalLayout
		{
			return content.vLayout;
		}
		override public function get numChildren():int
		{
			return content.numChildren;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return content.addChildAt(child, index);
		}
		override public function getChildAt(index:int):DisplayObject
		{
			return content.getChildAt(index);
		}
		override public function getChildByName(name:String):DisplayObject
		{
			return content.getChildByName(name);
		}
		override public function getChildIndex(child:DisplayObject):int
		{
			return content.getChildIndex(child);
		}
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			return content.removeChildAt(index,dispose);
		}
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			return content.removeChild(child, dispose);
		}
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			content.setChildIndex(child, index);
		}
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			content.swapChildrenAt(index1, index2);
		}
		override public function set clipContent(value:Boolean):void
		{
			content.clipContent = value;
		}
		override public function get layout():ILayout
		{
			return content.layout;
		}
		override public function set layout(value:ILayout):void
		{
			content.layout = value;
		}
		override protected function validateSize():void
		{
			super.validateSize();
			
			if(_backgroundSkin) 
			{
				_backgroundSkin.width = width;
				_backgroundSkin.height = height;
			}
			if(_backgroundDisabledSkin) 
			{
				_backgroundDisabledSkin.width = width;
				_backgroundDisabledSkin.height = height;
			}
			
			validateContentSize();
		}
		public var padding:Number = 0;
		protected function validateContentSize():void
		{
			super.saLayout.layoutChild(content,padding/2,padding/2,padding/2,padding/2);
		}
		/**
		 * @private
		 */
		protected var _backgroundSkin:DisplayObject;
		
		/**
		 * A display object displayed behind the header's content.
		 *
		 * <p>In the following example, the header's background skin is set to
		 * a <code>Quad</code>:</p>
		 *
		 * <listing version="3.0">
		 * header.backgroundSkin = new Quad( 10, 10, 0xff0000 );</listing>
		 *
		 * @default null
		 */
		public function get backgroundSkin():DisplayObject
		{
			return this._backgroundSkin;
		}
		
		/**
		 * @private
		 */
		public function set backgroundSkin(value:DisplayObject):void
		{
			if(this._backgroundSkin == value)
			{
				return;
			}
			
			if(this._backgroundSkin && this._backgroundSkin != this._backgroundDisabledSkin)
			{
				super.removeChild(this._backgroundSkin);
			}
			this._backgroundSkin = value;
			if(this._backgroundSkin && this._backgroundSkin.parent != this)
			{
				//this._backgroundSkin.touchable = false;
				super.addChildAt(this._backgroundSkin, 0);
				_backgroundSkin.width = width;
				_backgroundSkin.height = height;
			}
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		/**
		 * @private
		 */
		protected var _backgroundDisabledSkin:DisplayObject;
		
		/**
		 * A background to display when the header is disabled.
		 *
		 * <p>In the following example, the header's disabled background skin is
		 * set to a <code>Quad</code>:</p>
		 *
		 * <listing version="3.0">
		 * header.backgroundDisabledSkin = new Quad( 10, 10, 0x999999 );</listing>
		 *
		 * @default null
		 */
		public function get backgroundDisabledSkin():DisplayObject
		{
			return this._backgroundDisabledSkin;
		}
		
		/**
		 * @private
		 */
		public function set backgroundDisabledSkin(value:DisplayObject):void
		{
			if(this._backgroundDisabledSkin == value)
			{
				return;
			}
			
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin != this._backgroundSkin)
			{
				super.removeChild(this._backgroundDisabledSkin);
			}
			this._backgroundDisabledSkin = value;
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent != this)
			{
				//this._backgroundDisabledSkin.touchable = false;
				super.addChildAt(this._backgroundDisabledSkin, 0);
				_backgroundDisabledSkin.width = width;
				_backgroundDisabledSkin.height = height;
			}
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
	}
}