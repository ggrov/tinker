package tinker.core.command;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IViewReference;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.IWorkingSet;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.handlers.WizardHandler.New;
import org.eventb.core.pm.IUserSupport;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;
import org.eventb.core.seqprover.eventbExtensions.Tactics;
import org.eventb.internal.ui.prooftreeui.ProofTreeUI;
import org.eventb.internal.ui.prooftreeui.ProofTreeUIPage;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import tinker.core.socket.TinkerConnector;

public class CommandExecutor {
	private static CommandExecutor instance = null;
	public static String SUCCESS = "SUCCESS";

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

	/*
	 * This function is used to find the proof tree UI object so that we can
	 * update proof tree immediately when Tinker has instructed an application
	 * of tactic.
	 */
	@SuppressWarnings("restriction")
	private static ProofTreeUI getProofTreeUI(IWorkbenchWindow ww) {
		System.out.println("work bench=" + ww);
		final IViewReference[] Pages = ww.getPages()[0].getViewReferences();
		// System.out.println("pages len=" + Pages.length + ", p");
		for (int i = 0; i < Pages.length; i++) {

			IViewReference ir = Pages[i];
			if (ir.getPart(false) instanceof ProofTreeUI) {
				// ProofTreeUI result = (ProofTreeUI)ir.getPart(true);
				// return result;
				ProofTreeUI ptu = (ProofTreeUI) ir.getPart(true);
				return ptu;
			}
		}
		return null;
	}

	/*
	 * Find the current page that displays the proof tree
	 */
	protected static IUserSupport getUserSupport(ProofTreeUI ui) {
		final ProofTreeUIPage page = (ProofTreeUIPage) ui.getCurrentPage();
		if (page == null) {
			return null;
		}
		return page.getUserSupport();
	}

	private static String Handle_NAME_OPEN_NODES(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		Map names = command.getParameters();
		IProofTreeNode[] nodes = pt.getOpenDescendants();
		int j = 0;
		if (nodes.length == names.entrySet().size()) {
			for (Iterator<Map.Entry<String, String>> i = names.entrySet().iterator(); i.hasNext();) {
				Entry entry = i.next();
				String name = (String) entry.getValue();
				session.nameToNodeMap.put(name, nodes[j]);
				session.nodeToNameMap.put(nodes[j], name);

				System.out.println(nodes[j].toString());
				j++;
			}
		}
		String result = (new Command("NAMING_COMPLETE", names)).toString();
		return result;
	}

	private static String handle_GET_ALL_OPEN_NODES(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String result;
		IProofTreeNode[] nodes = pt.getOpenDescendants();
		String pplan = command.getParameter("PPLAN");
		if (pplan.equals("")) {
			nodes = pt.getOpenDescendants();
		} else {
			nodes = session.nameToNodeMap.get(pplan).getOpenDescendants();
			if (nodes == null) {
				result = (new Command("ERROR")).addParamter("INFO", "EXCEPTION FOUND: PPLAN IS NOT FOUND IN SESSION")
						.toString();
				return result;
			}
		}

		HashMap temp = new HashMap<>();
		for (int i = 0; i < nodes.length; i++) {
			if (session.nodeToNameMap.get(nodes[i]) == null) {
				String require = (new Command("NEED_NAMING")).addParamter("NUM", nodes.length)
						.addParamter("PARENT", "").toString();
				return require;
			}
			temp.put(String.valueOf(i), session.nodeToNameMap.get(nodes[i]));

		}
		result = (new Command("NAMES", temp)).toString();
		return result;
	}

	private static String handle_GET_PNODE_GOAL_TAG(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String nodename = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(nodename);
		String result = (new Command("RETURN_TAG")).addParamter("TAG",
				String.valueOf(pnode.getSequent().goal().getTag())).toString();
		return result;
	}

	@SuppressWarnings("unused")
	private static String handle_APPLY_TACTIC(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {

		String result;
		String tactic = command.getParameter("TACTIC");
		String targetNode = command.getParameter("NODE");
		IProofTreeNode target = session.nameToNodeMap.get(targetNode);

		pt.getSequent().goal().getGivenTypes();
		// System.out.println("applying tactic = " + tactic);
		Object tac_result = getTactic(tactic).apply(target, pm);
		try {
			// Try to update the proof tree UI after the tactic is applied
			final IWorkbenchWindow ww = session.getWorkbenchWindow();
			final ProofTreeUI ui = getProofTreeUI(ww);
			final ProofTreeUIPage ptp = (ProofTreeUIPage) ui.getCurrentPage();
			Display.getDefault().asyncExec(new Runnable() {

				@Override
				public void run() {
					ptp.getViewer().expandAll();
					ptp.getViewer().refresh();

				}
			});
		} catch (Exception e) {
		}
		// Thread.sleep(1000);
		// System.out.println("tactic result = " + tac_result);
		if (tac_result == null) {
			// null means no error
			int new_node_num = target.getOpenDescendants().length;

			if (target.isOpen()) {
				// no rule has been applied to the node.
				result = (new Command("ERROR")).addParamter("ERROR_INFO",
						"THIS TACTIC DOES NOT HAVE EFFECT ON NODE " + targetNode).toString();
			} else if (new_node_num > 0 && !target.isOpen()) {
				// Target node is not open after applying this tactic, this
				// means it has new child nodes
				// which needs naming
				result = (new Command("NEED_NAMING")).addParamter("PARENT", targetNode)
						.addParamter("NUM", String.valueOf(new_node_num)).toString();
			} else if (target.isClosed()) {
				// Closed - This node has no open descendants. The proof
				// for its sequent is complete.
				result = (new Command("NODE_CLOSED")).toString();

			} else {
				result = (new Command("ERROR")).addParamter("ERROR_INFO", "UNKNOWN ERROR").toString();

			}

		} else {
			result = (new Command("ERROR")).addParamter("ERROR_INFO", tac_result.toString()).toString();

		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public static String execute(Command command, IProofTreeNode pt, IProofMonitor pm, TinkerConnector tinker,
			TinkerSession session) throws Exception {

		if (session.getRodinPluginSate() == TinkerSession.RP_STATE_EXECUTING) {
			System.out.println("EXECUTE:\t" + command.getCommand());

			String result = null;
			switch (command.getCommand()) {
			/*
			 * case "GET_OPEN_DESCENDANTS_NUM": result = (new
			 * Command("PENDING_NODES_NUM")).addParamter("NUM",
			 * pt.getOpenDescendants().length).toString();
			 * 
			 * break;
			 */
			case "NAME_OPEN_NODES":
				result = Handle_NAME_OPEN_NODES(command, pt, pm, tinker, session);
				break;
			case "GET_ALL_OPEN_NODES":
				result = handle_GET_ALL_OPEN_NODES(command, pt, pm, tinker, session);
				break;
			case "GET_PNODE_GOAL_TAG":
				result = handle_GET_PNODE_GOAL_TAG(command, pt, pm, tinker, session);
				break;
			case "GET_PNODE_GOAL_TYPE":
				break;
			case "APPLY_TACTIC":
				result = handle_APPLY_TACTIC(command, pt, pm, tinker, session);
				break;
			default:
				break;
			}
			return result;
		} else {
			throw new Exception("Try execute while not in EXECUTION STATE");
		}
	}

	private static ITactic getTactic(String tacticName) {
		// System.out.println("apply " + tacticName);
		switch (tacticName) {
		case "lasoo":
			return Tactics.lasoo();
		case "prune":
			return Tactics.prune();
		case "impI":
			return Tactics.impI();
		case "conjI":
			return Tactics.conjI();
		case "allI":
			return Tactics.allI();
		case "hyp":
			return Tactics.hyp();
		default:
			return Tactics.autoRewrite();
		}

	}

}
