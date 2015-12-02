package starlingExtensions.flash.animation
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;

import managers.Handlers;

import starling.animation.Juggler;
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.MovieClip;
import starling.events.Event;
import starling.utils.deg2rad;

import starlingExtensions.animation.player.AnimationFrame;
import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.interfaces.IMovieClip;
import starlingExtensions.parsers.model.DisplayObjectProps;

import utils.Range;
import utils.TimeOut;
import utils.Utils;

/** Dispatched whenever the movie has displayed its last frame. */
	[Event(name="complete", type="starling.events.Event")]
	
	public class FlashMovieClip extends FlashSprite_Mirror implements IMovieClip,IClonable
	{
		private static const PLAY_MODE_NORMAL:String = "normal";
		private static const PLAY_MODE_RANGE:String = "range";
		
		public function FlashMovieClip(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null)
		{
			super(_mirror, _rootMirror);
			//DEBUG = true;
		}
		protected var flashMovieClip:flash.display.MovieClip;
		protected var flashMovieClipClassName:String;
		protected var _juggler:Juggler;
		override public function updateMirror(_mirror:DisplayObjectContainer=null, _rootMirror:FlashDisplay_Mirror=null):void
		{
			super.updateMirror(_mirror, _rootMirror);
			flashMovieClip = _mirror as flash.display.MovieClip;
			flashMovieClipClassName = getQualifiedClassName(flashMovieClip);
			
			autoPlay = rootMirror.autoPlayMovieClips || FlashDisplay_Converter.getFlashObjField(_mirror,"autoPlay")==true;
			
			_juggler = this.juggler ? this.juggler : Starling.current.juggler;
			
			var _numFrames:int = numFrames;
			
			var _fps:Number = flashMovieClip.hasOwnProperty("fps") ? flashMovieClip["fps"] : rootMirror.fps;
			mDefaultFrameDuration = 1.0 / _fps;
			
			mLoop = true;
			mPlaying = true;
			mCurrentTime = 0.0;
			mCurrentFrame = 0;
			mDurations = new Vector.<Number>(_numFrames);
			mStartTimes = new Vector.<Number>(_numFrames);
			
			for (var i:int=0; i<_numFrames; ++i)
			{
				mDurations[i] = mDefaultFrameDuration;
				mStartTimes[i] = i * mDefaultFrameDuration;
			}
		}
		override public function addChildAt(child:starling.display.DisplayObject, index:int):starling.display.DisplayObject
		{
			if(child is FlashMovieClip_Mirror)
			{
				(child as FlashMovieClip_Mirror).autoPlay = false;
			}
			return super.addChildAt(child, index);
		}
		override public function createChildren():void
		{
			super.createChildren();
			autoPlayClip();
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if(value) resume();
			else pause();
		}
		public var autoPlay:Boolean = false;
		public var autoPlayDelay:Number = 0;
		public var autoPlayDelayRange:Number = 0;
		public var randomFirstFrame:Boolean = false;
		public function autoPlayClip():void
		{
			if(autoPlayDelayRange>0) autoPlayDelay = randRange(0,autoPlayDelayRange);
			
			if(randomFirstFrame) randomizeCurentFrame();
			else if(autoPlayDelay>0) currentFrame = 0;
			
			if(autoPlay) playWithDelay(autoPlayDelay);
		}
		public function play():void
		{
			TimeOut.clearTimeOuts(play);
			
			super.visible = true;
			if(!autoAnimate) _juggler.add(this);
			
			reversePlaying = false;
			paused = false;
			mPlaying = true;
		}
		public function playRandomFrame():void
		{
			currentFrame = Utils.randRange(0,numFrames-1);
			play();
		}
		public function gotoAndPlay(frame:*):void
		{
			resetPlayMode();
			currentFrame = frame;
			play();
		}
		public function playReversible():void
		{
			play();
			reversePlaying = true;
		}
		// play mode 
		protected var _playMode:String;
		public function set playMode(value:String):void
		{
			_playMode = value;
		}
		public function get playMode():String
		{
			return _playMode;
		}
		public function resetPlayMode():void
		{
			playMode = PLAY_MODE_NORMAL;
		}
		protected var playRange:Range;
		public function playBetween(startFrame:int,endFrame:int,loop:Boolean=true):void
		{
			if(startFrame>endFrame || startFrame==endFrame || startFrame<0 || startFrame>numFrames-1 || endFrame<0 || endFrame>numFrames-1) return; 
			
			resetPlayMode();
			
			if(!playRange) playRange = new Range(-1,-1,false);
			currentFrame = startFrame;
			playRange.from = startFrame;
			playRange.to = endFrame;
			
			this.loop = loop;
			playMode = PLAY_MODE_RANGE;
			if(!isPlaying) play();
		}
		private var _playTill:int = -1;
		public function playTill(frame:*):void
		{
			resetPlayMode();
			_playTill = filterFrame(frame);
			play();
		}
		public function playWithDelay(delay:Number):void
		{
			if(delay>0) TimeOut.setTimeOutFunc(play,delay);
			else play();
		}
		public function next(step:int=1):void
		{
			currentFrame = currentFrame+step;
		}
		private function filterFrame(value:int):int
		{
			var _numFrames:int = numFrames;
			if(value>=_numFrames) return 0;
			if(value<0) value = _numFrames + value;
			if(value<0) return _numFrames-1;
			return value;
		}
		public function gotoAndStop(frame:*):void
		{
			resetPlayMode();
			var _hideOnStop:Boolean = hideOnStop;
			hideOnStop = false;
			
			stop();
			
			hideOnStop = _hideOnStop;
			
			currentFrame = frame;
		}
		public var hideOnStop:Boolean = true;
		public function stop():void
		{
			resetPlayMode();
			TimeOut.clearTimeOuts(play);
			
			if(!autoAnimate) _juggler.remove(this);
			currentFrame = 0;
			paused = false;
			
			if(hideOnStop) super.visible = false;
		}
		public var paused:Boolean = false;
		public function pause():void
		{
			if(!isPlaying) return;
			
			paused = true;
			mPlaying = false;
			TimeOut.clearTimeOuts(play);
		}
		public function resume():void
		{
			if(!mPlaying && paused) play(); 
		}
		protected function checkFrame():Boolean
		{
			//playTill
			if(_playTill>0 && mCurrentFrame>=_playTill)
			{
				mCurrentFrame = _playTill;
				_playTill = -1;
				pause();
				_complete = true;
			}
			//playMode
			if(_playMode==PLAY_MODE_RANGE)
			{
				_complete = mCurrentFrame>=playRange.to || (reversePlaying && mCurrentFrame<=playRange.from);
				if(mCurrentFrame>=playRange.to) mCurrentFrame = playRange.to;
				if(reversePlaying && mCurrentFrame<=playRange.from) mCurrentFrame = playRange.from;
			}
			else 
			{
				_complete = mCurrentFrame==numFrames-1 || (reversePlaying && mCurrentFrame<=0);
				if(reversePlaying && mCurrentFrame==0) mCurrentFrame = 0;
			}
			
			if(_complete) onComplete();
			
			return _complete;
		}
		protected var _frames:Vector.<AnimationFrame>;
		protected static var framesByClassName:Dictionary = new Dictionary();
		public var controlChildMovieClips:Boolean = true;
		public var targetAnimationFields:Object;
		protected function update(passedTime:Number=-1,newFrame:Boolean=true):void
		{
			var _numChildren:int = numChildren;
			var flashChild:flash.display.DisplayObject;
			var _mirror:starling.display.DisplayObject;
			
			// getting frames from the global frames repositoy by the flash movie clip class name
			if(!_frames) _frames = framesByClassName[flashMovieClipClassName];
			
			if(!_frames)
			{
				_frames = new Vector.<AnimationFrame>(numFrames,true);
				framesByClassName[flashMovieClipClassName] = _frames;
			}
			
			if(_frames[mCurrentFrame]) var frame:AnimationFrame = _frames[mCurrentFrame]; 
			else 
			{
				flashMovieClip.gotoAndStop(mCurrentFrame+1);
				frame = new AnimationFrame(numChildren,true);
				_frames[mCurrentFrame] = frame;
			} 
			var _numFrames:int = numFrames;
			
			for(var i:int=0;i<_numChildren;i++)
			{
				_mirror = getChildAt(i);
				flashChild = getMirror(_mirror);
				if(!flashChild) flashChild = flashMovieClip.getChildAt(i);
				
				if(_mirror && flashChild)
				{
					if(controlChildMovieClips && _mirror is FlashMovieClip_Mirror)
					{
						if(!newFrame) (_mirror as FlashMovieClip_Mirror).advanceTime(passedTime);
						else (_mirror as FlashMovieClip_Mirror).next();
					}
					if(newFrame)
					{	
						var objProps:DisplayObjectProps = frame.displayObjects[i] ? frame.displayObjects[i] : null;
						
						var childAlpha:Number = !objProps ? flashChild.alpha : objProps.alpha;
						
						if(childAlpha>0)
						{
							if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("x")) _mirror.x = !objProps ? flashChild.x : objProps.x;
							if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("y")) _mirror.y = !objProps ? flashChild.y : objProps.y;
							if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("alpha")) _mirror.alpha = childAlpha;
							
							if(!(_mirror is starling.display.MovieClip)) 
							{
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("width")) _mirror.width = !objProps ? flashChild.width : objProps.width;
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("height")) _mirror.height = !objProps ? flashChild.height : objProps.height;
							}
							
							if(objProps)
							{
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("skewX")) _mirror.skewX = objProps.skewX;
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("skewY")) _mirror.skewY = objProps.skewY;
							}
							else
							{
								var _skew:Array = FlashDisplay_Converter.getSkew(flashChild,false);
								
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("skewX")) _mirror.skewX = deg2rad(_skew[0]);
								if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("skewY")) _mirror.skewY = deg2rad(_skew[1]);
							}
							
							if(!targetAnimationFields || targetAnimationFields.hasOwnProperty("rotation"))
							{
								var absSkewX:Number = Math.abs(_mirror.skewX);
								var absSkewY:Number = Math.abs(_mirror.skewY);
								
								if(Math.round(absSkewX)==Math.round(absSkewY) || Math.round(absSkewX)+Math.round(absSkewY)==3.14) 
									_mirror.rotation = !objProps ? deg2rad(flashChild.rotation) : objProps.rotation;
							
							}
							//trace("FlashMovieClip.update()",visible,_complete,mCurrentFrame,mirror+"-"+mirror.visible+","+mirror.alpha,flashChild+"-"+flashChild.visible+","+flashChild.alpha);
						}
						else _mirror.alpha = childAlpha;
						
						if(!objProps) 
						{
							objProps = new DisplayObjectProps();
							objProps.x = flashChild.x;
							objProps.y = flashChild.y;
							objProps.alpha = flashChild.alpha;
							objProps.width = flashChild.width;
							objProps.height = flashChild.height;
							objProps.skewX = _mirror.skewX;
							objProps.skewY = _mirror.skewY;
							objProps.rotation = _mirror.rotation;
							
							frame.displayObjects[i] = objProps;
						}
					}
					if(_mirror is IFlashMovieClipChild) (_mirror as IFlashMovieClipChild).frameStep(mCurrentFrame,_numFrames);
				}
			}
		}
		protected var mDurations:Vector.<Number>;
		protected var mStartTimes:Vector.<Number>;
		
		protected var mDefaultFrameDuration:Number;
		protected var mCurrentTime:Number;
		protected var mCurrentFrame:int;
		protected var mLoop:Boolean;
		protected var mPlaying:Boolean;
		
		private function updateStartTimes():void
		{
			var numFrames:int = this.numFrames;
			
			mStartTimes.length = 0;
			mStartTimes[0] = 0;
			
			for (var i:int=1; i<numFrames; ++i)
				mStartTimes[i] = mStartTimes[int(i-1)] + mDurations[int(i-1)];
		}
		// IAnimatable
		
		/** @inheritDoc */
		/**
		 * controls animation on each render pass. Juggler is used only for reading the Juggler.curentPassedTime 
		 */		
		protected var autoAnimate:Boolean = false;
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			if(autoAnimate && _juggler ) advanceTime(_juggler.curentPassedTime);
		}
		public function getTotalTimeAt(frame:int):int
		{
			if(frame<0 || frame>numFrames-1) return 0;
			
			return mStartTimes[frame] + mDurations[frame]
		}
		private var reversePlaying:Boolean = false;
		public function advanceTime(passedTime:Number):void
		{
			if (!mPlaying || passedTime <= 0.0) return;
			
			if(DEBUG) trace("FlashMovieClip.advanceTime()",mirror,this,currentFrame);
			
			var finalFrame:int;
			var previousFrame:int = mCurrentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;
			var hasCompleteListener:Boolean = hasEventListener(Event.COMPLETE); 
			var dispatchCompleteEvent:Boolean = false;
			var totalTime:Number = this.totalTime;
			
			if(reversePlaying) 
			{
				if(playMode==PLAY_MODE_RANGE) passedTime = totalTime - getTotalTimeAt(playRange.to) - passedTime;
				else passedTime = totalTime - passedTime;
			}
			
			if (mLoop && mCurrentTime >= totalTime)
			{ 
				mCurrentTime = 0.0; 
				mCurrentFrame = 0; 
			}
			
			if (mCurrentTime < totalTime)
			{
				mCurrentTime += passedTime;
				finalFrame = flashMovieClip.totalFrames - 1;
				
				while (mCurrentTime > mStartTimes[mCurrentFrame] + mDurations[mCurrentFrame])
				{
					if (mCurrentFrame == finalFrame)
					{
						if (mLoop && !hasCompleteListener)
						{
							mCurrentTime -= totalTime;
							mCurrentFrame = 0;
						}
						else
						{
							breakAfterFrame = true;
							restTime = mCurrentTime - totalTime;
							dispatchCompleteEvent = hasCompleteListener;
							mCurrentFrame = finalFrame;
							mCurrentTime = totalTime;
						}
					}
					else
					{
						mCurrentFrame++;
					}
					
					if (breakAfterFrame) break;
				}
				
				// special case when we reach *exactly* the total time.
				if (mCurrentFrame == finalFrame && mCurrentTime == totalTime)
					dispatchCompleteEvent = hasCompleteListener;
			}
			
			if (dispatchCompleteEvent)
				dispatchEventWith(Event.COMPLETE);
			
			if (mLoop && restTime > 0.0)
				advanceTime(restTime);
			
			checkFrame();
			
			update(passedTime,mCurrentFrame != previousFrame);			
		}
		public var zigzagPlayMode:Boolean = false;
		public var hideOnComplete:Boolean = false;
		public var randomRepeatDelay:Boolean = false;
		public var repeatDelayRandomRange:Number = 3000;
		public var repeatDelay:Number = 0;
		public var randomLooping:Boolean = false;
		
		private var _complete:Boolean
		public var completeHandler:Function;
		public var stopToFirstFrameOnComplete:Boolean = false;
		protected function onComplete():void
		{
			reversePlaying = zigzagPlayMode ? !reversePlaying : false;
			
			if(!reversePlaying || !zigzagPlayMode)
			{
				Handlers.functionCall(completeHandler);
				if(hideOnComplete) visible = false;
				
				if(stopToFirstFrameOnComplete) stop();
				else 
				{
					pause();
					
					if(loop)
					{
						if(_playMode==PLAY_MODE_RANGE) currentFrame = playRange.from;
						else
						{
							repeatDelay = randomRepeatDelay ? randRange(repeatDelayRandomRange/4,repeatDelayRandomRange) : repeatDelay;
							if(randomLooping) randomizeCurentFrame();
						}
						
						playWithDelay(reversePlaying ? 0 : repeatDelay); 
					}
				}
			}
		}
		public function randomizeCurentFrame():void
		{
			currentFrame = randRange(0,numFrames-1);
		}
		/** Indicates if the clip is still playing. Returns <code>false</code> when the end 
		 *  is reached. */
		public function get isPlaying():Boolean 
		{
			if (mPlaying)
				return mLoop || mCurrentTime < totalTime;
			else
				return false;
		}
		/** Indicates if a (non-looping) movie has come to its end. */
		public function get isComplete():Boolean 
		{
			return !mLoop && mCurrentTime >= totalTime;
		}
		
		// properties  
		
		/** The total duration of the clip in seconds. */
		public function get totalTime():Number 
		{
			var _numFrames:int = flashMovieClip.totalFrames;
			return mStartTimes[int(_numFrames-1)] + mDurations[int(_numFrames-1)];
		}
		
		/** The time that has passed since the clip was started (each loop starts at zero). */
		public function get currentTime():Number { return mCurrentTime; }
		
		/** The total number of frames. */
		public function get numFrames():int { return flashMovieClip.totalFrames; }
		
		/** Indicates if the clip should loop. */
		public function get loop():Boolean { return mLoop; }
		public function set loop(value:Boolean):void { mLoop = value; }
		
		/** The index of the frame that is currently displayed. */
		public function get currentFrame():int { return mCurrentFrame; }
		public function set currentFrame(value:int):void
		{
			value = filterFrame(value);
			mCurrentFrame = value;
			mCurrentTime = 0.0;
			
			for (var i:int=0; i<value; ++i)
				mCurrentTime += getFrameDuration(i);
			
			update();
		}
		/** Returns the duration of a certain frame (in seconds). */
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return mDurations[frameID];
		}
		
		/** The default number of frames per second. Individual frames can have different 
		 *  durations. If you change the fps, the durations of all frames will be scaled 
		 *  relatively to the previous value. */
		public function get fps():Number { return 1.0 / mDefaultFrameDuration; }
		public function set fps(value:Number):void
		{
			if (value <= 0) throw new ArgumentError("Invalid fps: " + value);
			
			var newFrameDuration:Number = 1.0 / value;
			var acceleration:Number = newFrameDuration / mDefaultFrameDuration;
			mCurrentTime *= acceleration;
			mDefaultFrameDuration = newFrameDuration;
			
			for (var i:int=0; i<numFrames; ++i) 
			{
				var duration:Number = mDurations[i] * acceleration;
				mDurations[i] = duration;
			}
			
			updateStartTimes();
		}
		override public function clone():starling.display.DisplayObject
		{
			var c:FlashMovieClip = new FlashMovieClip(mirror,rootMirror);
			c.autoPlay = autoPlay;
			c.zigzagPlayMode = zigzagPlayMode;
			return c;
		}
		public static function randRange(minNum:Number, maxNum:Number,offset:Number=1):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + offset)) + minNum);
		}
	}
}