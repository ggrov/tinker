import org.apache.commons.lang3.StringEscapeUtils;


public class test {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String a=StringEscapeUtils.escapeJava("a ∧ b ∧ c ⇒ c ∧ b ∧ a");
		System.out.println(a);
		System.out.println(StringEscapeUtils.escapeJava(a));
	}

}
