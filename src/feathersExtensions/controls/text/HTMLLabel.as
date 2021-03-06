package feathersExtensions.controls.text
{
import feathers.controls.text.TextFieldTextRenderer;

import starling.display.DisplayObject;

public class HTMLLabel extends TextFieldTextRenderer
	{
		public function HTMLLabel()
		{
			super();
		}
		override protected function initialize():void
		{
			super.initialize();
			isHTML = embedFonts = true;
			//wordWrap = true;
		}
		public var padding:Number = 0;
		override public function validate():void
		{
			super.validate();
			
			if(_backgroundSkin) 
			{
				_backgroundSkin.width = width + padding;
				_backgroundSkin.height = height + padding;
				_backgroundSkin.x = -padding/2;
				_backgroundSkin.y = -padding/2;
			}
			if(_backgroundDisabledSkin) 
			{
				_backgroundDisabledSkin.width = width + padding;
				_backgroundDisabledSkin.height = height + padding;
				_backgroundDisabledSkin.x = -padding/2;
				_backgroundDisabledSkin.y = -padding/2;
			}
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
				this._backgroundSkin.touchable = false;
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
				this._backgroundDisabledSkin.touchable = false;
				super.addChildAt(this._backgroundDisabledSkin, 0);
				_backgroundDisabledSkin.width = width;
				_backgroundDisabledSkin.height = height;
			}
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
	}
}