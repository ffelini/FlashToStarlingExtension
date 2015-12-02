package mvc.view.interfaces
{
import mvc.controller.AbstractController;

public interface IAbstractView
	{
		function setController(value:AbstractController):void
		function onModelUpdated():void
	}
}