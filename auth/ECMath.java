
import java.math.BigInteger;
import java.security.*;
import java.security.spec.*;

public class ECMath {
    /**
     * The following methods are adapted from
     * <https://www.codota.com/web/assistant/code/rs/5c76b44751856b00011a0653#L67>
     */
    public static ECPoint scalarMultiply(ECPoint p, BigInteger kin, EllipticCurve curve) {
        ECPoint r = ECPoint.POINT_INFINITY;
        BigInteger prime = ((ECFieldFp) curve.getField()).getP();
        BigInteger k = kin.mod(prime);
        int length = k.bitLength();
        byte[] binarray = new byte[length];
        for (int i = 0; i <= length-1; i++) {
            binarray[i] = k.mod(BigInteger.TWO).byteValue();
            k = k.divide(BigInteger.TWO);
        }

        for (int i = length-1; i >= 0; i--) {
            // i should start at length-1 not -2 because the MSB of binarry may not be 1
            r = doublePoint(r, curve);
            if (binarray[i] == 1)
                r = addPoint(r, p, curve);
        }
        return r;
    }

        private static ECPoint addPoint(ECPoint r, ECPoint s, EllipticCurve curve) {
            if (r.equals(s))
                return doublePoint(r, curve);
            else if (r.equals(ECPoint.POINT_INFINITY))
                return s;
            else if (s.equals(ECPoint.POINT_INFINITY))
                return r;
            BigInteger prime = ((ECFieldFp) curve.getField()).getP();
            // use NBI modInverse();
            BigInteger tmp = r.getAffineX().subtract(s.getAffineX());
            BigInteger slope = (r.getAffineY().subtract(s.getAffineY())).multiply(tmp.modInverse(prime)).mod(prime);
            BigInteger xOut = (slope.modPow(BigInteger.TWO, prime).subtract(r.getAffineX())).subtract(s.getAffineX()).mod(prime);
            BigInteger yOut = s.getAffineY().negate().mod(prime);
            yOut = yOut.add(slope.multiply(s.getAffineX().subtract(xOut))).mod(prime);
            ECPoint out = new ECPoint(xOut, yOut);
            return out;
        }

        private static ECPoint doublePoint(ECPoint r, EllipticCurve curve) {
            if (r.equals(ECPoint.POINT_INFINITY))
                return r;
            BigInteger slope = (r.getAffineX().pow(2)).multiply(BigInteger.valueOf(3));
            slope = slope.add(curve.getA());
            BigInteger prime = ((ECFieldFp) curve.getField()).getP();
            // use NBI modInverse();
            BigInteger tmp = r.getAffineY().multiply(BigInteger.TWO);
            slope = slope.multiply(tmp.modInverse(prime));
            BigInteger xOut = slope.pow(2).subtract(r.getAffineX().multiply(BigInteger.TWO)).mod(prime);
            BigInteger yOut = (r.getAffineY().negate()).add(slope.multiply(r.getAffineX().subtract(xOut))).mod(prime);
            ECPoint out = new ECPoint(xOut, yOut);
            return out;
        }
}
