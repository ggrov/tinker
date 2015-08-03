package tinker.core.execute;

import java.util.HashMap;

import org.apache.commons.lang3.StringEscapeUtils;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class CommandParser {
	

	public static Command parseCommand(String commandstr) throws Exception{

		Command result = new Command();
		try {
			//System.out.println("parsing "+commandstr);
			JSONObject jObject = (JSONObject) JSONValue.parse(commandstr);
			//System.out.println("done "+commandstr);
			
			result.setCommand((String) jObject.get("CMD"));
			//System.out.println("CMD="+jObject.get("CMD"));
			JSONObject params = (JSONObject) jObject.get("PARAMS");
			//System.out.println("PARAMS="+params.toJSONString());
			if (params != null) {
				result.setParameters(params);
			} else {
				result.setParameters(null);
			}
			return result;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			throw e;
		}

	}
}
