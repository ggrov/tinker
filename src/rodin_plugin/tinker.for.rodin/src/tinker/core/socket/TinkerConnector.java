package tinker.core.socket;

import java.net.*;
import java.io.*;
import java.io.ObjectInputStream.GetField;

import org.eventb.core.seqprover.IProofMonitor;

import tinker.core.command.TinkerSession;

public class TinkerConnector {

	/*
	 * public static String WRITE_SUCCESS = "WRITE_SUCCESS"; public static
	 * String WRITE_FAIL = "WRITE_FAIL";
	 * 
	 * public static String READ_EXCEPTION = null; public static String
	 * READ_TIMEOUT = "READ_TIMEOUT";
	 * 
	 * public static String UNCONNECTED = "UNCONNECTED";
	 */

	public static class RodinCancelInteruption extends Exception {

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		private int s;

		public RodinCancelInteruption(int RodinPluginState) {
			s = RodinPluginState;
		}

		public int GetState() {
			return s;
		}
	}

	IProofMonitor monitor;
	int timeout = 500;
	int port = 1991;
	ServerSocket serverSocket = null;
	Socket connection = null;
	BufferedReader input = null;
	BufferedWriter output = null;;

	private TinkerSession session;

	public TinkerConnector(IProofMonitor pm, TinkerSession session) {
		this.monitor = pm;
		this.session = session;
	}

	public void listen() throws Exception {
		
		//Rodin plugin creates a server socket listening for client socket connection
		//Rather than let the server socket block the thread, there is an timeout for the 
		//listening, offering a chance to check if the operation is cancelled.
		//The timeout exception is caught and new server socket is created immediately.
		System.out.println("WAIT TINKER COMMAND..");
		session.setSocketState(TinkerSession.SOCKET_STATE_LISTENING);
		while (session.getSocketState() == TinkerSession.SOCKET_STATE_LISTENING) {
			if (monitor == null || monitor.isCanceled() == true) {
				session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
				break;
			}

			try {
				System.out.println("LISTENING");
				serverSocket = new ServerSocket(port);
				serverSocket.setSoTimeout(timeout);
				connection = serverSocket.accept();
				connection.setSoTimeout(timeout);
				input = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
				output = new BufferedWriter(new OutputStreamWriter(connection.getOutputStream(), "UTF-8"));

				session.setSocketState(TinkerSession.SOCKET_STATE_CONNECTED);
				// System.out.println("INCOMING CMD");
				return;

			} catch (SocketTimeoutException ex) {
				try {
					serverSocket.close();
					connection.close();
				} catch (Exception e) {
				}
				continue;

			} catch (SocketException ex) {
				session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
				throw ex;
			} catch (Exception ex) {
				ex.printStackTrace();
				throw ex; 
			}
		}
		session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
		throw new RodinCancelInteruption(TinkerSession.RP_STATE_CANCELLING_LISTENING);
	}

	public String blockedRead() throws Exception{
		while (true){
			try{
			String result= input.readLine();
			if (result!=null){
				return result;
			}
			}catch(SocketTimeoutException ex){
				continue;
			}
		}
	}
	
	public String fromTinker() throws Exception {
		//Plugin read from Tinker through socket. Rather than letting the socket block the thread,
		//there is a timeout of 500 ms, creating a chance to check if 
		//the operation is cancelled in Rodin.The exception of timeout is caught and ignored
		
		while (session.getSocketState()==TinkerSession.SOCKET_STATE_CONNECTED) {
			if (monitor == null || monitor.isCanceled() == true) {

				session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
				// session.setRodinPluginSate(TinkerSession.RP_STATE_CANCELLING_WAITING_COMMAND);
				break;
			}

			try {

				String result = (input.readLine());

				if (result != null) {
					/*
					 * if (result.equals("SESSION_END")) {
					 * setState(STATE_TERMINATED); return UNCONNECTED; }
					 */
					/*
					 * if (result.equals("COMMAND_END")){ this.close(); return
					 * result; }
					 */
					/*
					 * if (result.equals("TINKER_HAND_SHAKE")) {
					 * setState(STATE_CONNECTED); return receive(); }
					 */
					System.out.println("RECEIVE:\t" + result);
					return result;
				} else {
					continue;
				}
			} catch (Exception e) {
				if (e instanceof SocketTimeoutException) {
					continue;
				} else if (e instanceof SocketException) {
					
				}
				e.printStackTrace();
				// Anything exception other than timeout will disconnect the socket and end the operation
				session.setSocketState(TinkerSession.SOCKET_STATE_DISCONNECTED);
				this.close();
				throw e;
			}
		}
		// if cancelled in Rodin
		System.out.println("Rodin Cancelled while waiting for Tinker Command. \n Rodin Blocked until Tinker Replies");
		//this.close();
		throw new RodinCancelInteruption(TinkerSession.RP_STATE_CANCELLING_WAITING_COMMAND);
	}

	public void toTinker(String str) throws Exception {
		//According to the socket model,
		//We assume that whenever there is a socket message to Tinker
		//Tinker will be always listening. This toTinker method will block the thread.
			try {
				output.write(str);
				output.flush();
				System.out.println("SENT   :\t" + str);
				return;
			} catch (IOException e) {
				e.printStackTrace();
				throw e;
			}
		
	}

	public void reset() {
		this.close();
	}

	public void close() {
		try {
			input.close();
		} catch (Exception e) {

		}
		try {
			output.close();
		} catch (Exception e) {

		}
		try {
			connection.close();
		} catch (Exception e) {

		}
		try {
			serverSocket.close();
		} catch (Exception e) {

		}

	}
}
