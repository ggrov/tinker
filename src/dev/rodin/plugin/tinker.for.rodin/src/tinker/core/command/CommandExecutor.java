package tinker.core.command;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.ui.internal.handlers.WizardHandler.New;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;
import org.eventb.core.seqprover.eventbExtensions.Tactics;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import tinker.core.socket.TinkerConnector;

public class CommandExecutor {
	private static CommandExecutor instance = null;
	public static String SUCCESS = "SUCCESS";
	public static HashMap<String, IProofTreeNode> nameToNodeMap = new HashMap<>();
	public static HashMap<IProofTreeNode, String> nodeToNameMap = new HashMap<>();

	public static void clear() {
		nameToNodeMap.clear();
		nodeToNameMap.clear();
	}

	private CommandExecutor() {
		// TODO Auto-generated constructor stub
	}

	private static int comCount = 0;

	public static CommandExecutor getInstance() {
		if (instance == null) {
			instance = new CommandExecutor();

		}
		return instance;
	}

	@SuppressWarnings("unchecked")
	public static String execute(Command command, IProofTreeNode pt,
			IProofMonitor pm, TinkerConnector tinker) {
		System.out.println("EXECUTE:\t" + command.getCommand());

		String result = null;
		IProofTreeNode[] nodes;
		Map names;
		switch (command.getCommand()) {
		case "GET_OPEN_DESCENDANTS_NUM":
			result = (new Command("PENDING_NODES_NUM")).addParamter("NUM",
					pt.getOpenDescendants().length).addParamter("TEST", "⇔").toString();

			break;
		case "NAME_OPEN_NODES":
			names = command.getParameters();
			nodes = pt.getOpenDescendants();
			int j = 0;
			if (nodes.length == names.entrySet().size()) {
				for (Iterator<Map.Entry<String, String>> i = names.entrySet()
						.iterator(); i.hasNext();) {
					Entry entry = i.next();
					String name = (String) entry.getValue();
					nameToNodeMap.put(name, nodes[j]);
					nodeToNameMap.put(nodes[j], name);
					
					j++;
				}
			}
			result = (new Command("NAMING_COMPLETE", names)).toString();

			break;
		case "GET_ALL_OPEN_NODES":
			names = command.getParameters();
			nodes = pt.getOpenDescendants();
			HashMap temp = new HashMap<>();
			for (int i = 0; i < nodes.length; i++) {
				if (nodeToNameMap.get(nodes[i]) == null) {
					throw new UnsupportedOperationException(
							"Tinker must name all node before this operation");
				}
				temp.put(String.valueOf(i), nodeToNameMap.get(nodes[i]));

			}
			result = (new Command("NAMES", temp)).toString();
			break;

		default:
			break;
		}
		System.out.println();
		return result;

	}

	private static ITactic tacticMap(String tacticName) {
		System.out.println("apply " + tacticName);
		switch (tacticName) {
		case "lasoo":
			return Tactics.lasoo();
		case "prune":
			return Tactics.prune();

		default:
			return Tactics.autoRewrite();
		}

	}

}
