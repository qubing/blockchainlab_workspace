# [SCUT区块链上机实践] - 智能合约开发

### 开始之前
> 请确保已经完成了Lab0的所有安装操作，并对Fabric框架有了基本认识。

## 1. 智能合约的Go语言支持
### 1.1. Go语言基础
(省略)

### 1.2. 常用Go依赖包
#### 屏幕输出
```
import(
    "fmt"
)

func doPrint() {
    fmt.Print("hello")
    fmt.Printf("hello %s !", "go-lang")
}
```
#### 字符串拼接
```
import (
    "bytes"
    "fmt"
)

func doStringConcat() {
    var buffer bytes.Buffer
    buffer.WriteString("[")
    buffer.WriteString("a,")
    buffer.WriteString("b,")
    buffer.WriteString("c")
    buffer.WriteString("]")
    fmt.Printf("result: %s", buffer.String())
}
```
#### 数字<->字符
```
import (
    "strconv"
    "fmt"
)

func doStrConv() {
    //String -> Number
    num, err := strconv.Atoi([]byte("123456")
    if err != nil {
        fmt.Printf("convert failed. %s", err.Error())
        return
    }
    fmt.Printf("conver result: %d", num)
    
    //Number -> String
    str := strconv.Itoa(654321)
    fmt.Printf("conver result: %s", str)
}
```
#### 结构体<->JSON
```
import (
    "encoding/json"
    "fmt"
)
type Car struct {
    Id string `json: "id"`
    Color string `json: "color"`
    Owner OwnerRelation `json: "owner"`
}

func parseJSON() {
    str := `{"id": "00000001", "color": "red"}`
    carAsBytes := []byte(str)
	car := Car{}
    err := json.Unmarshal(carAsBytes, &car)
    if (err != nil) {
        fmt.Printf("JSON parse failed. %s", err.Error())
        return
    }
    fmt.Printf("car->(id: %s, color: %s)", car.Id, car.Color)
}

func toJSON() {
    var car Car
    car.Id = "00000001"
    car.Color = "red"
    bytes, err := json.Marshal(car)
    if (err != nil) {
        fmt.Printf("JSON convert failed. %s", err.Error())
        return
    }
    fmt.Printf("JSON result: %s", string(bytes))
}
```

### 1.3. 用Go语言编写Fabric智能合约(Chaincode)
#### 1.3.1. Chaincode程序结构介绍
##### Fabric依赖包
除了程序用到的Go语言基本依赖包以外，用于Chaincode开发的常用依赖包，主要有2个，如下：

```
import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)
```
##### 定义Chaincode结构体
> 作为Chaincode的运行对象。

```
//SimpleChaincode chaincode object
type SimpleChaincode struct {
}
```
##### 定义Go语言主程序入口
> 创建并启动Chaincode运行对象。

```
//Application Main Entry
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
```
##### 初始化方法(Init)
> Chaincode部署(initiate)或升级(upgrade)时被一次性触发。

```
//Chaincode Initialization
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	//TODO: to be implemented.

	return shim.Success(nil)
}
```

##### 调用方法(Invoke)
> Chaincode被调用(Invoke)时触发，根据对账本的操作类型，可分为读操作和写操作。只包含读操作处理时，该调用为同步调用（可以定义返回值）；包含写操作处理时，该调用为异步调用(不可以定义返回值)，返回值仅仅代表通讯完成。

```
//Invoke Function
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
    function, args := stub.GetFunctionAndParameters()
	if function == "ReadXXX" {
		//TODO: to be implemented.
		return shim.Succsss(XXXX)
	} else if function == "WriteXXX" {
		//TODO: to be implemented.
		return shim.Succsss(XXXX)
	}
	
	
	return shim.Error("ERROR MESSAGE: XXXX.")
}
```
> Invoke方法是所有的调用操作的程序入口，可以通过定义不同的FunctionName来进行区分。

> 只读功能的返回值，可以通过`shim.Succsss(XXXX)`传递给调用端。

> 系统错误可以通过`shim.Error("ERROR MESSAGE: XXXX.")`传递给调用端。


#### 1.3.2. Chaincode的程序开发
Fabric提供了大量的Chaincode API，以满足对账本数据的访问。

##### A. <环境相关API>

###### GetTxID
> - 获取当前的事务ID（仅限于invoke调用）

```
func (t *MyChaincode) doGetTxID(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetTxID("%s") \n<Begin>\n`, key)
	txId := stub.GetTxID()

	fmt.Println("<End>")
	return shim.Success([]byte(txId))
}
```

###### GetTxTimestamp
> - 获取当前事务的时间戳（仅限于invoke调用）

```
func (t *MyChaincode) doGetTxTimestamp(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetTxTimestamp("%s") \n<Begin>\n`, key)
	txTimestamp, err := stub.GetTxTimestamp()

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success([]byte(txTimestamp.String()))
}
```

###### GetCreator
> - 获取当前事务的调用者E-Cert（仅限于invoke调用）

```
func (t *MyChaincode) doGetCreator(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetCreator("%s") \n<Begin>\n`, key)
	byts, err := stub.GetCreator()

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(byts)
}
```

###### GetChannelID
> - 获取当前智能合约所在Channel的ID

```
func (t *MyChaincode) doGetChannelID(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetChannelID("%s") \n<Begin>\n`, key)
	channelID := stub.GetChannelID()

	fmt.Println("<End>")
	return shim.Success([]byte(channelID))
}
```

###### GetFunctionAndParameters
> - 获取被调用的FunctionID和相关参数数组 (通常用于在invoke方法中分发调用请求)

```
func (t *MyChaincode) doGetFunctionAndParameters(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Printf(`GetFunctionAndParameters() \n<Begin>\n`)
	functionName,args := stub.GetFunctionAndParameters()
	msg := fmt.Sprintf(`{"function_name": "%s", "args": ["s%", "%s"]}`, functionName, args[0], args[1])
	fmt.Println("<End>")
	return shim.Success([]byte(msg))
}
```

###### CID.GetID
> - 获取当前用户的ID（证书公钥）

```
import (
    "github.com/hyperledger/fabric/core/chaincode/lib/cid"
)

func (t *MyChaincode) doGetCIDID(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`CID.GetID() \n<Begin>`)

	mspID, err := cid.GetID(stub)
	if err != nil {
		fmt.Printf(`CID.GetID() failed. Error: '%s'`, err.Error())
		return shim.Error(err.Error())
	}

	fmt.Printf(`CID.GetID() successfully. ID: '%s'`, mspID)
	return shim.Success(nil)
}

```

###### CID.GetMSPID
> - 获取当前用户的所属组织ID

```
import (
    "github.com/hyperledger/fabric/core/chaincode/lib/cid"
)

func (t *MyChaincode) doGetMSPID(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`CID.GetMSPID() \n<Begin>`)

	mspID, err := cid.GetMSPID(stub)
	if err != nil {
		fmt.Printf(`CID.GetMSPID() failed. Error: '%s'`, err.Error())
		return shim.Error(err.Error())
	}

	fmt.Printf(`CID.GetMSPID() successfully. MSPID: '%s'`, mspID)
	return shim.Success(nil)
}
```

###### CID.GetAttributeValue
> - 获取当前用户的指定属性 (在用户登录时必需明确指定)

```
import (
    "github.com/hyperledger/fabric/core/chaincode/lib/cid"
)

func (t *MyChaincode) doGetAttributeValue(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`CID.GetAttributeValue() \n<Begin>`)
	attrName := "admin"
	attrVal, ok, err := cid.GetAttributeValue(stub, attrName)
	if err != nil {
		fmt.Printf(`CID.GetAttributeValue('%s') failed. Error: '%s'`, attrName, err.Error())
		return shim.Error(err.Error())
	} else if !ok {
		fmt.Printf(`CID.GetAttributeValue('%s') failed. Not found.`, attrName)
		return shim.Success(nil)
	}

	fmt.Printf(`CID.GetAttributeValue('%s') successfully. Val: '%s'`, attrName, attrVal)
	return shim.Success(nil)
}
```

###### CID.AssertAttributeValue
> - 验证当前访问用户是否具备指定属性值

```
import (
    "github.com/hyperledger/fabric/core/chaincode/lib/cid"
)

func (t *MyChaincode) doAssertAttributeValue(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`CID.AssertAttributeValue() \n<Begin>`)
	attrName := "email"
	attrVal := "user1@org1"
	err := cid.AssertAttributeValue(stub, attrName, attrVal)
	if err != nil {
		fmt.Printf(`CID.AssertAttributeValue('%s', '%s') failed. Error: '%s'`, attrName, attrVal, err.Error())
		return shim.Error(err.Error())
	}
	fmt.Printf(`CID.AssertAttributeValue('%s', '%s') successfully.`, attrName, attrVal)
	return shim.Success(nil)
}
```

> 如果需要连续的CID操作的情况，可参考下面方法。

```
// Get the client ID object
id, err := cid.New(stub)
if err != nil {
   // Handle error
}
mspid, err := id.GetMSPID()
if err != nil {
   // Handle error
}
switch mspid {
   case "org1MSP":
      err = id.AssertAttributeValue("attr1", "true")
   case "org2MSP":
      err = id.AssertAttributeValue("attr2", "true")
   default:
      err = errors.New("Wrong MSP")
}
```

##### B. <账本读写相关API - 普通KV>

###### GetState
> 读取账本中的键值对(根据键值进行唯一性读取)

```
func (t *MyChaincode) doGetState(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetState("%s") \n<Begin>\n`, key)
	byts, err := stub.GetState(key)

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(byts)
}
```
###### PutState
> 写入账本中的键值对(支持创建和修改)

```
func (t *MyChaincode) doPutState(stub shim.ChaincodeStubInterface, key string, val string) pb.Response {
	fmt.Printf(`PutState("%s", "%s") \n<Begin>\n`, key, val)
	err := stub.PutState(key, []byte(val))

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(nil)
}
```
###### DelState
> 删除账本中的键值对

```
func (t *MyChaincode) doDelState(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`DelState("%s") \n<Begin>\n`, key)
	err := stub.DelState(key)

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(nil)
}
```

###### GetStateByRange
> 读取账本中的键值对(根据键值范围进行批量查询)

```
func (t *MyChaincode) doGetStateByRange(stub shim.ChaincodeStubInterface, key0, key1 string) pb.Response {
	fmt.Printf(`GetStateByRange("%s","%s") \n<Begin>\n`, key0, key1)
	resultIt, err := stub.GetStateByRange(key0, key1)

	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")
	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			fmt.Printf(`[Error] Iterator mistake. Ignored.(%s)`, err.Error())
			continue
		}
		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(response.Value))
	}
	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```
> 注意: 设计键值规则时，要考虑到不等长键值可能会带来的隐患。

###### GetStateByRangeWithPagination
> 读取账本中的键值对(根据键值范围进行批量查询|分页支持)

```
func (t *MyChaincode) doGetStateByRangeWithPagination(stub shim.ChaincodeStubInterface, key0, key1 string, pageSize int32, bookmark string) pb.Response {
	fmt.Printf(`GetStateByRangeWithPagination("%s","%s","%d","%s") \n<Begin>\n`, key0, key1, pageSize, bookmark)
	resultIt, metadata, err := stub.GetStateByRangeWithPagination(key0, key1, pageSize, bookmark)

	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString(fmt.Sprintf(`{"page_title": {"count": %d, "bookmark": "%s"},\n`, metadata.FetchedRecordsCount, metadata.Bookmark))
	buff.WriteString(`"page_data":[`)
	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			fmt.Printf(`[Error] Iterator mistake. Ignored.(%s)`, err.Error())
			continue
		}
		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(response.Value))
	}
	buff.WriteString("]}")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### CreateCompositeKey
> 创建账本中的键值对的***联合查询索引***，用于指定范围的键值对查询(根据键值范围进行批量查询)

```
func (t *MyChaincode) doCreateCompositeKey(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Printf(`CreateCompositeKey("%s","%s", "%s") \n<Begin>\n`, args[0], args[1], args[2])
	indexName := "sex~name"
	jsonString := fmt.Sprintf(`{"name": "%s", "sex":"%s", "age": %s}`, args[0], args[1], args[2])
	err := stub.PutState(args[0], []byte(jsonString))
	if err != nil {
		return shim.Error(err.Error())
	}

	sexNameIndexKey, err := stub.CreateCompositeKey(indexName, []string{args[1], args[0]})
	if err != nil {
		return shim.Error(err.Error())
	}
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(sexNameIndexKey, []byte{0x00})
	if err != nil {
		return shim.Error("Failed to add state:" + err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(nil)
}
```

###### GetStateByPartialCompositeKey
> 查询账本中的键值对(根据***联合查询索引***进行批量查询)

```
func (t *MyChaincode) doGetStateByPartialCompositeKey(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Printf(`GetStateByPartialCompositeKey("%s") \n<Begin>\n`, args[0])
	indexName := "sex~name"
	resultIt, err := stub.GetStateByPartialCompositeKey(indexName, []string{args[0]})
	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")
	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		_, compositeKeyParts, err := stub.SplitCompositeKey(response.Key)
		if err != nil {
			return shim.Error(err.Error())
		}
		returnedName := compositeKeyParts[1]
		byts, err := stub.GetState(returnedName)
		if err == nil {
			if buff.Len() > 1 {
				buff.WriteString(",")
			}
			buff.WriteString(string(byts))
		}
	}
	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### GetStateByPartialCompositeKeyWithPagination
> 查询账本中的键值对(根据***联合查询索引***进行批量查询|分页支持)

```
func (t *MyChaincode) doGetStateByPartialCompositeKeyWithPagination(stub shim.ChaincodeStubInterface, args []string, pageSize int32, bookmark string) pb.Response {
	fmt.Printf(`GetStateByPartialCompositeKey("%s") \n<Begin>\n`, args[0])
	indexName := "sex~name"
	resultIt, metadata, err := stub.GetStateByPartialCompositeKeyWithPagination(indexName, []string{args[0]}, pageSize, bookmark)
	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString(fmt.Sprintf(`{"page_title": {"count": %d, "bookmark": "%s"},\n`, metadata.FetchedRecordsCount, metadata.Bookmark))
	buff.WriteString(`"page_data":[`)

	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		_, compositeKeyParts, err := stub.SplitCompositeKey(response.Key)
		if err != nil {
			return shim.Error(err.Error())
		}
		returnedName := compositeKeyParts[1]
		byts, err := stub.GetState(returnedName)
		if err == nil {
			if buff.Len() > 1 {
				buff.WriteString(",")
			}
			buff.WriteString(string(byts))
		}
	}
	buff.WriteString("]}")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### SplitCompositeKey
> 解析针对联合查询索引，进行拆分(完整的使用方法，参见上面的例子)

```
...
_, compositeKeyParts, err := stub.SplitCompositeKey(response.Key)
if err != nil {
	return shim.Error(err.Error())
}
returnedName := compositeKeyParts[1]
byts, err := stub.GetState(returnedName)
...
```

###### GetHistoryForKey
> 查询指定键值对更新历史(包括已删除数据，可用于历史追溯)

```
func (t *MyChaincode) doGetHistoryForKey(stub shim.ChaincodeStubInterface, key string) pb.Response {
	fmt.Printf(`GetHistoryForKey("%s") \n<Begin>\n`, key)
	historyIt, err := stub.GetHistoryForKey(key)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer historyIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")

	for historyIt.HasNext() {
		historyResult, err := historyIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(fmt.Sprintf(
			`{"tx_id": "%s", 
				"time": "%v", 
				"value": "%s", 
				"del_flg": "%v"
			}`, historyResult.TxId, historyResult.Timestamp, historyResult.Value, historyResult.IsDelete))
	}

	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### GetQueryResult
> 查询账本中的键值对(使用非结构化查询进行批量查询)

```
func (t *MyChaincode) doGetQueryResult(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Printf(`GetQueryResult("%s") \n<Begin>\n`, args[0])
	age, _ := strconv.Atoi(args[0])
	queryString := fmt.Sprintf(`{"selector":{"age":{ "$gte": %d }}}`, age)
	queryIt, err := stub.GetQueryResult(queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer queryIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")

	for queryIt.HasNext() {
		queryResult, err := queryIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(queryResult.GetValue()))
	}

	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```
> 该方法仅限于LedageDB使用CouchDB时使用。
> 非结构化查询语法: https://docs.mongodb.com/manual/reference/operator/query

###### GetQueryResultWithPagination
> 查询账本中的键值对(使用非结构化查询进行批量查询|分页支持)

```
func (t *MyChaincode) doGetQueryResultWithPagination(stub shim.ChaincodeStubInterface, args []string, pageSize int32, bookmark string) pb.Response {
	fmt.Printf(`GetQueryResult("%s") \n<Begin>\n`, args[0])
	age, _ := strconv.Atoi(args[0])
	queryString := fmt.Sprintf(`{"selector":{"age":{ "$gte": %d }}}`, age)
	queryIt, metadata, err := stub.GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer queryIt.Close()

	var buff bytes.Buffer
	buff.WriteString(fmt.Sprintf(`{"page_title": {"count": %d, "bookmark": "%s"},\n`, metadata.FetchedRecordsCount, metadata.Bookmark))
	buff.WriteString(`"page_data":[`)

	for queryIt.HasNext() {
		queryResult, err := queryIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(queryResult.GetValue()))
	}

	buff.WriteString("]}")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### SetStateValidationParameter
> 在智能合约中实设置指定键值对的背书策略，该背书策略将覆盖智能合约部署时指定的背书策略

```
func (t *MyChaincode) doSetStateValidationParameter(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`SetStateValidationParameter() \n<Begin>`)
	key := "my_key"
	ep := `OR(Org1.member, Org2.member)`
	err := stub.SetStateValidationParameter(key, []byte(ep))
	fmt.Println("<End>")
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}
```

###### GetStateValidationParameter
> 读取指定键值对的背书策略读取指定数据集的私有键值对的背书策略, 仅返回通过`SetStateValidationParameter`设置的背书策略

```
func (t *MyChaincode) doGetStateValidationParameter(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`GetStateValidationParameter() \n<Begin>`)
	key := "my_key"
	peBytes, err := stub.GetStateValidationParameter(key)
	fmt.Println("<End>")
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(peBytes)
}
```

##### C. <账本读写相关API - 私有KV>

###### GetPrivateData
> 读取账本中指定集合中的私有键值对(根据键值进行唯一性读取)

```
func (t *MyChaincode) doGetPrivateData(stub shim.ChaincodeStubInterface, collection, key string) pb.Response {
	fmt.Printf(`GetGetPrivateData("%s", "%s") \n<Begin>\n`, collection, key)
	byts, err := stub.GetPrivateData(collection, key)

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(byts)
}
```

###### PutPrivateData
> 写入账本中指定集合中的私有键值对(支持创建和修改)

```
func (t *MyChaincode) doPutPrivateData(stub shim.ChaincodeStubInterface, collection, key, val string) pb.Response {
	fmt.Printf(`PutPrivateData("%s", "%s", "%s") \n<Begin>\n`, collection, key, val)
	err := stub.PutPrivateData(collection, key, []byte(val))

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(nil)
}
```

###### DelPrivateData
> 删除账本中指定集合中的私有键值对

```
func (t *MyChaincode) doDelPrivateData(stub shim.ChaincodeStubInterface, collection, key string) pb.Response {
	fmt.Printf(`DelPrivateData("%s", "%s") \n<Begin>\n`, collection, key)
	err := stub.DelPrivateData(collection, key)

	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("<End>")
	return shim.Success(nil)
}
```

###### GetPrivateDataByRange
> 读取账本中的私有键值对(根据键值范围进行批量查询, 使用方法同`GetStateByRange()`)

```
func (t *MyChaincode) doGetPrivateDataByRange(stub shim.ChaincodeStubInterface, collection, key0, key1 string) pb.Response {
	fmt.Printf(`GetPrivateDataByRange("%s","%s","%s") \n<Begin>\n`, collection, key0, key1)
	resultIt, err := stub.GetPrivateDataByRange(collection, key0, key1)

	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")
	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			fmt.Printf(`[Error] Iterator mistake. Ignored.(%s)`, err.Error())
			continue
		}
		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(response.Value))
	}
	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### GetPrivateDataByPartialCompositeKey
> 查询账本中的私有键值对(根据***联合查询索引***进行批量查询，使用方法同`GetStateByPartialCompositeKey`)

```
func (t *MyChaincode) doGetPrivateDataByPartialCompositeKey(stub shim.ChaincodeStubInterface, collection string , args []string) pb.Response {
	fmt.Printf(`GetPrivateDataByPartialCompositeKey("%s") \n<Begin>\n`, args[0])
	indexName := "sex~name"
	resultIt, err := stub.GetPrivateDataByPartialCompositeKey(collection, indexName, []string{args[0]})
	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")
	for resultIt.HasNext() {
		response, err := resultIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		_, compositeKeyParts, err := stub.SplitCompositeKey(response.Key)
		if err != nil {
			return shim.Error(err.Error())
		}
		returnedName := compositeKeyParts[1]
		byts, err := stub.GetState(returnedName)
		if err == nil {
			if buff.Len() > 1 {
				buff.WriteString(",")
			}
			buff.WriteString(string(byts))
		}
	}
	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### GetPrivateDataQueryResult
> 查询账本中的键值对(使用非结构化查询进行批量查询，使用方法同`GetQueryResult`)

```
func (t *MyChaincode) doGetPrivateDataQueryResult(stub shim.ChaincodeStubInterface, collection string, args []string) pb.Response {
	fmt.Printf(`GetPrivateDataQueryResult("%s", "%s") \n<Begin>\n`, collection, args[0])
	age, _ := strconv.Atoi(args[0])
	queryString := fmt.Sprintf(`{"selector":{"age":{ "$gte": %d }}}`, age)
	queryIt, err := stub.GetPrivateDataQueryResult(collection, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer queryIt.Close()

	var buff bytes.Buffer
	buff.WriteString("[")

	for queryIt.HasNext() {
		queryResult, err := queryIt.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if buff.Len() > 1 {
			buff.WriteString(",")
		}
		buff.WriteString(string(queryResult.GetValue()))
	}

	buff.WriteString("]")
	fmt.Println("<End>")
	return shim.Success(buff.Bytes())
}
```

###### SetPrivateDataValidationParameter
> 在智能合约中实设置指定数据集的私有键值对的背书策略，该背书策略将覆盖智能合约部署时指定的背书策略

```
func (t *MyChaincode) doSetPrivateDataValidationParameter(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`SetPrivateDataValidationParameter() \n<Begin>`)
	collection := "my_collection"
	key := "my_key"
	ep := `OR(Org1.member, Org2.member)`
	err := stub.SetPrivateDataValidationParameter(collection, key, []byte(ep))
	fmt.Println("<End>")
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}
```


###### GetPrivateDataValidationParameter
> 读取指定数据集的私有键值对的背书策略, 仅返回通过`SetPrivateDataValidationParameter`设置的背书策略

```
func (t *MyChaincode) doGetPrivateDataValidationParameter(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`GetPrivateDataValidationParameter() \n<Begin>`)
	collection := "my_collection"
	key := "my_key"
	peBytes, err := stub.GetPrivateDataValidationParameter(collection, key)
	fmt.Println("<End>")
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(peBytes)
}
```

##### D. <集成调用相关API>

###### InvokeChaincode
> 调用其他Chaincode的功能(实现Chaincode集成甚至跨Channel集成)

```
import(
    ...
    "github.com/hyperledger/fabric/common/util"
    ...
)

func (t *MyChaincode) doInvokeChaincode(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`InvokeChaincode() \n<Begin>`)
	chaincodeName := "exmple03"
	funcName := "query"
	args := []string{funcName, "a", "b"}
	channelName := "channel02"
	fmt.Printf(`InvokeChaincode("%s, %s, %s") >`, chaincodeName, args, channelName)
	byteArgs := util.ArrayToChaincodeArgs(args)
	fmt.Println("<End>")
	return stub.InvokeChaincode(chaincodeName, byteArgs, channelName)
}
```

###### SetEvent
> 发送一个指定指定的事件消息(可被SDK订阅方接收)

```
func (t *MyChaincode) doSetEvent(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(`SetEvent() \n<Begin>`)
	topicName := "car_owner_changed"
	msg := fmt.Sprintf("The owner of car (%s) has been changed successfully.", "xxxxxx")

	err := stub.SetEvent(topicName, []byte(msg))
	fmt.Println("<End>")

	if err != nil {
		return shim.Success(nil)
	} else {
		return shim.Error(err.Error())
	}
}
```

> 参考1: https://github.com/hyperledger/fabric/blob/v1.4.0/core/chaincode/shim/interfaces.go

> 参考2: https://github.com/hyperledger/fabric/blob/v1.4.0/core/chaincode/lib/cid/interfaces.go

> API示例: https://raw.githubusercontent.com/qubing/fabric-api/master/chaincode/go/chaincode-api-go/chaincode-api-go.go


#### 1.3.3. Chaincode的单元测试
Fabric提供了Mock对象，以满足对Chaincode的脱机单元测试。
##### MockStub的创建
```
scc := new(SimpleChaincode)
stub := shim.NewMockStub("ex02", scc)
```

##### Init方法的MockAPI
```
res := stub.MockInit("1", args)
if res.Status != shim.OK {
	fmt.Println("Init failed", string(res.Message))
	t.FailNow()
}
```

##### Invoke方法的MockAPI
> 写操作

```
res := stub.MockInvoke("1", args)
if res.Status != shim.OK {
	fmt.Println("Invoke", args, "failed", string(res.Message))
	t.FailNow()
}
```
> 只读操作

```
res := stub.MockInvoke("1", [][]byte{[]byte("query"), []byte(name)})
if res.Status != shim.OK {
	fmt.Println("Query", name, "failed", string(res.Message))
	t.FailNow()
}
if res.Payload == nil {
	fmt.Println("Query", name, "failed to get value")
	t.FailNow()
}
if string(res.Payload) != value {
	fmt.Println("Query value", name, "was not", value, "as expected")
	t.FailNow()
}
```

> 键值对状态的测试

```
scc := new(SimpleChaincode)
stub := shim.NewMockStub("ex02", scc)
stub.MockInit("1", args)
bytes := stub.State[name]
if bytes == nil {
	fmt.Println("State", name, "failed to get value")
	t.FailNow()
}
if string(bytes) != value {
	fmt.Println("State value", name, "was not", value, "as expected")
	t.FailNow()
}
```
> 局限: 由于很多Chaincode API对联机操作环境有很高的依赖，暂时没办法提供MockAPI。

> 参考: https://github.com/hyperledger/fabric/blob/v1.0.5/core/chaincode/shim/mockstub.go

## 2. 智能合约的Java语言支持
==TO BE DONE==

## 3. 智能合约的Node.JS语言支持
==TO BE DONE==

## 4. Fabric的开发模式
> 开发模式和生产模式的区别

```
- Peer节点的启动参数中增加了 '--peer-chaincodedev=true'
- Chaincode的运行时容器不再是系统动态生成，而是通过Docker Compose脚本直接指定
```

##### 创建新的工作目录, 用于保存开发模式的网络设置:
```
$ mkdir -p ~/workspace/dev-network
$ cd ~/workspace/dev-network
$ mkdir base scripts
$ cp -r ../first_network/crypto-config ./
$ cp -r ../first_network/channel-artifacts/ ./
$ echo "COMPOSE_PROJECT_NAME=dev" > .env
$ echo "FABRIC_VERSION=1.0.5" >> .env
```

##### 编辑`./base/base.yaml`, 添加如下内容:
```
#
# base.yaml(DEV)
#

version: '2'

services:
  peer-base:
    image: hyperledger/fabric-peer:x86_64-${FABRIC_VERSION}
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      # the following setting starts chaincode containers on the same
      # bridge network as the peers
      # https://docs.docker.com/compose/networking/
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_bc-dev
      #- CORE_LOGGING_LEVEL=ERROR
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_GOSSIP_USELEADERELECTION=true
      - CORE_PEER_GOSSIP_ORGLEADER=false
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start

  db-base:
    image: hyperledger/fabric-couchdb:x86_64-${FABRIC_VERSION}
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=

  cli-base:
    container_name: cli
    image: hyperledger/fabric-tools:x86_64-${FABRIC_VERSION}
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID=cli
      - CORE_PEER_TLS_ENABLED=false
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer/scripts
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
```
#### 编辑`./base/docker-compose-base.yaml`, 添加如下内容:
```
#
# docker-compose-base.yaml(DEV+DB)
#

version: '2'

services:

  orderer.example.com:
    container_name: orderer.example.com
    image: hyperledger/fabric-orderer:x86_64-${FABRIC_VERSION}
    environment:
      - ORDERER_GENERAL_LOGLEVEL=debug
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_GENESISMETHOD=file
      - ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      - ORDERER_GENERAL_TLS_ENABLED=false
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric
    command: orderer
    volumes:
    - ../channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
    - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
    - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
    ports:
      - 7050:7050

  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    extends:
      file: base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer0.org1.example.com
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls:/etc/hyperledger/fabric/tls
    ports:
      - 7051:7051
      - 7053:7053

  db0.org1.example.com:
    container_name: db0.org1.example.com
    extends:
      file: base.yaml
      service: db-base
    networks:
      - bc-dev

  ca.org1.example.com:
    container_name: ca.org1.example.com
    image: hyperledger/fabric-ca:x86_64-${FABRIC_VERSION}
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org1
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_TLS_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem
      - FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/8e5bf29c85ed292783c36d48ceebe5e9fc2de97765947fe2b97fe54d030bc443_sk
    ports:
      - "7054:7054"
    command: sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/8e5bf29c85ed292783c36d48ceebe5e9fc2de97765947fe2b97fe54d030bc443_sk -b admin:adminpw -d'
    volumes:
      - ./crypto-config/peerOrganizations/org1.example.com/ca/:/etc/hyperledger/fabric-ca-server-config
    networks:
      - bc-dev
```
#### 编辑`./docker-compose-dev.yaml`, 添加如下内容:
```
# 
# docker-compose-dev.yaml
#

version: '2'

networks:
  bc-dev:

services:

  orderer.example.com:
    extends:
      file:   base/docker-compose-base.yaml
      service: orderer.example.com
    container_name: orderer.example.com
    environment:
      - ORDERER_GENERAL_TLS_ENABLED=false
    networks:
      - bc-dev

  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer0.org1.example.com
    environment:
      - CORE_PEER_TLS_ENABLED=false
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=db0.org1.example.com:5984
      # - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      # - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    command: /bin/bash -c 'sleep 10; peer node start --peer-chaincodedev=true -o orderer.example.com:7050'
    volumes:
       - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      - orderer.example.com
      - db0.org1.example.com
    networks:
      - bc-dev

  db0.org1.example.com:
    container_name: db0.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: db0.org1.example.com
    # environment:
    #   - COUCHDB_USER=
    #   - COUCHDB_PASSWORD=
    networks:
      - bc-dev
 
  ca.org1.example.com:
    container_name: ca.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: ca.org1.example.com
    networks:
      - bc-dev

  cli:
    container_name: cli
    extends:
      file:  base/base.yaml
      service: cli-base
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID=cli
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer/scripts
    command: /bin/bash -c 'sleep 20; ./setup_dev.sh'
    volumes:
        - /var/run/:/host/var/run/
        - ./../chaincodes/:/opt/gopath/src/chaincodes
        - ./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      - orderer.example.com
      - peer0.org1.example.com
    networks:
      - bc-dev

  chaincode-runtime:
    container_name: chaincode-runtime
    image: hyperledger/fabric-ccenv:x86_64-${FABRIC_VERSION}
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID=chaincode
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_TLS_ENABLED=false
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      - CORE_CHAINCODE_ID_NAME=mycc:1.0
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer/scripts
    command: /bin/bash -c 'cd /opt/gopath/src/chaincodes/chaincode_example02; go build; ./chaincode_example02'
    volumes:
        - /var/run/:/host/var/run/
        - ./../chaincodes/:/opt/gopath/src/chaincodes
        - ./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      - orderer.example.com
      - peer0.org1.example.com
    networks:
      - bc-dev
```

#### 编辑`./scripts/setup_dev.sh`, 添加如下内容:
```
CHANNEL_NAME=channel01

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ../channel-artifacts/$CHANNEL_NAME.tx
echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
echo

peer channel join -b $CHANNEL_NAME.block
echo "===================== Channel \"$CHANNEL_NAME\" joined successfully ===================== "
echo

peer chaincode install -n mycc -v 1.0 -p chaincodes/chaincode_example02

echo "===================== Channel \"$CHANNEL_NAME\" chaincode installed successfully ===================== "
echo

peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a","100","b","100"]}'
echo "===================== Channel \"$CHANNEL_NAME\" chaincode instantiated successfully ===================== "
echo

sleep 10

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
```
#### 启动开发模式
执行下述命令(Docker网络):
```
$ cd ~/workspace/dev_network
$ docker-compose -f docker-compose-dev.yaml up -d
```
通过Kitematic查看`cli`和`chaincode-runtime`的屏幕输出:

> cli的屏幕输出
![image](https://note.youdao.com/yws/api/personal/file/WEBd192cd408f3b04b16520808692fb19c0?method=download&shareKey=60dd38ebd847e0cb2969da515b7f1da6)

> chaincode-runtime的屏幕输出
![image](https://note.youdao.com/yws/api/personal/file/WEB6186297465afb8ac99f6fc84263c4faa?method=download&shareKey=634f1929edc956bb5c2ee8ff8559339b)




## 5. Chaincode 安装和部署
### 5.1. 安装Chaincode
> 命令语法:

```
Usage:
  peer chaincode install [flags]

Flags:
  -c, --ctor string      Constructor message for the chaincode in JSON format (default "{}")
  -h, --help             help for install
  -l, --lang string      Language the chaincode is written in (default "golang")
  -n, --name string      Name of the chaincode
  -p, --path string      Path to chaincode
  -v, --version string   Version of the chaincode specified in install/instantiate/upgrade commands

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
```

> 例如：

```
peer chaincode installl -n example02 -p chaincodes/chaincode_example02 -v 1.0
```

### 5.2. 部署Chaincode
> 命令语法:

```
Usage:
  peer chaincode instantiate [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -E, --escc string        The name of the endorsement system chaincode to be used for this chaincode
  -h, --help               help for instantiate
  -l, --lang string        Language the chaincode is written in (default "golang")
  -n, --name string        Name of the chaincode
  -P, --policy string      The endorsement policy associated to this chaincode
  -v, --version string     Version of the chaincode specified in install/instantiate/upgrade commands
  -V, --vscc string        The name of the verification system chaincode to be used for this chaincode

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
```

> 例如：

```
peer chaincode instantiate -o orderer.example.com:7050 -C channel01 -n example02 -v 1.0 -c '{"Args":["init","a","100","b","100"]}' -P "OR('Org1MSP.member','Org2MSP.member')"
```

### 5.3. 升级Chaincode
> 命令语法:

```
Usage:
  peer chaincode upgrade [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -E, --escc string        The name of the endorsement system chaincode to be used for this chaincode
  -h, --help               help for upgrade
  -l, --lang string        Language the chaincode is written in (default "golang")
  -n, --name string        Name of the chaincode
  -p, --path string        Path to chaincode
  -P, --policy string      The endorsement policy associated to this chaincode
  -v, --version string     Version of the chaincode specified in install/instantiate/upgrade commands
  -V, --vscc string        The name of the verification system chaincode to be used for this chaincode

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
```

例如：
```
peer chaincode upgrade -o orderer.example.com:7050 -C channel01 -n example02 -v 1.1 -c '{"Args":["init","a","100","b","100"]}' -P "OR('Org1MSP.member','Org2MSP.member')"
```

> 注意：
> - 版本号必须大于现存的版本号
> - 指定的Chaincode必须已经存在，并完成部署
> - 可以修改背书策略

## 6. 使用Fabric CLI访问Chaincode
### 6.1. 访问Chaincode的查询功能(只读)
> 语法:

```
Usage:
  peer chaincode query [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -h, --help               help for query
  -x, --hex                If true, output the query value byte array in hexadecimal. Incompatible with --raw
  -n, --name string        Name of the chaincode
  -r, --raw                If true, output the query value as raw bytes, otherwise format as a printable string
  -t, --tid string         Name of a custom ID generation algorithm (hashing and decoding) e.g. sha256base64

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
  -v, --version                    Display current version of fabric peer server

```

> 例如:

```
peer chaincode query -C channel01 -n example02 -c '{"Args":["query","a"]}'
```


### 6.2. 访问Chaincode的写入功能(异步,无返回值)
> 语法:

```
Usage:
  peer chaincode invoke [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -h, --help               help for invoke
  -n, --name string        Name of the chaincode

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
  -v, --version                    Display current version of fabric peer server


```

> 例如:

```
peer chaincode invoke -C channel01 -n example02 -c '{"Args":["invoke","a","b","10"]}'
```