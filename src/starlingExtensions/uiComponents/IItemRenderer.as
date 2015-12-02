package starlingExtensions.uiComponents
{
	public interface IItemRenderer
	{
		function set data(value:Object):void
		function get data():Object
			
		function set selected(value:Boolean):void
		function get selected():Boolean
			
		function set list(value:List):void
		function get list():List
			
		function reset():void
		function updateLayout():void
	}
}