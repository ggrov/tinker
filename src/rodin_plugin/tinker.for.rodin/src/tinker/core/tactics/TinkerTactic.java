package tinker.core.tactics;

import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;

import tinker.core.command.Command;
import tinker.core.command.CommandExecutor;
import tinker.core.command.CommandParser;
import tinker.core.command.TinkerSession;
import tinker.core.socket.TinkerConnector;
import tinker.core.socket.TinkerConnector.RodinCancelInteruption;

public class TinkerTactic implements ITactic {

	private IWorkbenchWindow getThisWorkBench() {
		// It is assumed that there is only one Rodin Instance
		// .getWorkbenchWindows()[0]);

		IWorkbenchWindow[] windows = PlatformUI.getWorkbench().getWorkbenchWindows();
		return windows[0];
	}

	@Override
	public Object apply(IProofTreeNode ptNode, IProofMonitor pm) {

		TinkerSession session = new TinkerSession(getThisWorkBench());
		session.setRodinState(TinkerSession.RODIN_STATE_APPLYING);

		pm.setTask("Wait for Tinker..");

		TinkerConnector tinker = new TinkerConnector(pm, session);
		String reply_command = null;
		String exception_info = null;

		try {

			tinker.listen(); 
			session.setRodinPluginSate(TinkerSession.RP_STATE_WAITING_COMMAND);
		} catch (RodinCancelInteruption e1) {
			session.setRodinPluginSate(e1.GetState());
		} catch (Exception e) {
			e.printStackTrace();
			session.setRodinPluginSate(TinkerSession.RP_STATE_EXCEPTION);
		}

		while (session.getRodinPluginSate() == TinkerSession.RP_STATE_WAITING_COMMAND) {
			String read;
			System.out.println("Waiting for command");
			/*
			 * if (read.equals("TINKER_DISCONNECT")) break; else if
			 * (read.equals("COMMAND_END")) continue; else if
			 * (read.equals(TinkerConnector.UNCONNECTED)) break;
			 */
			try {
				//Read socket, if cancelled, tinker connector will throw an RodinCancelInteruption
				read = tinker.fromTinker();
				session.setRodinPluginSate(TinkerSession.RP_STATE_EXECUTING);
				Command cmd = (new CommandParser()).parseCommand(read);

				if (cmd.getCommand().equals("DISCONNECT_NORMALLY")) {
					session.setRodinPluginSate(TinkerSession.RP_STATE_DISCONNECTING_FROM_TINKER);
					break;
				} else if (cmd.getCommand().equals("DISSCONNECT_WITH_ERROR")) {
					session.setRodinPluginSate(TinkerSession.RP_STATE_DISCONNECTING_WITH_ERROR);
					exception_info = cmd.getParameter("ERROR");
					break;
				}
				//Set state to RP_STATE_EXECUTING so the command executor can execute
				session.setRodinPluginSate(TinkerSession.RP_STATE_EXECUTING);
				//Execute the command from tinker
				reply_command = CommandExecutor.execute(cmd, ptNode, pm, tinker, session);
				
				//after execution, check if user has clicked Cancel. If so then throw exception 
				if (pm == null || pm.isCanceled()) {
					throw new RodinCancelInteruption(TinkerSession.RP_STATE_CANCELLING_EXECUTING);
				}

				if (session.getRodinPluginSate() == TinkerSession.RP_STATE_EXECUTING) {
					tinker.toTinker(reply_command);
				} else {
					throw new Exception("Executing while not in EXECUTION STATE");
				}
				
				//After sending command to Tinker, Rodin Plugin state is set back to RP_STATE_WAITING_COMMAND
				session.setRodinPluginSate(TinkerSession.RP_STATE_WAITING_COMMAND);
			} catch (RodinCancelInteruption e1) {
				session.setRodinPluginSate(e1.GetState());
				break;
			} catch (Exception e) {
				e.printStackTrace();
				session.setRodinPluginSate(TinkerSession.RP_STATE_EXCEPTION);
				break;
			}

		}


		// handle cancellation and exception
		if (session.getRodinPluginSate() == TinkerSession.RP_STATE_CANCELLING_EXECUTING) {
			cancel_Executing(tinker, session);
		} else if (session.getRodinPluginSate() == TinkerSession.RP_STATE_CANCELLING_WAITING_COMMAND) {
			cancel_Waiting(tinker, session);
		} else if (session.getRodinPluginSate() == TinkerSession.RP_STATE_CANCELLING_LISTENING) {
			cancel_Listening(tinker, session);
		} else if (session.getRodinPluginSate() == TinkerSession.RP_STATE_EXCEPTION) {
			handle_Exception(tinker,session);
		}
		
		
		//close socket after cancellation/exception handling
		tinker.close();
		// handle finishing after possible cancellation
		if (session.getRodinPluginSate() == TinkerSession.RP_STATE_DISCONNECTING_FROM_TINKER) {
			application_finish(session);
		} else if (session.getRodinPluginSate() == TinkerSession.RP_STATE_DISCONNECTING_WITH_ERROR) {
			application_finish_with_error(session);
			exception_info="Disconnected with Error";
		} else if (session.getRodinPluginSate()==TinkerSession.RP_STATE_CANCELLED){
			application_finish_with_cancellation(session);
			exception_info="Canceled";
		}else{
			exception_info+="Unexpted state";
		}
		
		System.out.println("Disconnected. Tinker Tactics complete.");
		// pm.setCanceled(true);
		return exception_info;
	}

	private void application_finish(TinkerSession session) {
		//Method name matches the action in Petri Net
		//Only change the state of session. Does nothing else
		
		session.setRodinPluginSate(TinkerSession.RP_STATE_READY);
		session.setRodinState(TinkerSession.RODIN_STATE_APPLICATION_DONE);
	}

	private void application_finish_with_error(TinkerSession session) {
		//Method name matches the action in Petri Net
		//Only change the state of session. Does nothing else
		
		session.setRodinPluginSate(TinkerSession.RP_STATE_READY);
		session.setRodinState(TinkerSession.RODIN_STATE_APPLICATION_DONE);
	}
	
	private void application_finish_with_cancellation(TinkerSession session){

		//Method name matches the action in Petri Net
		//Only change the state of session. Does nothing else
		session.setRodinPluginSate(TinkerSession.RP_STATE_READY);
		session.setRodinState(TinkerSession.RODIN_STATE_APPLICATION_DONE);
	}

	private void cancel_Executing(TinkerConnector tinker, TinkerSession session) {

		//Method name matches the action in Petri Net
		/*This method will send an RODIN_CANCEL message to Tinker that will be waiting an 
		 *execution result. Tinker will raise an exception with this message and change
		 *its state
		 *
		 *  */
		try {
			tinker.toTinker("RODIN_CANCEL");
		} catch (Exception e) {

		}
		session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
		session.setRodinPluginSate(TinkerSession.RP_STATE_CANCELLED);
	}

	private void cancel_Waiting(TinkerConnector tinker, TinkerSession session) {

		//Method name matches the action in Petri Net
		/*User clicked cancel button in Rodin while Tinker is tasking
		*This will result in an force disconnection between them because there
		*is no way Rodin could synchronise the state with Tinker if Tinker is not reading
		*to the socket.(Tinker will only listen after whatever the task is done and 
		*new command is sent.
		*
		*Tinker will raise an exception and enter an exception state. This operation should
		*be avoided by user. User should always try to disconnect from Tinker/TinkerGUI first
		*after the connection is made.
		* 
		*/	
		session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
		session.setRodinPluginSate(TinkerSession.RP_STATE_CANCELLED);
	}

	private void cancel_Listening(TinkerConnector tinker, TinkerSession session) {
		//Method name matches the action in Petri Net
		/*This method will be called if user clicked cancel button before connecting to Tinker.
		 *The application should end immediately without affecting any state in Tinker
		 *  */
		
		session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
		session.setRodinPluginSate(TinkerSession.RP_STATE_CANCELLED);
	}

	
	private void handle_Exception(TinkerConnector tinker, TinkerSession session){
		session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
		session.setRodinPluginSate(TinkerSession.RP_STATE_CANCELLED);
	}
}
