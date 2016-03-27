package starlingExtensions.flash {
import feathers.display.Scale3Image;
import feathers.display.Scale9Image;

import feathersExtensions.display.SmartScale3Image;
import feathersExtensions.display.SmartScale9Image;
import feathersExtensions.utils.TextureUtils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display3D.Context3DProfile;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;

import haxePort.starlingExtensions.flash.movieclipConverter.ConvertUtils;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashAtlas;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirror;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirrorRoot;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirrorRoot;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashSpriteMirror;
import haxePort.starlingExtensions.flash.movieclipConverter.MirrorDescriptor;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

import managers.Handlers;

import managers.ObjPool;
import managers.resourceManager.IResource;
import managers.resourceManager.ManagerRemoteResource;

import starling.animation.Juggler;
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.Button;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.ConcreteTexture;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.utils.VAlign;

import starlingExtensions.abstract.IOptimizedDisplayObject;
import starlingExtensions.batch.TextFieldBatch;
import starlingExtensions.containers.AdvancedSprite;
import starlingExtensions.decorators.DecoratorManger;
import starlingExtensions.decorators.Decorator_Button;
import starlingExtensions.flash.animation.FlashMovieClip;
import starlingExtensions.flash.animation.FlashMovieClip_Mirror;
import starlingExtensions.flash.animation.SmartJuggler;
import starlingExtensions.flash.movieclipConverter.ConvertDescriptor;
import starlingExtensions.flash.textureAtlas.ConcreteTexture_Dynamic;
import starlingExtensions.flash.textureAtlas.TextureAtlas_Dynamic;
import starlingExtensions.interfaces.IActivable;
import starlingExtensions.interfaces.IJugglerAnimator;
import starlingExtensions.namespaceFlashConverter;
import starlingExtensions.uiComponents.FlashLabelButton;
import starlingExtensions.uiComponents.SmartImage;
import starlingExtensions.uiComponents.SmartTextField;
import starlingExtensions.utils.deg2rad;

import utils.Memory;
import utils.ObjUtil;
import utils.log;
/**
 * The basic class that will represent a starling clone of an flash display intance.
 * The point of this class is to allow developers to use FLASH IDE as a graphical editor in the same old way but with GPU accelerated rendering provided by Starling.
 * As a developer you will have to extend this class and write the basic setup required for falsh converting.
 *
 * The basic classes for convertion are :
 * 1. Sprite - FlashSprite_Mirror
 * 2. MovieClip - FlashMovieClip_Mirror
 * 3. Shape, Bitmap, Group of shapes - Image
 * 4. Button - Button
 *
 * If you want to write your own components you will have to extend those classes ase they are base classes used for convertion.
 *
 * Basic template example
 * public class WelcomeLayer extends SplashScreeen
 * {
	 * 		public function WelcomeLayer()
	 * 		{			
	 * 			super();		
	 * 			scaleToCoordinateSystem = false;		
	 * 			autoPlayMovieClips = true;			
	 * 			fps = 15;	
	 * 		}
	 * 		// describing the convertion process
			override protected function setupConverter():void
	 * 		{
	 * 			super.setupConverter();
	 * 			convertDescriptor.associateClasses(LayerPopUpSplashScreen,PopUpLayer);
	 * 			convertDescriptor.associateClasses(WelcomeMC,UI_WelcomeMC);
	 * 		}	
	 * 		setting up the flash mirror
	 * 		override protected function setupMirror():void
	 * 		{
	 * 			mirror = flashMirror = new LayerWelcome();
	 *    		super.setupMirror();	
	 * 		}			
	 *      // registering instances
	 * 		override public function createChildren():void
	 * 		{		
	 * 			super.createChildren();	
	 * 			welcomeMC = getMirror(flashMirror.welcomeMC) as UI_WelcomeMC;
	 * 			playBtn = getMirror(flashMirror.controls.playBtn);	
	 * 			fbLoginBtn = getMirror(flashMirror.controls.fbLoginBtn);	
	 * 			settingsBtn = getMirror(flashMirror.controls.settingsBtn);		
	 * 			fairyGirl = getMirror(flashMirror.container.fairyGirl) as FlashMovieClip_Mirror;	
	 * 			waterDrop = getMirror(flashMirror.container.waterDrop) as FlashMovieClip_Mirror;	
	 * 		}
	 * }
 * @author peak
 *
 */
public class FlashDisplay_Mirror extends AdvancedSprite implements IActivable,IResource,IJugglerAnimator,IFlashMirrorRoot {
    /**
     * flash mirror instance
     */
    public var mirror:flash.display.DisplayObject;
    /**
     * flash mirror class instance. If this instance is set and there is no mirror instance then this class will be instantiated.
     */
    public var mirrorClass:Class;
    /**
     * if there is no mirror and no mirrorClass thsi url will be loaded as a source for the mirro flash display object.
     */
    public var mirrorSwfUrl:String;
    /**
     * as we extend AdvancedSprite class we may want to update layout after instance creates his children.
     */
    public var autoUpdateLayoutData:Boolean = true;

    /**
     * if true this instance will dispose and create automatically his textures when visible value will change
     */
    public var autoTextureActivation:Boolean = false;
    /**
     * deprecated flash. Don't use it
     */
    public var autoTextureBmdCompressToByteArray:Boolean = false;
    /**
     * if true this instance will automatically redraw his texture
     */
    public var redrawTextures:Boolean = true;

    public var disposeMirrorBitmaps:Boolean = true;
    public var clearShapes:Boolean = true;

    private var _childrenCreated:Boolean = false;
    private var _active:Boolean = false;

    /**
     * this value will be multiplied to the mirror size. Increase it to get better quality
     */
    public function set quality(value:Number):void {
        _quality = value;
    }

    protected var _quality:Number = 1;
    public function get quality():Number {
        return _quality;
    }

    public function set_quality(value:Number):Number {
        _quality = value;
        return _quality;
    }

    public function get_quality():Number {
        return _quality;
    }

    /**
     * if true all movieclips are automatically played
     */
    public var autoPlayMovieClips:Boolean = false;
    /**
     * framerate assigned to all movieclips by default
     */
    public var fps:Number = 24;
    /**
     * a Bitmap font instance that should be stored in order to set up textfields styles
     */
    public static var BITMAP_FONT:BitmapFont;

    public function FlashDisplay_Mirror() {
        super();

        setupConverter();

        initJuggler();
    }

    protected var useSmartScreenQuality:Boolean = true;

    protected function calculateScreenQuality():void {
        var smallestSideSize:Number = Math.min(AdvancedSprite.coordinateSystemRect.width, AdvancedSprite.coordinateSystemRect.height);
        quality = 1;//Capabilities.screenDPI > 200 ? 1 - (smallestSideSize/Capabilities.screenDPI/10) : 1;

        converter.useFeathersScaledImages = true;
        converter.removeGaps = smallestSideSize >= relativeRect.width / 2.5;
    }

    public var converter:FlashDisplay_Converter;

    protected function setupConverter():void {
        converter = new FlashDisplay_Converter();
        converter.convertDescriptor = new ConvertDescriptor();
        if (useSmartScreenQuality) calculateScreenQuality();
    }

    public function createTextureAtlasDynamic(atlas:TextureAtlasAbstract, atlasBmd:BitmapData):ITextureAtlasDynamic {
        var texture:ConcreteTexture_Dynamic = TextureUtils.textureFromBmd(atlasBmd, atlas.atlasRegionScale, null);
        var tAtlas:TextureAtlas_Dynamic = TextureUtils.getAtlas(texture, atlas);
        handleLostContext(tAtlas, true);
        storeAtlas(tAtlas, atlasBmd);
        return tAtlas;
    }

    public function saveAtlasPng(atlas:TextureAtlasAbstract, atlasBmd:BitmapData):void {
        TextureUtils.saveAtlasPng(atlas.imagePath, atlasBmd);
    }

    public function get convertDescriptor():ConvertDescriptor {
        return converter.convertDescriptor as ConvertDescriptor;
    }

    public function onDescriptorReset(descriptor:AtlasDescriptor):void {
    }

    public function convertSprite(sprite:flash.display.DisplayObjectContainer, spClass:Class):IFlashSpriteMirror {
        var result:IFlashSpriteMirror;
        if (FlashDisplay_Converter.isFlashMovieClip(sprite)) {
            result = spClass != null ? new spClass(sprite as MovieClip, this) : new FlashMovieClip(sprite as MovieClip, this);
            (sprite as MovieClip).stop();
        }
        else result = spClass != null ? new spClass(sprite, this) : new FlashSprite_Mirror(sprite, this);

        storeInstance(result, sprite);
        return result;
    }

    public function storeInstance(instance:*, _mirror:flash.display.DisplayObject, mirrorRect:Rectangle = null):void {
        //restoreMirror(_mirror);
        if (_childrenCreated) return;

        registerMirror(instance, _mirror);
        setupByMirror(instance as starling.display.DisplayObject, _mirror, false, mirrorRect);
    }

    protected var registerInstancesByClass:Boolean = false;
    protected var mirrors:Dictionary = new Dictionary();

    public function registerMirror(instance:*, _mirror:flash.display.DisplayObject):void {
        if (!_mirror || !instance) return;

        instance.name = _mirror.name;

        mirrors[_mirror] = instance;
        mirrors[instance] = _mirror;

        if (registerInstancesByClass) {
            registerInstance(getQualifiedClassName(instance), instance as starling.display.DisplayObject);
            if (instance is FlashMovieClip_Mirror) registerInstance(getQualifiedClassName(FlashMovieClip_Mirror), instance as starling.display.DisplayObject);
        }
    }

    protected var instancesByClass:Dictionary = new Dictionary();

    protected function registerInstance(key:String, instance:starling.display.DisplayObject):void {
        var instances:Vector.<starling.display.DisplayObject> = getInstances(key);
        if (!instances) {
            instances = new Vector.<starling.display.DisplayObject>();
            instancesByClass[key] = instances;
        }
        if (instances.indexOf(instance) < 0) instances.push(instance);
    }

    public function getInstances(className:String):Vector.<starling.display.DisplayObject> {
        return instancesByClass[className];
    }

    public function getMirror(mirror:*):* {
        //trace("FlashDisplay_Mirror.getMirror(mirror)",mirror,mirrors[mirror]);
        var m:* = mirrors[mirror];
        if (m is IFlashMirror) (m as IFlashMirror).validateChildrenCreation();
        return m;
    }

    override public function getChildAt(index:int):starling.display.DisplayObject {
        var c:starling.display.DisplayObject = super.getChildAt(index);
        if (c is IFlashMirror) (c as IFlashMirror).validateChildrenCreation();
        return c;
    }

    override public function getChildByName(name:String):starling.display.DisplayObject {
        var c:starling.display.DisplayObject = super.getChildByName(name);
        if (c is IFlashMirror) (c as IFlashMirror).validateChildrenCreation();
        return c;
    }

    namespaceFlashConverter static var atlasesAndBmd:Dictionary = new Dictionary();

    public function storeAtlas(atlas:ITextureAtlasDynamic, bmd:BitmapData):void {
        handleLostContext(atlas as TextureAtlas_Dynamic, true);

        if (bmd) {
            if (redrawTextures) {
                ObjUtil.dispose(bmd);
                bmd = null;
            }
            else if (!autoTextureBmdCompressToByteArray) namespaceFlashConverter::atlasesAndBmd[atlas] = bmd;
            else {
                var ba:ByteArray = bmd.getPixels(bmd.rect);
                ba.compress();
                namespaceFlashConverter::atlasesAndBmd[atlas] = ba;
                namespaceFlashConverter::atlasesAndBmd[ba] = bmd.rect;

                ObjUtil.dispose(bmd);
                bmd = null;
            }
        }
    }

    public var textfieldsBatchSprite:TextFieldBatch = new TextFieldBatch();
    protected var _batchTextFields:Boolean = Capabilities.isDebugger;
    /**
     * flasg that controls textfields batching. Required to be set before createChildren call
     */
    public function set batchTextFields(value:Boolean):void {
        _batchTextFields = value;

        if (value) addChild(textfieldsBatchSprite);
        else textfieldsBatchSprite.removeFromParent();
    }

    public function get batchTextFields():Boolean {
        return _batchTextFields;
    }

    public function onChildrenCreationComplete():void {
        var t:Number = getTimer();
        if (autoUpdateLayoutData) updateLayoutData();
        log(this, "updateLayoutData duration-" + (getTimer() - t));

        batchTextFields = _batchTextFields;
        _childrenCreated = true;
    }

    public function createChild(flashChild:flash.display.DisplayObject, childClass:Class):void {
        var downSubtext:SubtextureRegion;
        var upSubtext:SubtextureRegion;
        var downT:Texture;
        var upT:Texture;

        var subTexture:SubtextureRegion = _descriptor.getSubtexture(flashChild);
        if (subTexture == null) {
            var subTextures:Vector.<SubtextureRegion> = _descriptor.getSubtextures(flashChild);
            subTexture = subTextures ? subTextures[0] : null;
        }

        // checking if subTextures frameLabels matches to an button
        if (subTextures && subTextures.length == 2) {
            downSubtext = subTexture.frameLabel == ConvertUtils.BUTTON_KEYFRAME_DOWN ? subTexture : (subTextures[1].frameLabel == ConvertUtils.BUTTON_KEYFRAME_DOWN ? subTextures[1] : null);
            upSubtext = subTexture.frameLabel == ConvertUtils.BUTTON_KEYFRAME_UP ? subTexture : (subTextures[1].frameLabel == ConvertUtils.BUTTON_KEYFRAME_UP ? subTextures[1] : null);
        }

        downT = downSubtext ? getSubtextureByName(downSubtext.name, downSubtext.symbolName) : null;
        upT = upSubtext ? getSubtextureByName(upSubtext.name, upSubtext.symbolName) : null;

        if ((downT && upT && (flashChild is SimpleButton || flashChild is MovieClip)) || ObjUtil.isExtensionOf(childClass, Button)) {
            createButton(flashChild as MovieClip, childClass);
        }
        else if (converter.isMovieClip(flashChild as MovieClip)) {
            createMovieClip(flashChild as MovieClip, childClass);
        }
        else if (flashChild is flash.text.TextField) {
            createTextField(flashChild as flash.text.TextField, childClass);
        }
        else {
            var _mirrorType:String = FlashDisplay_Converter.getFlashObjType(flashChild);
            if (_mirrorType == ConvertUtils.TYPE_SCALE3_IMAGE) {
                var direction:String = FlashDisplay_Converter.getFlashObjField(flashChild, "direction");
                createScale3Image(flashChild, childClass, direction);
            }
            else if (_mirrorType == ConvertUtils.TYPE_SCALE9_IMAGE) {
                createScale9Image(flashChild, childClass);
            }
            else if (_mirrorType == ConvertUtils.TYPE_QUAD) {
                var _color:uint = FlashDisplay_Converter.getFlashObjField(flashChild, "color");
                if (isNaN(_color)) _color = 0xFFFFFF;
                var quadAlpha:Number = FlashDisplay_Converter.getFlashObjField(flashChild, "quadAlpha");
                if (isNaN(quadAlpha)) quadAlpha = 1;

                createQuad(flashChild, childClass, _color, quadAlpha);
            }
            else {
                createImage(flashChild, childClass);
            }
        }
    }

    private function getSubTexture(flashChild:flash.display.DisplayObject):Texture {
        var subTexture:SubtextureRegion = _descriptor.getSubtexture(flashChild);
        if (subTexture == null) {
            var subTextures:Vector.<SubtextureRegion> = _descriptor.getSubtextures(flashChild);
            subTexture = subTextures ? subTextures[0] : null;
        }

        var t:Texture = subTexture ? getSubtextureByName(subTexture.name, subTexture.symbolName) : null;

        if (converter.debug) {
            log(this, "getSubTexture", flashChild, "subTexture.name - " + subTexture.name, "subTexture.symbolName - " + subTexture.symbolName, "t - " + t);
        }

        t = t ? t : Texture.fromColor(2, 2, 0xCCCCCC, true, 1);
        var _mirrorType:String = FlashDisplay_Converter.getFlashObjType(flashChild);

        if (_mirrorType == ConvertUtils.TYPE_PRIMITIVE) {
            var extrusion:Number = FlashDisplay_Converter.getFlashObjField(flashChild, ConvertUtils.FIELD_EXTRUSION_FACTOR);
            extrusion = !isNaN(extrusion) || extrusion < 100 ? extrusion : 100;
            t = TextureAtlas_Dynamic.extrudeTexture(t, null, null, extrusion);
        }
        t = t ? t : Texture.fromColor(2, 2, 0xCCCCCC, true, 1);
        return t;
    }

    private function getSubTexturesByFlashInstance(flashChild:flash.display.DisplayObject):Vector.<Texture> {
        var subTexture:SubtextureRegion = _descriptor.getSubtexture(flashChild);
        if (subTexture == null) {
            var subTextures:Vector.<SubtextureRegion> = _descriptor.getSubtextures(flashChild);
            subTexture = subTextures ? subTextures[0] : null;
        }
        var _subtextures:Vector.<Texture> = getSubtextures(subTexture.name, subTexture.symbolName);
        return _subtextures;
    }

    public function onChildCreated(flashChild:flash.display.DisplayObject, resultObj:starling.display.DisplayObject):void {
        if (!resultObj.parent) {
            var _mirrorIndex:int = flashChild.parent ? flashChild.parent.getChildIndex(flashChild) : -1;
            var _parent:starling.display.DisplayObjectContainer = getMirror(flashChild.parent);
            _parent.addChildAt(resultObj, _mirrorIndex);

            ObjUtil.registerInstance(_parent, resultObj);

            if (converter.isEconomicButton(flashChild as MovieClip) && !(resultObj.parent is FlashLabelButton)) {
                DecoratorManger.decorate(Decorator_Button, resultObj, true);
            }
        }
        storeInstance(resultObj, flashChild);
    }

    public function createTextField(flashTextField:flash.text.TextField, childClass:Class):void {
        var field:flash.text.TextField = flashTextField as flash.text.TextField;
        var tf:TextFormat = field.defaultTextFormat;

        var resultObj:starling.text.TextField = childClass ? new childClass(field.width, field.height, field.text, tf.font, int(tf.size), uint(tf.color), Boolean(tf.bold)) :
                new SmartTextField(field.width, field.height, field.text, BITMAP_FONT ? BITMAP_FONT.name : tf.font, int(tf.size), uint(tf.color), Boolean(tf.bold));

        (resultObj as starling.text.TextField).autoScale = true;
        (resultObj as starling.text.TextField).hAlign = tf.align;
        (resultObj as starling.text.TextField).vAlign = VAlign.CENTER;
        resultObj.touchable = false;
        onChildCreated(flashTextField, resultObj);
    }

    public function createScale9Image(flashImage:flash.display.DisplayObject, childClass:Class):void {
        var t:Texture = getSubTexture(flashImage);
        var resultObj:SmartScale9Image = new SmartScale9Image(TextureUtils.scale9Textures(t));
        onChildCreated(flashImage, resultObj);
    }

    public function createScale3Image(flashImage:flash.display.DisplayObject, childClass:Class, direction:String):void {
        var t:Texture = getSubTexture(flashImage);
        var resultObj:SmartScale3Image = new SmartScale3Image(TextureUtils.scale3Textures(t, direction));
        onChildCreated(flashImage, resultObj);
    }

    public function createQuad(flashImage:flash.display.DisplayObject, childClass:Class, color:uint, quadAlpha:Number):void {
        var resultObj:Quad = new Quad(100, 100, color);
        resultObj.alpha = quadAlpha;
        onChildCreated(flashImage, resultObj);
    }

    public function createMovieClip(flashMovieClip:MovieClip, childClass:Class):void {
        if (ObjUtil.isExtensionOf(childClass, Button)) {
            createButton(flashMovieClip, childClass);
            return;
        }
        var subTexture:SubtextureRegion = _descriptor.getSubtexture(flashMovieClip);
        var subTextures:Vector.<SubtextureRegion> = _descriptor.getSubtextures(flashMovieClip);
        if (subTexture == null) {
            subTexture = subTextures ? subTextures[0] : null;
        }

        var _subtextures:Vector.<Texture> = getSubTexturesByFlashInstance(flashMovieClip);
        var _fps:Number = FlashDisplay_Converter.getFlashObjField(flashMovieClip, ConvertUtils.FIELD_FPS, fps);
        var resultObj:starling.display.MovieClip = childClass ? new childClass(_subtextures, _fps, flashMovieClip, this, subTextures) :
                new FlashMovieClip_Mirror(_subtextures, _fps, flashMovieClip, this, subTextures);

        (resultObj as FlashMovieClip_Mirror).textureRegionScale = subTexture.parent.atlasRegionScale;
        onChildCreated(flashMovieClip, resultObj);
    }

    public function createImage(flashImage:flash.display.DisplayObject, childClass:Class):void {
        childClass = ObjUtil.isExtensionOf(childClass, Image) ? childClass : SmartImage;
        var t:Texture = getSubTexture(flashImage);
        var resultObj:Image = new childClass(t);
        (resultObj as Image).readjustSize();
        onChildCreated(flashImage, resultObj);
    }

    public function createButton(flashButton:MovieClip, childClass:Class):void {

        var downSubtext:SubtextureRegion;
        var upSubtext:SubtextureRegion;
        var subTexture:SubtextureRegion = _descriptor.getSubtexture(flashButton);
        if (subTexture == null) {
            var subTextures:Vector.<SubtextureRegion> = _descriptor.getSubtextures(flashButton);
            subTexture = subTextures ? subTextures[0] : null;
        }

        // checking if subTextures frameLabels matches to an button
        if (subTextures && subTextures.length == 2) {
            downSubtext = subTexture.frameLabel == ConvertUtils.BUTTON_KEYFRAME_DOWN ? subTexture : (subTextures[1].frameLabel == ConvertUtils.BUTTON_KEYFRAME_DOWN ? subTextures[1] : null);
            upSubtext = subTexture.frameLabel == ConvertUtils.BUTTON_KEYFRAME_UP ? subTexture : (subTextures[1].frameLabel == ConvertUtils.BUTTON_KEYFRAME_UP ? subTextures[1] : null);
        }

        var t:Texture = subTexture ? getSubtextureByName(subTexture.name, subTexture.symbolName) : null;
        var downT:Texture = downSubtext ? getSubtextureByName(downSubtext.name, downSubtext.symbolName) : null;
        var upT:Texture = upSubtext ? getSubtextureByName(upSubtext.name, upSubtext.symbolName) : null;

        upT = upT ? upT : t;
        downT = downT ? downT : t;

        var resultObj:Button = childClass ? new childClass(upT, "", downT) : new Button(upT, "", downT);
        onChildCreated(flashButton, resultObj);
    }

    private static var sharedMirrors:Vector.<FlashDisplay_Mirror> = new <FlashDisplay_Mirror>[];

    public function getSubtextureByName(name:String, symbolName:String):SubTexture {
        var st:SubTexture = _descriptor.getConf(name + "_subtexture") as SubTexture;
        if (st) return st;

        for each(var atlas:TextureAtlas_Dynamic in _descriptor.textureAtlases) {
            st = atlas.getTexture(name) as SubTexture;
            if (st) {
                _descriptor.setConf(name + "_subtexture", st);
                _descriptor.setConf(st, atlas);
                return st;
            }
        }
        if (st == null) {
            for each(var mirror:FlashDisplay_Mirror in sharedMirrors) {
                st = mirror.getSubtextureByName(name, symbolName);
                if (st) {
                    _descriptor.setConf(name + "_subtexture", st);
                    _descriptor.setConf(st, atlas);
                    return st;
                }
            }
        }
        return st;
    }

    public function getSubtextures(name:String, symbolName:String):Vector.<Texture> {
        var st:Vector.<Texture> = _descriptor.getConf(symbolName + "_subtextures") as Vector.<Texture>;
        if (st) return st;

        var _st:Vector.<Texture>;
        for each(var atlas:TextureAtlas_Dynamic in _descriptor.textureAtlases) {
            _st = atlas.getTextures(symbolName);
            for each(var t:Texture in _st) {
                _descriptor.setConf(t, atlas);
            }
            st = st ? st.concat(_st) : _st.concat();
        }

        if (st == null || st.length == 0) {
            for each(var mirror:FlashDisplay_Mirror in sharedMirrors) {
                _st = mirror.getSubtextures(name, symbolName);
                st = st ? st.concat(_st) : _st.concat();
            }
        }
        if(st != null) {
            st = st.sort(sortSubTextures);
        }

        log(this, "sortSubTextures name="+name+" symbolName="+symbolName, st.toString().split("SubTexture").join("\nSubTexture"));

        _descriptor.setConf(symbolName + "_subtextures", st);

        return st;
    }

    private function sortSubTextures(subTextureA:SubTexture, subTextureB:SubTexture):Number {
        var frameA:int = parseInt(subTextureA.name.split("_")[1]);
        var frameB:int = parseInt(subTextureB.name.split("_")[1]);
        return frameA > frameB ? 1 : (frameA < frameB ? -1 : 0);
    }

    public static function isCreated(instance:starling.display.DisplayObject):Boolean {
        if (instance is FlashSprite_Mirror && (instance as FlashSprite_Mirror).created) return true;
        if (instance is FlashMovieClip_Mirror && (instance as FlashMovieClip_Mirror).created) return true;
        if (instance.parent is FlashSprite_Mirror && (instance.parent as FlashSprite_Mirror).created) return true;
        if (instance.parent is FlashMovieClip_Mirror && (instance.parent as FlashMovieClip_Mirror).created) return true;

        return false;
    }

    public function getMirrorRect(_mirror:*):Rectangle {
        if (!(_mirror is flash.display.DisplayObject)) _mirror = getMirror(_mirror);
        return _descriptor.mirrorRects[_mirror];
    }

    private function setupByMirror(instance:starling.display.DisplayObject, _mirror:flash.display.DisplayObject, checkCreation:Boolean = false, mirrorRect:Rectangle = null):void {
        if (instance == this || !instance || !_mirror || (checkCreation && isCreated(instance))) return;

        // applying transformation and original datas
        if (!mirrorRect) mirrorRect = _descriptor.mirrorRects[_mirror] ? _descriptor.mirrorRects[_mirror] : _mirror.getBounds(_mirror.parent);

        //restoreMirror(_mirror);

        instance.name = _mirror.name;

        var isSimpleSprite:Boolean = instance is starling.display.Sprite && !(instance is Scale3Image) && !(instance is Scale9Image);

        instance.x = Math.round(isSimpleSprite ? _mirror.x : mirrorRect.x);
        instance.y = Math.round(isSimpleSprite ? _mirror.y : mirrorRect.y);

        if (instance is IOptimizedDisplayObject) (instance as IOptimizedDisplayObject).setSize(Math.round(mirrorRect.width), Math.round(mirrorRect.height));
        else {
            instance.width = Math.round(mirrorRect.width);
            instance.height = Math.round(mirrorRect.height);
        }
        var _skew:Array = FlashDisplay_Converter.getSkew(_mirror);
        var sx:Number = _skew[0];
        var sy:Number = _skew[1];

        var skewX:Number = deg2rad(sx);
        var skewY:Number = deg2rad(sy);

        if (isSimpleSprite) {
            if (Math.round(skewX) == Math.round(skewY) || Math.round(sx) + Math.round(sy) == 360)
                instance.rotation = deg2rad(_mirror.rotation);
            else {
                instance.skewX = skewX;
                instance.skewY = skewY;
            }

            instance.scaleX = _mirror[ConvertUtils.FIELD_DEFAULT_SCALEX] ? _mirror[ConvertUtils.FIELD_DEFAULT_SCALEX] : _mirror.scaleX;
            instance.scaleY = _mirror[ConvertUtils.FIELD_DEFAULT_SCALEY] ? _mirror[ConvertUtils.FIELD_DEFAULT_SCALEY] : _mirror.scaleY;
            instance.touchable = (_mirror as flash.display.DisplayObjectContainer).mouseEnabled;
        }
        else {
            instance.skewX = skewX;
            instance.skewY = skewY;

            instance.x += mirrorRect.width * (instance.skewY / 3.14);
            instance.y += mirrorRect.height * (instance.skewX / 3.14);
            instance.x = Math.round(instance.x);
            instance.y = Math.round(instance.y);
        }

        ObjUtil.cloneFields(_mirror, instance);

        // disposing unneded content
        if (_mirror is Bitmap && disposeMirrorBitmaps && !redrawTextures) {
            ObjUtil.dispose(_mirror);
            _mirror = null;
        }
        if (_mirror is Shape && clearShapes && !redrawTextures) {
            ObjUtil.dispose(_mirror);
            _mirror = null;
        }
        // registering mirrors for intances goten from ObjPool
        if (instance is FlashSprite_Mirror) (instance as FlashSprite_Mirror).updateMirror(_mirror as flash.display.DisplayObjectContainer, this);
        if (instance is FlashMovieClip_Mirror) (instance as FlashMovieClip_Mirror).namespaceFlashConverter::updateMirror(_mirror as MovieClip, this);
    }

    /**
     * override this methods to pass the flash mirror, mirrorClass or mirrorSwfUrl as the soruce for converting
     *
     */
    protected function setupMirror():void {
        if (mirror) return;

        if (mirrorClass) mirror = new mirrorClass();
        else {
            mirror = ManagerRemoteResource.getResource(mirrorSwfUrl);
            if (!mirror) refreshSource(mirrorSwfUrl);
        }
        registerMirror(this, mirror);

    }

    public function refreshSource(url:String, refreshWaitStack:Boolean = false):void {
        var source:* = ManagerRemoteResource.getResource(url);
        if (source) visible = true;
        else {
            ManagerRemoteResource.addToWaitStack(url, this);
            if (source != ManagerRemoteResource.LOADING) ManagerRemoteResource.loadResource(url);
        }
    }

    public var _juggler:SmartJuggler;

    protected function initJuggler():void {
        _juggler = new SmartJuggler();
    }

    public function get juggler():Juggler {
        if (!_juggler) _juggler = new SmartJuggler();
        return _juggler;
    }

    public var creationRenderCounter:int = 0;
    protected var numFramesTillFirstActivation:int = 1;

    override public function render(support:RenderSupport, parentAlpha:Number):void {
        super.render(support, parentAlpha);
        if (creationRenderCounter <= numFramesTillFirstActivation && created) {
            creationRenderCounter++;
            if (creationRenderCounter > numFramesTillFirstActivation && visible && !active) activate(true);
        }
    }

    /**
     * This instance is creating himself when becomes visible
     * @param value
     *
     */
    override public function set visible(value:Boolean):void {
        if (value == visible) return;
        super.visible = value;

        if (visible && !mirror) {
            log(this, "before setupMirror", Memory.privateMemory, Memory.totalMemory);

            setupMirror();

            log(this, "after setupMirror", Memory.privateMemory, Memory.totalMemory);
        }
        if (!mirror) {
            super.visible = false;
            return;
        }
        if (visible && mirror && !_childrenCreated) {
            convertFlashMirror();
        }

        if (creationRenderCounter > 1) activate(visible);

        touchable = visible;
    }

    private function convertFlashMirror():void {
        TextureAtlas_Dynamic.debug = converter.debug;
        registerMirror(this, mirror);
        converter.convert(mirror, this, AdvancedSprite.coordinateSystemRect, Starling.current.profile == Context3DProfile.BASELINE_EXTENDED);
        if (converter.isSharingAtlasesRegions() && sharedMirrors.indexOf(this) < 0) sharedMirrors.push(this);
    }

    public function activateJuggler(_activate:Boolean):void {
        if (_activate) {
            Starling.juggler.add(_juggler);
            _juggler.play();
        }
        else Starling.juggler.remove(_juggler);
    }

    private var requireActivationControl:Boolean = false;

    /**
     * method that toggle activation state(drawing and textures memory)
     * @param active
     *
     */
    public function activate(_active:Boolean):void {
        if (!_descriptor || !_childrenCreated || this._active == _active) return;

        // first atlases activation is ignored as they are already active after convertion
        if (requireActivationControl) activateAtlases(_active);

        this._active = _active;

        activateJuggler(_active);

        requireActivationControl = true;

        if (converter.debug) log(this, "activate", _active);
    }

    public function activateAtlases(active:Boolean, forceTextureDispose:Boolean = false):void {
        if (!_descriptor || !_descriptor.textureAtlases) return;

        var _autoTextureActivation:Boolean = autoTextureActivation;
        if (!active && forceTextureDispose) autoTextureActivation = true;

        //if(!autoTextureActivation && !redrawTextures) return;

        var numAtlases:int = _descriptor.textureAtlases.length;
        for (var i:int = 0; i < numAtlases; i++) {
            activateAtlas(_descriptor.textureAtlases[i] as TextureAtlas_Dynamic, active);
        }
        autoTextureActivation = _autoTextureActivation;
    }

    protected function activateAtlas(atlas:TextureAtlas_Dynamic, active:Boolean):void {
        var t:Number = active ? getTimer() : 0;

        if (autoTextureActivation) atlas.dispose();
        if (active) {
            var bmd:BitmapData = namespaceFlashConverter::atlasesAndBmd[atlas] is BitmapData ? namespaceFlashConverter::atlasesAndBmd[atlas] : null;

            if (!bmd) {
                if (autoTextureBmdCompressToByteArray) {
                    var ba:ByteArray = namespaceFlashConverter::atlasesAndBmd[atlas];
                    var rect:Rectangle = namespaceFlashConverter::atlasesAndBmd[ba];
                    ba.uncompress();

                    bmd = new BitmapData(rect.width, rect.height);
                    bmd.setPixels(rect, ba);
                    ba.compress();
                }
                else {
                    bmd = converter.redrawAtlas(atlas);
                }
            }

            atlas.update(atlas.get_atlas(), bmd);

            handleLostContext(atlas, true);

            if (autoTextureBmdCompressToByteArray || redrawTextures) {
                if (redrawTextures) delete namespaceFlashConverter::atlasesAndBmd[atlas];
                ObjUtil.dispose(bmd);
                bmd = null;
            }
            if (converter.debug) log(this, "activateAtlas duration", getTimer() - t, this, active, atlas.get_atlas().imagePath);
        }
    }

    protected function handleLostContext(atlas:TextureAtlas_Dynamic, restore:Boolean = true):void {
        if (!(atlas.texture is ConcreteTexture)) return;

        (atlas.texture as ConcreteTexture).onRestore = null;
        if (!restore) return;

        (atlas.texture as ConcreteTexture).onRestore = function ():void {
            if (visible) activateAtlas(atlas, true);
        }
    }

    public function get active():Boolean {
        return _active;
    }

    public function get created():Boolean {
        return _childrenCreated;
    }

    protected var _descriptor:MirrorDescriptor = new MirrorDescriptor();

    public function get_descriptor():MirrorDescriptor {
        return _descriptor;
    }

    public function get descriptor():MirrorDescriptor {
        return _descriptor;
    }

    public function adChildAt(child:*, index:int):void {
        addChildAt(child as starling.display.DisplayObject, index);
    }

    public function adChild(child:*):void {
        addChild(child);
    }

    public function getChildAtIndex(index:int):* {
        return getChildAtIndex(index);
    }

    public function numChildrens():int {
        return numChildren;
    }
}

}
