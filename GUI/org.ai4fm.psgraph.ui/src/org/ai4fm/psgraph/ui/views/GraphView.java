/*******************************************************************************
 * Copyright (c) 2009, 2010 Fabian Steeg. All rights reserved. This program and
 * the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * <p/>
 * Contributors: Fabian Steeg - initial API and implementation; see bug 277380
 *******************************************************************************/

package org.ai4fm.psgraph.ui.views;

import org.ai4fm.psgraph.ui.PSGraphUIPlugin;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.ActionContributionItem;
import org.eclipse.jface.action.IContributionItem;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.IWorkbenchActionConstants;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;
import org.eclipse.zest.core.widgets.Graph;
import org.eclipse.zest.internal.dot.DotImport;

/**
 * View showing the Zest import for a DOT input. Listens to *.dot files and
 * other files with DOT content in the workspace and allows for image file
 * export via calling a local 'dot' (location is selected in a dialog and stored
 * in the preferences).
 * 
 * @author Fabian Steeg (fsteeg)
 */
public final class GraphView extends ViewPart {

	public static final String ID = "org.ai4fm.psgraph.ui.views.GraphView"; //$NON-NLS-1$

	private static final RGB BACKGROUND = JFaceResources.getColorRegistry()
			.getRGB("org.eclipse.jdt.ui.JavadocView.backgroundColor"); //$NON-NLS-1$

	private static final String LAYOUT = "";
	private static final String EXPORT_MODE = "";
	private static final String LINK_MODE = "";

	private static final String RESOURCES_ICONS_LAYOUT = "resources/icons/layout.gif"; //$NON-NLS-1$
	private static final String RESOURCES_ICONS_EXPORT_MODE = "resources/icons/export-mode.gif"; //$NON-NLS-1$
	private static final String RESOURCES_ICONS_LINK_MODE = "resources/icons/link-mode.gif"; //$NON-NLS-1$


	private boolean exportFromZestGraph = true;
	private boolean linkImage = false;

	private Composite composite;
	private Graph graph;
	
	// buttons
	private Action nextAction;
	private Action backAction;
	private Action exitAction;
	private Action searchAction;

	private String dotString = "";
	private String init = "digraph G { "+
"Vc [style=filled,fillcolor=gray,shape=box,width=0,height=0,fontcolor=white];"+
"Ve [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"rule: HOL.impI\"];"+
"Vp [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"rule: HOL.allI\"];"+
"Vq [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"tactic: assumption\"];"+
"Vp -> Ve [label=\"default_wire\"];"+
"Ve -> Vq [label=\"default_wire\"];"+
"Vc -> Vp [label=\"default_wire\"];"+
"}"; //$NON-NLS-1$


	/**
	 * {@inheritDoc}
	 * 
	 * @see org.eclipse.ui.part.WorkbenchPart#createPartControl(org.eclipse.swt.widgets.Composite)
	 */
	@Override
	public void createPartControl(final Composite parent) {
		composite = new Composite(parent, SWT.NULL);
		GridLayout layout = new GridLayout();
		composite.setLayout(layout);
		composite.setBackground(new Color(composite.getDisplay(), BACKGROUND));
		
		updateGraph(init);
		addLayoutButton();
		addExportModeButton();
		addLinkModeButton();
		
		makeActions();
		contributeToActionBars();
	}

	public Graph getGraph() {
		return graph;
	}

	private void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	private void fillLocalPullDown(IMenuManager manager) {
		manager.add(nextAction);
		manager.add(new Separator());
		manager.add(backAction);
	}

	
	private void fillLocalToolBar(IToolBarManager manager) {
		manager.add(nextAction);
		manager.add(backAction);
		// manager.add(action2);
	}	
	
	private void makeActions() {
		nextAction = new Action() {
			public void run() {
				updateGraph("x -> y");
			}
		};
		nextAction.setText("Next");
		nextAction.setToolTipText("Apply next step");
		nextAction.setImageDescriptor(PlatformUI.getWorkbench().getSharedImages().
			getImageDescriptor(ISharedImages.IMG_TOOL_FORWARD));

		backAction = new Action() {
			public void run() {
				updateGraph("x -> y");
			}
		};
		backAction.setText("Back");
		backAction.setToolTipText("Backtrack previous step");
		backAction.setImageDescriptor(PlatformUI.getWorkbench().getSharedImages().
			getImageDescriptor(ISharedImages.IMG_TOOL_UNDO));		
		
	}
	
	
	
	public void setGraph(final String dot, boolean async) {
		dotString = dot;
		Runnable runnable = new Runnable() {
			@Override
			public void run() {
				updateZestGraph(dot);
			}

			private void updateZestGraph(final String currentDot) {
				if (graph != null) {
					graph.dispose();
				}
				if (composite != null) {
					DotImport dotImport = new DotImport(dotString);
					if (dotImport.getErrors().size() > 0) {
						String message = String.format(
								"Could not import DOT: %s, DOT: %s", //$NON-NLS-1$
								dotImport.getErrors(), dotString);
						PSGraphUIPlugin
								.getDefault()
								.getLog()
								.log(new Status(IStatus.ERROR,
										PSGraphUIPlugin.PLUGIN_ID, message));
						return;
					}
					graph = dotImport.newGraphInstance(composite, SWT.NONE);
					setupLayout();
					composite.layout();
					graph.applyLayout();
				}
			}
		};
		Display display = getViewSite().getShell().getDisplay();
		if (async) {
			display.asyncExec(runnable);
		} else {
			display.syncExec(runnable);
		}
	}

	private void addExportModeButton() {
		Action toggleRenderingAction = new Action(EXPORT_MODE, SWT.TOGGLE) {
			@Override
			public void run() {
				exportFromZestGraph = toggle(this, exportFromZestGraph);
			}
		};
		toggleRenderingAction.setId(toggleRenderingAction.getText());
		toggleRenderingAction.setImageDescriptor(PSGraphUIPlugin
				.getImageDescriptor(RESOURCES_ICONS_EXPORT_MODE));
		IToolBarManager mgr = getViewSite().getActionBars().getToolBarManager();
		mgr.add(toggleRenderingAction);
	}

	private boolean toggle(Action action, boolean input) {
		action.setChecked(!action.isChecked());
		IToolBarManager mgr = getViewSite().getActionBars().getToolBarManager();
		for (IContributionItem item : mgr.getItems()) {
			if (item.getId() != null && item.getId().equals(action.getText())) {
				ActionContributionItem i = (ActionContributionItem) item;
				i.getAction().setChecked(!i.getAction().isChecked());
				return !input;
			}
		}
		return input;
	}

	private void addLayoutButton() {
		Action layoutAction = new Action(LAYOUT) {
			@Override
			public void run() {
				if (graph != null) {
					graph.applyLayout();
				}
			}
		};
		layoutAction.setImageDescriptor(PSGraphUIPlugin
				.getImageDescriptor(RESOURCES_ICONS_LAYOUT));
		IToolBarManager mgr = getViewSite().getActionBars().getToolBarManager();
		mgr.add(layoutAction);
		mgr.add(new Separator());
	}



	private void addLinkModeButton() {
		Action linkModeAction = new Action(LINK_MODE, SWT.TOGGLE) {
			@Override
			public void run() {
				linkImage = toggle(this, linkImage);
			}
		};
		linkModeAction.setId(linkModeAction.getText());
		linkModeAction.setImageDescriptor(PSGraphUIPlugin
				.getImageDescriptor(RESOURCES_ICONS_LINK_MODE));
		getViewSite().getActionBars().getToolBarManager().add(linkModeAction);
	}

	

	public void updateGraph(String currentDot) {
		if (currentDot.equals(dotString)
				|| currentDot.equals("")) {
			return;
		}
		setGraph(currentDot, true);
	}



	private void setupLayout() {
		if (graph != null) {
			GridData gd = new GridData(GridData.FILL_BOTH);
			graph.setLayout(new GridLayout());
			graph.setLayoutData(gd);
			Color color = new Color(graph.getDisplay(), BACKGROUND);
			graph.setBackground(color);
			graph.getParent().setBackground(color);
		}
	}



	/**
	 * {@inheritDoc}
	 * 
	 * @see org.eclipse.ui.part.WorkbenchPart#dispose()
	 */
	@Override
	public void dispose() {
		super.dispose();
		if (graph != null) {
			graph.dispose();
		}
		if (composite != null) {
			composite.dispose();
		}
	}

	/**
	 * {@inheritDoc}
	 * 
	 * @see org.eclipse.ui.part.WorkbenchPart#setFocus()
	 */
	@Override
	public void setFocus() {
		if (graph != null && !graph.isDisposed()) {
			graph.setFocus();
		}
	}
}
