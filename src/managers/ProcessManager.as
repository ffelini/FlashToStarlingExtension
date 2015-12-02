package managers
{
import flash.sampler.getSavedThis;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import mx.utils.NameUtil;

import utils.log;

public dynamic class ProcessManager extends Array
	{
		/**
		 * Abstract class that register working state of any process. 
		 * 
		 */		
		public function ProcessManager()
		{
			length = 0;
		}
		private static var _inst:ProcessManager;
		public static function get inst():ProcessManager
		{
			if(!_inst) _inst = new ProcessManager();
			
			return _inst;
		}
		private var proceses:Dictionary = new Dictionary();
		/**
		 * 
		 * @param processID - any instance or value that may be used as identifier for for an process work.
		 * @param isLoading - value to update working state of the process
		 * @return the manager loading state. Returns true if still have processes in working state
		 * 
		 */		
		protected var processIDS:Dictionary = new Dictionary();
		public function process(processID:*="defaultProcess",_isWorking:Boolean=true,trackProcessWorkingTime:Boolean=true):Boolean
		{
			var f:Function
			
			if(!processIDS[processID])
			{
				var uid:String = NameUtil.createUniqueName(processID);
				if(processID is Function) 
				{
					uid = getSavedThis(processID as Function)+"."+processID;
					processIDS[processID] = uid;
					processID = uid;
				}
			}
			else processID = processIDS[processID];
			
			if(processID)
			{
				var i:int = indexOf(processID);
			
				if(_isWorking) 
				{
					if(i<0) 
					{
						push(processID);
						proceses[processID] = getTimer();
					}
				}
				else if(i>=0) 
				{
					var processTimeStamp:Number = proceses[processID];
					var duration:Number = getTimer() - processTimeStamp;

					splice(i,1);
					delete proceses[processID];
				}
				log("----- ProcessManager","process","processID-"+processID,"processWorkingState-"+_isWorking,"duration-"+duration,"workingProcesess-"+length,"waiting stack-"+this);
			}
			return length>0;
		}
		public function processIsWorking(processID:String):Boolean
		{
			return indexOf(processID)>=0;
		}
		public function get isWorking():Boolean
		{
			return length>0;
		}
	}
}