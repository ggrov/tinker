package tinker.core.execute;

import java.util.HashMap;

import org.eclipse.ui.IWorkbenchWindow;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;

import tinker.core.states.PluginStates;
import tinker.core.states.SocketStates;
import tinker.core.states.TacticStates;

public class TinkerSession {

	public HashMap<String, IProofTreeNode> nameToNodeMap = new HashMap<>();
	public HashMap<IProofTreeNode, String> nodeToNameMap = new HashMap<>();

	private String sessionCode;
	private IWorkbenchWindow workbenchWindow;

	
	//Initialisation
	private int SocketState = SocketStates.DISCONNECTED;
	private int PluginSate = PluginStates.READY;
	private int TacticState = TacticStates.NOT_APPLICABLE;

	private IProofMonitor pm;
	
	private String psgraph;
	
	

	public TinkerSession(IWorkbenchWindow workbench, IProofMonitor pm) {
		this.sessionCode = String.valueOf((new Object()).hashCode());
		this.workbenchWindow = (workbench);
		this.pm = pm;
	}

	public IProofMonitor getMonitor(){
		return this.pm;
	}
	
	public String getSessionCode() {
		return String.valueOf(this.hashCode());
	}

	public IWorkbenchWindow getWorkbenchWindow() {
		return workbenchWindow;
	}

	public int getSocketState() {
		return SocketState;
	}

	public void setSocketState(int socketState) {
		SocketState = socketState;
	}

	public int getPluginSate() {
		return PluginSate;
	}

	public void setPluginSate(int rodinPluginSate) {
		PluginSate = rodinPluginSate;
	}

	public int getTacticState() {
		return TacticState;
	}

	public void setTacticState(int rodinState) {
		TacticState = rodinState;
	}

	public String getPsgraph() {
		return psgraph;
	}

	public void setPsgraph(String psgraph) {
		this.psgraph = psgraph;
	}

}
