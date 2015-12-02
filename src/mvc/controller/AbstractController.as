package mvc.controller {
import flash.events.EventDispatcher;

import managers.Handlers;

import mvc.model.AbstractModel;
import mvc.model.AppAction;

import starlingExtensions.interfaces.IActivable;

public class AbstractController extends EventDispatcher implements IActivable {
    protected var _model:AbstractModel;

    public function AbstractController(model:AbstractModel) {
        super();

        controllers.push(this);

        _model = model;

        Handlers.add(_model.save, false, onModelSaved);
    }

    public static var controllers:Vector.<AbstractController> = new Vector.<AbstractController>();

    public static function activateControllers(value:Boolean):void {
        for each(var controller:AbstractController in controllers) {
            controller.activate(value);
        }
    }

    protected var _active:Boolean = false;
    public function get active():Boolean {
        return _active;
    }

    public function activate(value:Boolean):void {
        _active = value;
    }

    protected function onModelSaved(key:*, serverStore:Boolean):void {

    }

    public function processAction(action:AppAction, data:Object = null):Boolean {
        return false;
    }

    public function add(data:Object):void {

    }

    public function remove(data:Object):void {

    }

    public function toggle(data:Object):void {

    }

    public function toggleAdding(data:Object):void {

    }

    public function block(data:Object):void {

    }

    public function unblock(data:Object):void {

    }

    public function close(data:Object):void {

    }

    public function open(data:Object):void {

    }

    public function cancel(data:Object):void {

    }

    public function send(data:Object):void {

    }

    public function update(data:Object):void {

    }

    protected function onError(error:Object):void {

    }

    protected var loadingHanler:Function;

    protected function loading(value:Boolean):void {
        if (loadingHanler != null) loadingHanler(value);
    }

    // notifications logic
    public function clearNotifications():void {
        _notification = "";
    }

    protected function updateNotifications():void {

    }

    protected var _notification:String = "";
    public function get notification():String {
        return _notification;
    }

    public function get details():String {
        return "";
    }
}
}