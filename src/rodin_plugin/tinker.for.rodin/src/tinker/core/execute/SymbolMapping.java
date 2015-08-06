package tinker.core.execute;

import org.eventb.core.ast.Formula;

public class SymbolMapping {
	public static String tagToString (int tag){
		switch (tag){
		case Formula.LAND:
			return "∧";
		case Formula.LOR:
			return "∨";
		case Formula.NOT:
			return "¬";
		case Formula.EXISTS:
			return "∃";
		case Formula.FORALL:
			return "∀";
		case Formula.IN:
			return "∈";
		default :
			return "";
		}
	}
	
	public static int tagFromString (String str){
		switch (str) {
		case "AND":
		case "∧":
			return Formula.LAND;
		case "OR":
		case "∨":
			return Formula.LOR;
		case "NOT":
		case "¬":
			return  Formula.NOT;
		case "FORALL":
		case "∀":
			return  Formula.FORALL;
		case "EXISTS":
		case "∃":
			return  Formula.EXISTS;
		case "IN":
		case "∈":
			return Formula.IN;
		default:
			return -1;
		}

	}
}
