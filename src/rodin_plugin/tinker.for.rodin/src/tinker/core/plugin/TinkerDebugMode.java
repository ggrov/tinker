package tinker.core.plugin;

import static java.util.Collections.emptyList;
import static java.util.Collections.singletonList;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eventb.core.ast.Formula;
import org.eventb.core.ast.IPosition;
import org.eventb.core.ast.Predicate;
import org.eventb.core.ast.QuantifiedPredicate;
import org.eventb.core.seqprover.IProofMonitor;
import org.eventb.core.seqprover.IProofTreeNode;
import org.eventb.core.seqprover.ITactic;
import org.eventb.core.seqprover.eventbExtensions.Tactics;
import org.eventb.ui.prover.DefaultTacticProvider;
import org.eventb.ui.prover.ITacticApplication;

import tinker.core.execute.CommandExecutor;
import tinker.core.socket.TinkerConnector;
import tinker.core.tactics.TinkerTactic;

public class TinkerDebugMode extends DefaultTacticProvider {
	public static class TinkerApplication extends DefaultPositionApplication {

		private static final String TACTIC_ID = "org.eventb.ui.tinker.debugprover";

		public TinkerApplication(Predicate hyp) {
			super(hyp, IPosition.ROOT);
		}

		@Override
		public ITactic getTactic(String[] inputs, String globalInput) {
			return new TinkerTactic();
		}

		@Override
		public String getTacticID() {
			return TACTIC_ID;
		}

	}

	@Override
	public List<ITacticApplication> getPossibleApplications(IProofTreeNode node, Predicate hyp, String globalInput) {
		
		if (node != null && node.isOpen()) {
			final ITacticApplication appli = new TinkerApplication(hyp);
			return singletonList(appli);
		}
		return emptyList();
	}

}
