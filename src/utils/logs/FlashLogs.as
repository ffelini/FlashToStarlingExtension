package utils.logs
{
import flash.system.Capabilities;

import utils.log;

public class FlashLogs
	{
		public function FlashLogs()
		{
			log(this,"Capabilities.os - "+Capabilities.os);
			log(this,"Capabilities.manufacturer - "+Capabilities.manufacturer);
			log(this,"Capabilities.version - "+Capabilities.version);
			log(this,"Capabilities.screenResolutionX-",Capabilities.screenResolutionX);
			log(this,"Capabilities.screenResolutionY-",Capabilities.screenResolutionY);
			log(this,"Capabilities.pixelAspectRatio-",Capabilities.pixelAspectRatio);
			log(this,"Capabilities.touchscreenType-",Capabilities.touchscreenType);
			log(this,"Capabilities.screenDPI-",Capabilities.screenDPI);
			log(this,"Capabilities.language-",Capabilities.language);
			log(this,"Capabilities.languages-",Capabilities.languages);
			log(this,"Capabilities.playerType-",Capabilities.playerType);
		}
	}
}