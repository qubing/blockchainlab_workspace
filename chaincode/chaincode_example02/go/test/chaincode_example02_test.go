package main

import (
	"testing"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-chaincode-go/shimtest"
	"github.com/hyperledger/fabric/common/util"
)

func Test_Init(t *testing.T) {
	mycc := new(SimpleChaincode)
	stub := shimtest.NewMockStub("example02", mycc)
	response := stub.MockInit("init", util.ToChaincodeArgs("a"))
	if response.Status != shim.ERROR {
		t.Fail()
	}
	args := []string{"init", "a", "100", "b", "100"}

	response = stub.MockInit("init", util.ToChaincodeArgs(args...))
	if response.Status != shim.OK {
		t.Fail()
	}
}

func Test_Invoke_query_a(t *testing.T) {
	mycc := new(SimpleChaincode)
	stub := shimtest.NewMockStub("example02", mycc)

	stub.MockInit("init", util.ToChaincodeArgs("init", "a", "100", "b", "100"))
	valBytes, err := stub.GetState("a")
	if err != nil {
		t.Errorf(`query failed with error "%s"`, err.Error())
	}

	if string(valBytes) != "100" {
		t.Errorf(`query failed with unexpected result. expected: "100", actual: "%s"`, string(valBytes))
	}

	response := stub.MockInvoke("invoke", util.ToChaincodeArgs("transfer", "a", "b", "10"))
	if response.Status != shim.OK {
		t.Errorf(`invoke failed with error: "%s".`, response.Message)
	}

	valBytes, err = stub.GetState("a")
	if err != nil {
		t.Errorf(`query failed with error "%s"`, err.Error())
	}
	if string(valBytes) != "90" {
		t.Errorf(`query failed with unexpected result. expected: "90", actual: "%s"`, string(valBytes))
	}
}
