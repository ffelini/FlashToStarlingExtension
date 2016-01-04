package starlingExtensions.flash.textureAtlas {
import flash.display.BitmapData;
import flash.display.BitmapEncodingColorSpace;
import flash.display.StageQuality;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

import starling.textures.ConcreteTexture;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.TextureInfo;

import starlingExtensions.atf.Encoder;
import starlingExtensions.atf.EncodingOptions;

import utils.log;

public class TextureAtlas_Dynamic extends TextureAtlas implements ITextureAtlasDynamic {
    public static var debug:Boolean = false;

    public function TextureAtlas_Dynamic(texture:Texture, atlas:Object = null) {
        refreshConcretTexture(texture);
        super(concretTexture, atlas as XML);

        if (atlas is TextureAtlasAbstract) haxeParseAtlas(atlas as TextureAtlasAbstract);
    }

    private var _atlas:TextureAtlasAbstract;

    public function set_atlas(value:TextureAtlasAbstract):TextureAtlasAbstract {
        _atlas = value;

        if (!subtextures) subtextures = new Dictionary();
        if (!subtextures[_atlas]) subtextures[_atlas] = new Dictionary();

        _textureScale = _atlas.atlasRegionScale;
        _textureScale = !isNaN(_textureScale) ? _textureScale : 1;
        return _atlas;
    }

    public function get_atlas():TextureAtlasAbstract {
        return _atlas;
    }

    public var _textureScale:Number = 1;
    public function set textureScale(value:Number):void {
        _textureScale = value;
    }

    public function get textureScale():Number {
        return _textureScale;
    }

    public function set_textureScale(value:Number):Number {
        _textureScale = value;
        return _textureScale
    }

    public function get_textureScale():Number {
        return _textureScale;
    }

    protected var subtextures:Dictionary = new Dictionary();

    protected function haxeParseAtlas(atlas:TextureAtlasAbstract):void {
        atlas = atlas;

        if (!mTextureInfos[atlas]) {
            var scale:Number = mAtlasTexture ? mAtlasTexture.scale : _textureScale;
            for each(var subtexture:SubtextureRegion in atlas.subtextures) {
                addSubtextureRegion(subtexture);
            }
        }
    }

    protected function addSubtextureRegion(subTexture:SubtextureRegion, scale:Number = 1):void {
        addRegion(subTexture.name, subTexture.regionRect, subTexture.frameRect, subTexture.rotated);

        scaledRegions[subTexture.regionRect] = scale;
    }

    override public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Boolean = false):void {
        if (!mTextureInfos[_atlas]) mTextureInfos[_atlas] = new Dictionary();

        var tInfo:TextureInfo = mTextureInfos[_atlas][name];
        if (!tInfo) tInfo = new TextureInfo(region, frame, rotated);
        else {
            tInfo.region = region;
            tInfo.frame = frame;
            tInfo.rotated = rotated;
        }
        mTextureInfos[_atlas][name] = tInfo;

        if(debug) {
            log(this, "addRegion", "name - " + name, "region - " + region, "frame - " + frame);
        }
    }

    public function getTextureObjByName(name:String):* {
        return getTexture(name);
    }

    private var scaledRegions:Dictionary = new Dictionary();

    override public function getTexture(name:String):Texture {
        var t:Texture = subtextures[_atlas][name];
        if (t) return t;

        var tInfo:TextureInfo = mTextureInfos[_atlas] ? mTextureInfos[_atlas][name] : null;
        var region:Rectangle = tInfo ? tInfo.region : null;

        if (region && (!scaledRegions[region] || scaledRegions[region] == 1)) {
            region.x *= _textureScale;
            region.y *= _textureScale;
            region.width *= _textureScale;
            region.height *= _textureScale;

            var frame:Rectangle = tInfo.frame;
            if (frame) {
                frame.x *= _textureScale;
                frame.y *= _textureScale;
                frame.width *= _textureScale;
                frame.height *= _textureScale;
            }
            scaledRegions[region] = _textureScale;
        }
        if (!region) return null;

        t = Texture.fromTexture(mAtlasTexture, region, frame);

        subtextures[_atlas][name] = t;
        subtextures[t] = name;

        return t;
    }

    override public function getRegion(name:String):Rectangle {
        var tInfo:TextureInfo = mTextureInfos[_atlas][name];
        return tInfo ? tInfo.region : null;
    }

    override public function getFrame(name:String):Rectangle {
        var tInfo:TextureInfo = mTextureInfos[_atlas][name];
        return tInfo ? tInfo.frame : null;
    }

    override public function removeRegion(name:String):void {
        delete mTextureInfos[_atlas][name];
    }

    override public function getNames(prefix:String = "", result:Vector.<String> = null):Vector.<String> {
        if (result == null) result = new <String>[];

        for (var name:String in mTextureInfos[_atlas])
            if (name.indexOf(prefix) == 0)
                result.push(name);

        result.sort(Array.CASEINSENSITIVE);
        return result;
    }

    public function getExtrudedTexture(name:String, frame:Rectangle = null, region:Rectangle = null, extrusionFactor:Number = 100):* {
        return extrudeTexture(getTexture(name), frame, region, extrusionFactor);
    }

    public function getTexturesObj(prefix:String = "", result:* = null):* {
        return getTextures(prefix, result as Vector.<Texture>);
    }

    override public function getTextures(prefix:String = "", result:Vector.<Texture> = null):Vector.<Texture> {
        if (result) result.length = 0;
        return super.getTextures(prefix, result);
    }

    public var concretTexture:ConcreteTexture_Dynamic;

    protected function refreshConcretTexture(t:Texture):void {
        if (!t) return;
        _textureSource = t;

        if (t is ConcreteTexture) (t as ConcreteTexture).onRestore = null;
        concretTexture = new ConcreteTexture_Dynamic(t.base, t.format, t.nativeWidth, t.nativeHeight, t.mipMapping, t.premultipliedAlpha, false, t.scale);
    }

    public function setTexture(value:*):void {
        texture = value as Texture;
    }

    protected var _textureSource:Texture;
    public function get textureSource():Object {
        return _textureSource;
    }

    public function get_textureSource():* {
        return _textureSource;
    }

    override public function set texture(value:Texture):void {
        var t:Number = getTimer();

        refreshConcretTexture(value);
        super.texture = concretTexture;
        updateSubtextures();

        log(this, "TextureAtlas_Dynamic.texture(value)", this, "duration-" + (getTimer() - t), _atlas.imagePath);
    }

    public function curentTexture():* {
        return texture;
    }

    protected function updateSubtextures():void {
        for each(var subTexture:SubTexture in subtextures[_atlas]) {
            if (subTexture) updateSubtextureParent(subTexture, mAtlasTexture);
        }
    }

    public function updateAtlas(atlas:TextureAtlasAbstract, forceUpdating:Boolean = false):void {
        haxeParseAtlas(atlas);
    }

    /**
     * checking if the size of new bidmapData match to the curent texture size. If not dispose the texture
     */
    public function prepareForBitmapDataUpload(bmdWidth:Number, bmdHeight:Number):void {
        if (bmdWidth != texture.nativeWidth || bmdHeight != texture.nativeHeight) dispose();
    }

    public static var useTextureScaleValue:Boolean = false;

    public function updateBitmapData(data:BitmapData):void {
        prepareForBitmapDataUpload(data.width, data.height);

        if (isDisposed) texture = getAtlasTexture(data, _textureScale);
        else {
            if (useTextureScaleValue) (texture as ConcreteTexture_Dynamic).scale = _textureScale;

            if (encodeToAtf) (texture as ConcreteTexture_Dynamic).uploadAtfData(atfEncode(data));
            else (texture as ConcreteTexture_Dynamic).uploadBitmapData(data);
            updateSubtextures();
        }
    }

    public function haxeUpdate(atlas:TextureAtlasAbstract, data:BitmapData):void {
        update(atlas, data);
    }

    public function update(atlas:TextureAtlasAbstract, data:BitmapData):void {
        updateAtlas(atlas);
        updateBitmapData(data);
    }

    public function get isDisposed():Boolean {
        return concretTexture.isDisposed;
    }

    public function get_isDisposed():Boolean {
        return concretTexture.isDisposed;
    }

    override public function dispose():void {
        super.dispose();
        log(this, "TextureAtlas_Dynamic.dispose()", this, _atlas.imagePath);
    }

    public function updateSubtextureParent(st:SubTexture, parent:Texture):void {
        st.parent = parent;

        if (_textureScale != 1) {
            var stName:String = subtextures[st];
            var tInfo:TextureInfo = mTextureInfos[_atlas][stName];
            var region:Rectangle = tInfo ? tInfo.region : null;

            if (region && (!scaledRegions[region] || scaledRegions[region] == 1)) {
                st.transformationMatrix.translate((region.x * _textureScale) / parent.nativeWidth, (region.y * _textureScale) / parent.nativeHeight);
                st.transformationMatrix.scale((region.width * _textureScale) / parent.nativeWidth, (region.height * _textureScale) / parent.nativeHeight);

                var frame:Rectangle = tInfo.frame;
                if (frame) {
                    frame.x *= _textureScale;
                    frame.y *= _textureScale;
                    frame.width *= _textureScale;
                    frame.height *= _textureScale;
                    st.mFrame = frame;
                }

                scaledRegions[region] = _textureScale;
            }
        }
    }

    public static function extrudeTexture(t:Texture, frame:Rectangle = null, region:Rectangle = null, extrusionFactor:Number = 100):Texture {
        if (t && (frame || region || extrusionFactor < 100)) {
            frame = frame ? frame : new Rectangle();
            var factor:Number = t.width / t.height;
            extrusionFactor = extrusionFactor > 1 ? extrusionFactor / 100 : extrusionFactor;

            frame.width = t.width * extrusionFactor;
            frame.height = frame.width / factor;
            frame.x = (t.width - frame.width) / 2;
            frame.y = (t.height - frame.height) / 2;

            t = Texture.fromTexture(t, frame);
        }
        return t;
    }

    public static var useMipMaps:Boolean = false;
    public static var encodeToAtf:Boolean = false;

    public static function getAtlasTexture(atlasBmd:BitmapData, scale:Number = 1):Texture {
        if (!useTextureScaleValue) scale = 1;

        var time:Number = getTimer();

        var t:Texture = encodeToAtf ? getAtfTexture(atlasBmd, scale) : Texture.fromBitmapData(atlasBmd, useMipMaps, false, scale);

        if(debug) log(TextureAtlas_Dynamic, "getAtlasTexture", "encodeToAtf - " + encodeToAtf, "rect - " + atlasBmd.rect, "DURATION-" + (getTimer() - time));

        return t;
    }

    public static function getAtfTexture(atlasBmd:BitmapData, scale:Number = 1):Texture {
        var atfBa:ByteArray = atfEncode(atlasBmd);

        var time:Number = getTimer();

        var t:Texture = Texture.fromAtfData(atfBa, scale, useMipMaps);

        log(TextureAtlas_Dynamic, "getAtfTexture", atlasBmd.rect, getTimer() - time);

        return t;
    }

    public static var atfEncodingOptions:EncodingOptions;

    public static function atfEncode(atlasBmd:BitmapData):ByteArray {
        var time:Number = getTimer();

        var atfBa:ByteArray = new ByteArray();

        if (!atfEncodingOptions) {
            atfEncodingOptions = new EncodingOptions();
            atfEncodingOptions.quantization = 20;
            atfEncodingOptions.flexbits = 0;
            atfEncodingOptions.mipmap = useMipMaps;
            atfEncodingOptions.mipQuality = StageQuality.HIGH;
            atfEncodingOptions.colorSpace = BitmapEncodingColorSpace.COLORSPACE_4_4_4;
        }

        Encoder.encode(atlasBmd, atfEncodingOptions, atfBa);

        log(TextureAtlas_Dynamic, "atfEncode", atlasBmd.rect, getTimer() - time);

        return atfBa;
    }

    public static function parseBool(value:String):Boolean {
        return value.toLowerCase() == "true";
    }
}
}