package {
import flash.display.Stage;
import flash.display.StageDisplayState;

public class FullScreenManager {

	private var stage:Stage;

	public function FullScreenManager() {
	}

	public function setStage(stage:Stage) {
		this.stage = stage;
	}

	public function toggleFullScreen():void {
		if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			stage.displayState = StageDisplayState.NORMAL;
		} else {
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
	}
}
}
