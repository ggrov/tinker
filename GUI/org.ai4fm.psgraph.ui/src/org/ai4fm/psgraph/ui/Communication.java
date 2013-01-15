package org.ai4fm.psgraph.ui;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Text;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.StringTokenizer;

public class Communication {
	
	private ServerSocket server;
	private Socket client;
	private boolean connected;
	
	private int PORT = 4444;
	private BufferedReader in;
	private PrintWriter out;
	
	public final int CMD_EXIT = 0; // terminate
	public final int CMD_NEXT = 1; // next step
	public final int CMD_BACK = 2; // backtrack
	public final int CMD_PPLAN = 3; // get pplan
	public final int CMD_GRAPH = 4; // get graph
	
	private String pplan;
	private String graph;
	private String errormsg;
	
	public static Text pplanviewer;
	private Composite composite;
	
	public Communication(Composite composite){
		pplan = "";
		graph = "";
		errormsg = "";
		this.composite = composite;
		connected = false;
	}
	
	public boolean isConnected(){
		return connected;
	}
	
	public String getGraph(){
		return graph;
	}
	
	public String getPPlan(){
		return pplan;
	}
	
	public String getError(){
		return errormsg;
	}
	
	// should we do nothing if connected?
	public void connect(){
		try{
			// server = new ServerSocket(PORT);
			client = new Socket("localhost",PORT);//server.accept();
			in = new BufferedReader(new InputStreamReader(client.getInputStream()));
			out	= new PrintWriter(client.getOutputStream(),true);
			connected = true;
			errorMessage("Connection made","Connected to Isabelle");
		}catch(IOException e){
			connected = false;
			errorMessage("Connection error","Cannot connect to Isabelle");
		}
	}
	
	public void tryConnect(){
		if (!connected)
			connect();
	}
	
	
	public void disconnect(){
		try{
			if(connected)
				out.println(CMD_EXIT);
			in.close();
			out.close();
			client.close();
			//server.close();
		}catch (IOException e){
			// nothing to do
		}
		connected = false;
	}

	// FIXME: throw more useful exceptions
	public void onlySendCmd(int cmd){
		if (!connected)
			return ;
		out.println(cmd);

	}

	public String readAll(){
		String end = "ENDMSG";
		if (!connected)
			return null;
		try{
			String ret = "";
			String line;
			do{
				line = in.readLine().trim(); 
				if(line == null || line.contains(end))
					return ret;
				ret += line + "\n";
			} while (true);
				
			/* do {
			    line = in.readLine ();
			    ret += line;
			} while (line != null); */
 			// return ret;
		}catch(IOException io){
			return null;	
		}			
	}
	
	// FIXME: throw more useful exceptions
	public String sendCmd(int cmd){
		if (!connected)
			return null;
		try{
			out.println(cmd);
			return readAll();
		}catch(Exception io){
			return null;	
		}
	}
	
	public boolean sendNext(){
		String ret = sendCmd(CMD_NEXT);
		// pplanviewer.setText("hello");
		if (ret == null)
			errorMessage("No return", "Nullpointer returned from back cmd");
		StringTokenizer str = new StringTokenizer(ret,":");
		String status = str.nextToken().trim();
		if (status.equals("OK"))
			return true;
		errormsg = str.nextToken().trim();
		errorMessage("Error",errormsg);
		return false;		
	}
	
	public boolean sendBack(){
		String ret = sendCmd(CMD_BACK);
		if (ret == null)
			errorMessage("No return", "Nullpointer returned from back cmd");
		StringTokenizer str = new StringTokenizer(ret,":");
		String status = str.nextToken().trim();
		if (status.equals("OK"))
			return true;
		errormsg = str.nextToken().trim();
		errorMessage("Error",errormsg);
		return false;
	}	
	
	public boolean sendGraph(){
		String ret = sendCmd(CMD_GRAPH);
		if (ret == null)
			return false;
		// hack
		graph = ret.replaceAll("blockindent=2digraph", "digraph");
		// errorMessage("graph",graph);
		return true;
	}

	public boolean sendPPlan(){
		String ret = sendCmd(CMD_PPLAN);
		if (ret == null)
			return false;
		pplan = ret;
		pplanviewer.setText(pplan);
		return true;
	}
	
	public void errorMessage(String title, String message){
		MessageBox dialog = new MessageBox(composite.getShell(), SWT.ICON_ERROR | SWT.OK);
		dialog.setText(title);
		dialog.setMessage(message);
		dialog.open();
	}

}
