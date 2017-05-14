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

	public function ImageLoader() {
	}

	public function loadImage(nativePath:String):void {
		file = new File();
		file.nativePath = nativePath;
		if (file.parent != currentDirectory) {
			currentDirectory = file.parent;
			currentDirectoryContent = currentDirectory.getDirectoryListing();
			currentDirectoryContentLength = currentDirectory.length;
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
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
		loader.loadBytes(file.data);
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
		while (currentDelta < currentFileNumberOfDirectory && notFound) {
			proposedCurrentId = ((currentFileNumberOfDirectory + currentDelta) % currentDirectoryContentLength + currentDirectoryContentLength) % currentDirectoryContent.length; //positive modulo
			notFound = supportedExtensions.indexOf((currentDirectoryContent[proposedCurrentId] as File).extension) == -1;
			if (notFound) {
				currentDelta += delta;
			}
		}

		loadImage(currentDirectoryContent[proposedCurrentId].nativePath);
	}

}
}
