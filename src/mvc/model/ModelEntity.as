package mvc.model
{
import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

public class ModelEntity extends Proxy
	{
		/**
		 * Constructor.
		 */
		public function ModelEntity(data:Object=null)
		{
			setData(data);
		}
		/**
		 * Creates a <code>PropertyProxy</code> from a regular old <code>Object</code>.
		 */
		public static function fromObject(source:Object, onChangeCallback:Function = null):ModelEntity
		{
			const newValue:ModelEntity = new ModelEntity(onChangeCallback);
			for(var propertyName:String in source)
			{
				newValue[propertyName] = source[propertyName];
			}
			return newValue;
		}
		
		public function setData(data:Object=null):void
		{
			if(!data) return;
			for(var prop:String in data)
			{
				setPropertyValue(prop,data[prop]);
			}
			data = null;
		}
		protected function setPropertyValue(prop:String,value:*):Boolean
		{
			if(this.hasOwnProperty(prop)) 
			{
				try{
					this[prop] = value;
				}catch(e:Error){return false}
				return true;
			}
			return false;
		}
		public function reset():void
		{
			
		}
		public function toString():String
		{
			return "";
		}	
		private var bindersByPropName:Array = new Array();
		public function bind(propName:String,target:Object,targetPropName:String):void
		{
			var binders:Dictionary = bindersByPropName[propName];
			if(!binders) 
			{
				binders = new Dictionary();
				bindersByPropName[propName] = binders;
			}
			var targetPropNames:Array = binders[target];
			if(!targetPropNames) 
			{
				targetPropNames = [];
				binders[target] = targetPropNames;
			}
			if(targetPropNames.indexOf(targetPropName)<0) targetPropNames.push(targetPropName);
		}
		public function unbind(propName:String,target:Object,targetPropName:String):void
		{
			var binders:Dictionary = bindersByPropName[propName];
			if(binders)
			{
				var targetPropNames:Array = binders[target];
				
				var i:int = targetPropNames.indexOf(targetPropName);
				if(i>=0) targetPropNames.splice(i,1);
			}
		}
		private function processBinders(propName:String):void
		{
			var binders:Dictionary = bindersByPropName[propName];
			for each(var binder:Object in binders)
			{
				var targetPropNames:Array = binders[binder];
				for each(var targetPropName:String in targetPropNames)
				{
					if(binder.hasOwnProperty(targetPropName)) binder[targetPropName] = this[propName];
				}
			}
		}
		/**
		 * @private
		 */
		private var _subProxyName:String;
		
		/**
		 * @private
		 */
		private var _onChangeCallbacks:Vector.<Function> = new <Function>[];
		
		/**
		 * @private
		 */
		private var _names:Array = [];
		
		/**
		 * @private
		 */
		private var _storage:Object = {};
		
		/**
		 * @private
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return this._storage.hasOwnProperty(name);
		}
		
		/**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if(this.flash_proxy::isAttribute(name))
			{
				const nameAsString:String = name is QName ? QName(name).localName : name.toString();
				if(!this._storage.hasOwnProperty(nameAsString))
				{
					const subProxy:ModelEntity = new ModelEntity(subProxy_onChange);
					subProxy._subProxyName = nameAsString;
					this._storage[nameAsString] = subProxy;
					this._names.push(nameAsString);
					this.fireOnChangeCallback(nameAsString);
				}
				return this._storage[nameAsString];
			}
			return this._storage[name];
		}
		
		/**
		 * @private
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			const nameAsString:String = name is QName ? QName(name).localName : name.toString();
			this._storage[nameAsString] = value;
			if(this._names.indexOf(nameAsString) < 0)
			{
				this._names.push(nameAsString);
			}
			this.setPropertyValue(name,value);
			this.fireOnChangeCallback(nameAsString);
		}
		
		/**
		 * @private
		 */
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			const nameAsString:String = name is QName ? QName(name).localName : name.toString();
			const index:int = this._names.indexOf(nameAsString);
			if(index >= 0)
			{
				this._names.splice(index, 1);
			}
			const result:Boolean = delete this._storage[nameAsString];
			if(result)
			{
				this.fireOnChangeCallback(nameAsString);
			}
			return result;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if(index < this._names.length)
			{
				return index + 1;
			}
			return 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return this._names[index - 1];
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			const name:* = this._names[index - 1];
			return this._storage[name];
		}
		
		/**
		 * Adds a callback to react to property changes.
		 */
		public function addOnChangeCallback(callback:Function):void
		{
			this._onChangeCallbacks.push(callback);
		}
		
		/**
		 * Removes a callback.
		 */
		public function removeOnChangeCallback(callback:Function):void
		{
			const index:int = this._onChangeCallbacks.indexOf(callback);
			if(index >= 0)
			{
				this._onChangeCallbacks.splice(index, 1);
			}
		}
		
		/**
		 * @private
		 */
		private function fireOnChangeCallback(forName:String):void
		{
			const callbackCount:int = this._onChangeCallbacks.length;
			for(var i:int = 0; i < callbackCount; i++)
			{
				var callback:Function = this._onChangeCallbacks[i] as Function;
				callback(this, forName);
			}
			processBinders(forName);
		}
		
		/**
		 * @private
		 */
		private function subProxy_onChange(proxy:ModelEntity, name:String):void
		{
			this.fireOnChangeCallback(proxy._subProxyName);
		}
	}
}