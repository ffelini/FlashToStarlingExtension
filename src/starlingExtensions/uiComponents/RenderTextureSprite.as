package starlingExtensions.uiComponents
{
import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.textures.RenderTexture;

public class RenderTextureSprite extends SmartSprite
	{
		protected var renderSprite:Sprite = new Sprite();
		
		public function RenderTextureSprite(tw:Number,th:Number)
		{
			super();
			
			renderTexture = new RenderTexture(tw,th,false);
			
			renderImg = new SmartImage(renderTexture);
			renderImg.width = renderTexture.width;
			renderImg.height = renderTexture.height;
			super.addChildAt(renderImg,0);
		}
		public var autoRedraw:Boolean = false;
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if(autoRedraw && boundsChanged) redraw();
		}
		public function redraw(_clear:Boolean=true):void
		{
			//renderT.drawBundled(drawBundled);
			if(_clear) renderTexture.clear();
			
			renderTexture.draw(renderSprite);
			
			renderImg.texture = renderTexture;
			renderImg.readjustSize();
			//(renderImg.texture as ConcreteTexture_Dynamic).base = renderTexture.base;
		}
		protected var renderImg:SmartImage;
		public var renderTexture:RenderTexture;
		protected function drawBundled():void
		{
			var _numChildren:int = numChildren;
			
			for(var i:int=0;i<_numChildren;i++)
			{
				renderTexture.draw(getChildAt(i));
			}
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return renderSprite.addChildAt(child, index);
		}
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			return renderSprite.removeChildAt(index, dispose);
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return renderSprite.addChild(child);
		}
		override public function contains(child:DisplayObject):Boolean
		{
			return renderSprite.contains(child);
		}
		override public function getChildAt(index:int):DisplayObject
		{
			return renderSprite.getChildAt(index);
		}
		override public function getChildByName(name:String):DisplayObject
		{
			return renderSprite.getChildByName(name);
		}
		override public function getChildIndex(child:DisplayObject):int
		{
			return renderSprite.getChildIndex(child);
		}
		override public function get numChildren():int
		{
			return renderSprite.numChildren;
		}
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			return renderSprite.removeChild(child, dispose);
		}
		override public function removeChildren(beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false):void
		{
			renderSprite.removeChildren(beginIndex, endIndex, dispose);
		}
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			renderSprite.setChildIndex(child, index);
		}
		override public function sortChildren(compareFunction:Function):void
		{
			renderSprite.sortChildren(compareFunction);
		}
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			renderSprite.swapChildren(child1, child2);
		}
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			renderSprite.swapChildrenAt(index1, index2);
		}
	}
}