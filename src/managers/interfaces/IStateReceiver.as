package managers.interfaces
{
import starling.display.DisplayObject;

public interface IStateReceiver
	{
		function set state(value:Object):void
		function get state():Object
		function get stateName():String
		function includeInState(obj:DisplayObject,state:*):void
		function excludeFromState(obj:DisplayObject,state:*):void
	}
}