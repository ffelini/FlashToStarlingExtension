package feathersExtensions.controls
{
import feathers.controls.Callout;
import feathers.controls.Label;

import feathersExtensions.groups.SmartLayoutGroup;

import flash.geom.Point;

import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import utils.Range;

public class RangeSlider extends SmartLayoutGroup
	{
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		
		public var sliderPadding:Number = 5;
		public var direction:String = HORIZONTAL;
		public var liveDragging:Boolean = true;
		
		public function RangeSlider()
		{
			super();
		}
		override protected function initChildren():void
		{
			super.initChildren();
			
			if(!_thumb) thumb = _thumbFactory!=null ? _thumbFactory() : defaultThumbFactory();
			if(!_track) track = _trackFactory!=null ? _trackFactory() : defaultTrackFactory();
			if(!_title) title = _titleFactory!=null ? _titleFactory() : defaultTitleFactory();
			
			isQuickHitAreaEnabled = false;
			
			range = _range;
			targetRange = _targetRange;
			
			touchable = true;
		}
		protected var _step:Number = 1;
		protected function set step(value:Number):void
		{
			_step = value;
		}
		protected var _range:Range = new Range(0,100);
		public function set range(value:Range):void
		{
			_range = value;
			
			if(_title)
			{
				if(_title.hasOwnProperty("text")) _title["text"] = _titleLabelFunction!=null ? String(_titleLabelFunction(_range)) : defaultTitleLabelFunction(_range);
			}
		}
		protected var _targetRange:Range = new Range(0,100);
		public function set targetRange(value:Range):void
		{
			if(value==_targetRange) return;
			
			_targetRange = value;
			
			fromValue = _targetRange.from;
			toValue = _targetRange.to;
		}
		public function set fromValue(value:int):void
		{
			value = value>_range.to ? _range.to : (value<_range.from ? _range.from : value);
			
			if(value==_targetRange.from) return;
			
			_targetRange.from = value;
			updateThumb();
		}
		public function set toValue(value:int):void
		{
			value = value>_range.to ? _range.to : (value<_range.from ? _range.from : value);
			
			if(value==_targetRange.to) return;
			
			_targetRange.to = value;
			updateThumb();
		}
		public function get range():Range
		{
			return _targetRange;
		}
		
		protected var _title:DisplayObject;
		public function set title(value:DisplayObject):void
		{
			if(_title) _title.removeFromParent();
			
			_title = value;
			
			addChildAt(_title as DisplayObject,0);
		}
		protected var _titleFactory:Function;
		public function set titleFactory(value:Function):void
		{
			_titleFactory = value;
		}
		protected var _titleLabelFunction:Function;
		public function set titleLabelFunction(value:Function):void
		{
			_titleLabelFunction = value;
		}
		public static function defaultTitleLabelFunction(_range:Range):String
		{
			return _range.from + "..............." + Math.round(_range.from + (_range.to-_range.from)/2) + "..............." + _range.to;
		}
		protected var _track:DisplayObject;
		public function set track(value:DisplayObject):void
		{
			if(_track) _track.removeFromParent();
			
			_track = value;
			
			addChildAt(_track,0);
		}
		private static var p:Point = new Point();
		override protected function onTouch(e:TouchEvent):void
		{
			super.onTouch(e);
			var t:Touch = e.getTouch(this,TouchPhase.BEGAN);
			if(!t) return;

			stage.addEventListener(TouchEvent.TOUCH,stageTouchHandler);
			processTouch(t);
		}
		protected static var callOutLabel:Label;
		protected static var callOut:Callout;
		protected function processTouch(t:Touch):void
		{
			p = t.getLocation(this,p);
			
			var percentX:Number = p.x/width;
			var percentValue:Number = Math.round(percentX*(_range.to - _range.from));
			
			if(!callOutLabel) callOutLabel = new Label();
			
			var callOutDirection:String;
			if(p.x>_thumb.x+_thumb.width/2)
			{
				toValue = _range.from + percentValue;
				callOutLabel.text = _callOutLabelFunction!=null ? _callOutLabelFunction(_targetRange.to) : defaultCallOutLabelFunction(_targetRange.to);
				callOutDirection = Callout.DIRECTION_RIGHT;
			}
			else
			{
				fromValue = _range.from + percentValue;
				callOutLabel.text = _callOutLabelFunction!=null ? _callOutLabelFunction(_targetRange.from) : defaultCallOutLabelFunction(_targetRange.from);
				callOutDirection = Callout.DIRECTION_LEFT;				
			}
			if(!thumbUpdated) return;
			
			if(callOut) callOut.close(false);
			
			callOut = Callout.show(callOutLabel,_thumb,callOutDirection,false,callOut ? callOutFactory : null);
			callOutLabel.textRendererProperties.wordWrap = false;
			callOut.disposeContent = false;
			callOut.disposeOnSelfClose = false;
			
			thumbUpdated = false;
		}
		protected function callOutFactory():Callout
		{
			return callOut;
		}
		protected var _callOutLabelFunction:Function;
		public function set callOutLabelFunction(value:Function):void
		{
			_callOutLabelFunction = value;
		}
		public static function defaultCallOutLabelFunction(value:Number):String
		{
			return " " + value + " ";
		}
		protected var thumbUpdated:Boolean = false;
		protected function updateThumb():void
		{
			if(!_thumb) return;
			
			var rangeDiff:Number = _range.to - _range.from;
			var curentDiff:Number = _targetRange.to - _targetRange.from;
			var percentDiff:Number = curentDiff / rangeDiff;
			var fromPercent:Number = (_targetRange.from-_range.from)/rangeDiff;
			
			_thumb.x = sliderPadding/2 + ((width-sliderPadding/2)*fromPercent);
			_thumb.width = percentDiff*(width - sliderPadding);
			
			thumbUpdated = true;
		}
		private function stageTouchHandler(e:TouchEvent):void
		{
			var t:Touch = liveDragging ? e.getTouch(stage,TouchPhase.MOVED) : null;
			if(t) processTouch(t);
			else
			{
				t = e.getTouch(stage,TouchPhase.ENDED);
				if(!t) return;
				
				stage.removeEventListener(TouchEvent.TOUCH,stageTouchHandler);
				onValueChanged();
				
				if(callOut) callOut.close(false);
			}
		}
		protected var _trackFactory:Function;
		public function set trackFactory(value:Function):void
		{
			_trackFactory = value;
		}
		protected var _thumb:DisplayObject;
		public function set thumb(value:DisplayObject):void
		{
			if(_thumb) _thumb.removeFromParent();
			
			_thumb = value;
			_thumb.touchable = false;
			
			addChild(_thumb);
		}
		protected var _thumbFactory:Function;
		public function set thumbFactory(value:Function):void
		{
			_thumbFactory = value;
		}
		public static function defaultTrackFactory():Quad
		{
			return new Quad(100,100,0xF1B437);
		}
		public static function defaultThumbFactory():Quad
		{
			return new Quad(100,100,0xFFFFFF);
		}
		public static function defaultTitleFactory():Label
		{
			return new Label();
		}
		public var valueChangeHandler:Function;		
		protected function onValueChanged():void
		{
			if(_targetRange && valueChangeHandler!=null) valueChangeHandler();
		}
		override protected function validateSize():void
		{
			super.validateSize();
			if(_title)
			{
				_title.height = height/2;
				_title.y = 0;
				_title.x = width/2 - _title.width/2;
			}
			if(_track) 
			{
				_track.width = width;
				_track.height = height/2;
				_track.y = height - height/4 - _track.height/2;
			}
			if(_thumb)
			{
				_thumb.height = height/2 - sliderPadding;
				_thumb.y = height - height/4 - _thumb.height/2;
			}
			updateThumb();
		}
	}
}