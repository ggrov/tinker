package tinker.core.tactics;

import javax.sound.midi.Soundbank;

import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;

import tinker.core.command.Command;
import tinker.core.command.CommandExecutor;
import tinker.core.command.CommandParser;
import tinker.core.socket.TinkerConnector;

public class TinkerTactic implements ITactic {

	@Override
	public Object apply(IProofTreeNode ptNode, IProofMonitor pm) {
		pm.setTask("Wait for Tinker..");
		CommandExecutor.clear();
		TinkerConnector tinker = new TinkerConnector(pm);
		String result = null;
		boolean isException=false;
		tinker.serve();
		while (pm != null && !pm.isCanceled()
				&& tinker.getState() == TinkerConnector.STATE_CONNECTED) {
			String read = tinker.receive();
			if (tinker.getState() == TinkerConnector.STATE_CONNECTED) {
				try {
					Command cmd = (new CommandParser()).parseCommand(read);
					result = CommandExecutor.execute(cmd, ptNode, pm, tinker);
					tinker.send(result);
				} catch (Exception ex) {
					result= "ERROR";
					isException=true;
					ex.printStackTrace();
					break;
				}
				
			} else if (tinker.getState() == TinkerConnector.STATE_TERMINATED) {
				break;
			} else {
				result = read;
				break;
			}

		}
		if (!isException) result=null;
		tinker.close();
		System.out.println("Disconnected. Tinker Tactics complete.");
		// pm.setCanceled(true);
		return result;
	}

}
