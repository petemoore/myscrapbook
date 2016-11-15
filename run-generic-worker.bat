:: run the generic worker

:: cd to folder containing this script
pushd %~dp0

go get -u github.com/taskcluster/generic-worker
copy /y /b %GOPATH%\bin\generic-worker.exe .\generic-worker.exe

.\generic-worker.exe run --configure-for-aws > .\generic-worker.log 2>&1
