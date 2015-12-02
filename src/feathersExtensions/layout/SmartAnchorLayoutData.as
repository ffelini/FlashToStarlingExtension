package feathersExtensions.layout
{
import feathers.layout.AnchorLayoutData;

public class SmartAnchorLayoutData extends AnchorLayoutData
	{
		public var maxWidth:Number = NaN;
		public var maxHeight:Number = NaN;
		
		public var minWidth:Number = NaN;
		public var minHeight:Number = NaN;
		
		public function SmartAnchorLayoutData(top:Number=NaN, right:Number=NaN, bottom:Number=NaN, left:Number=NaN, horizontalCenter:Number=NaN, verticalCenter:Number=NaN,
												percentWidth:Number=NaN, percentHeight:Number=NaN)
		{
			super(top, right, bottom, left, horizontalCenter, verticalCenter);
			
			this.percentWidth = percentWidth;
			this.percentHeight = percentHeight;
		}
	}
}