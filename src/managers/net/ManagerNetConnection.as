/**
 * Created by valera on 28.09.2015.
 */
package managers.net {
import air.net.URLMonitor;

import flash.events.StatusEvent;
import flash.net.URLRequest;

import managers.Handlers;

import utils.log;

public class ManagerNetConnection {
    public function ManagerNetConnection() {
    }

    private static var urlMonitor:URLMonitor;
    public static var NET_CONNECTION_CHECK_REPEAT_DELAY:Number = 5000;

    public static function getUrlMonitor():URLMonitor {
        return urlMonitor;
    }

    public static function get connected():Boolean {
        return urlMonitor ? urlMonitor.available : false;
    }

    public static function monitorNetConnection(forceMonitoring:Boolean = false):void {
        if (urlMonitor && !forceMonitoring) return;

        if (!urlMonitor) urlMonitor = new URLMonitor(new URLRequest("http://www.google.com"));

        urlMonitor.pollInterval = NET_CONNECTION_CHECK_REPEAT_DELAY;

        if (forceMonitoring) {
            urlMonitor.stop();
            urlMonitor.removeEventListener(StatusEvent.STATUS, onNetConnectionStatus);
            urlMonitor.addEventListener(StatusEvent.STATUS, onNetConnectionStatus);
            urlMonitor.start();
        }
    }

    protected static function onNetConnectionStatus(event:StatusEvent):void {
        Handlers.call(monitorNetConnection, urlMonitor.available);
        if (urlMonitor.available) {
            event.target.removeEventListener(StatusEvent.STATUS, onNetConnectionStatus);
            (event.target as URLMonitor).stop();
        }
        log(ManagerNetConnection, "onNetConnectionStatus", "CONNECTED - " + urlMonitor.available, event.code);
    }
}
}
