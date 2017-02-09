package tinker.core.util;

public class Immutable {

    private final Object immuObj;

    public Immutable() {
        immuObj = new Object();
    }

    @Override
    public final int hashCode() {
        int hash = 7;
        hash = 29 * hash + this.immuObj.hashCode();
        return hash;
    }

    @Override
    public final boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Immutable other = (Immutable) obj;
        return obj.hashCode() == this.hashCode();
    }

}