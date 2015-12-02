package starlingExtensions.flash.animation
{
import flash.display.MovieClip;

import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;

import starling.textures.Texture;

import starlingExtensions.flash.FlashDisplay_Mirror;

public class FlashMovieClip_CustomMirror extends FlashMovieClip_Mirror
	{
		public function FlashMovieClip_CustomMirror(textures:Vector.<Texture>, fps:Number=12, _mirror:MovieClip=null, _rootMirror:FlashDisplay_Mirror=null, _subtextures:Vector.<SubtextureRegion>=null)
		{
			super(textures, fps, _mirror, _rootMirror, _subtextures);
		}
		protected var frameLabelLoops:Array = [];
		protected var currentLoops:Array = [];
		protected var currentFrameLabel:String = "";
		public function loopFrame(frameLabel:String,loops:int):void
		{
			frameLabelLoops[frameLabel] = loops;
		}
		override public function advanceTime(passedTime:Number):void
		{
			if (!mPlaying || passedTime <= 0.0) return;
			
			super.advanceTime(passedTime);
			
			processLoops();			
		}
		protected function processLoops():void
		{
			var _frame:String = subtextures[currentFrame] ? subtextures[currentFrame].frameLabel : ""; 
			
			if(_frame!=currentFrameLabel && frameLabelLoops[_frame]>0)
			{
				if(!currentLoops[_frame]) currentLoops[_frame] = 1;
				else currentLoops[_frame]++;
				
				if(currentLoops[_frame]<frameLabelLoops[_frame])
				{
					playFrame(currentFrameLabel);
					return;
				}
				else currentLoops[_frame] = null;
			}
			currentFrameLabel = _frame;
		}
		override protected function onComplete():void
		{
			super.onComplete();
		}
	}
}