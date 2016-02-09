package starlingExtensions.flash.textureAtlas {
import feathersExtensions.utils.TextureUtils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;

import haxePort.starlingExtensions.flash.movieclipConverter.FlashAtlas;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

import managers.Handlers;

import starling.textures.Texture;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

import starlingExtensions.utils.DisplayUtils;

/**
 * The basic class for dynamic atlases generation. The point of using it is to add remote and dynamic content to the atlas when is required.
 * By default is uses the maximum possible size so on each addRegion calls it will reupload same texture size with new updated content.
 * @author peak
 *
 */
public class FlashAtlas_Dynamic extends FlashAtlas {
    private var _isFull:Boolean = false;

    private var helpTexture:Texture;
    private var maxSize:Number = 1024;
    public var onFullHandler:Function;

    public function FlashAtlas_Dynamic() {
        super();

        resetDescriptor();
        debug = debugAtlas = true;
    }

    override public function resetDescriptor():AtlasDescriptor {
        descriptor = super.resetDescriptor();
        descriptor.smartSizeIncrease = false;
        helpTexture = Texture.fromColor(2, 2);
        descriptor.atlas = TextureUtils.getAtlas(helpTexture, descriptor.atlasAbstract);
        return descriptor;
    }

    override public function createTextureAtlasDynamic(atlas:TextureAtlasAbstract, atlasBmd:BitmapData):ITextureAtlasDynamic {
        var t:ConcreteTexture_Dynamic = TextureUtils.textureFromBmd(atlasBmd, atlas.atlasRegionScale);
        return TextureUtils.getAtlas(t, atlas);
    }

    override public function saveAtlasPng(path:String, atlasBmd:BitmapData):void {
        TextureUtils.saveAtlasPng(path, atlasBmd);
    }

    override public function getMaximumWidth():int {
        return maxSize;
    }

    override public function getMaximumHeight():int {
        return maxSize;
    }

    override public function checkSubtexture(obj:DisplayObject, name:String = "", descriptors:Array = null):AtlasDescriptor {
        return null;
    }

    override public function addSubTexture(descriptor:AtlasDescriptor, obj:DisplayObject, name:String = "", onAtlasIsFullCall:Boolean = true):SubtextureRegion {
        var subTexture:SubtextureRegion = super.addSubTexture(descriptor, obj, name);
        if (subTexture) {
            if (autoUpdateAtlas) updateAtlas();
        } else {
            if (subtextureObj.parent == this) subtextureObj.parent.removeChild(subtextureObj);
            if (requireUpdate) updateAtlas(true);
            _isFull = true;
            Handlers.call(onFullHandler, obj, name);
        }
        return subTexture;
    }

    public var autoUpdateAtlas:Boolean = true;
    public var autoUpdateDelay:Number = 5000;
    private var lastUpdateAtlas:Number = 0;

    public function updateAtlas(forceUpdating:Boolean = false):void {
        var t:Number = getTimer();
        if (forceUpdating || !descriptor.atlas || t - lastUpdateAtlas > autoUpdateDelay) {
            createTextureAtlas(descriptor);
            lastUpdateAtlas = t;
        }
    }

    override public function drawAtlas(descriptor:AtlasDescriptor, rect:Rectangle):BitmapData {
        var bmd:BitmapData = super.drawAtlas(descriptor, rect);

        return bmd;
    }

    override public function createTextureAtlas(descriptor:AtlasDescriptor):haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic {
        if (width == 0 || height == 0) return null;

        atlasBmd = drawAtlas(descriptor, descriptor.maxRect);
        descriptor.atlas.updateBitmapData(atlasBmd);
        (descriptor.atlas as TextureAtlas_Dynamic).concretTexture.onRestore = restoreAtlas;
        atlasBmd.dispose();
        atlasBmd = null;
        requireUpdate = false;

        return descriptor.atlas;
    }

    private function restoreAtlas():void {
        updateAtlas(true);
    }

    public var requireUpdate:Boolean = false;

    /**
     *
     * @param obj new display instance to add
     * @param name - subtexture registration name
     * @param _updateAtlas - force redraw and upload
     * @param includeAllMovieClipFrames - if true then adding all movieClips frames
     * @return
     *
     */
    public function addRegion(obj:DisplayObject, name:String, _updateAtlas:Boolean = true, includeAllMovieClipFrames:Boolean = true,
                              maxSizeRect:Rectangle = null, objProcessHandler:Function = null):SubtextureRegion {
        if (objProcessHandler != null) obj = objProcessHandler(obj);

        if (includeAllMovieClipFrames && obj is MovieClip && (obj as MovieClip).totalFrames > 1) {
            addMovieClip(descriptor, obj as MovieClip, false);
            return null;
        }
        if (!_updateAtlas) {
            _updateAtlas = autoUpdateAtlas;
            autoUpdateAtlas = false;
            requireUpdate = true;
        }
        else {
            var _autoUpdateDelay:Number = autoUpdateDelay;
            autoUpdateDelay = 0;
        }
        if (maxSizeRect && obj.width + obj.height > maxSizeRect.width + maxSizeRect.height) {
            DisplayUtils.helpRect.setEmpty();
            DisplayUtils.helpRect.width = obj.width;
            DisplayUtils.helpRect.height = obj.height;
            RectangleUtil.fit(DisplayUtils.helpRect, maxSizeRect, ScaleMode.SHOW_ALL, false, DisplayUtils.helpRect);
            DisplayUtils.setBounds(obj, DisplayUtils.helpRect);
        }

        var subTexture:SubtextureRegion = addSubTexture(descriptor, obj, name);
        autoUpdateAtlas = _updateAtlas;
        autoUpdateDelay = _autoUpdateDelay;

        return subTexture;
    }

    public function getSubtexture(name:String, region:Rectangle = null, frame:Rectangle = null, extrusionFactor:Number = 100):* {
        var t:Texture;
        if (descriptor.atlas != null) {
            if (region != null || frame != null || extrusionFactor < 100) t = descriptor.atlas.getExtrudedTexture(name, region, frame, extrusionFactor);
            else t = descriptor.atlas.getTextureObjByName(name);
        }
        if (!t) {
            subTextures = getSubtextures(name, subTextures) as Vector.<Texture>;
            t = subTextures && subTextures.length > 0 ? subTextures[0] : null;
        }
        return t;
    }

    public function getSubtextures(name:String, result:*):* {
        return descriptor.atlas != null ? descriptor.atlas.getTexturesObj(name, result) : null;
    }

    public function getSubtexturesForObj(obj:DisplayObject, result:Object = null):Object {
        var objName:String = getQualifiedClassName(obj);
        return getSubtextures(objName, result);
    }

    private static var subTextures:Vector.<Texture>;

    public function getSubtextureForObj(obj:DisplayObject, region:Rectangle = null, frame:Rectangle = null, extrusionFactor:Number = 100):Texture {
        var objName:String = getQualifiedClassName(obj);
        var t:Texture = getSubtexture(objName, region, frame, extrusionFactor) as Texture;
        return t;
    }

    override public function addMovieClip(descriptor:AtlasDescriptor, mc:MovieClip, includeAllFrames:Boolean):void {
        var _updateAtlas:Boolean = autoUpdateAtlas;
        var _autoUpdateDelay:Number = autoUpdateDelay;

        autoUpdateDelay = 0;
        autoUpdateAtlas = false;

        super.addMovieClip(descriptor, mc, includeAllFrames);
        if (_updateAtlas) updateAtlas();

        autoUpdateAtlas = _updateAtlas;
        autoUpdateDelay = _autoUpdateDelay;
    }

    /**
     * adding a atlas region
     * @param bmd
     * @param name - subtexture registration name
     * @param alpha
     * @param _updateAtlas
     * @param bmdProcessHandler
     * @return
     *
     */
    public function addBitmapDataRegion(bmd:BitmapData, name:String, alpha:Number = 1, _updateAtlas:Boolean = true, maxSizeRect:Rectangle = null, bmdProcessHandler:Function = null):SubtextureRegion {
        var bmp:Bitmap = new Bitmap(bmd, "auto", true);
        bmp.alpha = alpha;
        return addRegion(bmp, name, _updateAtlas, true, maxSizeRect, bmdProcessHandler);
    }

    public function get isFull():Boolean {
        return _isFull;
    }
}
}