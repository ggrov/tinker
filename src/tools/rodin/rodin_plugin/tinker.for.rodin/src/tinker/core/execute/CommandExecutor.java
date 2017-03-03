package tinker.core.execute;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IViewReference;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.internal.handlers.WizardHandler.New;
import org.eventb.core.EventBPlugin;
import org.eventb.core.IPORoot;
import org.eventb.core.ast.AssociativeExpression;
import org.eventb.core.ast.AssociativePredicate;
import org.eventb.core.ast.AtomicExpression;
import org.eventb.core.ast.BinaryExpression;
import org.eventb.core.ast.BinaryPredicate;
import org.eventb.core.ast.BoolExpression;
import org.eventb.core.ast.BoundIdentDecl;
import org.eventb.core.ast.BoundIdentifier;
import org.eventb.core.ast.ExtendedExpression;
import org.eventb.core.ast.ExtendedPredicate;
import org.eventb.core.ast.Formula;
import org.eventb.core.ast.FormulaFactory;
import org.eventb.core.ast.FreeIdentifier;
import org.eventb.core.ast.IFormulaFilter;
import org.eventb.core.ast.IPosition;
import org.eventb.core.ast.ISealedTypeEnvironment;
import org.eventb.core.ast.ITypeEnvironment;
import org.eventb.core.ast.IntegerLiteral;
import org.eventb.core.ast.LiteralPredicate;
import org.eventb.core.ast.MultiplePredicate;
import org.eventb.core.ast.Predicate;
import org.eventb.core.ast.QuantifiedExpression;
import org.eventb.core.ast.QuantifiedPredicate;
import org.eventb.core.ast.RelationalPredicate;
import org.eventb.core.ast.SetExtension;
import org.eventb.core.ast.SimplePredicate;
import org.eventb.core.ast.UnaryExpression;
import org.eventb.core.ast.UnaryPredicate;
import org.eventb.core.pm.IProofAttempt;
import org.eventb.core.pm.IUserSupport;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;
import org.eventb.core.seqprover.eventbExtensions.AutoTactics;
import org.eventb.core.seqprover.eventbExtensions.DLib;
import org.eventb.core.seqprover.eventbExtensions.Lib;
import org.eventb.core.seqprover.eventbExtensions.Tactics;
import org.eventb.core.seqprover.eventbExtensions.AutoTactics.TrueGoalTac;
import org.eventb.internal.core.ast.Position;
import org.eventb.internal.core.seqprover.eventbExtensions.utils.FreshInstantiation;
import org.eventb.internal.ui.prooftreeui.ProofTreeUI;
import org.eventb.internal.ui.prooftreeui.ProofTreeUIPage;
import org.eventb.internal.ui.prover.tactics.AutoProver.AutoProverApplication;
import org.eventb.internal.ui.prover.tactics.EqvLR;
import org.eventb.pp.PPCore;
import org.eventb.ui.prover.ITacticApplication;

import tinker.core.protocol.session.TinkerSession;
import tinker.core.protocol.states.PluginStates;
import tinker.core.socket.TinkerConnector;

@SuppressWarnings("restriction")
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
	public static Predicate parseStr(String str, ITypeEnvironment typeEnv) {
		final FormulaFactory ff = typeEnv.getFormulaFactory();
		Predicate predicate = DLib.parsePredicate(ff, str);
		if (predicate == null) {
			// error = "Parse error for predicate: "+ predString;
			return null;
		}
		if (!Lib.typeCheckClosed(predicate, typeEnv)) {
			// error = "Type check failed for Predicate: "+predicate;
			predicate = null;
			return null;
		}
		return predicate;
	}

	public static class PredicateParseException extends Exception {
		private String info;

		PredicateParseException(String info) {
			this.info = info;
		}

		public String getInfo() {
			return info;
		}
	}

	private static boolean matchTerm(String term1, String term2, String context, TinkerSession session)
			throws Exception {
		IProofTreeNode contextNode = session.nameToNodeMap.get(context);
		Predicate p1 = parseStr(term1, contextNode.getSequent().typeEnvironment());
		Predicate p2 = parseStr(term2, contextNode.getSequent().typeEnvironment());
		if (p1 == null) {
			throw new PredicateParseException(term1);
		}
		if (p2 == null) {
			throw new PredicateParseException(term2);
		}
		// For current work, we only match 2 identical term
		return p1.equals(p2);
	}

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

	private static List<IProofTreeNode> get_unnamed_open_nodes(IProofTreeNode pt, TinkerSession session) {
		IProofTreeNode[] opens = pt.getOpenDescendants();
		List<IProofTreeNode> result = new ArrayList<>();
		for (IProofTreeNode p : opens) {
			String name = session.nodeToNameMap.get(p);
			if (name == null) {
				result.add(p);
			}
		}
		return result;
	}

	private static String Handle_NAME_OPEN_NODES(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		Map names = command.getParameters();
		List<IProofTreeNode> nodes = get_unnamed_open_nodes(pt, session);
		int j = 0;
		System.out.println("NAMING, length=" + nodes.size() + ", size=" + names.entrySet().size());
		if (nodes.size() == names.entrySet().size()) {
			for (Iterator<Map.Entry<String, String>> i = names.entrySet().iterator(); i.hasNext();) {

				Entry entry = i.next();
				String name = (String) entry.getValue();
				session.nameToNodeMap.put(name, nodes.get(j));
				session.nodeToNameMap.put(nodes.get(j), name);
				System.out.println("[name=" + name + ", p=" + nodes.get(j).toString() + "]");
				///System.out.println(nodes.get(j).toString());
				j++;
			}
		}
		String result = (new Command("NAMING_COMPLETE", names)).toString();
		return result;
	}

	private static String handle_GET_GOAL_CONCLUSION(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {

		String node = command.getParameter("PNODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		String goalstr = pnode.getSequent().goal().toString();

		Command cmd = (new Command("GET_GOAL_CONCLUSION_RESULT")).addParamter("GOAL", goalstr);

		return cmd.toString();
	}

	private static String handle_GET_HYPS(Command command, IProofTreeNode pt, IProofMonitor pm, TinkerConnector tinker,
			TinkerSession session) throws Exception {

		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		System.out.println("GETTING HYPs of " + pnode.toString());
		int c = 0;
		Command cmd = (new Command("GET_HYPS_RESULT"));
		for (Predicate p : pnode.getSequent().selectedHypIterable()) {
			cmd = cmd.addParamter(String.valueOf(c), p.toString());
			c++;
		}
		return cmd.toString();
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

	private static void refresh_proofTreeUI(TinkerSession session) {
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
	}

	private static String[] tailOf(String[] list) {
		String[] result = new String[list.length - 1];
		for (int i = 1; i < list.length; i++) {
			result[i - 1] = list[i];
		}
		return result;
	}

	@SuppressWarnings("unused")
	private static String handle_APPLY_TACTIC(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {

		String result;
		String tactic_type = command.getParameter("TYPE").toUpperCase();
		String targetNode = command.getParameter("NODE");
		IProofTreeNode target = session.nameToNodeMap.get(targetNode);

		pt.getSequent().goal().getGivenTypes();
		// System.out.println("applying tactic = " + tactic);
		Object tac_result = null;

		// String[] args = command.getParameter("ARGS").split(",");

		// Order of arguments are
		// 0. tactic target = ON_HYP | ON_GOAL
		// 1. arg 1
		// 2. arg 2
		// 3. arg 3
		// .. arg ... etc
		String tac_name = command.getParameter("TACTIC");
		if (tactic_type.equals("AUTO_TACTIC")) {
			tac_result = getAutoTactic(tac_name, target).apply(target, pm);
		} else if (tactic_type.equals("ON_HYP")) {
			tac_result = getOnHypTactic(tac_name, command, target).apply(target, pm);
		} else {
			tac_result = getOnGoalTactic(tac_name, command, target).apply(target, pm);

		}

		refresh_proofTreeUI(session);
		// wait 50ms for refresh prooftreeUI
		Thread.sleep(50);
		// System.out.println("tactic result = " + tac_result);
		if (tac_result == null) {
			// null means no error
			// int new_node_num = target.getOpenDescendants().length;
			int new_node_num = get_unnamed_open_nodes(target, session).size();
			if (target.isOpen()) {
				// no rule has been applied to the node.
				result = (new Command("ERROR")).addParamter("ERROR_INFO",
						"THIS TACTIC DOES NOT HAVE EFFECT ON NODE " + targetNode).toString();
			} else if (new_node_num > 0 && !target.isOpen()) {
				// Target node is not open after applying this tactic, this
				// means it has new child nodes
				// which needs naming

				// try to discharge dummy
				IProofTreeNode first = target.getOpenDescendants()[0];
				if (first.getSequent().goal().equals(DLib.True(first.getSequent().getFormulaFactory()))) {
					(new AutoTactics.TrueGoalTac()).apply(first, pm);
				}
				new_node_num = get_unnamed_open_nodes(target, session).size();

				result = (new Command("NEED_NAMING")).addParamter("PARENT", targetNode)
						.addParamter("NUM", String.valueOf(new_node_num)).toString();
			} else if (target.isClosed()) {
				// Closed - This node has no open descendants. The proof
				// for its sequent is complete.
				result = (new Command("NODE_CLOSED")).toString();

			} else {
				// Should never happen
				result = (new Command("ERROR")).addParamter("ERROR_INFO", "UNKNOWN ERROR").toString();

			}

		} else {
			result = (new Command("ERROR")).addParamter("ERROR_INFO", tac_result.toString()).toString();

		}
		return result;
	}

	private static String handle_MATCH_TERMS(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {

		String ctx = command.getParameter("CONTEXT");
		String t1 = command.getParameter("TERM1");
		String t2 = command.getParameter("TERM2");
		boolean match;
		String result;
		try {
			match = matchTerm(t1, t2, ctx, session);
			result = String.valueOf(match);
		} catch (PredicateParseException e) {
			result = "FAILED TO PARSE TERM:" + e.getInfo();
		}
		Command resultCmd = new Command("MATCH_RESULT").addParamter("RESULT", result);

		return resultCmd.toString();
	}

	private static boolean check_top_symbol(String symbol, String pnode, TinkerSession session) {
		IProofTreeNode pt = session.nameToNodeMap.get(pnode);
		int tag = pt.getSequent().goal().getTag();
		return tag == SymbolMapping.tagFromString(symbol);

	}

	private static String handle_TOP_SYMBOL_IS(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String pnode = command.getParameter("NODE");
		String symbol = command.getParameter("SYMB");
		Command cmd = new Command("TOP_SYMBOL_CHECK_RESULT").addParamter("RESULT",
				String.valueOf(check_top_symbol(symbol, pnode, session)));

		return cmd.toString();
	}

	public static List<String> getSubterms(Predicate p, IProofTreeNode node) {
		List<String> predicates_str = new ArrayList<>();
		Predicate new_p = p;

		if (p instanceof QuantifiedPredicate) {
			predicates_str.add(p.toString());
			QuantifiedPredicate q = (QuantifiedPredicate) p;
			final ISealedTypeEnvironment typenv = node.getSequent().typeEnvironment();
			final FreshInstantiation inst = new FreshInstantiation(q, typenv);
			new_p = inst.getResult();
		}

		predicates_str.add(new_p.toString());

		int i = p.getChildCount();
		// System.out.println("FOUND SUBTERM="+ p.toString());
		for (int k = 0; k < i; k++) {
			Formula f = new_p.getChild(k);
			if (f instanceof Predicate) {
				predicates_str.addAll(getSubterms((Predicate) f, node));
			}
		}
		return predicates_str;

	}

	private static String handle_SUB_TERMS(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String result;
		String termstr = command.getParameter("TERM");
		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		System.out.println("termstr=" + termstr);
		Predicate term = parseStr(termstr, pnode.getSequent().typeEnvironment());
		List<String> subterms = getSubterms(term, pnode);
		Command cmd = (new Command("SUB_TERMS"));
		for (int i = 0; i < subterms.size(); i++) {
			cmd = cmd.addParamter(String.valueOf(i), subterms.get(i).toString());
		}

		result = cmd.toString();
		return result;
	}

	private static String handle_GET_TOP_SYMBOL(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {

		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		String termstr = command.getParameter("TERM");
		Predicate term = parseStr(termstr, pnode.getSequent().typeEnvironment());
		String tag = SymbolMapping.tagToString(term.getTag());

		Command cmd = (new Command("GET_TOP_SYMBOL_RESULT")).addParamter("TAG", tag);
		return cmd.toString();
	}

	private static String handle_GET_GOAL_TERM(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		String term = pnode.getSequent().goal().toString();
		Command cmd = (new Command("GET_GOAL_TERM_RESULT")).addParamter("TERM", term);
		return cmd.toString();
	}

	private static String handle_HAS_HYP_WITH_TOPSYMBOL(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) throws Exception {
		String node = command.getParameter("NODE");
		System.out.println("HAS_HYP_WITH TOPSB node=" + node);
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		System.out.println(pnode.toString());
		String symb = command.getParameter("SYMB");
		int tag = SymbolMapping.tagFromString(symb);
		boolean considerNeg = false;
		if (tag == Formula.IN) {
			considerNeg = true;
		}
		Predicate hyp = find_first_hyp_with_tag(pnode, tag, false);

		Command cmd = (new Command("HAS_HYP_WITH_TOPSYMBOL_RESULT")).addParamter("RESULT", hyp != null);
		return cmd.toString();
	}

	@SuppressWarnings("unchecked")
	public static String execute(Command command, IProofTreeNode pt, IProofMonitor pm, TinkerConnector tinker,
			TinkerSession session) throws Exception {

		if (session.getPluginSate() == PluginStates.APPLYING) {
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

			case "APPLY_TACTIC":
				result = handle_APPLY_TACTIC(command, pt, pm, tinker, session);
				break;
			case "MATCH_TERMS":
				result = handle_MATCH_TERMS(command, pt, pm, tinker, session);
				break;

			case "GET_HYPS":
				result = handle_GET_HYPS(command, pt, pm, tinker, session);
				break;
			case "GET_GOAL_CONCLUSION":
				result = handle_GET_GOAL_CONCLUSION(command, pt, pm, tinker, session);
				break;
			case "SUB_TERMS":
				result = handle_SUB_TERMS(command, pt, pm, tinker, session);
				break;
			case "GET_TOP_SYMBOL":
				result = handle_GET_TOP_SYMBOL(command, pt, pm, tinker, session);
				break;
			case "TOP_SYMBOL_IS":
				result = handle_TOP_SYMBOL_IS(command, pt, pm, tinker, session);
				break;
			case "GET_GOAL_TERM":
				result = handle_GET_GOAL_TERM(command, pt, pm, tinker, session);
				break;
			//case "ALL_SYMBOL":

				//break;
			case "GET_PSGRAPH":
				result = handle_GET_PSGRAPH(command, pt, pm, tinker, session);
				break;
			case "CAN_SYMPLIFY_HYPS":
				result = handle_CAN_SIMPLIFY_HYPS(command, pt, pm, tinker, session);
				break;
			case "HYPS_HAVE_USE_OF":
				result= handle_HYPS_HAVE_USE_OF(command, pt, pm, tinker, session);
				break;
			case "HAS_HYP_WITH_TOPSYMBOL":
				result = handle_HAS_HYP_WITH_TOPSYMBOL(command, pt, pm, tinker, session);
				return result;
			case "HAS_DEF_OF":
				result = handle_HAS_DEF_OF(command, pt, pm, tinker, session);
				break;
			default:
				throw new Exception("Unknown Command: "+ command.getCommand());
			}
			return result;
		} else {
			throw new Exception("Try execute while not in EXECUTION STATE");
		}
	}

	private static boolean search_predicate_for_subterm(Predicate p, IProofTreeNode pt, String s){
		//search subterms of the predicate for a match of the string
		//Be very careful of using this function. Because the type of the terms are not checked.
		//Users are supposed to only use it in a naive way, where only some obvious and unambiguous term is being searched
		List<String> subterms= getSubterms(p,pt);
		for (String subterm: subterms){
			if (s.equals(subterm)){
				return true;
			}
		}
		return false;
		
	}
	
	private static String handle_HYPS_HAVE_USE_OF(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) {
		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		String varstr = command.getParameter("TERM");
		Command result = new Command("RESULT_HYPS_HAVE_USE_OF");
		for (Predicate hyp : pnode.getSequent().selectedHypIterable()) {
			if (search_predicate_for_subterm(hyp, pnode, varstr)){
				result.addParamter("RESULT", "true");
				return result.toString();
			}
		}

		result.addParamter("RESULT", "false");
		return result.toString();
	}
	
	private static String handle_HAS_DEF_OF(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) {
		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		String termstr = command.getParameter("TERM");
		Command result = new Command("HAS_DEF_RESULT");
		for (Predicate hyp : pnode.getSequent().hypIterable()) {
			if (hyp.getTag() == Formula.EQUAL) {
				if (hyp.getChild(0).toString().equals(termstr) || hyp.getChild(1).toString().equals(termstr)) {
					result.addParamter("RESULT", "true");
					return result.toString();
				}
			}
		}
		result.addParamter("RESULT", "false");
		return result.toString();
	}

	private static String handle_CAN_SIMPLIFY_HYPS(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) {
		String node = command.getParameter("NODE");
		IProofTreeNode pnode = session.nameToNodeMap.get(node);
		ITactic t = new AutoTactics.EqHypTac();
		t.apply(pnode, pm);
		Command result;
		if (pnode.hasChildren()) {
			pnode.pruneChildren();
			result = new Command("CAN_SYMPIFY_HYPS_RESULT");
			result = result.addParamter("RESULT", "true");
		} else {
			result = new Command("CAN_SYMPIFY_HYPS_RESULT");
			result = result.addParamter("RESULT", "false");
		}
		return result.toString();
	}

	private static String handle_GET_PSGRAPH(Command command, IProofTreeNode pt, IProofMonitor pm,
			TinkerConnector tinker, TinkerSession session) {
		// TODO Auto-generated method stub
		Command cmd = new Command("PS_GRAPH");
		cmd.addParamter("PS", session.getPsgraph());

		return cmd.toString();
	}

	private static ITactic getOnGoalTactic(String tacticName, Command cmd, IProofTreeNode pnode) {
		switch (tacticName.toUpperCase()) {
		case "INST":
			String[] inst_values = cmd.getParameter("PARAM").split(",");
			return Tactics.exI(inst_values);
		case "IMPL":
			return Tactics.impI();
		case "DO_CASE":
			String caseterm = cmd.getParameter("1");
			return Tactics.doCase(caseterm);
		default:
			return new Tactics.FailureTactic();

		}
	}

	private static Predicate get_hyp(String str, IProofTreeNode pnode) {
		Predicate term = parseStr(str, pnode.getSequent().typeEnvironment());
		if (term == null)
			return null;
		for (Predicate hyp : pnode.getSequent().hiddenHypIterable()) {
			if (term.equals(hyp)) {
				return hyp;
			}
		}
		return null;
	}

	private static List<Integer> get_predicate_tag_in_list(Predicate p) {
		int size = p.getChildCount();
		List<Integer> result = new ArrayList<Integer>();
		if (p instanceof UnaryPredicate) {
			result.add(p.getTag());
			List a = get_predicate_tag_in_list((Predicate) p.getChild(0));
			result.addAll(a);
		} else if (p instanceof BinaryPredicate) {
			List a = get_predicate_tag_in_list((Predicate) p.getChild(0));
			result.addAll(a);
			result.add(p.getTag());
			List b = get_predicate_tag_in_list((Predicate) p.getChild(1));
			result.addAll(b);
		} else if (p instanceof SimplePredicate) {
			result.add(p.getTag());
		} else if (p instanceof QuantifiedPredicate) {
			result.add(p.getTag());
			List a = get_predicate_tag_in_list((Predicate) p.getChild(0));
			result.addAll(a);
		} else if (p instanceof AssociativePredicate) {
			List a = get_predicate_tag_in_list((Predicate) p.getChild(0));
			result.addAll(a);
			result.add(p.getTag());
			List b = get_predicate_tag_in_list((Predicate) p.getChild(1));
			result.addAll(b);
		}
		return result;
	}

	private static Predicate find_first_hyp_with_tag(IProofTreeNode pnode, int tag, boolean considerNeg) {
		if (pnode.getSequent() != null) {
			for (Predicate hyp : pnode.getSequent().selectedHypIterable()) {
				if (hyp.getTag() == tag) {
					return hyp;
				} else if (considerNeg && hyp.getTag() == Formula.NOT) {
					// hypothesis with NOT is also considered
					// so find (pnode, IN) will return both a∈some_set and
					// ¬a∈some_set
					if (hyp.getChild(0).getTag() == tag) {
						return hyp;
					}
				}

			}
		}
		return null;
	}

	private static List<Predicate> find_all_hyp_with_tag(IProofTreeNode pnode, int tag, Iterable<Predicate> hyps) {
		List<Predicate> result = new ArrayList<Predicate>();
		for (Predicate hyp : hyps) {
			if (hyp.getTag() == tag) {
				result.add(hyp);
			} else if (hyp.getTag() == Formula.NOT) {
				// hypothesis with NOT is also considered
				// so find all (pnode, IN) will add both a∈some_set and
				// ¬a∈some_set
				if (hyp.getChild(0).getTag() == tag) {
					result.add(hyp);
				}
			}

		}
		return result;
	}

	private static IPosition find_first_position_with_tag(Predicate p, int tag) {
		List<IPosition> result = p.getPositions(new NaiveFormulaFilter());
		if (result.size() > 0) {
			for (IPosition pos : result) {
				if (p.getSubFormula(pos).getTag() == tag) {
					return pos;
				}

			}
			return null;
		} else {
			return null;
		}
	}

	private static ITactic getOnHypTactic(String tacticName, Command cmd, IProofTreeNode pnode) {
		String term = cmd.getParameter("TERM");
		Predicate hyp;
		if (term != null) {
			hyp = get_hyp(term, pnode);
		} else {
			hyp = null;
		}
		switch (tacticName) {
		case "simple_split_case":
			if (hyp != null) {
				return Tactics.disjE(hyp);
			} else {
				hyp = find_first_hyp_with_tag(pnode, Formula.LOR, false);
				if (hyp != null) {
					return Tactics.disjE(hyp);
				} else {
					return new Tactics.FailureTactic();
				}
			}

		case "EqHypTac": // eqvRewrite Equivalent Hypothesis rewrite tactic

			final ITacticApplication appli = (new EqvLR()).getPossibleApplications(pnode, hyp, null).get(0);

			return appli.getTactic(null, null);
		case "remove_MEMBERSHIP":

			if (hyp != null) {
				IPosition pos = find_first_position_with_tag(hyp, Formula.IN);
				if (pos != null) {
					return Tactics.removeMembership(hyp, pos);
				} else {
					return new Tactics.FailureTactic();
				}

			} else {
				hyp = find_first_hyp_with_tag(pnode, Formula.IN, true);
				if (hyp != null) {
					IPosition pos = find_first_position_with_tag(hyp, Formula.IN);
					return Tactics.removeMembership(hyp, pos);
				} else {
					return new Tactics.FailureTactic();
				}
			}
		case "eh_SETDEF":
			List<Predicate> equals = find_all_hyp_with_tag(pnode, Formula.EQUAL, pnode.getSequent()
					.selectedHypIterable());
			for (Predicate h : equals) {
				if (h.getChild(1).getTag() == Formula.SETEXT) {
					return Tactics.eqE(h);
				}
			}
		case "rewrite_NOT_OR":
			// Tactics.removeNeg(hyp, position);
			// rewrite not (a or b) to not a and not b
			List<Predicate> nots = find_all_hyp_with_tag(pnode, Formula.NOT, pnode.getSequent().selectedHypIterable());
			for (Predicate h : nots) {
				System.out.println(h.getSyntaxTree());
				if (h.getTag() == Formula.NOT) {
					if (h.getChild(0).getTag() == Formula.LOR) {
						System.out.println("appying R_NO ON " + h.toString());
						List<IPosition> t = h.getPositions(new NaiveFormulaFilter());

						return Tactics.removeNeg(hyp, t.get(0));
					}
				}
			}
		case "INST": // instantiate
			String termstr = cmd.getParameter("HYP");
			Predicate selected_hyp = null;
			Predicate hyp_term = parseStr(termstr, pnode.getSequent().typeEnvironment());
			for (Predicate h : pnode.getSequent().selectedHypIterable()) {
				if (hyp_term.equals(h)) {
					selected_hyp = h;
					break;
				}
			}
			
			String[] inst_values = cmd.getParameter("PARAM").split(",");
			return Tactics.allD(selected_hyp, inst_values);
		//two on hyp auto tactics

		case "simp_rewrite":
			return (new AutoTactics.AutoRewriteTac());
		case "equal_hyp_rewrite":
			return new AutoTactics.EqHypTac();
		case "partition_rewrite":
			return new AutoTactics.PartitionRewriteTac();
			
		default:
			return new Tactics.FailureTactic();
		}

	}

	private static ITactic getAutoTactic(String tacticName, IProofTreeNode pnode) {
		System.out.println("applying auto tactic: name= " + tacticName);
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
		case "newPP_AL":
			return Tactics.afterLasoo(PPCore.newPP(true, 2000, 3000));
		case "newPP_UR":
			return PPCore.newPP(false, 2000, 3000);
		case "newPP_R":
			return PPCore.newPP(true, 2000, 3000);
		case "autoProver":
			// Simple copy from the construction of
			// AutoProver.AutoProverApplication
			final Object origin = pnode.getProofTree().getOrigin();
			if (!(origin instanceof IProofAttempt)) {
				return new Tactics.FailureTactic();
			}
			final IProofAttempt pa = (IProofAttempt) origin;
			final IPORoot poRoot = pa.getComponent().getPORoot();
			return EventBPlugin.getAutoPostTacticManager().getSelectedAutoTactics(poRoot);
		default:
			return Tactics.autoRewrite();
		}

	}
}