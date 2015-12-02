package managers
{
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import haxePort.managers.interfaces.IResetable;

import starlingExtensions.interfaces.IActivable;
import starlingExtensions.interfaces.IDataInstance;

import utils.log;

public class ObjPool
	{
		public static var DEBUG:Boolean = false;
		
		public function ObjPool()
		{
		}
		private static var _inst:ObjPool;
		public static function get inst():ObjPool
		{
			if(_inst) return _inst;
			_inst = new ObjPool();
			return _inst;
		}
		public var OBJ_POOL:Dictionary = new Dictionary();
		public function add(inst:Object,key:*):void
		{
			if(!inst || !key) return;
			
			var list:Array = getPool(key);
			
			if(list.indexOf(inst)<0) 
			{
				list.push(inst);
				if(inst is IActivable) (inst as IActivable).activate(false);
				if(inst is IResetable) (inst as IResetable).reset();
			}
			
			if(DEBUG) log(this,"add(inst, instClass)",key,list ? list.length : 0);
		}
		public function addInstances(instances:*,key:*,clearSource:Boolean=false):void
		{
			if(!instances || !key) return;
			for each(var inst:Object in instances)
			{
				if(inst is Array || inst is Vector || inst is XMLList) addInstances(inst,key,clearSource);
				else add(inst,key);
			}
			if(clearSource)
			{
				try{
					instances.length = 0;				
				}catch(e:Error){}
			}
		}
		public function get(key:*,instantiate:Boolean=true,...dataParams):Object
		{
			if(!key) return null;
			
			var list:Array = getPool(key);
			var inst:Object = list ? list.pop() : null;
			var isFromPool:Boolean = inst;
			
			try{ 
				if(!inst && instantiate && key is Class) inst = new key(); 
			}catch(e:Error){}
			
			if(inst is IDataInstance) (inst as IDataInstance).setData.apply(null,filterFuncParams((inst as IDataInstance).setData,dataParams));
			
			if(DEBUG) log(this,"get(objClass, instantiate, parameters)",key,inst,"isFromPool-"+isFromPool,list ? list.length : 0);
			
			return inst;
		}
		public function getPool(key:*):Array
		{
			var id:String = key is Class ? getQualifiedClassName(key) : key+"";
			var list:Array = OBJ_POOL[id];
			if(!list)
			{
				list = [];
				OBJ_POOL[id] = list;
			}
			return list;
		}
		public function clear(key:*):void
		{
			var list:Array = getPool(key);
			if(list) list.length = 0;
		}
		public static function functionCall(func:Function,...parameters):Array
		{
			if(func==null) return null;
			parameters = filterFuncParams(func,parameters);
			func.apply(null,parameters);
			return parameters;
		}
		private static function filterFuncParams(func:Function,params:Array):Array
		{
			if(func==null) return null;
			
			var params:Array = params.splice(0,func.length);
			if(params.length<func.length) params[func.length-1] = null;
			return params;
		}
	}
}