package tinker.core.util;

import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.internal.core.seqprover.ProofTreeNode;

public class NodeReference {
	private final IProofTreeNode pTreeNode;
	public NodeReference(IProofTreeNode nodes) {
		this.pTreeNode=nodes;
	}
	
	public IProofTreeNode getNode(){
		return this.pTreeNode;
	}
	
    @Override
    public final int hashCode() {
        
        return System.identityHashCode(pTreeNode);
    }

    @Override
    public final boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final NodeReference other = (NodeReference) obj;
        return obj.hashCode() == this.hashCode();
    }
}
