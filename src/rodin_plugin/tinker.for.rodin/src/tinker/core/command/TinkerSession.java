package tinker.core.command;

import java.util.HashMap;

import org.eclipse.ui.IWorkbenchWindow;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;

public class TinkerSession {

	// SOCKET STATES
	public static int SOCKET_STATE_LISTENING = 100;
	public static int SOCKET_STATE_CONNECTED = 200;
	public static int SOCKET_STATE_DISCONNECTED = 300;

	// RODIN PLUGIN STATE
	public static int RP_STATE_READY = 1000;
	public static int RP_STATE_WAITING_COMMAND = 1001;
	public static int RP_STATE_EXECUTING = 1002;

	public static int RP_STATE_DISCONNECTING_WITH_ERROR = 1003;
	public static int RP_STATE_DISCONNECTING_FROM_TINKER = 1004;

	public static int RP_STATE_CANCELLING_LISTENING = 2001;
	public static int RP_STATE_CANCELLING_WAITING_COMMAND = 2002;
	public static int RP_STATE_CANCELLING_EXECUTING = 2003;

	public static int RP_STATE_CANCELLED = 2004;

	public static int RP_STATE_EXCEPTION = 2005;

	// RODIN PROVER STATE

	// Rodin states does not affect anything. This is just a state used in
	// modeling.
	// The mechanism of Rodin states is implemented already by Rodin.
	public static int RODIN_STATE_NO_OBLIGATION = 3001;
	public static int RODIN_STATE_OBLIGATION = 3002;
	public static int RODIN_STATE_APPLYING = 3003;
	public static int RODIN_STATE_APPLICATION_DONE = 3004;

	public HashMap<String, IProofTreeNode> nameToNodeMap = new HashMap<>();
	public HashMap<IProofTreeNode, String> nodeToNameMap = new HashMap<>();

	private String sessionCode;
	private IWorkbenchWindow workbenchWindow;

	private int SocketState = SOCKET_STATE_DISCONNECTED;
	private int RodinPluginSate = RP_STATE_READY;
	private int RodinState = RODIN_STATE_NO_OBLIGATION;

	private IProofMonitor pm;

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

	public int getRodinPluginSate() {
		return RodinPluginSate;
	}

	public void setRodinPluginSate(int rodinPluginSate) {
		RodinPluginSate = rodinPluginSate;
	}

	public int getRodinState() {
		return RodinState;
	}

	public void setRodinState(int rodinState) {
		RodinState = rodinState;
	}

}
