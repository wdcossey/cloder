unit DebugWriter;

interface

uses
  Windows,
  CloDer.Utils,
  CloDer.Common;

  procedure WriteDebugString(DebugMsg: string);

implementation

procedure WriteDebugString(DebugMsg: string);
var
  lastError : Cardinal;
  msgBuffer : PAnsiChar;
  myFileName: AnsiString;
begin
  lastError := GetLastError;

  FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
                nil,
                lastError,
                LANG_NEUTRAL,
                @msgBuffer,
                0,
                nil);

  myFileName := Trim(GetModuleFileNameAW(0, false));

  OutputDebugStringW(PWideChar(WideString('CloDer("' + myFileName + '"): ' + DebugMsg + '; LastError("' + Trim(msgBuffer) + '" [0x' + IntToHex(lastError, 8) + '])')));
end;

end.
