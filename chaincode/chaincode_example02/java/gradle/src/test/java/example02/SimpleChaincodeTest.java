package example02;

import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.ThrowableAssert.catchThrowable;

import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.mockito.InOrder;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

public class SimpleChaincodeTest {
    @Nested
    class InvokeInitTransaction {
        @Test
        public void initLedger() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);

            contract.init(ctx, "A", "100", "B", "200");

            InOrder inOrder = inOrder(stub);
            inOrder.verify(stub).putStringState("A", "100");
            inOrder.verify(stub).putStringState("B", "200");
        }

        @Test
        public void whenBalanceANotValid() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);

            Throwable thrown = catchThrowable(() -> {
                contract.init(ctx, "A", "100A", "B", "200");
            });
            
            assertThat(thrown).isNotNull();
        }
    }

    @Nested
    class InvokeTransferTransaction {
        @Test
        public void whenBalanceEnough() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);

            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("A")).thenReturn("100");
            when(stub.getStringState("B")).thenReturn("100");

            Throwable thrown = catchThrowable(() -> {
                contract.transfer(ctx, "A", "B", "15");
            });

            assertThat(thrown).isNull();
        }

        @Test
        public void whenBalanceNotEnough() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);

            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("A")).thenReturn("100");
            when(stub.getStringState("B")).thenReturn("100");

            Throwable thrown = catchThrowable(() -> {
                contract.transfer(ctx, "A", "B", "150");
            });

            assertThat(thrown)
                .isInstanceOf(ChaincodeException.class)
                .hasNoCause()
                .hasMessage(String.format(SimpleChaincode.Message.NoEnoughBalance.toString(), "A"));
        }
    }

    @Nested
    class InvokeQueryTransaction {

        @Test
        public void whenAccountNotExists() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("A")).thenReturn("");

            Throwable thrown = catchThrowable(() -> {
                contract.query(ctx, "A");
            });

            assertThat(thrown)
                .isInstanceOf(ChaincodeException.class)
                .hasNoCause()
                .hasMessage(String.format(SimpleChaincode.Message.AccountNotExsiting.toString(), "A"));
        }

        @Test
        public void whenAccountExists() {
            SimpleChaincode contract = new SimpleChaincode();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("A")).thenReturn("100");
            assertThat(contract.query(ctx, "A")).isEqualTo("100");
        }
    }
}
