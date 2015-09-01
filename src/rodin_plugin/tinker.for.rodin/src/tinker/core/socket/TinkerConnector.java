package tinker.core.socket;

import java.net.*;
import java.io.*;
import java.io.ObjectInputStream.GetField;

import org.eventb.core.seqprover.IProofMonitor;

import tinker.core.execute.TinkerSession;
import tinker.core.states.PluginStates;
import tinker.core.states.SocketStates;

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

	public static class TinkerSessionEnd extends Exception {

		/**
		 * 
		 */
		private static final long serialVersionUID = -4894990671097140908L;

	}

	IProofMonitor monitor;
	int timeout = 500;
	int port = 1985;
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

		// Rodin plugin creates a server socket listening for client socket
		// connection
		// Rather than let the server socket block the thread, there is an
		// timeout for the
		// listening, offering a chance to check if the operation is cancelled.
		// The timeout exception is caught and new server socket is created
		// immediately.
		System.out.println("WAIT TINKER COMMAND..");
		session.setSocketState(SocketStates.LISTENING);
		while (session.getSocketState() == SocketStates.LISTENING) {
			if (monitor == null || monitor.isCanceled() == true) {

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

				session.setSocketState(SocketStates.CONNECTED);
				// System.out.println("INCOMING CMD");
				return;

			} catch (SocketTimeoutException ex) {
				// ignore timeout and re listen
				try {
					serverSocket.close();
					connection.close();
				} catch (Exception e) {
				}
				continue;

			} catch (SocketException ex) {
				// Throw any socket exception and other exception that is not
				// expected
				throw ex;
			} catch (Exception ex) {

				ex.printStackTrace();
				throw ex;
			}
		}
		session.setSocketState(SocketStates.DISCONNECTED);
		throw new RodinCancelInteruption(PluginStates.READY);
	}

	public String blockedRead() throws Exception {
		while (true) {
			try {
				String result = input.readLine();
				if (result != null) {
					return result;
				}
			} catch (SocketTimeoutException ex) {
				continue;
			}
		}
	}

	public String fromTinker() throws Exception {
		// Plugin read from Tinker through socket. Rather than letting the
		// socket block the thread,
		// there is a timeout of 500 ms, creating a chance to check if
		// the operation is cancelled in Rodin.The exception of timeout is
		// caught and ignored

		while (session.getSocketState() == SocketStates.CONNECTED) {
			if (monitor == null || monitor.isCanceled() == true) {
				if (session.getPluginSate() != PluginStates.CANCELLATION_ORDERED)
					break;
			}

			try {

				String result = (input.readLine());

				if (result != null) {

					System.out.println("RECEIVE:\t" + result);
					/*
					 * if (result.equals("COMMAND_END")){ this.close(); return
					 * result; }
					 */
					/*
					 * if (result.equals("TINKER_HAND_SHAKE")) {
					 * setState(STATE_CONNECTED); return receive(); }
					 */
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
				throw e;
			}
		}
		// if cancelled in Rodin
		System.out.println("Rodin Cancelled while waiting for Tinker Command. \n Rodin Blocked until Tinker Replies");

		throw new RodinCancelInteruption(PluginStates.CANCELLATION_ORDERED);
	}

	public void toTinker(String str) throws Exception {
		// According to the socket model,
		// We assume that whenever there is a socket message to Tinker
		// Tinker will be always listening. This toTinker method will block the
		// thread.
		if (session.getSocketState() == SocketStates.SENDING_CANCELLATION
				|| session.getSocketState() == SocketStates.SENDING_CMD)
			try {
				session.setSocketState(SocketStates.CONNECTED);
				output.write(str);
				output.flush();
				System.out.println("SENT   :\t" + str);
				return;
			} catch (IOException e) {
				e.printStackTrace();
				throw e;
			}
		else
			throw new Exception("Unexpected attempt using this method \"toTinker\"");
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
		session.setSocketState(SocketStates.DISCONNECTED);
	}
}
