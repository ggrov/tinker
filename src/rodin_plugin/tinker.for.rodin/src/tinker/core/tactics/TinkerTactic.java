package tinker.core.tactics;

import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;

import tinker.core.command.Command;
import tinker.core.command.CommandExecutor;
import tinker.core.command.CommandParser;
import tinker.core.command.TinkerSession;
import tinker.core.socket.TinkerConnector;

public class TinkerTactic implements ITactic {

	@Override
	public Object apply(IProofTreeNode ptNode, IProofMonitor pm) {

		pm.setTask("Wait for Tinker..");
		TinkerSession session = new TinkerSession();
		TinkerConnector tinker = new TinkerConnector(pm);
		String result = null;
		boolean isException = false;

		do {
			tinker.serve();
			String read = tinker.receive();

			if (read.equals("TINKER_DISCONNECT"))
				break;
			else if (read.equals("COMMAND_END"))
				continue;
			else if (read.equals(TinkerConnector.UNCONNECTED))
				break;

			Command cmd = (new CommandParser()).parseCommand(read);
			try {
				result = CommandExecutor.execute(cmd, ptNode, pm, tinker,
						session);
				tinker.send(result);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				isException = true;
				result = e.getMessage();
			}

		} while (pm != null && !pm.isCanceled() && !isException);

		if (!isException)
			result = null;
		tinker.close();
		System.out.println("Disconnected. Tinker Tactics complete.");
		// pm.setCanceled(true);
		return result;
	}

}
