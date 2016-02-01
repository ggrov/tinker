package tinker.core.process;

import java.io.File;
import java.io.IOException;
import java.lang.ProcessBuilder.Redirect;

import tinker.core.plugin.PluginActivator;
import tinker.core.preference.PreferenceConstants;

public class TinkerGUIProcess {
	private static final TinkerGUIProcess INSTANCE = new TinkerGUIProcess();
	private static Process gui = null;

	private TinkerGUIProcess() {
	}

	public static TinkerGUIProcess getInstance() {
		return INSTANCE;
	}

	private boolean isRunning() {
		if (gui == null) {
			return false;
		}

		try {
			int i = gui.exitValue();
		} catch (IllegalThreadStateException e) {
			return true;
		}
		return false;
	}

	public void Shutdown() {
		if (isRunning()) {
			gui.destroy();
		}
	}

	public Process getProcess() throws IOException {
		String path = PluginActivator.getDefault().getPreferenceStore().getString(PreferenceConstants.GUI_PATH);
		if (gui == null || !isRunning()) {

			int i = path.lastIndexOf("/");
			if (i < 0)
				i = path.lastIndexOf("\\");
			File dir = new File(path.substring(0, i+1));

			ProcessBuilder pb = new ProcessBuilder("java","-jar", path);
			pb.directory(dir);
			pb.redirectOutput(Redirect.INHERIT);
			pb.redirectError(Redirect.INHERIT);
			gui=pb.start();
		}
		return gui;
	}
}
