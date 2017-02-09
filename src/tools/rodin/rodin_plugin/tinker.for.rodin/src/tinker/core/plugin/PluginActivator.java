package tinker.core.plugin;

import org.eclipse.core.runtime.Plugin;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceStore;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import tinker.core.process.TinkerProcess;

/**
 * The activator class controls the plug-in life cycle
 */
public class PluginActivator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "tinker.for.rodin"; //$NON-NLS-1$

	// The shared instance
	private static PluginActivator plugin;
	
	/**
	 * The constructor
	 */
	public PluginActivator() {
	}
	
	//@Override
	public void start(BundleContext context) throws Exception {
		//super.start(context);
		plugin = this;
		enableAssertions();
	}

	/**
	 * Enable Java assertion checks for this plug-in.
	 */
	private void enableAssertions() {
		getClass().getClassLoader().setDefaultAssertionStatus(true);
	}

	//@Override
	public void stop(BundleContext context) throws Exception {
	    TinkerProcess.getInstance().Shutdown();
		plugin = null;
		//super.stop(context);
	}

	/**
	 * Returns the shared instance
	 *
	 * @return the shared instance
	 */
	public static PluginActivator getDefault() {
		return plugin;
	}



	

}
