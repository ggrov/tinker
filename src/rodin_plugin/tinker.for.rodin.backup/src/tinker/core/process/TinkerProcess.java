package tinker.core.process;

import java.io.IOException;
import java.lang.ProcessBuilder.Redirect;

import tinker.core.plugin.PluginActivator;
import tinker.core.preference.PreferenceConstants;

public class TinkerProcess {
	private static final TinkerProcess INSTANCE = new TinkerProcess();
	private static Process ptinker=null;
	private TinkerProcess() {}
	
	public static TinkerProcess getInstance(){
		return INSTANCE;
	}
	
	public boolean isRunning(){
		if (ptinker==null){
			return false;
		}
		
		try{
			int i=ptinker.exitValue();
		}catch (IllegalThreadStateException  e){
			return true;
		}
		return false;
	}

	public void Shutdown(){
		if(isRunning()){
			ptinker.destroy();
		}
	}
	
	public Process getProcess() throws IOException{
		String path = PluginActivator.getDefault().getPreferenceStore().getString(PreferenceConstants.TINKER_PATH);
		
		Runtime rt = Runtime.getRuntime();
		if (ptinker==null || !isRunning()){
			
			ProcessBuilder pb = new ProcessBuilder(path);

			pb.redirectOutput(Redirect.INHERIT);
			pb.redirectError(Redirect.INHERIT);
			ptinker =pb.start();
		}
		
		
		return ptinker;
	}
}
	
	

