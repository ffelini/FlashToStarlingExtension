package feathersExtensions.skins
{
import feathers.display.TiledImage;
import feathers.skins.StateWithToggleValueSelector;

import starling.textures.Texture;

public class TiledImageStateValueSelector extends StateWithToggleValueSelector
	{
		public function TiledImageStateValueSelector()
		{
			super();
		}
		
		/**
		 * @private
		 */
		protected var _imageProperties:Object;
		
		/**
		 * Optional properties to set on the Image instance.
		 *
		 * @see starling.display.Image
		 */
		public function get imageProperties():Object
		{
			if(!this._imageProperties)
			{
				this._imageProperties = {};
			}
			return this._imageProperties;
		}
		
		/**
		 * @private
		 */
		public function set imageProperties(value:Object):void
		{
			this._imageProperties = value;
		}
		
		/**
		 * @private
		 */
		override public function setValueForState(value:Object, state:Object, isSelected:Boolean = false):void
		{
			if(!(value is Texture))
			{
				throw new ArgumentError("Value for state must be a Texture instance.");
			}
			super.setValueForState(value, state, isSelected);
		}

		override public function updateValue(target:Object, state:Object, oldValue:Object = null):Object
		{
			const texture:Texture = super.updateValue(target, state) as Texture;
			if(!texture)
			{
				return null;
			}
			
			if(oldValue is TiledImage)
			{
				var image:TiledImage = TiledImage(oldValue);
				image.texture = texture;
			}
			else
			{
				image = new TiledImage(texture);
			}
			
			for(var propertyName:String in this._imageProperties)
			{
				if(image.hasOwnProperty(propertyName))
				{
					var propertyValue:Object = this._imageProperties[propertyName];
					image[propertyName] = propertyValue;
				}
			}
			
			return image;
		}
	}
}