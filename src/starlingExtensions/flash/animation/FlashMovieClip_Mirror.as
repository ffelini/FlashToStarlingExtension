package starlingExtensions.flash.animation {
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.getQualifiedClassName;

import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirror;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;

import managers.Handlers;

import starling.animation.Juggler;
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.MovieClip;
import starling.textures.Texture;

import starlingExtensions.flash.FlashDisplay_Mirror;
import starlingExtensions.flash.FlashSprite_Mirror;
import starlingExtensions.interfaces.IClonable;
import starlingExtensions.interfaces.IMovieClip;
import starlingExtensions.namespaceFlashConverter;

import utils.Range;
import utils.TimeOut;
import utils.Utils;

public class FlashMovieClip_Mirror extends starling.display.MovieClip implements IFlashMirror,IClonable,IMovieClip {
    public static var DEBUG:Boolean = false;

    private static const PLAY_MODE_NORMAL:String = "normal";
    private static const PLAY_MODE_RANGE:String = "range";

    public var mirror:flash.display.MovieClip;
    public var rootMirror:FlashDisplay_Mirror;

    public var subtextures:Vector.<SubtextureRegion>;

    public var zigzagPlayMode:Boolean = false;

    public var hideOnComplete:Boolean = false;
    public var randomRepeatDelay:Boolean = false;
    public var repeatDelayRandomRange:Number = 3000;
    public var repeatDelay:Number = 0;

    public var randomLooping:Boolean = false;

    protected var _created:Boolean = false;

    public function FlashMovieClip_Mirror(textures:Vector.<Texture>, fps:Number = 12, _mirror:flash.display.MovieClip = null, _rootMirror:FlashDisplay_Mirror = null, _subtextures:Vector.<SubtextureRegion> = null) {
        super(textures, fps);
        namespaceFlashConverter::updateMirror(_mirror, _rootMirror);

        subtextures = _subtextures;
    }

    public function setSource(source:FlashMovieClip_Mirror):void {
        init(source.mTextures, source.fps);
        subtextures = source.subtextures;
    }

    protected var juggler:Juggler;
    protected var mirrorClassName:String;

    namespaceFlashConverter function updateMirror(_mirror:flash.display.MovieClip = null, _rootMirror:FlashDisplay_Mirror = null):void {
        mirror = _mirror;
        mirrorClassName = getQualifiedClassName(_mirror);
        rootMirror = _rootMirror;

        juggler = rootMirror ? rootMirror.juggler : Starling.current.juggler;

        autoPlay = rootMirror && rootMirror.autoPlayMovieClips || FlashDisplay_Converter.getFlashObjField(_mirror, "autoPlay") == true;
        autoPlay = parent && parent is FlashMovieClip && (parent as FlashMovieClip).controlChildMovieClips ? false : autoPlay;
    }

    public function createChildren():void {
        _created = true;
        autoPlayClip();
    }

    public function validateChildrenCreation():void {
        if (!_created && rootMirror && rootMirror.created) createChildren();
    }

    public function get textures():Vector.<Texture> {
        return mTextures;
    }

    /**
     * controls animation on each render pass. Juggler is used only for reading the Juggler.curentPassedTime
     */
    protected var autoAnimate:Boolean = false;

    override public function render(support:RenderSupport, parentAlpha:Number):void {
        super.render(support, parentAlpha);
        if (autoAnimate && juggler) advanceTime(juggler.curentPassedTime);
    }

    public function getTotalTimeAt(frame:int):int {
        if (frame < 0 || frame > numFrames - 1) return 0;

        return mStartTimes[frame] + mDurations[frame]
    }

    private var reversePlaying:Boolean = false;

    override public function advanceTime(passedTime:Number):void {
        if (!mPlaying || passedTime <= 0.0) return;

        if (reversePlaying) {
            if (playMode == PLAY_MODE_RANGE) passedTime = totalTime - getTotalTimeAt(playRange.to) - passedTime;
            else passedTime = totalTime - passedTime;
        }

        super.advanceTime(passedTime);
        checkFrame();

        if (DEBUG) trace("FlashMovieClip_Mirror.advanceTime()", mirror, this, passedTime, mCurrentFrame, pivotX, pivotY, width, height, scaleX, scaleY);
    }

    protected function checkFrame():Boolean {
        //playTill
        if (_playTill > 0 && mCurrentFrame >= _playTill) {
            pause();
            currentFrame = _playTill;
            _playTill = -1;
            //_complete = true;
        }
        else {
            //playMode
            if (_playMode == PLAY_MODE_RANGE) {
                _complete = mCurrentFrame >= playRange.to || (reversePlaying && mCurrentFrame <= playRange.from);
                if (mCurrentFrame >= playRange.to) currentFrame = playRange.to;
                if (reversePlaying && mCurrentFrame <= playRange.from) currentFrame = playRange.from;
            }
            else {
                _complete = mCurrentFrame == numFrames - 1 || (reversePlaying && mCurrentFrame <= 0);
                if (reversePlaying && mCurrentFrame == 0) currentFrame = 0;
            }
        }

        if (_complete) onComplete();

        return _complete;
    }

    public function randomizeCurentFrame():int {
        currentFrame = randRange(0, numFrames - 1);
        return currentFrame;
    }

    public function gotoAndStopToRandomizedFrame():void {
        gotoAndStop(randomizeCurentFrame());
    }

    protected var _complete:Boolean;
    public var completeHandler:Function;
    public var stopToFirstFrameOnComplete:Boolean = false;

    protected function onComplete():void {
        reversePlaying = zigzagPlayMode ? !reversePlaying : false;

        if (!reversePlaying || !zigzagPlayMode) {
            Handlers.functionCall(completeHandler);
            if (hideOnComplete) visible = false;

            if (stopToFirstFrameOnComplete) stop();
            else {
                pause();

                if (loop) {
                    if (_playMode == PLAY_MODE_RANGE) currentFrame = playRange.from;
                    else {
                        repeatDelay = randomRepeatDelay ? randRange(repeatDelayRandomRange / 4, repeatDelayRandomRange) : repeatDelay;
                        if (randomLooping) randomizeCurentFrame();
                    }

                    playWithDelay(reversePlaying ? 0 : repeatDelay);
                }
            }
        }
    }

    private var _numFrames:int = 0;

    override public function set currentFrame(value:int):void {
        super.currentFrame = filterFrame(value);
    }

    public var useStarlingReadjustSizeMethod:Boolean = false;

    override public function set texture(value:Texture):void {
        //if(checkFrame()) value = textures[mCurrentFrame];

        super.texture = value;

        setupPivots();

        if (useStarlingReadjustSizeMethod) super.readjustSize();
        else readjustSize();
    }

    override public function readjustSize():void {
        var subTextureConf:SubtextureRegion = curentSubtextureRegion;

        var w:Number = subTextureConf ? subTextureConf.width * textureRegionScale : -1;
        var h:Number = subTextureConf ? subTextureConf.height * textureRegionScale : -1;

        if (w > 0 && h > 0) {
            mVertexData.setPosition(0, 0.0, 0.0);
            mVertexData.setPosition(1, w, 0.0);
            mVertexData.setPosition(2, 0.0, h);
            mVertexData.setPosition(3, w, h);

            onVertexDataChanged();
        }
        else {
            var frame:Rectangle = texture.frame;
            var width:Number = frame ? frame.width : texture.width;
            var height:Number = frame ? frame.height : texture.height;

            mVertexData.setPosition(0, 0.0, 0.0);
            mVertexData.setPosition(1, width, 0.0);
            mVertexData.setPosition(2, 0.0, height);
            mVertexData.setPosition(3, width, height);

            if (subTextureConf) {
                subTextureConf.width = frame.width;
                subTextureConf.height = frame.height;
            }

            onVertexDataChanged();
        }
    }

    public var textureRegionScale:Number = 1;
    private var pivotScaleX:Number = 1;
    private var pivotScaleY:Number = 1;

    protected function setupPivots():void {
        var subTextureConf:SubtextureRegion = curentSubtextureRegion;
        if (!subTextureConf) return;

        pivotX = (subTextureConf ? subTextureConf.pivotX * textureRegionScale : pivotX) / pivotScaleX;
        pivotY = (subTextureConf ? subTextureConf.pivotY * textureRegionScale : pivotY) / pivotScaleY;
    }

    private var _numSubtextureRegions:int;

    protected function get curentSubtextureRegion():SubtextureRegion {
        _numSubtextureRegions = subtextures.length;
        return subtextures ? (mCurrentFrame < _numSubtextureRegions ? subtextures[mCurrentFrame] : null) : null;
    }

    public function playFrame(frameLabel:String, stopOnNextLabel:Boolean = false, loops:int = 1):void {
        var subTexture:SubtextureRegion = subtextures[frameLabel];
        if (subTexture) gotoAndPlay(subtextures.indexOf(subTexture));
    }

    public function gotoAndPlay(frame:*):void {
        resetPlayMode();
        currentFrame = frame;
        play();
    }

    public function gotoAndStop(frame:*):void {
        resetPlayMode();
        var _hideOnStop:Boolean = hideOnStop;
        hideOnStop = false;

        stop();

        hideOnStop = _hideOnStop;

        currentFrame = frame;
    }

    private function filterFrame(value:int):int {
        var _numFrames:int = numFrames;
        if (value >= _numFrames) return 0;
        if (value < 0) value = _numFrames + value;
        if (value < 0) return _numFrames - 1;
        return value;
    }

    // play mode
    protected var _playMode:String;
    public function set playMode(value:String):void {
        _playMode = value;
    }

    public function get playMode():String {
        return _playMode;
    }

    public function resetPlayMode():void {
        _playTill = -1;
        playMode = PLAY_MODE_NORMAL;
    }

    protected var playRange:Range;

    public function playBetween(startFrame:int, endFrame:int, loop:Boolean = true):void {
        if (startFrame > endFrame || startFrame == endFrame || startFrame < 0 || startFrame > numFrames - 1 || endFrame < 0 || endFrame > numFrames - 1) return;

        resetPlayMode();
        if (!playRange) playRange = new Range(-1, -1, false);
        currentFrame = startFrame;
        playRange.from = startFrame;
        playRange.to = endFrame;

        this.loop = loop;
        playMode = PLAY_MODE_RANGE;
        if (!isPlaying) play();
    }

    protected var _playTill:int = -1;

    public function playTill(frame:*):void {
        resetPlayMode();
        _playTill = filterFrame(frame);
        play();
    }

    public var paused:Boolean = false;

    override public function pause():void {
        if (!isPlaying) return;

        paused = true;
        super.pause();
        TimeOut.clearTimeOuts(play);
    }

    public function resume():void {
        if (!mPlaying && paused) play();
    }

    public var autoPlay:Boolean = false;
    public var autoPlayDelay:Number = 0;
    public var autoPlayDelayRange:Number = 0;
    public var randomFirstFrame:Boolean = false;

    public function autoPlayClip():void {
        if (autoPlayDelayRange > 0) autoPlayDelay = randRange(0, autoPlayDelayRange);

        if (randomFirstFrame) randomizeCurentFrame();
        else if (autoPlayDelay > 0) currentFrame = 0;

        if (autoPlay) playWithDelay(autoPlayDelay);
    }

    protected function playWithDelay(delay:Number):void {
        if (delay > 0) TimeOut.setTimeOutFunc(play, delay);
        else play();
    }

    public function playReversible():void {
        play();
        reversePlaying = true;
    }

    override public function play():void {
        TimeOut.clearTimeOuts(play);
        reversePlaying = false;

        super.visible = true;
        super.play();
        paused = false;

        if (!autoAnimate) juggler.add(this);
    }

    public function playRandomFrame():void {
        currentFrame = Utils.randRange(0, numFrames - 1);
        play();
    }

    public var hideOnStop:Boolean = true;

    override public function stop():void {
        resetPlayMode();
        TimeOut.clearTimeOuts(play);

        super.stop();
        paused = false;

        if (!autoAnimate) juggler.remove(this);

        if (hideOnStop) super.visible = false;
    }

    public function next(step:int = 1):void {
        currentFrame = currentFrame + step;
    }

    override public function get hasVisibleArea():Boolean {
        validateChildrenCreation();
        return super.hasVisibleArea;
    }

    override public function set visible(value:Boolean):void {
        super.visible = value;
        if (value) validateChildrenCreation();

        if (value) resume();
        else pause();
    }

    public function get_created():Boolean {
        return _created;
    }

    public function get created():Boolean {
        return _created;
    }

    public function setupMirror():void {
    }

    public function clone():DisplayObject {
        var c:FlashMovieClip_Mirror = new FlashMovieClip_Mirror(mTextures, fps, mirror, rootMirror, subtextures);
        c.texture = texture;
        c.autoPlay = autoPlay;
        c.zigzagPlayMode = zigzagPlayMode;
        c.textureRegionScale = textureRegionScale;
        c.hideOnStop = hideOnStop;
        c.loop = loop;
        return c;
    }

    public static function randRange(minNum:Number, maxNum:Number, offset:Number = 1):Number {
        return (Math.floor(Math.random() * (maxNum - minNum + offset)) + minNum);
    }

    [Inline]
    public static function processAllMovieClips(container:DisplayObjectContainer, movieClipProcessFunction:*):void {
        var _numChildren:int = container.numChildren;
        var child:DisplayObject;

        for (var i:int = 0; i < _numChildren; i++) {
            child = container is FlashSprite_Mirror ? (container as FlashSprite_Mirror).fastGetChildAt(i) : container.getChildAt(i);

            if (child is IFlashMirror && !(child as IFlashMirror).get_created()) continue;

            if (child is DisplayObjectContainer) processAllMovieClips(child as DisplayObjectContainer, movieClipProcessFunction);
            else {
                if (child is IMovieClip || child is MovieClip) {
                    if (movieClipProcessFunction is String && child.hasOwnProperty(movieClipProcessFunction)) child[movieClipProcessFunction]();
                    else if (movieClipProcessFunction is Function) movieClipProcessFunction(child);
                }
            }
        }
    }
}
}