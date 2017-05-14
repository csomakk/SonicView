package {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.utils.Dictionary;

public class CacheManager {

	private var cacheDictionary:Dictionary = new Dictionary();

	private var cachedPaths:Array = [];

	private var loaderInProgress:Loader;

	private var cacheNativePathInProgress:String;

	private const CACHE_MAX_FILES:int = 10;

	public function CacheManager() {
	}

	public function getFromCache(fileNativePath:String):Bitmap {
		if (cacheDictionary[fileNativePath]) {
			return cacheDictionary[fileNativePath];
		}
		return null;
	}

	public function saveToCache(fileNativePath:String, bitmap:Bitmap):void {
		cacheDictionary[fileNativePath] = bitmap;
	}

	public function cache(fileNativePath:String):void {
		if (cacheDictionary[fileNativePath]) {
			trace('was already cached', fileNativePath);
			return;
		}
		var file:File = new File();
		file.nativePath = fileNativePath;
		if (file.exists) {
			file.addEventListener(Event.COMPLETE, loadCompleteHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			file.load();
			cacheNativePathInProgress = fileNativePath;
		}
	}

	private function onIoError(event:IOErrorEvent):void {
		trace('CacheManager.onIoError');
	}

	private function loadCompleteHandler(event:Event):void {
		if (loaderInProgress) {
			loaderInProgress.unloadAndStop(true);
		}
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		if (event.target.data != null) {
			loader.loadBytes(event.target.data);
		} else {
			trace("bytes were null of file!");
		}
		loaderInProgress = loader;
	}

	private function loadBytesHandler(event:Event):void {
		var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);
		cacheDictionary[cacheNativePathInProgress] = Bitmap(loaderInfo.content);
		cachedPaths.push(cacheNativePathInProgress);
		trace("cached: ", cacheNativePathInProgress);
		cacheNativePathInProgress = null;
		garbageCollectCache();
	}

	private function garbageCollectCache():void {
		if (cachedPaths.length > CACHE_MAX_FILES) {
			var lastUsed:String = cachedPaths.reverse().pop();
			cacheDictionary[lastUsed] = null;
			trace('removed from cache: ', lastUsed);
			cachedPaths.reverse();
		}
	}


}
}
