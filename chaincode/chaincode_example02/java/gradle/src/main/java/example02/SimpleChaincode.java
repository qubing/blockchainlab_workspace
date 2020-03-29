/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package example02;

import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;

import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Transaction;

// import java.lang.Integer;

@Contract(
    name = "Example02"
)

@Default
public final class SimpleChaincode implements ContractInterface {
    enum Message {
        AccountNotExsiting("Account '%s' does not exist."),
        NoEnoughBalance("There is no enough balance to transfer in account '%s'."),
        BalanceNotValid("Account balance is not valid. ('%s': %s)");
    
        private String tmpl;
    
        private Message(String tmpl) {
            this.tmpl = tmpl;
        }
    
        public String toString() {
            return this.tmpl;
        }
    }

    @Transaction()
    public void init(final Context ctx, final String keyA, final String valueA, final String keyB, final String valueB) {
        ChaincodeStub stub = ctx.getStub();

        try {
            Integer.valueOf(valueA);
        } catch(Exception e) {
            String errorMessage = String.format(Message.BalanceNotValid.toString(), keyA, valueA);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, e);
        }

        try {
            Integer.valueOf(valueB);
        } catch(Exception e) {
            String errorMessage = String.format(Message.BalanceNotValid.toString(), keyB, valueB);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, e);
        }

        // init account A
        stub.putStringState(keyA, valueA);
        // init account B
        stub.putStringState(keyB, valueB);
    }
    
    @Transaction()
    public String query(final Context ctx, final String key) {
        ChaincodeStub stub = ctx.getStub();
        String valueA = stub.getStringState(key);

        // account not existing
        if (valueA.isEmpty()) {
            String errorMessage = String.format(Message.AccountNotExsiting.toString(), key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage);
        }

        return valueA;
    }

    @Transaction()
    public void transfer(final Context ctx, final String keyA, final String keyB, final String valueTrans) {
        ChaincodeStub stub = ctx.getStub();
        String valueA = stub.getStringState(keyA);
        String valueB = stub.getStringState(keyB);
        int intValueA = Integer.valueOf(valueA).intValue();
        int intValueB = Integer.valueOf(valueB).intValue();
        int intValueTrans = Integer.valueOf(valueTrans).intValue();
        if (intValueA < intValueTrans) {
            String errorMessage = String.format(Message.NoEnoughBalance.toString(), keyA);
            throw new ChaincodeException(errorMessage);
        }
        intValueA = intValueA - intValueTrans;
        stub.putStringState(keyA, String.valueOf(intValueA));
        intValueB =  intValueB + intValueTrans;
        stub.putStringState(keyB, String.valueOf(intValueB));
    }
}