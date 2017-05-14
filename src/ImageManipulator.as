package {
import flash.filesystem.File;

public class ImageManipulator {

	public function ImageManipulator() {
	}

	public function deleteFile(nativePath:String):void {
		var file:File = new File(nativePath);
		file.deleteFile()
	}

}
}
