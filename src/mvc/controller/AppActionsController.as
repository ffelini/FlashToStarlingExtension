package mvc.controller
{
import mvc.model.AbstractModel;
import mvc.model.AppAction;

public class AppActionsController extends AbstractController
	{
		public function AppActionsController(model:AbstractModel)
		{
			super(model);
		}
		public var curentAction:AppAction;
		override public function processAction(action:AppAction,data:Object=null):Boolean
		{
			if(action.type=="" || !action.controller) return false;
			
			curentAction = action;
			
			switch(action.type)
			{
				case AppAction.ADD:
				{
					action.controller.add(data);
					return true;
					break;
				}
				case AppAction.REMOVE:
				{
					action.controller.remove(data);	
					return true;
					break;
				}
				case AppAction.TOGGLE:
				{
					action.controller.toggle(data);
					return true;
					break;
				}
				case AppAction.TOGGLE_ADDING:
				{
					action.controller.toggleAdding(data);
					return true;
					break;
				}
				case AppAction.BLOCK:
				{
					action.controller.block(data);
					return true;
					break;
				}
				case AppAction.UNBLOCK:
				{
					action.controller.unblock(data);
					return true;
					break;
				}
				case AppAction.OPEN:
				{
					action.controller.open(data);
					return true;
					break;
				}
				case AppAction.CLOSE:
				{
					action.controller.close(data);
					return true;
					break;
				}
				case AppAction.CANCEL:
				{
					action.controller.cancel(data);
					return true;
					break;
				}
				default:
				{
					action.controller.processAction(action,data);
					break;
				}
				
			}
			return false;
		}
	}
}