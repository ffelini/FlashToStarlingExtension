package starlingExtensions.utils
{
import flash.utils.setTimeout;

import managers.ObjPool;

import starling.animation.IAnimatable;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

import starlingExtensions.animation.TweenExtension;

public class TweenUtils
	{
		public function TweenUtils()
		{
		}
		public static function add(obj:DisplayObject,properties:Object,transition:String,duration:Number=1,start:Boolean=true,
								   removeAllTweens:Boolean=true,toProperties:Boolean=true,startDelay:Number=0,repeat:Boolean=false,
								   useObjPoolTween:Boolean=true):TweenExtension 
		{
			if(removeAllTweens) 
			{
				if(startDelay>0) setTimeout(removeTweens,startDelay,obj);
				else removeTweens(obj); 
			}
			var tween:TweenExtension = useObjPoolTween ? ObjPool.inst.get(TweenExtension,false) as TweenExtension : null;
			
			if(!tween) tween = new TweenExtension(obj,duration,transition);
			else tween.reset(obj,duration,transition);
			
			if(useObjPoolTween) tween.addEventListener(Event.REMOVE_FROM_JUGGLER, onPooledTweenComplete);
			
			for(var p:String in properties)
			{
				if(toProperties) tween.animate(p,properties[p]);
				else
				{
					tween.animate(p,obj[p]);
					obj[p] = properties[p];
				}
			}
			
			if(start) 
			{
				if(startDelay>0) setTimeout(play,startDelay,tween);
				else play(tween);
			}
			
			properties = null;
			
			return tween;
		}
		private static function onPooledTweenComplete(event:Event):void
		{
			ObjPool.inst.add(event.target,TweenExtension);
		}
		public static function play(object:IAnimatable):void
		{
			Starling.juggler.add(object);
		}
		public static function fadeIn(obj:DisplayObject,transition:String,duration:Number=1,start:Boolean=true,removeAllTweens:Boolean=true,startDelay:Number=0):TweenExtension 
		{
			return add(obj,{"alpha":1},transition,duration,start,removeAllTweens,true,startDelay);
		}
		public static function fadeOut(obj:DisplayObject,transition:String,duration:Number=1,start:Boolean=true,removeAllTweens:Boolean=true,startDelay:Number=0):TweenExtension 
		{
			return add(obj,{"alpha":0},transition,duration,start,removeAllTweens,true,startDelay);
		}
		public static function fadeInOut(obj:DisplayObject,transition:String,duration:Number=1,start:Boolean=true,removeAllTweens:Boolean=true,startDelay:Number=0):void
		{
			var t:Tween = fadeIn(obj,Transitions.EASE_IN,duration/2,false,removeAllTweens,startDelay);
			t.onComplete = fadeInComplete;
			t.onCompleteArgs = [obj,t];
			setTimeout(play,startDelay,t);
		}
		private static function fadeInComplete(obj:DisplayObject,targetTween:Tween):void
		{
			var t:Tween = fadeOut(obj,Transitions.EASE_IN,targetTween.totalTime,false,false);
			t.onComplete = fadeOutComplete;
			t.onCompleteArgs = [obj,t];
			play(t);
		}
		private static function fadeOutComplete(obj:DisplayObject,targetTween:Tween):void
		{
			var t:Tween = fadeIn(obj,Transitions.EASE_IN,targetTween.totalTime,false,false);
			t.onComplete = fadeInComplete;
			t.onCompleteArgs = [obj,t];
			play(t);
		}
		public static function removeTweens(...objects):void
		{
			for each(var obj:DisplayObject in objects)
			{
				Starling.juggler.removeTweens(obj);
			}
		}
	}
}