export GOPROXY=https://goproxy.cn
rm -rf build
cp -r src build
cd build
go mod init example02
go mod vendor
go build