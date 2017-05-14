package {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

import mx.core.FlexGlobals;

public class ImageLoader {

	private var file:File;
	private var currentDirectory:File;

	[Bindable]
	public var currentDirectoryContent:Array;

	[Bindable]
	public var currentDirectoryContentLength:int;

	[Bindable]
	public var currentFileNumberOfDirectory:int;

	[Bindable]
	public var lastLoadedImageSource:Bitmap;

	[Bindable]
	public var lastLoadedImagePath:String = "";

	private const supportedExtensions:Array = ["jpg", "jpeg", "png"];

	private var loaderInProgress:Loader;

	public function ImageLoader() {
	}

	public function loadImage(nativePath:String):void {
		lastLoadedImagePath = nativePath;
		var cached:Bitmap = (FlexGlobals.topLevelApplication as Main).cacheManager.getFromCache(nativePath);
		if (cached) {
			trace("got cached image ", nativePath);
			lastLoadedImageSource = cached;
			updateCurrentFileNumberOfDirectory(nativePath);
			cacheDelta(1);
		} else {
			file = new File();
			file.nativePath = nativePath;
			if (file.parent != currentDirectory) {
				currentDirectory = file.parent;
				currentDirectoryContent = currentDirectory.getDirectoryListing();
				currentDirectoryContentLength = currentDirectoryContent.length;
			}
			if (file.exists) {
				file.addEventListener(Event.COMPLETE, loadCompleteHandler);
				file.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				file.load();
				updateCurrentFileNumberOfDirectory(file.nativePath);
			}
		}
	}

	private function updateCurrentFileNumberOfDirectory(nativePath:String):void {
		for (var i:int = 0; i < currentDirectoryContentLength; i++) {
			var currentDirectoryFile:File = currentDirectoryContent[i];
			if (nativePath == currentDirectoryFile.nativePath) {
				currentFileNumberOfDirectory = i;
				return;
			}
		}
	}

	private function onIoError(event:IOErrorEvent):void {
		trace('ImageLoader.onIoError');
	}

	private function loadCompleteHandler(event:Event):void {
		if (loaderInProgress) {
			loaderInProgress.unloadAndStop(true);
		}
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		if (file.data != null) {
			loader.loadBytes(file.data);
		} else {
			trace("bytes were null of file!");
		}
		loaderInProgress = loader;
	}

	private function loadBytesHandler(event:Event):void {
		var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);
		lastLoadedImageSource = Bitmap(loaderInfo.content);
		(FlexGlobals.topLevelApplication as Main).cacheManager.saveToCache(file.nativePath, lastLoadedImageSource);
		cacheDelta(1);
	}

	private function cacheDelta(delta:int):void {
		var proposedPath:String = getDeltaFileNativePath(delta);

		if (proposedPath) {
			(FlexGlobals.topLevelApplication as Main).cacheManager.cache(proposedPath);
		} else {
			trace('ImageLoader.cacheDelta() no openable files found');
		}
	}

	public function loadNext():void {
		loadDelta(1);
	}

	public function loadPrev():void {
		loadDelta(-1);
	}

	private function getDeltaFileNativePath(delta:int):String {
		var currentDelta:int = delta;
		var notFound:Boolean = true;
		var proposedCurrentId:int;
		var proposedFile:File;
		while (Math.abs(currentDelta) < currentDirectoryContentLength && notFound) {
			proposedCurrentId = ((currentFileNumberOfDirectory + currentDelta) % currentDirectoryContentLength + currentDirectoryContentLength) % currentDirectoryContent.length; //positive modulo
			proposedFile = currentDirectoryContent[proposedCurrentId];
			var proposedExtension:String = proposedFile.extension;
			if (proposedExtension) {
				proposedExtension = proposedExtension.toLowerCase();
			}
			notFound = supportedExtensions.indexOf(proposedExtension) == -1 || proposedFile.isDirectory; // not found if unsupported or directory
			if (notFound) {
				currentDelta += delta;
			}
		}
		return proposedFile.nativePath;
	}

	private function loadDelta(delta:int):void {
		var proposedPath:String = getDeltaFileNativePath(delta);

		if (proposedPath) {
			loadImage(proposedPath);
		} else {
			trace('ImageLoader.loadDelta no openable files found');
		}
	}

}
}
