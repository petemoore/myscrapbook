:: run the generic worker

:: cd to folder containing this script
pushd %~dp0

set GOPATH=C:\gopath

go get -u github.com/taskcluster/generic-worker > .\generic-worker.log 2>&1
copy /y /b %GOPATH%\bin\generic-worker.exe .\generic-worker.exe >> .\generic-worker.log 2>&1

c:\cygwin\bin\bash.exe -c '/usr/bin/wget https://raw.githubusercontent.com/petemoore/myscrapbook/master/worker-pre-run-steps.bat' >> .\generic-worker.log 2>&1
call .\worker-pre-run-steps.bat >> .\generic-worker.log 2>&1

echo running worker >> .\generic-worker.log 2>&1
.\generic-worker.exe run --configure-for-aws >> .\generic-worker.log 2>&1
