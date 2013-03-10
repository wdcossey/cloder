del bin\CloDer.dll.bak
copy bin\CloDer.dll bin\CloDer.dll.bak
tools\RichOff\RichOff.exe bin\CloDer.dll 40
tools\StripReloc\StripReloc.exe bin\CloDer.dll
tools\upx\upx.exe --best --crp-ms=999999 --force --brute bin\CloDer.dll

del bin\CloDer.exe.bak
copy bin\CloDer.exe bin\CloDer.exe.bak
tools\RichOff\RichOff.exe bin\CloDer.exe 40
tools\StripReloc\StripReloc.exe bin\CloDer.exe
tools\upx\upx.exe --best --crp-ms=999999 --force --brute bin\CloDer.exe
pause