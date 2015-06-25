package tinker.core.command;

import java.util.HashMap;

import org.eventb.core.seqprover.ITactic;
import org.eventb.core.seqprover.eventbExtensions.Tactics;

public class CommandMap {
	private static CommandMap instance = null;
	private static HashMap<String, ITactic> cmdMap = new HashMap<>();

	public static CommandMap getInstance() {
		if (instance == null) {
			instance = new CommandMap();
		}
		
		
		return instance;
	}

	private CommandMap() {
		
	}
	
	public static void add(String name, ITactic tac){
		cmdMap.put(name, tac);
	}
	
}
