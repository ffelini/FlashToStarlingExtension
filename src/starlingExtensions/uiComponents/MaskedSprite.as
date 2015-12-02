package starlingExtensions.uiComponents
{
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.RenderTexture;

public class MaskedSprite extends Sprite
	{
	
		public var mask:DisplayObject;
		
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			var _this:MaskedSprite = this;
			if (mask != null)
			{
				RenderTexturePool.instance.getTemporal(function(eraserTexture:RenderTexture):void {
					RenderTexturePool.instance.getTemporal(function(composedTexture:RenderTexture):void {
						eraserTexture.clear();
						composedTexture.clear();
						
						eraserTexture.draw(new Quad(eraserTexture.width, eraserTexture.height, 0xFF0000)); mask.blendMode = BlendMode.ERASE;
						
						mask.visible = true;
						eraserTexture.draw(mask, mask.getTransformationMatrix(Starling.current.root));
						mask.visible = false;
						
						for (var n:int = 0; n < numChildren; n++) composedTexture.draw(getChildAt(n), support.modelViewMatrix);
						
						var eraserImage:Image = new Image(eraserTexture);
						eraserImage.blendMode = BlendMode.ERASE;
						composedTexture.draw(eraserImage);
						
						support.pushMatrix();
						support.loadIdentity();
						new Image(composedTexture).render(support, parentAlpha);
						support.popMatrix();
					});
				});
			}
			else
			{
				super.render(support, parentAlpha);
			}
		}
	}
}

import flash.utils.Dictionary;

import starling.core.Starling;
import starling.textures.RenderTexture;

class RenderTexturePool
{
	private var availableInstances:Array = [];
	private var usingInstances:Dictionary = new Dictionary();
	static public const instance:RenderTexturePool = new RenderTexturePool();
	
	public function getTemporal(callback:Function):void
	{
		var texture:RenderTexture = get();
		try {
			callback(texture);
		} finally {
			release(texture);
		}
	}
	
	private function get stageWidth():int { return Starling.current.stage.stageWidth; }
	private function get stageHeight():int { return Starling.current.stage.stageHeight; }
	
	private function createNewInstance():RenderTexture
	{
		return new RenderTexture(stageWidth, stageHeight, true);
	}
	
	private function get():RenderTexture
	{
		if (availableInstances.length <= 0) availableInstances.push(createNewInstance());
		var instance:RenderTexture = availableInstances.pop();
		if (instance.width != stageWidth || instance.height != stageHeight)
		{
			instance.dispose();
			instance = createNewInstance();
		}
		usingInstances[instance] = true;
		return instance;
	}
	
	private function release(renderTexture:RenderTexture):void
	{
		if (usingInstances[renderTexture]) {
			delete renderTexture[renderTexture];
			availableInstances.push(renderTexture);
		}
	}
}