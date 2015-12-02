package managers.sound
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.media.AudioPlaybackMode;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.utils.Dictionary;

public class ManagerSound extends EventDispatcher
	{
		public static var SOUND_ON:Boolean = true;
		public static var MUSIC_ON:Boolean = true;
		
		public static var DEBUG:Boolean = false;
		
		private static var soundTransformHelper:SoundTransform;
		
		public function ManagerSound(target:IEventDispatcher=null)
		{
			super(target);
			
			SoundMixer.audioPlaybackMode  =  AudioPlaybackMode.AMBIENT;
				
			soundTransformHelper = new SoundTransform();
		}
		public var templates:Vector.<SoundTemplate> = new Vector.<SoundTemplate>();
		public function addTemplate(value:SoundTemplate):void
		{
			templates.push(value);
		}
		public function stopAll():void
		{
			SoundMixer.stopAll();
		}
		public function reset():void
		{
			
		}
		public static function updateAll(play:Boolean,removeFromQue:Boolean=true):void
		{
			for each(var template:SoundTemplate in playBackCache)
			{
				if(template)
				{
					if(play) playTemplate(template,true);
					else stopTemplate(template,removeFromQue);
				}
			}
		}
		public static var currentTemplate:SoundTemplate;
		protected static var playBackCache:Dictionary = new Dictionary();
		public static function playTemplate(template:SoundTemplate,stopCurentTemplate:Boolean=true,playTemplateMultipleTimes:Boolean=false,setAsCurrent:Boolean=true):void
		{
			if(!template || !template.ON || (!playTemplateMultipleTimes && template.playing)) return;
			
			if(DEBUG) trace("SoundManager.playTemplate()",template);
			
			if(stopCurentTemplate) stopTemplate(currentTemplate,true);
			
			template.play();
			
			playBackCache[template] = template;
			if(setAsCurrent) currentTemplate = template;
		}
		public static function stopTemplate(template:SoundTemplate,removeFromQue:Boolean=true):void
		{
			if(!template || !template.playing) return;
			
			if(DEBUG) trace("SoundManager.stopTemplate()",template);
			
			template.stop();
			if(template==currentTemplate) currentTemplate = null;
			if(removeFromQue) delete playBackCache[template];
		}
		public static function toggleTemplates(_stopTemplate:SoundTemplate,_playTemplate:SoundTemplate):void
		{
			stopTemplate(_stopTemplate);
			playTemplate(_playTemplate,true);
		}
		/**
		 * 
		 * @param sound - a Sound or sound Class instance
		 * @param _volume
		 * @param forcePlaying - ignoring ON flags if true
		 * @param startTime
		 * @return 
		 * 
		 */		
		public static function playSound(sound:*,_volume:Number=-1,forcePlaying:Boolean=false, startTime:Number=0, loops:int=0):SoundChannel
		{
			if(!sound || (!SOUND_ON && !forcePlaying)) return null;
			
			var soundChannels:Vector.<SoundChannel> = soundChanneslBySound[sound];
			if(!soundChannels)
			{
				soundChannels = new Vector.<SoundChannel>();
				soundChanneslBySound[sound] = soundChannels;
			}
			
			if(!(sound is Sound)) sound = SoundTemplate.getSound(sound);
			
			if(!soundTransformHelper) soundTransformHelper = new SoundTransform();
			soundTransformHelper.volume = _volume*_globalVolume;
			
			var channel:SoundChannel = (sound as Sound).play(startTime, loops, soundTransformHelper);
			if(channel) channel.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
			
			soundChannels.push(channel);
			soundChanneslBySound[channel] = sound;
			
			return channel;
		}
		/**
		 * 
		 * @param sound - a Sound, SoundChannel or Class intance
		 * 
		 */		
		public static function stopSound(sound:*):void
		{
			var soundChannel:SoundChannel = sound as SoundChannel;
			if(soundChannel)
			{	
				soundChannel.stop();
				soundChannel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
				soundChannel = null;
			}
			else
			{
				var soundChannels:Vector.<SoundChannel> = soundChanneslBySound[sound];
				for each(var channel:SoundChannel in soundChannels)
				{
					channel.stop();
					channel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
				}
				if(soundChannels) soundChannels.length = 0;
			}
		}
		protected static var _globalVolume:Number = 1;
		public static function setGlobalVolume(value:Number,affectTemplates:Boolean=true):void
		{
			_globalVolume = value;
			if(affectTemplates) SoundTemplate.setGlobalVolume(value);
			
			for each(var channels:Object in soundChanneslBySound)
			{
				if(channels is Vector.<SoundChannel>)
				{
					for each(var channel:SoundChannel in (channels as Vector.<SoundChannel>))
					{
						if(!soundTransformHelper) soundTransformHelper = new SoundTransform();
						soundTransformHelper.volume = _globalVolume;
						channel.soundTransform = soundTransformHelper;
					}
				}
			}
		}
		public static function get globalVolume():Number
		{
			return _globalVolume;
		}
		private static var soundChanneslBySound:Dictionary = new Dictionary();
		protected static function onSoundComplete(event:Event):void
		{
			var channel:SoundChannel = event.target as SoundChannel;
			channel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
			
			var sound:Sound = soundChanneslBySound[channel];
			if(sound)
			{
				var soundChannels:Vector.<SoundChannel> = soundChanneslBySound[sound];
				var i:int = soundChannels ? soundChannels.indexOf(channel) : -1;
				if(i>=0) soundChannels.splice(i,1);
			}
		}
	}
}