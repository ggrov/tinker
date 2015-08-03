package tinker.core.execute;

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
import org.eventb.core.ast.FreeIdentifier;
import org.eventb.core.ast.IFormulaFilter;
import org.eventb.core.ast.IntegerLiteral;
import org.eventb.core.ast.LiteralPredicate;
import org.eventb.core.ast.MultiplePredicate;
import org.eventb.core.ast.QuantifiedExpression;
import org.eventb.core.ast.QuantifiedPredicate;
import org.eventb.core.ast.RelationalPredicate;
import org.eventb.core.ast.SetExtension;
import org.eventb.core.ast.SimplePredicate;
import org.eventb.core.ast.UnaryExpression;
import org.eventb.core.ast.UnaryPredicate;

//select all predicate
public class NaiveFormulaFilter implements IFormulaFilter  {
	
	@Override
	public boolean select(ExtendedPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(ExtendedExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(UnaryPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(UnaryExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(SimplePredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(SetExtension expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(RelationalPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(QuantifiedPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(QuantifiedExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(MultiplePredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(LiteralPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(IntegerLiteral literal) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(FreeIdentifier identifier) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(BoundIdentifier identifier) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(BoundIdentDecl decl) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(BoolExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(BinaryPredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(BinaryExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(AtomicExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public boolean select(AssociativePredicate predicate) {
		// TODO Auto-generated method stub
		return true;
	}
	
	@Override
	public boolean select(AssociativeExpression expression) {
		// TODO Auto-generated method stub
		return false;
	}
}