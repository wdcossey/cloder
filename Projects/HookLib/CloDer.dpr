library CloDer;

{.$DEFINE WRITELOGDATA}

{$DEFINE APPCODE}

{.$R version.res}
{$R 'version.res' 'version.rc'}

uses
  Windows,
  CloDer.Common,
  CloDer.Utils,
  DebugWriter,
  uallHook;

{$IF Defined(WRITELOGDATA)}
type
  TPipeMessageId = (pmiCommand, pmiVersion, pmiStatus);

  TAPIHighLight = (ahlNone, ahlError, ahlWarning);

  TAPIData = array[0..12, 0..1] of String[255];
  TAPIRecord = record
    ProcessID      : Cardinal;
    ProcessFileName: String[64];
    LibraryFileName: String[64];
    APIFunction    : String[64];
    APIData        : TAPIData;
    APIResult      : Cardinal;
    APIHighLight   : TAPIHighLight;
  end;

type
  TPipeMessage = record
    Size: DWORD;
    Id: TPipeMessageId;
    Count: DWORD;
    Data: TAPIRecord;//array[0..8095] of Char;
  end;

  TProcessRecord = record
    ProcessID      : DWORD;
    ProcessFileName: string[40];
  end;

const
  szPipeName: PAnsiChar = '\\.\pipe\LogROM';
{$IFEND}

const
  dwMatchAccess: DWORD = PROCESS_VM_OPERATION or PROCESS_VM_READ or PROCESS_VM_WRITE;
  wSteamModule : string = 'WSteam.dll';

var
  InjectedDll: Boolean = False;
  InjectedPid: DWORD   = 0;
  DisableHook: Boolean = False;

{$IF Defined(WRITELOGDATA)}
var
  DO_NOT_LOG: Boolean = False;
{$IFEND}

var
    WriteProcessMemoryNextHook : function (hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
                                            nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;
    WriteProcessMemoryOrigHook : function (hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
                                            nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;

    OpenProcessNextHook : function (dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
    OpenProcessOrigHook : function (dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;

    LoadLibraryExWNextHook : function (lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
    LoadLibraryExWOrigHook : function (lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;

{$IF Defined(WRITELOGDATA)}
procedure Log(MyApiData: TAPIRecord);
var
  res: LongBool;
  cbRead: Cardinal;
  pmSetData: TPipeMessage;
  cGetData: Cardinal;
  i       : Integer;
begin
  DO_NOT_LOG := True;

  if not WaitNamedPipe(szPipeName, 2500) then
  begin
    Exit;
  end;

  ZeroMemory(@pmSetData, SizeOf(pmSetData));
  with pmSetData do
  begin
    Id := pmiStatus;
    Size := SizeOf(pmSetData);
    with Data do
    begin
      ProcessID := GetCurrentProcessId;
      ProcessFileName := Trim(GetModuleFileNameAW(0, false));
      LibraryFileName := MyApiData.LibraryFileName;
      APIFunction := MyApiData.APIFunction;
      APIData := MyApiData.APIData;
      APIHighLight := MyApiData.APIHighLight;
      APIResult := MyApiData.APIResult;
    end;
    Size := SizeOf(pmSetData);
  end;

  res := CallNamedPipe(szPipeName, @pmSetData, pmSetData.Size, @cGetData, SizeOf(cGetData), cbRead, 5000);

  Sleep(5);
  DO_NOT_LOG := False;
end;
{$IFEND}

function WriteProcessMemoryHookProc(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
                                    nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;
var
{$IF Defined(WRITELOGDATA)}
  APIData: TAPIRecord;
{$IFEND}
  vProtect: LongBool;
  oldProtect: DWORD;
begin

{$IF Defined(APPCODE)}
  if ((nSize > 0) {and (PatchWriteProcessMemory)}) then
  begin
    vProtect := VirtualProtect(lpBaseAddress, nSize, PAGE_EXECUTE_READWRITE, @oldProtect);
    if (vProtect) then
    begin
      Result := WriteProcessMemoryNextHook(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten);
      VirtualProtect(lpBaseAddress, nSize, oldProtect, @oldProtect);
    end
    else
    begin
      Result := WriteProcessMemoryNextHook(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten);
    end;
  end
  else
    Result := WriteProcessMemoryNextHook(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten);
{$ELSE}
    Result := WriteProcessMemoryNextHook(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten);
{$IFEND}

{$IF Defined(WRITELOGDATA)}
  if (not DO_NOT_LOG) then
  begin
    ZeroMemory(@APIData, SizeOf(APIData));
    APIData.APIFunction := 'WriteProcessMemory';
    APIData.LibraryFileName := kernel32;

    APIData.APIData[0][0] := 'hProcess';
    APIData.APIData[0][1] := '0x' + IntToHex(DWORD(hProcess), 8);

    APIData.APIData[1][0] := 'lpBaseAddress';
    APIData.APIData[1][1] := '0x' + IntToHex(DWORD(lpBaseAddress), 8);

    APIData.APIData[2][0] := 'lpBuffer';
    APIData.APIData[2][1] := '?';//'0x' + IntToHex(DWORD(lpBuffer), 8);

    APIData.APIData[3][0] := 'nSize';
    APIData.APIData[3][1] := IntToStr(nSize);

    APIData.APIData[4][0] := 'lpNumberOfBytesWritten';
    APIData.APIData[4][1] := IntToStr(lpNumberOfBytesWritten);

    APIData.APIResult := Int64(GetLastError);// DWORD(Result);
    Log(APIData);
  end;
{$IFEND}

end;

function LoadLibraryExWHookProc(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
{$IF Defined(WRITELOGDATA)}
var
  APIData: TAPIRecord;
{$IFEND}

begin

{$IF Defined(APPCODE)}
  Result := LoadLibraryExWNextHook(lpLibFileName, hFile, dwFlags);

  if (Pos(AnsiUpperCase(wSteamModule), AnsiUpperCase(WideCharToString(lpLibFileName))) > 0) then
  begin
    UnhookCode(@OpenProcessNextHook);
    UnhookCode(@WriteProcessMemoryNextHook);
    UnhookCode(@LoadLibraryExWNextHook);

    UnloadLibrary(GetCurrentProcessId, PAnsiChar(GetModuleFileNameAW(HInstance, false, 0)));
  end;

{$ELSE}
  Result := LoadLibraryExWNextHook(lpLibFileName, hFile, dwFlags);
{$IFEND}

{$IF Defined(WRITELOGDATA)}
  if (not DO_NOT_LOG) then
  begin
    ZeroMemory(@APIData, SizeOf(APIData));
    APIData.APIFunction := 'LoadLibraryExW';
    APIData.LibraryFileName := kernel32;

    APIData.APIData[0][0] := 'lpLibFileName';
    APIData.APIData[0][1] := Trim(lpLibFileName);

    APIData.APIData[1][0] := 'hFile';
    APIData.APIData[1][1] := '0x' + IntToHex(DWORD(hFile), 8);

    APIData.APIData[2][0] := 'dwFlags';
    APIData.APIData[2][1] := '0x' + IntToHex(DWORD(dwFlags), 8);

    APIData.APIResult := DWORD(Result);
    Log(APIData);
  end;
{$IFEND}
end;

function OpenProcessHookProc(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
{$IF Defined(WRITELOGDATA)}
var
  APIData: TAPIRecord;
{$IFEND}
begin

{$IF Defined(APPCODE)}
  if ((dwDesiredAccess = dwMatchAccess) and (bInheritHandle)) then
  begin
    //PatchWriteProcessMemory := True;
    WriteProcessMemoryOrigHook := GetProcAddress(LoadLibrary(kernel32),'WriteProcessMemory');
    HookCode(@WriteProcessMemoryOrigHook, @WriteProcessMemoryHookProc, @WriteProcessMemoryNextHook);

    LoadLibraryExWOrigHook := GetProcAddress(LoadLibrary(kernel32),'LoadLibraryExW');
    HookCode(@LoadLibraryExWOrigHook, @LoadLibraryExWHookProc, @LoadLibraryExWNextHook);
  end;
{$ELSE}

{$IFEND}

  Result := OpenProcessNextHook(dwDesiredAccess, bInheritHandle, dwProcessId);

{$IF Defined(WRITELOGDATA)}
  if (not DO_NOT_LOG) then
  begin
    ZeroMemory(@APIData, SizeOf(APIData));
    APIData.APIFunction := 'OpenProcess';
    APIData.LibraryFileName := kernel32;

    APIData.APIData[0][0] := 'dwDesiredAccess';
    APIData.APIData[0][1] := '0x' + IntToHex(DWORD(dwDesiredAccess), 8);

    APIData.APIData[1][0] := 'bInheritHandle';
    APIData.APIData[1][1] := '0x' + IntToHex(DWORD(bInheritHandle), 8);

    APIData.APIData[2][0] := 'dwProcessId';
    APIData.APIData[2][1] := IntToHex(DWORD(dwProcessId), 8);

    APIData.APIResult := DWORD(Result);
    Log(APIData);
  end;
{$IFEND}
end;

procedure DllMain(reason: integer) ;
var
  buf : array[0..MAX_PATH] of char;
  loader : string;
begin
  case reason of
    DLL_PROCESS_ATTACH:
    begin
    {$IFDEF DEBUG}
      DebugWarning;
      WriteDebugString('DLL_PROCESS_ATTACH');
    {$ENDIF}

      //WriteProcessMemoryOrigHook := GetProcAddress(LoadLibrary(kernel32),'WriteProcessMemory');
      //HookCode(@WriteProcessMemoryOrigHook, @WriteProcessMemoryHookProc, @WriteProcessMemoryNextHook);

      OpenProcessOrigHook := GetProcAddress(LoadLibrary(kernel32),'OpenProcess');
      HookCode(@OpenProcessOrigHook, @OpenProcessHookProc, @OpenProcessNextHook);

    end;
    DLL_PROCESS_DETACH:
    begin
    {$IFDEF DEBUG}
      WriteDebugString('DLL_PROCESS_DETACH');
    {$ENDIF}
    end;
  end;
end; (*DllMain*)

begin
  DllProc := @DllMain;
  DllProc(DLL_PROCESS_ATTACH) ;
end.

