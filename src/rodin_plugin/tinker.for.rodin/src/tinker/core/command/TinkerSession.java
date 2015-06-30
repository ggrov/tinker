package tinker.core.command;

import java.util.HashMap;

import org.eventb.core.seqprover.IProofTreeNode;

public class TinkerSession {
	public HashMap<String, IProofTreeNode> nameToNodeMap = new HashMap<>();
	public HashMap<IProofTreeNode, String> nodeToNameMap = new HashMap<>();
	
	
	
	public String getSessionCode(){
		return String.valueOf(this.hashCode());
	}
	
	
	
}
