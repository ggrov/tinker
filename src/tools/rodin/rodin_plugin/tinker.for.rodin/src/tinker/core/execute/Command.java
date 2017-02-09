package tinker.core.execute;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.lang3.StringEscapeUtils;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class Command {
	private String command;
	private HashMap<String, String> parameters = new HashMap<>();

	public Command() {

	}

	public Command(String cmd) {
		this.command = cmd;
	}

	public Command(String cmd, Map.Entry<String, String>[] params) {
		this.command = cmd;

		for (int i = 0; i < params.length; i++) {
			this.parameters.put(params[i].getKey(), params[i].getValue());
		}
	}

	public Command(String cmd, Map<String, String> params) {
		this.command = cmd;
		this.parameters.putAll(params);
	}

	public HashMap<String, String> getParameters() {
		return parameters;
	}

	private String unescape(String obj) {
	    String r= StringEscapeUtils.unescapeJava(obj);
	    return StringEscapeUtils.unescapeJava(r);
	}

	public String getParameter(String paramName) {
		return (unescape(this.parameters.get(paramName)));
	}

	public void setParameters(HashMap<String, String> parameters) {
		for (Iterator i = parameters.entrySet().iterator();i.hasNext();){
			Entry<String,String> e=(Entry) i.next();
			this.addParamter((String) e.getKey(), e.getValue());
		}
	}

	public Command addParamter(String key, Object value) {
		this.parameters.put(key, unescape(value.toString()));
		return this;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	@Override
	public String toString() {

		JSONObject resj = new JSONObject();
		Map<String, String> params = new HashMap<String, String>();
		for (Iterator i = this.parameters.entrySet().iterator(); i.hasNext();) {
			Map.Entry m = (Entry) i.next();
			String key = StringEscapeUtils.escapeJava(m.getKey().toString());
			String val = StringEscapeUtils.escapeJava(m.getValue().toString());
			params.put(key, val);
		}
		resj.put("CMD", StringEscapeUtils.escapeJava(this.getCommand()));
		resj.put("PARAMS", params);
		return JSONValue.toJSONString(resj);

	}

}
