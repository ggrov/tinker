package tinker.core.process;

import java.io.IOException;
import java.lang.ProcessBuilder.Redirect;

import tinker.core.plugin.PluginActivator;
import tinker.core.preference.PreferenceConstants;

public class TinkerProcess {
	private static final TinkerProcess INSTANCE = new TinkerProcess();
	private static Process ptinker=null;
	private TinkerProcess() {}
	
	private static final class OsUtils
	{
		   private static String OS = null;
		   public static String getOsName()
		   {
		      if(OS == null) { OS = System.getProperty("os.name"); }
		      return OS;
		   }
		   public static boolean isWindows()
		   {
		      return getOsName().startsWith("Windows");
		   }

		   public static boolean isUnix(){
			   // and so on
			   return !getOsName().startsWith("Windows");
		   }
		}
	
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
			System.out.println(path);
			pb.redirectOutput(Redirect.INHERIT);
			pb.redirectError(Redirect.INHERIT);
			ptinker =pb.start();
		}
		
		if (ptinker==null){
			return null;
		}
		
		return ptinker;
	}
}
	
	

