package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/common/util"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/core/chaincode/shim/ext/cid"
	"github.com/hyperledger/fabric/protos/peer"
)

// MyChaincode smart cotract
type MyChaincode struct {
}

// Init initialize smart contact
func (t *MyChaincode) Init(stub shim.ChaincodeStubInterface) peer.Response {
	stub.PutState("A", []byte("100"))
	stub.PutState("B", []byte("100"))

	stub.PutState("1000", []byte("a00"))
	stub.PutState("1001", []byte("a01"))
	stub.PutState("1002", []byte("a02"))
	stub.PutState("1010", []byte("a10"))
	stub.PutState("1011", []byte("a11"))
	stub.PutState("1100", []byte("b00"))
	stub.PutState("1101", []byte("b01"))
	stub.PutState("1102", []byte("b02"))
	stub.PutState("1110", []byte("b10"))
	stub.PutState("1111", []byte("b11"))
	return shim.Success(nil)
}

// Invoke smart cotract with functionName and args
func (t *MyChaincode) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	funcName, args := stub.GetFunctionAndParameters()
	if funcName == "charge" {
		if len(args) != 2 {
			return shim.Error("argument count is not correct.")
		}
		charge(stub, args)

	} else {
		return shim.Error("function name is not valid.")
	}
	return shim.Success(nil)
}

func charge(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	key := args[0]
	charge := args[1]
	valBytesBefore, _ := stub.GetState(key)
	valBefore, _ := strconv.Atoi(string(valBytesBefore))
	valCharge, _ := strconv.Atoi(charge)
	valNew := valBefore + valCharge
	if valNew < 0 {
		return shim.Error("charge failed.")
	}

	err := stub.PutState(key, []byte(strconv.Itoa(valNew)))

	if err != nil {
		return shim.Error("charge failed." + err.Error())
	}

	return shim.Success(nil)
}

func query01(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	key := args[0]
	valBytes, _ := stub.GetState(key)
	return shim.Success(valBytes)
}

func query02(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	begin := args[0]
	end := args[1]
	resultIt, _ := stub.GetStateByRange(begin, end)
	defer resultIt.Close()
	records := []string{}
	for resultIt.HasNext() {
		kv, _ := resultIt.Next()
		records = append(records, string(kv.GetValue()))
	}
	return shim.Success(writeRecordList(records))
}

// RecordList page data list
type RecordList struct {
	Records []string `json:"records"`
}

func writeRecordList(records []string) []byte {
	recordList := new(RecordList)
	buffer := new(bytes.Buffer)
	recordListData, _ := json.Marshal(recordList)
	buffer.WriteString(string(recordListData))
	return buffer.Bytes()
}

// PageRecordList page data list
type PageRecordList struct {
	MetaData PageMetadata `json:"metadata"`
	Records  []string     `json:"records"`
}

// PageMetadata metadata
type PageMetadata struct {
	FetchedCount int32  `json:"fetched_count"`
	BookMark     string `json:"book_mark"`
}

func writePageRecordList(metadata peer.QueryResponseMetadata, records []string) []byte {
	pageRecordList := new(PageRecordList)
	buffer := new(bytes.Buffer)
	pageRecordListData, _ := json.Marshal(pageRecordList)
	buffer.WriteString(string(pageRecordListData))
	return buffer.Bytes()
}

func query03(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	begin := args[0]
	end := args[1]
	pageSize := int32(2)
	bookMark := ""

	resultIt, metadata, _ := stub.GetStateByRangeWithPagination(begin, end, pageSize, bookMark)
	defer resultIt.Close()
	records := []string{}
	for resultIt.HasNext() {
		kv, _ := resultIt.Next()
		records = append(records, string(kv.GetValue()))
	}
	return shim.Success(writePageRecordList(*metadata, records))
}

// func query04(stub shim.ChaincodeStubInterface, args []string) peer.Response {
// 	//key := stub.CreateCompositeKey("region-sex", []string {"CN", "MALE"})
// 	//stub.PutState(key, []byte(""))
// 	resultIt, _ := stub.GetStateByPartialCompositeKey("region-sex", []string{"CN", "MALE"})
// 	defer resultIt.Close()
// 	for resultIt.HasNext() {
// 		kv, _ := resultIt.Next()
// 		_, keyParts, _ := stub.SplitCompositeKey(kv.GetKey())
// 		region := keyParts[0]
// 		sex := keyParts[1]
// 		...
// 	}
// }

func query05(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	selector := fmt.Sprintf(`{"selector": {"age": {"gt": %d}}}`, 18)
	resultIt, _ := stub.GetQueryResult(selector)
	defer resultIt.Close()
	records := []string{}
	for resultIt.HasNext() {
		kv, _ := resultIt.Next()
		records = append(records, string(kv.GetValue()))
	}

	return shim.Success(writeRecordList(records))
}

func testACL(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	err := cid.AssertAttributeValue(stub, "role", "admin")
	if err != nil {
		return shim.Error("no permission.")
	}

	return shim.Success(nil)
}

func testInvokeCC(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	// import "github.com/hyperledger/fabric/common/util"

	return stub.InvokeChaincode("mycc", util.ArrayToChaincodeArgs(args), stub.GetChannelID())
}

func testSetEvent(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	err := stub.SetEvent("topic_name_xxx", []byte("hello world."))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func main() {
	err := shim.Start(new(MyChaincode))
	if err != nil {
		fmt.Printf("Error to start smart contact : %s", err.Error())
	}
}
