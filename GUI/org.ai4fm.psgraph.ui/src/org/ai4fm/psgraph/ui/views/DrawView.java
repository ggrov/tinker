package org.ai4fm.psgraph.ui.views;

import org.ai4fm.psgraph.ui.Communication;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.part.ViewPart;

import java.awt.Frame;
import org.eclipse.swt.SWT;

import org.eclipse.swt.awt.SWT_AWT;

import quanto.gui.*;
import quanto.util.json.Json;
import quanto.data.*;
import quanto.layout.*;

public class DrawView extends ViewPart {

	public DrawView() {
		// TODO Auto-generated constructor stub
	}
	/**
	 * This is a callback that will allow us
	 * to create the viewer and initialize it.
	 */
	public void createPartControl(Composite parent) {
		System.setProperty("sun.awt.noerasebackground", "true");
		
		Composite composite = new Composite(parent, SWT.EMBEDDED | SWT.NO_BACKGROUND);
		Frame frame = SWT_AWT.new_Frame(composite);
		
		// load the theory. You only need to do this once, as long as you can get a hold of it later.
		Json.Input thyFile = new Json.Input(GraphEditor.class.getResourceAsStream("string_ve.qtheory"));
		Theory stringVETheory = Theory.fromJson(Json.parse(thyFile));
		
		String graphJson =
		  "{\"dir_edges\":{\"e0\":{\"src\":\"v0\",\"tgt\":\"v2\"},\"e1\":" +
		  "{\"src\":\"v2\",\"tgt\":\"v1\"}},\"wire_vertices\":{\"v2\":{" +
		  "\"annotation\":{\"coord\":[-0.26,1.35]}}},\"node_vertices\":{" +
		  "\"v0\":{\"data\":{\"type\":\"string\",\"value\":\"foo\"}," +
		  "\"annotation\":{\"coord\":[-1.1,1.99]}},\"v1\":{\"data\":{\"type\"" +
		  ":\"string\",\"value\":\"bar\"},\"annotation\":{\"coord\":[0.58,0.69]}}}}";
		
		Graph g = Graph.fromJson(graphJson, stringVETheory);
		
		// optional: layout with graphviz
		GraphLayout dot = new DotLayout();
		g = dot.layout(g);
		
		GraphEditPanel p = new GraphEditPanel(stringVETheory, /* readOnly = */ true);
		Communication.jsongraph = p;
		Communication.stringVETheory = stringVETheory;
		p.setGraph(g);
		frame.add(p.peer());
	}

	/**
	 * Passing the focus request to the viewer's control.
	 */
	public void setFocus() {}
	
	@Override
	public void dispose() {
		
	}
}
