package {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

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
	public var lastLoadedImagePath:String;

	private const supportedExtensions:Array = ["jpg", "jpeg", "png"];

	private var loaderInProgress:Loader;

	public function ImageLoader() {
	}

	public function loadImage(nativePath:String):void {
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
			lastLoadedImagePath = nativePath;
			updateCurrentFileNumberOfDirectory();
		}
	}

	private function updateCurrentFileNumberOfDirectory():void {
		for (var i:int = 0; i < currentDirectoryContentLength; i++) {
			var currentDirectoryFile:File = currentDirectoryContent[i];
			if (file.nativePath == currentDirectoryFile.nativePath) {
				currentFileNumberOfDirectory = i;
				return;
			}
		}
	}

	private function onIoError(event:IOErrorEvent):void {
		trace('IOERROR');
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
	}

	public function loadNext():void {
		loadDelta(1);
	}

	public function loadPrev():void {
		loadDelta(-1);
	}

	private function loadDelta(delta:int):void {
		var currentDelta:int = delta;
		var notFound:Boolean = true;
		var proposedCurrentId:int;
		var proposedFile:File;
		while (Math.abs(currentDelta) < currentDirectoryContentLength && notFound) {
			proposedCurrentId = ((currentFileNumberOfDirectory + currentDelta) % currentDirectoryContentLength + currentDirectoryContentLength) % currentDirectoryContent.length; //positive modulo
			proposedFile = currentDirectoryContent[proposedCurrentId];
			trace(proposedFile.nativePath);
			notFound = supportedExtensions.indexOf(proposedFile.extension) == -1 || proposedFile.isDirectory; // not found if unsupported or directory
			if (notFound) {
				currentDelta += delta;
			}
		}

		if (!notFound) {
			loadImage(proposedFile.nativePath);
		} else {
			trace('no openable files found');
		}
	}

}
}
