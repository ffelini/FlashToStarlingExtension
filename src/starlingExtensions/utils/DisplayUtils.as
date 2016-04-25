package starlingExtensions.utils {

import feathers.display.Scale3Image;
import feathers.display.Scale9Image;

import flash.geom.Point;
import flash.geom.Rectangle;

import haxePort.starlingExtensions.interfaces.ISmartDisplayObject;
import haxePort.utils.ObjUtil;

import starling.display.Button;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.Stage;
import starling.text.TextField;

import starlingExtensions.abstract.IOptimizedDisplayObject;
import starlingExtensions.decorators.DecoratorManger;
import starlingExtensions.flash.animation.FlashMovieClip_Mirror;
import starlingExtensions.interfaces.IClonable;

public class DisplayUtils {
    public static const PIVOT_CENTER:String = "centerPivot";
    public static const PIVOT_TOP:String = "ещзPivot";
    public static const PIVOT_BOTTOM:String = "bottomPivot";
    public static const PIVOT_LEFT:String = "leftPivot";
    public static const PIVOT_RIGHT:String = "rightPivot";
    public static const PIVOT_LEFT_CENTER:String = "leftCenterPivot";
    public static const PIVOT_RIGHT_CENTER:String = "rightCenterPivot";
    public static const PIVOT_TOP_CENTER:String = "topCenterPivot";
    public static const PIVOT_BOTTOM_CENTER:String = "bottomCenterPivot";

    public static const DEBUG_BOUNDS:String = "debug_bounds";
    public static const DEBUG_PIVOT:String = "debug_pivot";

    public function DisplayUtils() {
    }

    public static function debugChildren(container:DisplayObjectContainer, debug_mode:String, debug_alpha:Number = 0.5):void {
        if (container) {
            var numChildren:int = container.numChildren;
            for (var i:int = 0; i < numChildren; i++) {
                debugObject(container.getChildAt(i), debug_mode, debug_alpha);
            }
        }
    }

    public static function debugObject(object:DisplayObject, debug_mode:String, debug_alpha:Number = 0.5):void {
        if (object) {
            switch (debug_mode) {
                case DEBUG_BOUNDS:
                {
                    if (object.parent) {
                        var q:Quad = new Quad(1, 1, Math.random() * 0xFFFFFF);
                        q.alpha = debug_alpha;
                        q.touchable = false;
                        setBounds(q, object.getBounds(object.parent));
                        object.parent.addChild(q);
                    }
                    break;
                }
                case DEBUG_PIVOT:
                    q = new Quad(10, 10, 0);
                    q.touchable = false;
                    q.alpha = debug_alpha;
                    if (object is DisplayObjectContainer) {
                        (object as DisplayObjectContainer).addChild(q);
                    } else {
                        q.x = object.x - 5;
                        q.y = object.y - 5;
                        object.parent.addChild(q);
                    }
                    break;
            }
        }
    }

    public static function setParent(obj:DisplayObject, parent:DisplayObjectContainer, _setBounds:Boolean = true):void {
        if (!obj || !parent || parent == obj.parent) {
            return;
        }
        if (obj.stage && parent.stage) {
            var localP:Point = localToContent(obj, parent);

            if (_setBounds) {
                var localRect:Rectangle = obj.getBounds(parent);
                setBounds(obj, localRect);
            }

            obj.x = localP.x;
            obj.y = localP.y;
        }

        parent.addChild(obj);
    }

    public static function setPivot(object:DisplayObject, pivot:String, objBounds:Rectangle = null, keepVisualPosition:Boolean = true):Rectangle {
        var px:Number = object.pivotX;
        var py:Number = object.pivotY;

        if (!objBounds) objBounds = object.getBounds(object, helpRect);

        switch (pivot) {
            case PIVOT_CENTER:
            {
                px = objBounds.x + objBounds.width / 2;
                py = objBounds.y + objBounds.height / 2;
                break;
            }
            case PIVOT_BOTTOM_CENTER:
            {
                px = objBounds.x + objBounds.width / 2;
                py = objBounds.y + objBounds.height;
            }
        }
        object.pivotX = px;
        object.pivotY = py;

        if (keepVisualPosition) {
            object.x += px * object.scaleX;
            object.y += py * object.scaleY;
        }

        return objBounds;
    }

    public static function setObjectColor(value:DisplayObject, color:uint):void {
        if (value is Scale9Image) {
            (value as Scale9Image).color = color;
        }
        else if (value is Scale3Image) {
            (value as Scale3Image).color = color;
        }
        else {
            var container:DisplayObjectContainer = value is TextField ? null : value as DisplayObjectContainer;
            var numChildren:int = container ? container.numChildren : 0;
            var child:DisplayObject;

            if (numChildren > 0) {
                for (var i:int = 0; i < numChildren; i++) {
                    child = container.getChildAt(i);

                    if (!(child is TextField)) {
                        if (child is DisplayObjectContainer) setObjectColor(child, color);
                        else if (child is Quad) (child as Quad).color = color;
                    }
                }
            }
            else if (value is Quad) (value as Quad).color = color;
        }
    }

    public static function normalize(obj:DisplayObject):void {
        obj.x = Math.round(obj.x);
        obj.y = Math.round(obj.y);

        var b:Rectangle = obj.getBounds(obj.parent, helpRect);

        if (obj is IOptimizedDisplayObject) {
            (obj as IOptimizedDisplayObject).setSize(Math.round(b.width), Math.round(b.height));
        }
        else {
            obj.width = Math.round(b.width);
            obj.height = Math.round(b.height);
        }

    }

    public static function addUnder(obj:DisplayObject, under:DisplayObject):void {
        var i:int = under.parent.getChildIndex(under);
        i = i == 0 ? 0 : i - 1;
        under.parent.addChildAt(obj, i);
    }

    public static function addAbove(obj:DisplayObject, above:DisplayObject):void {
        var i:int = above.parent.getChildIndex(above) + 1;

        above.parent.addChildAt(obj, i);
    }

    public static function centrateToContent(obj:*, _coordinateSystemRect:Rectangle, _objRect:Rectangle = null):void {
        if (!_objRect) _objRect = obj.hasOwnProperty("getRect") ? obj.getRect(obj.parent) : obj.getBounds(obj.parent, helpRect);
        validateRect(_objRect);
        validateRect(obj);

        obj.x = _coordinateSystemRect.x + _coordinateSystemRect.width / 2 - _objRect.width / 2 + obj.x - _objRect.x;
        obj.y = _coordinateSystemRect.y + _coordinateSystemRect.height / 2 - _objRect.height / 2 + obj.y - _objRect.y;
    }

    public static function centrateToStage(obj:DisplayObject, coordinateSystemRect:Rectangle,
                                           xOffset:Number = 1, yOffset:Number = 1,
                                           affectHorizonalPosition:Boolean = true,
                                           affectVerticalPosition:Boolean = true,
                                           ignoreParentPivots:Boolean = false):void {
        helpRect = obj.getBounds(obj.stage, helpRect);
        helpRect.x = (coordinateSystemRect.width - helpRect.width) / 2;
        helpRect.y = (coordinateSystemRect.height - helpRect.height) / 2;

        helpRect.x *= xOffset;
        helpRect.y *= yOffset;

        helpPoint = obj.parent.globalToLocal(new Point(helpRect.x, helpRect.y), helpPoint);
        if (ignoreParentPivots) {
            helpPoint.x -= obj.parent.pivotX;
            helpPoint.y -= obj.parent.pivotY;
        }
        if (affectHorizonalPosition) obj.x = helpPoint.x;
        if (affectVerticalPosition) obj.y = helpPoint.y;
    }

    public static var helpRect:Rectangle;
    public static var helpPoint:Point = new Point();

    public static function setPosition(to:Object, from:Object):void {
        if(!to || !from) return;
        to.x = from.x;
        to.y = from.y;
    }

    public static function setGlobalPosition(obj:Object, x:Number, y:Number):void {
        if (!obj) return;

        helpRect = obj.hasOwnProperty("getRect") ? obj.getRect(obj.stage) : obj.getBounds(obj.stage, helpRect);
        helpPoint.x = helpRect.x + (x - helpRect.x);
        helpPoint.y = helpRect.y + (y - helpRect.y);

        var localPosition:Point = obj.parent ? obj.parent.globalToLocal(helpPoint) : obj.globalToLocal(helpPoint);
        obj.x = localPosition.x;
        obj.y = localPosition.y;
    }

    public static function stageRect(rect:Rectangle, coordinateSystem:DisplayObjectContainer, resultRect:Rectangle = null):Rectangle {
        var resultRect:Rectangle = resultRect ? resultRect : new Rectangle();

        var p:Point = new Point(rect.x, rect.y);
        coordinateSystem.localToGlobal(p, helpPoint);
        resultRect.x = helpPoint.x;
        resultRect.y = helpPoint.y;

        p.x = rect.x + rect.width;
        p.y = rect.y + rect.height;
        coordinateSystem.localToGlobal(p, helpPoint);
        resultRect.width = helpPoint.x - resultRect.x;
        resultRect.height = helpPoint.y - resultRect.y;

        return resultRect;
    }

    public static function cloneFrom(from:Sprite, to:Sprite, root:DisplayObject):void {
        if (from is Scale3Image || from is Scale9Image) return;

        var numChildren:int = from.numChildren;
        var child:DisplayObject;
        var childClone:DisplayObject;

        var toFL:Boolean = to.isFlattened;
        if (toFL) to.unflatten();
        var fromFL:Boolean = from.isFlattened;
        if (fromFL) from.unflatten();

        for (var i:int = 0; i < numChildren; i++) {
            child = from.getChildAt(i);
            if (to.hasOwnProperty(child.name) && to[child.name] != null) continue;
            if (root.hasOwnProperty(child.name) && root[child.name] != null) continue;

            childClone = cloneDO(child);
            if (childClone) {
                if (child is Sprite) cloneFrom(child as Sprite, childClone as Sprite, root);

                try {
                    if (to.hasOwnProperty(child.name)) to[child.name] = childClone;
                } catch (e:Error) {
                }

                try {
                    if (root.hasOwnProperty(child.name)) root[child.name] = childClone;
                } catch (e:Error) {
                }

                to.addChild(childClone);
            }
        }

        if (fromFL) {
            from.flatten();
            to.flatten();
        }
    }

    public static function cloneTransformationMatrix(from:DisplayObject, to:DisplayObject):void {
        if (!from || !to || from == to) return;
        to.transformationMatrix = from.transformationMatrix.clone();
    }

    public static function cloneDO(obj:DisplayObject):DisplayObject {
        if (!obj) return null;

        helpRect = null;

        var clone:DisplayObject = obj is IClonable ? (obj as IClonable).clone() : null;
        if (!clone) {
            if (obj is Sprite) clone = new Sprite();
            else if (obj is MovieClip) clone = new MovieClip((obj as MovieClip).mTextures);
            else if (obj is Button) clone = new Button((obj as Button).upState, (obj as Button).text, (obj as Button).downState);
            else if (obj is Image) clone = new Image((obj as Image).texture);
            else if (obj is Quad) {
                if (!helpRect) helpRect = obj.getBounds(obj.parent, helpRect);
                clone = new Quad(helpRect.width, helpRect.height, (obj as Quad).color);
            }
            else if (obj is TextField) {
                if (!helpRect) helpRect = obj.getBounds(obj.parent, helpRect);
                var t:TextField = obj as TextField;
                clone = new TextField(helpRect.width, helpRect.height, t.text, t.fontName, t.fontSize, t.color, t.bold);
                (clone as TextField).autoScale = t.autoScale;
                (clone as TextField).hAlign = t.hAlign;
                (clone as TextField).vAlign = t.vAlign;
                (clone as TextField).text = t.text;
            }
        }
        if (!clone) clone = ObjUtil.cloneInstance(obj) as DisplayObject;

        if (!helpRect) helpRect = obj.getBounds(obj.parent, helpRect);
        helpRect.x = Math.round(obj.x);
        helpRect.y = Math.round(obj.y);
        setBounds(clone, helpRect);

        clone.scaleX = obj.scaleX;
        clone.scaleY = obj.scaleY;
        clone.rotation = obj.rotation;
        clone.name = obj.name + "";
        clone.touchable = obj.touchable;

        DecoratorManger.setDecoration(obj, clone);

        return clone;
    }

    public static function clone(obj:DisplayObject):DisplayObject {
        var clone:DisplayObject;
        if (obj is IClonable) clone = (obj as IClonable).clone();

        if (obj is DisplayObjectContainer && !(obj is TextField)) {
            if (!clone) clone = cloneDO(obj);
            cloneFrom(obj as Sprite, clone as Sprite, clone);
        }
        else if (!clone) clone = cloneDO(obj);
        clone.transformationMatrix = obj.transformationMatrix;

        return clone;
    }

    public static function useTextures(from:DisplayObject, to:DisplayObject, debug:Boolean = false, toggleFlatten:Boolean = true):void {
        if (!from || !to) return;

        if (from is Scale3Image && to is Scale3Image) (to as Scale3Image).textures = (from as Scale3Image).textures;
        else if (from is Scale9Image && to is Scale9Image) (to as Scale9Image).textures = (from as Scale9Image).textures;
        else if (from is Sprite && to is Sprite) {
            var numChildren:int = (to as Sprite).numChildren;
            var _to:DisplayObject;
            var _from:DisplayObject;

            var toFL:Boolean = toggleFlatten ? (to as Sprite).isFlattened : false;
            var fromFL:Boolean = toggleFlatten ? (from as Sprite).isFlattened : false;
            if (toFL) (to as Sprite).unflatten();
            if (fromFL) (from as Sprite).unflatten();

            for (var i:int = 0; i < numChildren; i++) {
                _to = (to as Sprite).getChildAt(i);
                _from = (from as Sprite).getChildAt(i);
                useTextures(_from, _to, debug);
            }
            if (toFL) (to as Sprite).flatten();
            if (fromFL) (from as Sprite).flatten();
        }
        else if (from is FlashMovieClip_Mirror && to is FlashMovieClip_Mirror) (to as FlashMovieClip_Mirror).setSource(from as FlashMovieClip_Mirror);
        else if (from is MovieClip && to is MovieClip) (to as MovieClip).init((from as MovieClip).mTextures, (to as MovieClip).fps);
        else if (from is Button && to is Button) {
            (to as Button).downState = (from as Button).downState;
            (to as Button).upState = (from as Button).upState;
        }
        else if (from is Image && to is Image) {
            (to as Image).texture = (from as Image).texture;
            if (debug) trace("DisplayUtils.useTextures(from, to, debug)", from, to, from.visible, to.visible, from.alpha, to.alpha, (to as Image).texture == (from as Image).texture, (to as Image).texture.base == (from as Image).texture.base,
                    (to as Image).texture.width, (to as Image).texture.height, (to as Image).texture.width, (to as Image).texture.height);
        }

    }

    public static function clearContainer(container:DisplayObjectContainer):void {
        var numObjects:int = container.numChildren;
        for (var i:int = numObjects - 1; i >= 0; i--) {
            container.removeChildAt(i);
        }
    }

    public static function updateObjParent(obj:DisplayObject, newParent:DisplayObjectContainer, keepStagePosition:Boolean = true, keepStageObjSize:Boolean = true):void {
        if (!newParent || obj.parent == newParent) return;

        if (obj.parent) {
            if (keepStagePosition) {
                var gp:Point = obj.parent.localToGlobal(new Point(obj.x, obj.y));
                var lp:Point = newParent.globalToLocal(gp);

                obj.x = lp.x;
                obj.y = lp.y;

                obj.rotation += obj.parent.rotation;
            }
            if (keepStageObjSize) {
                obj.scaleX *= obj.parent.scaleX;
                obj.scaleY *= obj.parent.scaleY;
            }
        }
        newParent.addChild(obj);

        obj.scaleX /= obj.parent.scaleX;
        obj.scaleY /= obj.parent.scaleY;
        obj.rotation -= obj.parent.rotation;
    }

    public static function localToContent(obj:DisplayObject, content:DisplayObjectContainer, xOffset:Number = 0, yOffset:Number = 0):Point {
        if (!obj || !content || !obj.parent || (!content.parent && !(content is Stage))) return null;

        var gp:Point = obj.parent ? obj.parent.localToGlobal(new Point(obj.x + xOffset, obj.y + yOffset)) : obj.localToGlobal(new Point(xOffset, yOffset));
        return content.globalToLocal(gp);
    }

    [Inline]
    public static function forEachChild(sprite:Object, func:Function, ...parameters):void {
        var _numChildren:int = sprite.numChildren;
        var child:Object;

        var _parameters:Array = parameters.concat();
        _parameters.unshift(null);

        for (var i:int = _numChildren - 1; i >= 0; i--) {
            child = sprite.getChildAt(i);
            _parameters[0] = child;
            _parameters[1] = i;

            func.apply(child, _parameters);
        }
    }

    [Inline]
    public static function setBoundsFromObject(sourceObj:Object, obj:Object, round:Boolean = true):void {
        setBounds(obj,sourceObj.getBounds(obj.parent), round);
    }

    [Inline]
    public static function getScaleForObject(sourceObj:Object, obj:Object, round:Boolean = true):Point {
        if(!sourceObj || !obj) return null;

        var oldScaleX:Number = obj.scaleX;
        var oldScaleY:Number = obj.scaleY;
        var oldX:Number = obj.x;
        var oldY:Number = obj.y;

        setBoundsFromObject(sourceObj, obj, round);
        var result:Point = new Point(obj.scaleX, obj.scaleY);
        obj.scaleX = oldScaleX;
        obj.scaleY = oldScaleY;
        obj.x = oldX;
        obj.y = oldY;
        return result;
    }

    [Inline]
    public static function setBounds(obj:Object, rect:Rectangle, round:Boolean = true):void {
        if (!obj || !rect || rect.isEmpty()) return;

        if (obj is DisplayObject) {
            if (obj is MovieClip) {
                obj.x = round ? Math.round(rect.x) : rect.x;
                obj.y = round ? Math.round(rect.y) : rect.y;
            } else {
                obj.x = round ? Math.round(rect.x) + (obj.pivotX * obj.scaleX) : rect.x;
                obj.y = round ? Math.round(rect.y) + (obj.pivotY * obj.scaleY) : rect.y;
            }
        } else {
            obj.x = round ? Math.round(rect.x) : rect.x;
            obj.y = round ? Math.round(rect.y) : rect.y;
        }

        if (obj is ISmartDisplayObject) {
            (obj as ISmartDisplayObject).setSize(round ? Math.round(rect.width) : rect.width, round ? Math.round(rect.height) : rect.height);
        }
        else {
            obj.width = round ? Math.round(rect.width) : rect.width;
            obj.height = round ? Math.round(rect.height) : rect.height;
        }
    }

    [Inline]
    public static function validateSize(value:Number, max:Number, min:Number):Number {
        if (!isNaN(max)) value = value > max ? max : value;
        if (!isNaN(min)) value = value < min ? min : value;

        return value;
    }

    public static function validateRect(obj:Object):void {
        if (isNaN(obj.width)) obj.width = 1;
        if (isNaN(obj.height)) obj.height = 1;
        if (isNaN(obj.x)) obj.x = 0;
        if (isNaN(obj.y)) obj.y = 0;
    }

    [Inline]
    public static function isObjectVisibleOnTheStage(obj:DisplayObject):Boolean {
        var hasVisibleArea:Boolean = obj.scaleX != 0.0 && obj.scaleY != 0.0;
        var isVisible:Boolean = hasVisibleArea && obj.stage;

        if (isVisible) {
            while (obj && obj.parent && obj.parent != obj.stage) {
                obj = obj.parent.hasVisibleArea ? obj.parent : null;
            }
        }

        return isVisible && obj && obj.parent == obj.stage;
    }

    [Inline]
    public static function addTo(obj:Object, container:Object):void {
        if (obj.parent == container) return;

        helpRect = obj.hasOwnProperty("getRect") ? obj.getRect(container) : obj.getBounds(container, helpRect);
        setBounds(obj, helpRect);
        container.addChild(obj);
    }

    [Inline]
    public static function paraseParents(obj:DisplayObject):String {
        var s:String = "DisplayUtils.paraseParents(obj) - " + obj;
        while (obj.parent) {
            s += "\n" + obj + " name-" + obj.name + " visible-" + obj.visible + " alpha-" + obj.alpha + " blend-" + obj.blendMode + " filter-" + obj.filter;
            if (obj is Image) s += " color-" + (obj as Image).color + " tinted-" + (obj as Image).tinted + " smoothing-" + (obj as Image).smoothing + " texture repeate-" + (obj as Image).texture.repeat;

            obj = obj.parent;
        }
        return s;
    }

    [Inline]
    public static function setEnabled(target:DisplayObject, enabled:Boolean):void {
        if (!target) return;

        target.touchable = enabled;
        target.alpha = enabled ? 1 : 0.5;
    }
}
}