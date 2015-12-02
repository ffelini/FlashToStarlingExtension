package starlingExtensions.containers
{
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;

public class DisplayObjectContainerAbstract extends DisplayObjectContainer
	{
		public function DisplayObjectContainerAbstract()
		{
			super();
		}
		// child management
		
		public function addChildren(...children):void
		{
			for each(var child:DisplayObject in children)
			{
				addChild(child);
			}
		}
		/** Adds a child to the container at a certain index. */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var numChildren:int = mChildren.length; 
			
			if (index >= 0 && index <= numChildren)
			{
				if (mChildren.indexOf(child)>=0)
				{
					setChildIndex(child, index); // avoids dispatching events
				}
				else
				{
					// 'splice' creates a temporary object, so we avoid it if it's not necessary
					if (index == numChildren) mChildren[numChildren] = child;
					else                      mChildren.splice(index, 0, child);
					
					child.dispatchEventWith(Event.ADDED, true);
					
				}
				
				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			if (index >= 0 && index < numChildren)
			{
				var child:DisplayObject = mChildren[index];
				child.dispatchEventWith(Event.REMOVED, true);
				
				if (stage)
				{
					var container:DisplayObjectContainer = child as DisplayObjectContainer;
					if (container) container.broadcastEventWith(Event.REMOVED_FROM_STAGE);
					else           child.dispatchEventWith(Event.REMOVED_FROM_STAGE);
				}
				
				index = mChildren.indexOf(child); // index might have changed by event handler
				if (index >= 0) mChildren.splice(index, 1); 
				if (dispose) child.dispose();
				
				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}
		
		override public function set alpha(value:Number):void
		{
			var last:Number = alpha;
			
			super.alpha = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.alpha += value - last;
			}
		}
		
		override public function set pivotX(value:Number):void
		{
			var last:Number = pivotX;
			
			super.pivotX = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.x += value - last;
			}
		}
		
		override public function set pivotY(value:Number):void
		{
			var last:Number = pivotY;
			
			super.pivotY = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.y += value - last;
			}
		}
		
		override public function set rotation(value:Number):void
		{
			super.rotation = value;
		}
		override public function set scaleX(value:Number):void
		{
			var last:Number = scaleX;
			
			super.scaleX = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.scaleX += value - last;
			}
		}
		
		override public function set scaleY(value:Number):void
		{
			var last:Number = scaleY;
			
			super.scaleY = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.scaleY += value - last;
			}
		}
		
		override public function set touchable(value:Boolean):void
		{
			super.touchable = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.touchable = value;
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.visible = value;
			}
		}
		
		override public function set x(value:Number):void
		{
			var last:Number = x;
			
			super.x = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.x += value - last;
			}
		}
		
		override public function set y(value:Number):void
		{
			var last:Number = y;
			
			super.y = value;
			
			for each(var child:DisplayObject in mChildren)
			{
				child.y += value - last;
			}
		}
		
		
	}
}