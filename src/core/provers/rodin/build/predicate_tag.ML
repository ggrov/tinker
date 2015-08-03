

(* Predicate Tags in Rodin *)
structure PredicateTag = 
struct
 
	val NO_TAG = 0;

	(**
	 * <code>FREE_IDENT</code> represents a free occurence of an identifer.
	 * Can only be a FreeIdentifier AST node.
	 *)
	val FREE_IDENT = 1;

	(**
	 * <code>BOUND_IDENT_DECL</code> represents a declaration of a bound
	 * identifer (within a quantified formula). Can only be a BoundIdentDecl AST
	 * node.
	 *)
	val BOUND_IDENT_DECL = 2;

	(**
	 * <code>BOUND_IDENT</code> represents a bound occurence of an identifer.
	 * Can only be a BoundIdentifier AST node.
	 *)
	val BOUND_IDENT = 3;

	(**
	 * <code>INTLIT</code> represents an integer. Can only be an
	 * IntegerLiteral AST node.
	 *)
	val INTLIT = 4;

	(**
	 * <code>SETEXT</code> represents a set in extension {E1,E2,E3}. Can only
	 * be a SetExtension AST node.
	 *)
	val SETEXT = 5;

	(**
	 * <code>BECOMES_EQUAL_TO</code> represents a "becomes equal to"
	 * assignment, e.g., <code>x ≔ x + 1</code>. Can only be a
	 * BecomesEqualTo AST node.
	 *)
	val BECOMES_EQUAL_TO = 6;

	(**
	 * <code>BECOMES_MEMBER_OF</code> represents a "becomes member of"
	 * assignment, e.g., <code>x :\<in> S</code>. Can only be a
	 * BecomesMemberOf AST node.
	 *)
	val BECOMES_MEMBER_OF = 7;

	(**
	 * <code>BECOMES_SUCH_THAT</code> represents a "becomes such that"
	 * assignment, e.g., <code>x :| x < x'</code>. Can only be a
	 * BecomesSuchThat AST node.
	 *)
	val BECOMES_SUCH_THAT = 8;

	(**
	 * <code>PREDICATE_VARIABLE</code> represents a predicate variable.
	 * 
	 * @see PredicateVariable
	 * @since 1.2
	 *)
	val PREDICATE_VARIABLE = 9;

	(**
	 * First tag for a relational predicate.
	 * 
	 * @see RelationalPredicate
	 *)
	val FIRST_RELATIONAL_PREDICATE = 101;

	(**
	 * <code>EQUAL</code> represents equality.
	 * 
	 * @see RelationalPredicate
	 *)
	val EQUALITY = FIRST_RELATIONAL_PREDICATE + 0;

	(**
	 * <code>NOTEQUAL</code> represents difference
	 * 
	 * @see RelationalPredicate
	 *)
	val NOTEQUAL = FIRST_RELATIONAL_PREDICATE + 1;

	(**
	 * <code>LT</code> represents <
	 * 
	 * @see RelationalPredicate
	 *)
	val LT = FIRST_RELATIONAL_PREDICATE + 2;

	(**
	 * <code>LE</code> represents <= Can only be used in a RelationalPredicate
	 * AST node.
	 *)
	val LE = FIRST_RELATIONAL_PREDICATE + 3;

	(**
	 * <code>GT</code> represents > Can only be used in a RelationalPredicate
	 * AST node.
	 *)
	val GT = FIRST_RELATIONAL_PREDICATE + 4;

	(**
	 * <code>GE</code> represents >= Can only be used in a RelationalPredicate
	 * AST node.
	 *)
	val GE = FIRST_RELATIONAL_PREDICATE + 5;

	(**
	 * <code>IN</code> represents \u2208 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val IN = FIRST_RELATIONAL_PREDICATE + 6;

	(**
	 * <code>NOTIN</code> represents \u2209 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val NOTIN = FIRST_RELATIONAL_PREDICATE + 7;

	(**
	 * <code>SUBSET</code> represents \u2282 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val SUBSET = FIRST_RELATIONAL_PREDICATE + 8;

	(**
	 * <code>NOTSUBSET</code> represents \u2284 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val NOTSUBSET = FIRST_RELATIONAL_PREDICATE + 9;

	(**
	 * <code>SUBSETEQ</code> represents \u2286 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val SUBSETEQ = FIRST_RELATIONAL_PREDICATE + 10;

	(**
	 * <code>NOTSUBSETEQ</code> represents \u2288 Can only be used in a
	 * RelationalPredicate AST node.
	 *)
	val NOTSUBSETEQ = FIRST_RELATIONAL_PREDICATE + 11;

	(**
	 * First tag for a non-associative binary expression.
	 * 
	 * @see BinaryExpression
	 *)
	val FIRST_BINARY_EXPRESSION = 201;

	(**
	 * <code>MAPSTO</code> represents \u21a6
	 * 
	 * @see BinaryExpression
	 *)
	val MAPSTO = FIRST_BINARY_EXPRESSION + 0;

	(**
	 * <code>REL</code> represents \u2194
	 * 
	 * @see BinaryExpression
	 *)
	val REL = FIRST_BINARY_EXPRESSION + 1;

	(**
	 * <code>TREL</code> represents \ue100
	 * 
	 * @see BinaryExpression
	 *)
	val TREL = FIRST_BINARY_EXPRESSION + 2;

	(**
	 * <code>SREL</code> represents \ue101
	 * 
	 * @see BinaryExpression
	 *)
	val SREL = FIRST_BINARY_EXPRESSION + 3;

	(**
	 * <code>STREL</code> represents \ue102
	 * 
	 * @see BinaryExpression
	 * 
	 *)
	val STREL = FIRST_BINARY_EXPRESSION + 4;

	(**
	 * <code>PFUN</code> represents \u21f8
	 * 
	 * @see BinaryExpression
	 *)
	val PFUN = FIRST_BINARY_EXPRESSION + 5;

	(**
	 * <code>TFUN</code> represents \u2192
	 * 
	 * @see BinaryExpression
	 *)
	val TFUN = FIRST_BINARY_EXPRESSION + 6;

	(**
	 * <code>PINJ</code> represents \u2914
	 * 
	 * @see BinaryExpression
	 *)
	val PINJ = FIRST_BINARY_EXPRESSION + 7;

	(**
	 * <code>TINJ</code> represents \u21a3
	 * 
	 * @see BinaryExpression
	 *)
	val TINJ = FIRST_BINARY_EXPRESSION + 8;

	(**
	 * <code>PSUR</code> represents \u2900
	 * 
	 * @see BinaryExpression
	 *)
	val PSUR = FIRST_BINARY_EXPRESSION + 9;

	(**
	 * <code>TSUR</code> represents \u21a0
	 * 
	 * @see BinaryExpression
	 *)
	val TSUR = FIRST_BINARY_EXPRESSION + 10;

	(**
	 * <code>TBIJ</code> represents \u2916
	 * 
	 * @see BinaryExpression
	 *)
	val TBIJ = FIRST_BINARY_EXPRESSION + 11;

	(**
	 * <code>SETMINUS</code> represents \u2216
	 * 
	 * @see BinaryExpression
	 *)
	val SETMINUS = FIRST_BINARY_EXPRESSION + 12;

	(**
	 * <code>CPROD</code> represents \u00d7
	 * 
	 * @see BinaryExpression
	 *)
	val CPROD = FIRST_BINARY_EXPRESSION + 13;

	(**
	 * <code>DPROD</code> represents \u2297
	 * 
	 * @see BinaryExpression
	 *)
	val DPROD = FIRST_BINARY_EXPRESSION + 14;

	(**
	 * <code>PPROD</code> represents \u2225
	 * 
	 * @see BinaryExpression
	 *)
	val PPROD = FIRST_BINARY_EXPRESSION + 15;

	(**
	 * <code>DOMRES</code> represents \u25c1
	 * 
	 * @see BinaryExpression
	 *)
	val DOMRES = FIRST_BINARY_EXPRESSION + 16;

	(**
	 * <code>DOMSUB</code> represents \u2a64
	 * 
	 * @see BinaryExpression
	 *)
	val DOMSUB = FIRST_BINARY_EXPRESSION + 17;

	(**
	 * <code>RANRES</code> represents \u25b7
	 * 
	 * @see BinaryExpression
	 *)
	val RANRES = FIRST_BINARY_EXPRESSION + 18;

	(**
	 * <code>RANSUB</code> represents \u2a65
	 * 
	 * @see BinaryExpression
	 *)
	val RANSUB = FIRST_BINARY_EXPRESSION + 19;

	(**
	 * <code>UPTO</code> represents \u2025
	 * 
	 * @see BinaryExpression
	 *)
	val UPTO = FIRST_BINARY_EXPRESSION + 20;

	(**
	 * <code>MINUS</code> represents - Can only be used in a AST node.
	 *)
	val MINUS = FIRST_BINARY_EXPRESSION + 21;

	(**
	 * <code>DIV</code> represents integer division.
	 * 
	 * @see BinaryExpression
	 *)
	val DIV = FIRST_BINARY_EXPRESSION + 22;

	(**
	 * <code>MOD</code> represents mod
	 * 
	 * @see BinaryExpression
	 *)
	val MOD = FIRST_BINARY_EXPRESSION + 23;

	(**
	 * <code>EXPN</code> represents integer exponentiation.
	 * 
	 * @see BinaryExpression
	 *)
	val EXPN = FIRST_BINARY_EXPRESSION + 24;

	(**
	 * <code>FUNIMAGE</code> represents function application.
	 * 
	 * @see BinaryExpression
	 *)
	val FUNIMAGE = FIRST_BINARY_EXPRESSION + 25;

	(**
	 * <code>RELIMAGE</code> represents relational image []
	 * 
	 * @see BinaryExpression
	 *)
	val RELIMAGE = FIRST_BINARY_EXPRESSION + 26;

	(**
	 * First tag for a non-associative binary predicate.
	 * 
	 * @see BinaryPredicate
	 *)
	val FIRST_BINARY_PREDICATE = 251;

	(**
	 * <code>LIMP</code> represents \u21d2
	 * 
	 * @see BinaryPredicate
	 *)
	val LIMP = FIRST_BINARY_PREDICATE + 0;

	(**
	 * <code>LEQV</code> represents \u21d4
	 * 
	 * @see BinaryPredicate
	 *)
	val LEQV = FIRST_BINARY_PREDICATE + 1;

	(**
	 * First tag for an associative binary expression.
	 * 
	 * @see AssociativeExpression
	 *)
	val FIRST_ASSOCIATIVE_EXPRESSION = 301;

	(**
	 * <code>BUNION</code> represents \u222a
	 * 
	 * @see AssociativeExpression
	 *)
	val BUNION = FIRST_ASSOCIATIVE_EXPRESSION + 0;

	(**
	 * <code>BINTER</code> represents \u2229
	 * 
	 * @see AssociativeExpression
	 *)
	val BINTER = FIRST_ASSOCIATIVE_EXPRESSION + 1;

	(**
	 * <code>BCOMP</code> represents \u2218
	 * 
	 * @see AssociativeExpression
	 *)
	val BCOMP = FIRST_ASSOCIATIVE_EXPRESSION + 2;

	(**
	 * <code>FCOMP</code> represents \u003b
	 * 
	 * @see AssociativeExpression
	 *)
	val FCOMP = FIRST_ASSOCIATIVE_EXPRESSION + 3;

	(**
	 * <code>OVR</code> represents \ue103
	 * 
	 * @see AssociativeExpression
	 *)
	val OVR = FIRST_ASSOCIATIVE_EXPRESSION + 4;

	(**
	 * <code>PLUS</code> represents +
	 * 
	 * @see AssociativeExpression
	 *)
	val PLUS = FIRST_ASSOCIATIVE_EXPRESSION + 5;

	(**
	 * <code>MUL</code> represents *
	 * 
	 * @see AssociativeExpression
	 *)
	val MUL = FIRST_ASSOCIATIVE_EXPRESSION + 6;

	(**
	 * First tag for an associative binary predicate.
	 * 
	 * @see AssociativePredicate
	 *)
	val FIRST_ASSOCIATIVE_PREDICATE = 351;

	(**
	 * <code>LAND</code> represents \u2227
	 * 
	 * @see AssociativePredicate
	 *)
	val LAND = FIRST_ASSOCIATIVE_PREDICATE + 0;

	(**
	 * <code>LOR</code> represents \u2228
	 * 
	 * @see AssociativePredicate
	 *)
	val LOR = FIRST_ASSOCIATIVE_PREDICATE + 1;

	(**
	 * First tag for an atomic expression.
	 * 
	 * @see AtomicExpression
	 *)
	val FIRST_ATOMIC_EXPRESSION = 401;

	(**
	 * <code>INTEGER</code> represents \u2124
	 * 
	 * @see AtomicExpression
	 *)
	val INTEGER = FIRST_ATOMIC_EXPRESSION + 0;

	(**
	 * <code>NATURAL</code> represents \u2115
	 * 
	 * @see AtomicExpression
	 *)
	val NATURAL = FIRST_ATOMIC_EXPRESSION + 1;

	(**
	 * <code>NATURAL1</code> represents \u21151
	 * 
	 * @see AtomicExpression
	 *)
	val NATURAL1 = FIRST_ATOMIC_EXPRESSION + 2;

	(**
	 * <code>BOOL</code> represents BOOL
	 * 
	 * @see AtomicExpression
	 *)
	val BOOL = FIRST_ATOMIC_EXPRESSION + 3;

	(**
	 * <code>TRUE</code> represents TRUE
	 * 
	 * @see AtomicExpression
	 *)
	val TRUE = FIRST_ATOMIC_EXPRESSION + 4;

	(**
	 * <code>FALSE</code> represents FALSE
	 * 
	 * @see AtomicExpression
	 *)
	val FALSE = FIRST_ATOMIC_EXPRESSION + 5;

	(**
	 * <code>EMPTYSET</code> represents \u2205
	 * 
	 * @see AtomicExpression
	 *)
	val EMPTYSET = FIRST_ATOMIC_EXPRESSION + 6;

	(**
	 * <code>KPRED</code> represents pred
	 * 
	 * @see AtomicExpression
	 *)
	val KPRED = FIRST_ATOMIC_EXPRESSION + 7;

	(**
	 * <code>KSUCC</code> represents succ
	 * 
	 * @see AtomicExpression
	 *)
	val KSUCC = FIRST_ATOMIC_EXPRESSION + 8;

	(**
	 * <code>KPRJ1_GEN</code> represents prj1
	 * 
	 * @see AtomicExpression
	 * @since 1.0
	 *)
	val KPRJ1_GEN = FIRST_ATOMIC_EXPRESSION + 9;

	(**
	 * <code>KPRJ2_GEN</code> represents prj2
	 * 
	 * @see AtomicExpression
	 * @since 1.0
	 *)
	val KPRJ2_GEN = FIRST_ATOMIC_EXPRESSION + 10;

	(**
	 * <code>KID_GEN</code> represents id
	 * 
	 * @see AtomicExpression
	 * @since 1.0
	 *)
	val KID_GEN = FIRST_ATOMIC_EXPRESSION + 11;

	(**
	 * <code>KBOOL</code> represents a <code>bool</code> expression.
	 * 
	 * @see BoolExpression
	 *)
	val KBOOL = 601;

	(**
	 * First tag for a literal predicate.
	 * 
	 * @see LiteralPredicate
	 *)
	val FIRST_LITERAL_PREDICATE = 610;

	(**
	 * <code>BTRUE</code> represents \u22a4
	 * 
	 * @see LiteralPredicate
	 *)
	val BTRUE = FIRST_LITERAL_PREDICATE + 0;

	(**
	 * <code>BFALSE</code> represents \u22a5
	 * 
	 * @see LiteralPredicate
	 *)
	val BFALSE = FIRST_LITERAL_PREDICATE + 1;

	(**
	 * First tag for a simple predicate.
	 * 
	 * @see SimplePredicate
	 *)
	val FIRST_SIMPLE_PREDICATE = 620;

	(**
	 * <code>KFINITE</code> represents a "finite" predicate.
	 * 
	 * @see SimplePredicate
	 *)
	val KFINITE = FIRST_SIMPLE_PREDICATE + 0;

	(**
	 * First tag for a unary predicate.
	 * 
	 * @see UnaryPredicate
	 *)
	val FIRST_UNARY_PREDICATE = 701;

	(**
	 * <code>NOT</code> represents \u00ac
	 * 
	 * @see UnaryPredicate
	 *)
	val NOT = FIRST_UNARY_PREDICATE + 0;

	(**
	 * First tag for a unary expression.
	 * 
	 * @see UnaryExpression
	 *)
	val FIRST_UNARY_EXPRESSION = 751;

	(**
	 * <code>KCARD</code> represents card
	 * 
	 * @see UnaryExpression
	 *)
	val KCARD = FIRST_UNARY_EXPRESSION + 0;

	(**
	 * <code>POW</code> represents \u2119
	 * 
	 * @see UnaryExpression
	 *)
	val POW = FIRST_UNARY_EXPRESSION + 1;

	(**
	 * <code>POW1</code> represents \u21191
	 * 
	 * @see UnaryExpression
	 *)
	val POW1 = FIRST_UNARY_EXPRESSION + 2;

	(**
	 * <code>KUNION</code> represents union
	 * 
	 * @see UnaryExpression
	 *)
	val KUNION = FIRST_UNARY_EXPRESSION + 3;

	(**
	 * <code>KINTER</code> represents inter
	 * 
	 * @see UnaryExpression
	 *)
	val KINTER = FIRST_UNARY_EXPRESSION + 4;

	(**
	 * <code>KDOM</code> represents dom
	 * 
	 * @see UnaryExpression
	 *)
	val KDOM = FIRST_UNARY_EXPRESSION + 5;

	(**
	 * <code>KRAN</code> represents ran
	 * 
	 * @see UnaryExpression
	 *)
	val KRAN = FIRST_UNARY_EXPRESSION + 6;

	(**
	 * <code>KPRJ1</code> represents prj1
	 * 
	 * @see UnaryExpression
	 * @see #KPRJ1_GEN
	 *  This operator has become generic in version 2 of the
	 *             mathematical language
	 *)
	
	val KPRJ1 = FIRST_UNARY_EXPRESSION + 7;

	(**
	 * <code>KPRJ2</code> represents prj2
	 * 
	 * @see UnaryExpression
	 * @see #KPRJ2_GEN
	 *  This operator has become generic in version 2 of the
	 *             mathematical language
	 *)
	
	val KPRJ2 = FIRST_UNARY_EXPRESSION + 8;

	(**
	 * <code>KID</code> represents id
	 * 
	 * @see UnaryExpression
	 * @see #KID_GEN
	 *  This operator has become generic in version 2 of the
	 *             mathematical language
	 *)
	
	val KID = FIRST_UNARY_EXPRESSION + 9;

	(**
	 * <code>KMIN</code> represents min
	 * 
	 * @see UnaryExpression
	 *)
	val KMIN = FIRST_UNARY_EXPRESSION + 10;

	(**
	 * <code>KMAX</code> represents max
	 * 
	 * @see UnaryExpression
	 *)
	val KMAX = FIRST_UNARY_EXPRESSION + 11;

	(**
	 * <code>CONVERSE</code> represents ~
	 * 
	 * @see UnaryExpression
	 *)
	val CONVERSE = FIRST_UNARY_EXPRESSION + 12;

	(**
	 * <code>UNMINUS</code> represents the unary minus -
	 * 
	 * @see UnaryExpression
	 *)
	val UNMINUS = FIRST_UNARY_EXPRESSION + 13;

	(**
	 * First tag for a quantified expression.
	 * 
	 * @see QuantifiedExpression
	 *)
	val FIRST_QUANTIFIED_EXPRESSION = 801;

	(**
	 * <code>QUNION</code> represents \u22c3
	 * 
	 * @see QuantifiedExpression
	 *)
	val QUNION = FIRST_QUANTIFIED_EXPRESSION + 0;

	(**
	 * <code>QINTER</code> represents \u22c2
	 * 
	 * @see QuantifiedExpression
	 *)
	val QINTER = FIRST_QUANTIFIED_EXPRESSION + 1;

	(**
	 * <code>CSET</code> represents a comprehension set (either { E | P } or {
	 * L \u00b7 P | E } or \u03bb M \u00b7 P | E)
	 * 
	 * @see QuantifiedExpression
	 *)
	val CSET = FIRST_QUANTIFIED_EXPRESSION + 2;

	(**
	 * First tag for a quantified predicate.
	 * 
	 * @see QuantifiedPredicate
	 *)
	val FIRST_QUANTIFIED_PREDICATE = 851;

	(**
	 * <code>FORALL</code> represents \u2200
	 * 
	 * @see QuantifiedPredicate
	 *)
	val FORALL = FIRST_QUANTIFIED_PREDICATE + 0;

	(**
	 * <code>EXISTS</code> represents \u2203
	 * 
	 * @see QuantifiedPredicate
	 *)
	val EXISTS = FIRST_QUANTIFIED_PREDICATE + 1;
	
	(**
	 * First tag for a multiple predicate.
	 * 
	 * @see MultiplePredicate
	 * @since 1.0
	 *)
	val FIRST_MULTIPLE_PREDICATE = 901;

	(**
	 * <code>KPARTITION</code> represents a "partition" predicate.
	 * 
	 * @see MultiplePredicate
	 * @since 1.0
	 *)
	val KPARTITION = FIRST_MULTIPLE_PREDICATE + 0;

	(**
	 * First tag for extended formulae.
	 * 
	 * @see ExtendedPredicate
	 * @see ExtendedExpression
	 * @since 2.0
	 *)
	val FIRST_EXTENSION_TAG = 1000;

end
