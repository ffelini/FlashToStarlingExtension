package managers.sound
{
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

public class SoundTemplate
	{
		public var transformsBySound:Dictionary = new Dictionary();		
		public var randomRangeBySound:Dictionary = new Dictionary();
				
		private var _playing:Boolean = false;
		public function get playing():Boolean
		{
			return _playing;
		}
		public var name:String = "";
		public var id:*;
		
		public static var soundsByKey:Dictionary = new Dictionary();
		public var keys:Array = [];
		
		public static const templates:Vector.<SoundTemplate> = new Vector.<SoundTemplate>();
		
		public function SoundTemplate(_name:String="",_id:*=-1)
		{
			name= _name;
			id = _id;
			templates.push(this);
		}
		public function addSound(value:*,loop:Boolean=false,soundTransform:SoundTransform=null,volume:Number=1,randomRange:Number=500):void
		{
			if(!value) return;
			
			var sound:Sound = value as Sound;
			var key:* = sound && sound.url!="" ? sound.url : value;
			soundsByKey[key] = value; 
			
			if(keys.indexOf(key)<0) keys.push(key);
			
			transformsBySound[key] = soundTransform;
			randomRangeBySound[key] = randomRange;
		}
		public static function getSound(key:*):Sound
		{
			var s:Sound = soundsByKey[key] as Sound;
			
			if(!s && key is Class) s = new key();
			registerSound(s,key);
			
			return s;
		}
		private static function registerSound(s:Sound,key:*):void
		{
			if(!s || !key) return;
			
			soundsByKey[s] = key;
			soundsByKey[key] = s;
		}
		public function play(resetPosition:Boolean=true):void
		{
			_paused = false; 
			
			if(_playing) return;
			
			for each(var key:* in keys)
			{
				playSound(getSound(key),resetPosition);
			}
			_playing = true;
		}
		public function stop(savePosition:Boolean=false):void
		{
			for each(var key:* in keys)
			{
				stopSound(key,savePosition);
			}
			_playing = false;
		}
		private var _paused:Boolean = false;
		public function pause():void
		{
			if(!_playing) return;
			
			stop(true);
			_paused = true;
		}
		public function resume():void
		{
			if(_paused) play(false);
		}
		public var _volume:Number = 1;
		public function setVolume(value:Number):void
		{
			_volume = value>=0 ? value : 0;
			for each(var key:* in keys)
			{
				var channels:Vector.<SoundChannel> = channelsBySound[soundsByKey[key]];
				for each(var channel:SoundChannel in channels)
				{
					if(channel)
					{
						var st:SoundTransform = channel.soundTransform;
						st.volume = _volume*_globalVolume;
						channel.soundTransform = st;				
					}
				}
			}
		}
		public function get volume():Number
		{
			return _volume;
		}
		protected static var _globalVolume:Number = 1;
		public static function setGlobalVolume(value:Number):void
		{
			_globalVolume = value;
			for each(var template:SoundTemplate in templates)
			{
				template.setVolume(template.volume);
			}
		}
		public static function get globalVolume():Number
		{
			return _globalVolume;
		}
		protected var progressBySound:Dictionary = new Dictionary();
		protected var channelsBySound:Dictionary = new Dictionary();
		protected var playBack:Dictionary = new Dictionary();
		protected function playSound(s:Sound,resetPosition:Boolean=true):SoundChannel
		{
			if(!s || !ON) return null;
			
			var st:SoundTransform = transformsBySound[s] ? transformsBySound[s] : transformsBySound[soundsByKey[s]];
			if(st) st.volume = _volume*globalVolume;
			else 
			{
				st = new SoundTransform(_volume*globalVolume);
				transformsBySound[s] = st;
			}
			var position:Number = resetPosition ? 0 : progressBySound[s];
			position = isNaN(position) ? 0 : position;
			
			var channel:SoundChannel = s.play(position,0,st);
			if(!channel) return channel;
			
			channel.addEventListener(Event.SOUND_COMPLETE,onLoopTime);
			
			var channels:Vector.<SoundChannel> = channelsBySound[s];
			if(!channels) 
			{
				channels = new Vector.<SoundChannel>();
				channelsBySound[s] = channels;
			}
			channels.push(channel);
			playBack[channel] = s;
			
			return channel;
		}
		private function stopSound(key:*,savePosition:Boolean=false):void
		{
			var sound:Sound = key is Sound ? key as Sound : soundsByKey[key] as Sound;
			if(!sound) return;
			
			var channels:Vector.<SoundChannel> = channelsBySound[sound];
			var numChannels:int = channels ? channels.length : 0;
			for(var i:int=numChannels-1;i>=0;i--)
			{
				var channel:SoundChannel = channels[i];
				progressBySound[sound] = channel.position;
				
				removeChannel(sound,channel);
				channel.stop();
			}
		}
		protected function onLoopTime(e:Event):void
		{
			var channel:SoundChannel = e.target as SoundChannel;
			removeChannel(s,channel);
			
			if(!_playing) return;
			
			var s:Sound = playBack[channel];
			
			delete playBack[channel];
			
			var randRange:Number = randomRangeBySound[soundsByKey[s]] ? randomRangeBySound[soundsByKey[s]] : 0;
			setTimeout(playSound,Math.round(Math.random()*randRange),s);
		}
		public function removeChannel(sound:Sound,channel:SoundChannel):void
		{
			if(!sound || !channel) return;
			
			channel.removeEventListener(Event.SOUND_COMPLETE,onLoopTime);
			
			var channels:Vector.<SoundChannel> = channelsBySound[sound];
			if(!channels) return;
			
			var i:int = channels.indexOf(channel);
			if(i>=0) channels.splice(i,1);	
			channel = null;
		}
		protected var _ON:Boolean = true;
		public function set ON(value:Boolean):void
		{
			_ON = value;
			if(_playing && !_ON) stop();
		}
		public function get ON():Boolean
		{
			return _ON;
		}
		public function toString():String
		{
			return " name-"+name+" playing-"+_playing+" volume-"+_volume+" ON-"+ON+" sounds"+keys.length;
		}
	}
}