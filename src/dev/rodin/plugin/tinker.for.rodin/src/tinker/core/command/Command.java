package tinker.core.command;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class Command {
	private String command;
	private HashMap<String, Object> parameters= new HashMap<>();
	
	public Command() {
		
	}
	
	public Command(String cmd){
		this.command=cmd;
	}

	public Command(String cmd, Map.Entry<String, Object>[] params){
		this.command=cmd;
		
		for (int i=0;i<params.length;i++){
			this.parameters.put(params[i].getKey(), params[i].getValue());
		}
	}
	
	public Command(String cmd, Map<String, Object> params){
		this.command=cmd;
		this.parameters.putAll(params);
	}
	
	public HashMap<String, Object>  getParameters() {
		return parameters;
	}

	public Object getParameter(String paramName){
		return this.parameters.get(paramName);
	}
	

	public void setParameters(HashMap<String, Object> parameters) {
		this.parameters = parameters;
	}
	
	public Command addParamter(String key, Object value){
		this.parameters.put(key, value);
		return this;
	}

	public String getCommand() {
		return command;
	}


	public void setCommand(String command) {
		this.command = command;
	}
	
	@Override
	public String toString(){

		
		JSONObject resj=new JSONObject();
		Map<String,String> params=new HashMap<String,String>();
		for (Iterator i = this.parameters.entrySet().iterator();i.hasNext();){
			Map.Entry m=(Entry) i.next();
			String key=m.getKey().toString();
			String val=m.getValue().toString();
			System.out.println(key+","+val);
			params.put(key, val);
		}
		resj.put("CMD", this.getCommand());
		resj.put("PARAMS", params);
		return JSONValue.toJSONString(resj);
		
	}

}
