package tinker.core.socket;

import java.net.*;
import java.io.*;

import org.eventb.core.seqprover.IProofMonitor;

import tinker.core.command.TinkerSession;

public class TinkerConnector {
	public static String WRITE_SUCCESS = "WRITE_SUCCESS";
	public static String WRITE_FAIL = "WRITE_FAIL";
	public static String READ_EXCEPTION = null;
	public static String READ_TIMEOUT = "READ_TIMEOUT";
	public static String UNCONNECTED = "UNCONNECTED";

	public static int STATE_CREATED = 0;
	public static int STATE_CONNECTING = 1;
	public static int STATE_CONNECTED = 2;
	public static int STATE_READING = 3;
	public static int STATE_WRITING = 4;
	public static int STATE_TERMINATED = 5;
	public static int STATE_EXCEPTIONALLY_TERMINATED = 10;

	IProofMonitor monitor;
	int timeout = 500;
	int port = 1991;
	ServerSocket serverSocket = null;
	Socket connection = null;
	BufferedReader input = null;
	BufferedWriter output = null;
	
	private int state = STATE_CONNECTING;
	
	private TinkerSession session;
	
	
	
	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public TinkerConnector(IProofMonitor pm, TinkerSession session) {
		this.monitor = pm;
		this.session=session;
	}

	public Object serve() {

		System.out.println("WAIT TINKER COMMAND.." );
		while (getState() != STATE_CONNECTED) {
			if (monitor != null && !monitor.isCanceled()) {
				try {
					setState(STATE_CONNECTING);
					serverSocket = new ServerSocket(port);
					serverSocket.setSoTimeout(timeout);
					connection = serverSocket.accept();
					connection.setSoTimeout(timeout);
					input = new BufferedReader(new InputStreamReader(
							connection.getInputStream(), "UTF-8"));
					output = new BufferedWriter(new OutputStreamWriter(
							connection.getOutputStream(), "UTF-8"));

					setState(STATE_CONNECTED);
					System.out.println("INCOMING CMD");
					return null;
				} catch (Exception ex) {
					if (ex instanceof SocketTimeoutException) {
						try {
							serverSocket.close();
							connection.close();
						} catch (Exception e) {
						}

						continue;
					} else if (ex instanceof SocketException) {
						setState(STATE_EXCEPTIONALLY_TERMINATED);
					}
					ex.printStackTrace();
					break;

				}
			}else{
				//if cancelled in Rodin
				this.close();
				break;
			}

		}
		return UNCONNECTED;
	}

	public String receive() {
		if (getState() == STATE_CONNECTED) {
			setState(STATE_READING);
			while (monitor != null && !monitor.isCanceled()) {
				try {

					
					String result = (input.readLine());
					System.out.println("RECEIVE:\t" + result);
					
					if (result.equals("TINKER_DISCONNECT")) {
						setState(STATE_TERMINATED);
						return UNCONNECTED;
					}
					if (result.equals("COMMAND_END")){
						this.close();
						return result;
					}
					if (result.equals("TINKER_HAND_SHAKE")){
						setState(STATE_CONNECTED);
						return receive();
					}
					
					setState(STATE_CONNECTED);
					return result;
				} catch (Exception e) {
					if (e instanceof SocketTimeoutException) {
						continue;	
					} else if (e instanceof SocketException) {
						setState(STATE_EXCEPTIONALLY_TERMINATED);
					}
					e.printStackTrace();
					return READ_EXCEPTION;
				}
			}
			//if cancelled in Rodin
			this.close();
		}
		return UNCONNECTED;
	}

	public String send(String str) {
		if (getState() == STATE_CONNECTED) {
			setState(STATE_WRITING);
			try {
				output.write(str);
				output.flush();
				System.out.println("SENT   :\t"+str);
				setState(STATE_CONNECTED);
				return WRITE_SUCCESS;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return WRITE_FAIL;
			}
		}
		return UNCONNECTED;
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
