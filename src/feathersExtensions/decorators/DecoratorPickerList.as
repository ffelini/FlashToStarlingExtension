package feathersExtensions.decorators
{
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.core.FeathersControl;

import feathersExtensions.controls.SmartGroupedList;
import feathersExtensions.controls.SmartList;
import feathersExtensions.controls.dateChooser.FeathersDateListChooser;
import feathersExtensions.popUp.SmartAlert;
import feathersExtensions.renderers.SmartGroupedIR;
import feathersExtensions.renderers.SmartIR;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

import managers.ObjPool;

import starling.display.Stage;
import starling.events.Event;

import starlingExtensions.decorators.Decorator;

import utils.Range;

public class DecoratorPickerList extends Decorator
	{
		public function DecoratorPickerList()
		{
			super();
			enableMultipleDecoration = true;
		}
		/**
		 * 
		 * @param value - SmartList or SmartGroupedList
		 * @param _decorate
		 * @param params[0] - data to be updated, 
		 * params[1] - data properties array, 
		 * params[2] - objec with same properties as in params[1] but with values of Array type that contains the property possible values, 
		 * params[3] - pickerList class (SmartList subclass)
		 * params[4] - pickerList allowMultipleSelection
		 * parasm[5] - pickerList itemRendererProperties
		 * @return 
		 * 
		 */		
		override public function decorate(value:Object, _decorate:Boolean, params:Array=null):Boolean
		{
			if(!value) return false;
			
			var decorated:Boolean = super.decorate(value, _decorate, params);
			
			value.removeEventListener(Event.CHANGE,onItemSelected);
			
			if(!_decorate) return decorated;
			
			if(_decorate) value.addEventListener(Event.CHANGE,onItemSelected); 
			
			value.dataProviderSource = params[1];
			value.autoToggleSelection = false;
			
			return decorated;
		}
		public var dateListChooser:FeathersDateListChooser;
		public var pickerList:SmartList;
		protected var stage:Stage;
		
		protected var curentList:SmartList;
		protected var curentGroupedList:SmartGroupedList;
		public var selectedItem:Object;
		protected var curentData:Object;
		protected var curentDataProperties:Array;
		protected var curentPropertyPossibleValues:Array;

		protected var curentDecorationPrams:Array;
		protected function onItemSelected(e:Event):void
		{
			curentList = e.target as SmartList
			curentGroupedList = e.target as SmartGroupedList;
			
			selectedItem = curentList ? curentList.selectedItem : (curentGroupedList ? curentGroupedList.selectedItem : null);
			if(!selectedItem) return;
			
			curentDecorationPrams = decorationParams[e.target];
			curentData = curentDecorationPrams[0];
			curentDataProperties = curentDecorationPrams[1];
			curentPropertyPossibleValues = curentDecorationPrams[2][selectedItem] is Array ? curentDecorationPrams[2][selectedItem] : null;
			
			var pickerListClass:Class = curentDecorationPrams[3] ? curentDecorationPrams[3] : SmartList;
			stage = curentList ? curentList.stage : (curentGroupedList ? curentGroupedList.stage : null);
			
			var dataValue:* = selectedItem ? curentData[selectedItem] : null;
			if(selectedItem && !(curentPropertyPossibleValues is Range) && curentPropertyPossibleValues is Array) 
			{
				if(curentPropertyPossibleValues && curentPropertyPossibleValues.length>0)
				{
					if(!(pickerList is pickerListClass)) pickerList = ObjPool.inst.get(pickerListClass) as SmartList; 
					pickerList.autoToggleSelection = false;
					pickerList.autoScrollToSelectedItem = true;
					
					pickerList.itemRendererProperties = curentDecorationPrams[5] ? curentDecorationPrams[5] : {"useStateDelayTimer":false};
					pickerList.dataProviderSource = curentPropertyPossibleValues;
					pickerList.invalidateItemRenderersData();
					
					pickerList.setSize(stage.stageWidth*0.7,stage.stageHeight*0.5);
					
					var selectedItems:Vector.<Object> = dataValue as Vector.<Object>;
					if(!selectedItem) selectedItems = dataValue is Array ? Vector.<Object>(dataValue as Array) : new Vector.<Object>(dataValue);
					
					if(pickerList.allowMultipleSelection) pickerList.selectedItems = selectedItems;
					else pickerList.selectedItem = dataValue;
					
					pickerList.allowMultipleSelection = curentDecorationPrams[4];
					SmartAlert.show("","Make your choice",pickerList,SmartAlert.YES_NO_COLLECTION,true,true,null,null,onValueSelected);
				}
			}
			switch(curentDecorationPrams[2][selectedItem])
			{
				case "Date":
				{
					dateListChooser = ObjPool.inst.get(FeathersDateListChooser) as FeathersDateListChooser;
					dateListChooser.date = dataValue;
					dateListChooser.setSize(stage.stageWidth*0.7,stage.height*0.6);
					SmartAlert.show("","Set up your birth date",dateListChooser,SmartAlert.YES_NO_COLLECTION,true,true,null,null,onDateChoosed);
					break;
				}
			}
		}
		private function onDateChoosed(alert:SmartAlert,data:Object):void
		{
			if(data==SmartAlert.YES_DATA) updateSelectedUserValue(dateListChooser.date);
			unSelect();
		}
		private function onValueSelected(alert:SmartAlert,data:Object):void
		{
			if(data==SmartAlert.YES_DATA && selectedItem && pickerList.selectedItem)
					updateSelectedUserValue(pickerList.allowMultipleSelection ? pickerList.selectedItems : pickerList.selectedItem);
						
			unSelect();
		}
		protected function unSelect():void
		{
			if(curentList) curentList.unSelect()
			else if(curentGroupedList) curentGroupedList.unSelect();
		}
		protected function updateSelectedUserValue(value:*):void
		{
			if(curentData is Proxy) (curentData as Proxy).flash_proxy::setProperty(selectedItem+"",value);
			else curentData[selectedItem+""] = value;
			
			var ir:BaseDefaultItemRenderer;
			if(curentList) 
			{
				ir = curentList.getItemRenderer(curentList.selectedItem) as BaseDefaultItemRenderer;
			}
			if(curentGroupedList)
			{
				ir = curentGroupedList.getItemRenderer(curentGroupedList.selectedItem) as BaseDefaultItemRenderer;
			}
			
			if(!(ir is SmartIR) || !(ir is SmartGroupedIR)) ir.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		}
	}
}