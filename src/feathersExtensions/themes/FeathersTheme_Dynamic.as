package feathersExtensions.themes
{
import feathers.core.DisplayListWatcher;

import starling.display.DisplayObjectContainer;

public class FeathersTheme_Dynamic extends DisplayListWatcher
	{
		public function FeathersTheme_Dynamic(topLevelContainer:DisplayObjectContainer)
		{
			super(topLevelContainer);
			
			setupAtlas();
			setupTheme();
			
			themeAtlas.updateAtlas(true);
		}
		protected var themeAtlas:FeathersThemeAtlas_Dynamic;
		protected function setupAtlas():void
		{
			
		}
		protected function setupTheme():void
		{
			
		}
	}
}