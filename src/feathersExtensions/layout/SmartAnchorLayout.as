package feathersExtensions.layout
{
import feathers.core.FeathersControl;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;

import utils.ObjUtil;

public class SmartAnchorLayout extends AnchorLayout
	{
		public static var templateStageW:Number = 480;
		public static var templateStageH:Number = 762;
		
		public function SmartAnchorLayout()
		{
			super();
		}
		public function layoutChild(value:FeathersControl,l:Number=NaN,r:Number=NaN,t:Number=NaN,b:Number=NaN,hc:Number=NaN,vc:Number=NaN,pW:Number=NaN,pH:Number=NaN):SmartAnchorLayoutData
		{
			var d:SmartAnchorLayoutData = value.layoutData is SmartAnchorLayoutData ? value.layoutData as SmartAnchorLayoutData : new SmartAnchorLayoutData();
			if(!isNaN(l)) d.left = l;
			if(!isNaN(r)) d.right = r;
			if(!isNaN(t)) d.top = t;
			if(!isNaN(b)) d.bottom = b;
			if(!isNaN(hc)) d.horizontalCenter = hc;
			if(!isNaN(vc)) d.verticalCenter = vc;
			if(!isNaN(pW)) d.percentWidth = pW;
			if(!isNaN(pH)) d.percentHeight = pH;
			
			value.layoutData = d;
			return d;
		}
		public function setAnchors(value:FeathersControl,la:DisplayObject,ra:DisplayObject,ta:DisplayObject,ba:DisplayObject):void
		{
			var d:AnchorLayoutData = value.layoutData as AnchorLayoutData;
			if(!d) return;
			
			d.leftAnchorDisplayObject = la;
			d.rightAnchorDisplayObject = ra;
			d.topAnchorDisplayObject = ta;
			d.bottomAnchorDisplayObject = ba;
		}
		public function clone():AnchorLayout
		{
			return ObjUtil.cloneInstance(this) as AnchorLayout;
		}
	}
}