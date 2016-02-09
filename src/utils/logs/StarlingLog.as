package utils.logs
{
import starling.core.Starling;

import utils.log;

public class StarlingLog extends FlashLogs
	{
		public function StarlingLog()
		{
			super();
			
			log(this,"Starling.contentScaleFactor-",Starling.contentScaleFactor);
			log(this,"Starling.current.nativeStage.stageWidth-",Starling.current.nativeStage.stageWidth);
			log(this,"Starling.current.nativeStage.stageHeight-",Starling.current.nativeStage.stageHeight);
			log(this,"Starling.current.nativeStage.fullScreenWidth-",Starling.current.nativeStage.fullScreenWidth);
			log(this,"Starling.current.nativeStage.fullScreenHeight-",Starling.current.nativeStage.fullScreenHeight);
			log(this,"Starling.current.nativeStage.width-",Starling.current.nativeStage.width);
			log(this,"Starling.current.nativeStage.height-",Starling.current.nativeStage.height);
			log(this,"Starling.current.nativeStage.allowsFullScreen-",Starling.current.nativeStage.allowsFullScreen);
			log(this,"Starling.current.nativeStage.autoOrients-",Starling.current.nativeStage.autoOrients);
			log(this,"Starling.current.contentScaleFactor-",Starling.current.contentScaleFactor);
			log(this,"Starling.current.profile-",Starling.current.profile);
			log(this,"Starling.current.viewPort-",Starling.current.viewPort);
			log(this,"Starling.current.stage.stageWidth-",Starling.current.stage.stageWidth);
			log(this,"Starling.current.stage.stageHeight-",Starling.current.stage.stageHeight);
			log(this,"Starling.current.stage.width-",Starling.current.stage.width);
			log(this,"Starling.current.stage.height-",Starling.current.stage.height);
			log(this,"Starling.current.supportHighResolutions-",Starling.current.supportHighResolutions);
		}
	}
}