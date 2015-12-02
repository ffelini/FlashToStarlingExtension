package managers.resourceManager
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.ImageDecodingPolicy;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

import starling.textures.Texture;

import starlingExtensions.flash.textureAtlas.ManagerAtlas_Dynamic;

import utils.log;

/*
import workers.abstract.WorkerFactory;
import workers.abstract.WorkerVO;
*/
	public class ManagerRemoteResource extends EventDispatcher
	{
		public static var loadInBackground:Boolean = false;
		
		public static var resourceByUrl:Dictionary;
		public static var texturesByUrl:Dictionary;
		public static var waitStack:Dictionary;
		public static var bmdProcessHandlers:Dictionary;
		
		public static const LOADING:String = "loading";
		public static const ERROR:String = "error";
		
		public static var DEBUG:Boolean = false;
		
		public static var context:LoaderContext;
		
		public function ManagerRemoteResource(_loadInBackground:Boolean=false)
		{
			super();
			clear();
			loadInBackground = _loadInBackground;
			context = new LoaderContext(false,ApplicationDomain.currentDomain)
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			//if(loadInBackground) initLoadingWorker();
		}
		public static function clear():void
		{
			urlsByLoader = new Dictionary();
			resourceByUrl = new Dictionary();
			texturesByUrl = new Dictionary();
			waitStack = new Dictionary();
			flashAtlasUsers = new Dictionary();
			bmdProcessHandlers = new Dictionary();
		}
		/*private static var imagesLoadingWorker:WorkerVO;
		private static function initLoadingWorker():void
		{
			imagesLoadingWorker = WorkerFactory.createWorker(Workers.workers_ImageLoadingWorker,false,onImageLoaded,true);
		}
		private static function onImageLoaded(e:Event):void
		{
			var imgVO:Object = imagesLoadingWorker.receive();
			var bmd:BitmapData = new BitmapData(imgVO.width,imgVO.height);
			
			bmd.setPixels(new Rectangle(0,0,bmd.width,bmd.height),imgVO.data as ByteArray);
			addImage(imgVO.url,bmd);
		}*/
		protected static function disposeLoader(loader:Loader):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onResourceComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onResourceIOError);
			loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onResourceHTTPStatus);
			
			try{
				loader.close();
			}catch(e:Error){}
			
			loader.contentLoaderInfo.bytes.clear();
			loader.contentLoaderInfo.loader.unload();
			
			delete urlsByLoader[loader.contentLoaderInfo];
		}
		public static var urlsByLoader:Dictionary;
		public static var flashAtlasUsers:Dictionary;
		public static function loadResource(url:String,useFlashAtlas:Boolean=true,maxSizeRect:Rectangle=null,bmdProcessHandler:Function=null):void
		{
			if(DEBUG) log("ResourceManager.loadResource",url);
			if(isLoading(url)) 
			{
				addResource(url,LOADING);
				return;
			}
			var resource:Object = getResource(url);
			if(resource && resource!=ERROR)
			{
				refreshSourcesForWaitStack(url);
				return;
			}
			//if(loadInBackground) imagesLoadingWorker.send(url);
			//else
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onResourceComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onResourceIOError);
			loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,onResourceHTTPStatus);
			
			if(useFlashAtlas) flashAtlasUsers[url] = useFlashAtlas;
			urlsByLoader[loader] = url;
			texturesByUrl[url] = maxSizeRect;
			bmdProcessHandlers[url] = bmdProcessHandler;
			
			if(loadStack.indexOf(url)<0) loadStack.push(url);
			
			loader.load(new URLRequest(url),context);
		}
		protected static function onResourceIOError(event:IOErrorEvent):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var url:String = urlsByLoader[loaderInfo.loader];
			if(DEBUG) log("ResourceManager.onResourceIOError(event)",url);

			disposeLoader(loaderInfo.loader);
			addResource(url,ERROR);
		}
		protected static function onResourceHTTPStatus(event:HTTPStatusEvent):void
		{
			event.target.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onResourceHTTPStatus);
			//log("ResourceManager.onImageHTTPStatus(event)", (event.target as LoaderInfo).loaderURL);
		}
		protected static function onResourceComplete(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			
			var url:String = urlsByLoader[loaderInfo.loader];
			
			var bmd:BitmapData = loaderInfo.content is Bitmap ? Bitmap(loaderInfo.content).bitmapData : null;
			addResource(url,bmd ? bmd : loaderInfo.content);
			
			disposeLoader(loaderInfo.loader);
		}
		protected static function addResource(url:String,data:*):void
		{
			resourceByUrl[url] = data;
			resourceByUrl[data] = url;
			
			var i:int = loadStack.indexOf(url);
			if(i>=0) loadStack.splice(i,1);
			
			if(data is BitmapData && flashAtlasUsers[url]) addSourceToAtlas(url,data as BitmapData);
			
			if(DEBUG) log("ResourceManager.addResource",data,url);
			if(data+""!=LOADING) refreshSourcesForWaitStack(url);
		}
		private static function addSourceToAtlas(url:String,bmd:BitmapData):void
		{
			ManagerAtlas_Dynamic.getInstance(url).addBitmapDataRegion(bmd,url,1,!loading,texturesByUrl[url] is Rectangle ? texturesByUrl[url] : null,bmdProcessHandlers[url]); 
		}
		public static function isLoading(url:String):Boolean
		{
			return getResource(url)==LOADING || loadStack.indexOf(url)>=0;
		}
		private static var loadStack:Vector.<String> = new Vector.<String>();
		public static function get loading():Boolean
		{
			return loadStack.length>0;
		}
		public static function getResource(url:String):*
		{
			return resourceByUrl[url];
		}
		public static function getTexture(url:String,newInstance:Boolean=false,generateMipMaps:Boolean=false):Texture 
		{
			var resource:* = getResource(url);
			var bmd:BitmapData = resource as BitmapData;
			if(!bmd) return resource as Texture;
			
			var t:Texture = texturesByUrl[url] is Texture ? texturesByUrl[url] : null;
			if(!t) t = ManagerAtlas_Dynamic.getInstance(url).getSubtexture(url);
			
			if(t && !newInstance) 
				return setTexture(url,t);
			else 
				t = Texture.fromBitmapData(bmd,generateMipMaps);
			
			return setTexture(url,t);
		}
		public static function setTexture(key:String,value:Texture):Texture
		{
			texturesByUrl[key] = value;
			return value;
		}
		public static function removeImage(url:String):void
		{
			delete resourceByUrl[url];
		}
		public static function addToWaitStack(url:String,waiter:IResource):void
		{
			var stack:Vector.<IResource> = getWaitStack(url);
			stack.push(waiter);
			if(DEBUG) log("ResourceManager.addToWaitStack",url,stack.length);
		}
		public static function removeFromWaitStack(url:String,waiter:IResource):void
		{
			var stack:Vector.<IResource> = getWaitStack(url);
			var i:int = stack.indexOf(url);
			
			if(i>=0) stack.splice(i,1);
			
			if(DEBUG) log("ResourceManager.addToWaitStack",url,stack.length);
		}
		public static function removeWaitStack(url:String):void
		{
			delete waitStack[url];
		}
		public static function refreshSourcesForWaitStack(url:String):void
		{
			var stack:Vector.<IResource> = getWaitStack(url);
			if(stack) 
			{
				if(DEBUG) log("ResourceManager.refreshSourcesForWaitStack",url,stack.length);
				var waiters:int = stack.length;
				for(var i:int=waiters-1;i>=0;i--)
				{
					var waiter:IResource = stack.pop();
					waiter.refreshSource(url);	
				}
			}
		}
		public static function getWaitStack(url:String):Vector.<IResource>
		{
			var stack:Vector.<IResource> = waitStack[url] as Vector.<IResource>;
			if(!stack)
			{
				stack = new Vector.<IResource>;
				waitStack[url] = stack;
			}
			return stack;
		}
	}
}