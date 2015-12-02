package feathersExtensions.themes
{
import flash.display.DisplayObjectContainer;

import starlingExtensions.flash.textureAtlas.FlashAtlas_Dynamic;
import starlingExtensions.flash.textureAtlas.TextureAtlas_Dynamic;

public class FeathersThemeAtlas_Dynamic extends FlashAtlas_Dynamic
	{
		public function FeathersThemeAtlas_Dynamic()
		{
			super();	
			//debugAtlas = true;
		}
		override public function resetDescriptor():void
		{
			super.resetDescriptor();
			maxSize = 1024;
		}
		public function addFlashContent(includeAllMovieClipFrames:Boolean=true,...containers):void
		{
			var _updateAtlas:Boolean = autoUpdateAtlas;
			var _autoUpdateDelay:Number = autoUpdateDelay;
			
			autoUpdateDelay = 0;
			autoUpdateAtlas = false;
			
			for each (var doc:DisplayObjectContainer in containers)
			{
				addFlashContainer(doc,includeAllMovieClipFrames);
			}
			textureAtlas.updateAtlas(textureAtlas.get_atlas(),true);
			
			autoUpdateAtlas = _updateAtlas;
			autoUpdateDelay = _autoUpdateDelay;
		}
		private function addFlashContainer(doc:DisplayObjectContainer, includeAllMovieClipFrames:Boolean=true):void
		{
			if(!doc) return;
			var _numChildren:int = doc.numChildren;
			
			addChild(doc);
			
			for(var i:int=0;i<_numChildren;i++)
			{
				addRegion(doc.getChildAt(i),"",false,includeAllMovieClipFrames);
			}
		}
		public function get textureAtlas():TextureAtlas_Dynamic
		{
			return atlas ? atlas as TextureAtlas_Dynamic : getAtlas() as TextureAtlas_Dynamic;
		}
	}
}