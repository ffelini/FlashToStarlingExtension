package starlingExtensions.utils
{
import managers.Handlers;
import managers.sound.ManagerSound;

import starling.display.Button;
import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class TouchUtils
	{
		public function TouchUtils()
		{
		}
		public static function clicked(obj:DisplayObject,e:TouchEvent,considerEnabled:Boolean=true,upDelay:Number=10,sound:*=null):Touch
		{
			if(considerEnabled && obj is Button && !(obj as Button).enabled) return null;
			
			if(!obj || !obj.touchable) return null;
			
			var touch:Touch = e.getTouch(obj,TouchPhase.ENDED);
			
			if(!touch || !obj.hitTest(touch.getLocation(obj), true)) return null;
			
			if(sound) ManagerSound.playSound(sound);
			else Handlers.call(clicked,obj);
			
			return touch;
		}
	}
}