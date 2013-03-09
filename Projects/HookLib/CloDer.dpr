library CloDer;

{.$DEFINE WRITELOGDATA}

{$DEFINE APPCODE}

{$R version.res}

{.$LIBSUFFIX '64'}

uses
  Windows,
  //JwaWinType,
  //JwaNtStatus,
  //JwaWinternl,
  //JwaNative,
  //WinInet,
  //UrlMon,
  //Messages,
  //SysUtils,
  uallHook;
  //uallProcess,
  //uallDisasm,
  //uallDisasmEx,
  //uallKernel,
  //uallProtect,
  //uallRelocHook,
  //uallRing0,
  //uallTableHook,
  //uallTrapHook,
  //uallUtil,
  //IniFiles,
  //JwaNative;
  //JwaWinType;
  //JwaWinBase;
  //tlhelp32;

//{$R *.res}


type
  HANDLE = Windows.THandle;

  //TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2, cdtProcessInfo = 3);

{  TAPIData = array[0..12] of string[255];
  TAPIRecord = packed record
    ProcessID      : DWORD;
    ProcessFileName: string[40];
    APIIdentify    : string[90];
    APIData        : TAPIData;
    //APIResult      : Cardinal;}

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
    //APIResult      : string[100];
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
{$IFEND}

const
{$IF Defined(WRITELOGDATA)}
  szPipeName: PAnsiChar = '\\.\pipe\LogROM';
{$IFEND}

  dwMatchAccess: DWORD = PROCESS_VM_OPERATION or PROCESS_VM_READ or PROCESS_VM_WRITE;
  wSteamModule : string = 'WSteam.dll';

var
  InjectedDll: Boolean = False;
  InjectedPid: DWORD   = 0;
  DisableHook: Boolean = False;
  //PatchWriteProcessMemory: Boolean = False;

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

function GetModuleFileNameAW(module: dword; path: boolean; fill: integer = 0) : string;
var
  arrChA : array [0..MAX_PATH] of char;
  arrChW : array [0..MAX_PATH] of wideChar;
  i1     : integer;
  i      : Integer;
begin
  //DO_NOT_LOG := True;

  if GetVersion and $80000000 = 0 then
  begin
    GetModuleFileNameW(module, arrChW, MAX_PATH);
    for i := 0 to Length(arrChW) do
      arrChA[i] := Char(arrChW[i]);

  end
  else
    GetModuleFileNameA(module, arrChA, MAX_PATH);
  result := arrChA;
  for i1 := Length(result) downto 1 do
    if result[i1] = '\' then
    begin
      if path then
        Delete(result, i1 + 1, maxInt)
      else Delete(result, 1,      i1    );
        break;
    end;
  i1 := Length(result);
  if fill > i1 then
  begin
    SetLength(result, fill);
    for i1 := i1 + 1 to fill do
      result[i1] := #0;
  end;

  //DO_NOT_LOG := False;
end;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

function AnsiLowerCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharLowerBuff(Pointer(Result), Len);
end;

function FileExistsEx(const FileName: string): Boolean;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
  Windows.FindClose(Handle);
  Result := False;
end;

function TrimString(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;


function TrimPAnsiChar(const P: PAnsiChar): string;
var
  S: String;
begin
  if (P = nil) or not Assigned(P) then
  begin
    Result := String('');
    Exit;
  end
  else
  begin
    S := String(P);
    Result := TrimString(S);
  end;
end;

function TrimPWideChar(const P: PWideChar): string;
var
  S: String;
begin
  if (P = nil) or not Assigned(P) then
  begin
    Result := String('');
    Exit;
  end
  else
  begin
    S := String(P);
    Result := TrimString(S);
  end;
end;

procedure CvtInt;
{ IN:
    EAX:  The integer value to be converted to text
    ESI:  Ptr to the right-hand side of the output buffer:  LEA ESI, StrBuf[16]
    ECX:  Base for conversion: 0 for signed decimal, 10 or 16 for unsigned
    EDX:  Precision: zero padded minimum field width
  OUT:
    ESI:  Ptr to start of converted text (not start of buffer)
    ECX:  Length of converted text
}
asm
        OR      CL,CL
        JNZ     @CvtLoop
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AL,'-'
        INC     ECX
        DEC     ESI
        MOV     [ESI],AL
        RET
@C2:    MOV     ECX,10

@CvtLoop:
        PUSH    EDX
        PUSH    ESI
@D1:    XOR     EDX,EDX
        DIV     ECX
        DEC     ESI
        ADD     DL,'0'
        CMP     DL,'0'+10
        JB      @D2
        ADD     DL,('A'-'0')-10
@D2:    MOV     [ESI],DL
        OR      EAX,EAX
        JNE     @D1
        POP     ECX
        POP     EDX
        SUB     ECX,ESI
        SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AL,'0'
        SUB     ESI,EDX
        JMP     @z
@zloop: MOV     [ESI+EDX],AL
@z:     DEC     EDX
        JNZ     @zloop
        MOV     [ESI],AL
@D5:
end;

function IntToStr(Value: Integer): string;
//  FmtStr(Result, '%d', [Value]);
asm
        PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 16
        XOR     ECX, ECX       // base: 0 for signed decimal
        PUSH    EDX            // result ptr
        XOR     EDX, EDX       // zero filled field width: 0 for no leading zeros
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
        CALL    System.@LStrFromPCharLen
        ADD     ESP, 16
        POP     ESI
end;

function IntToHex(Value: Integer; Digits: Integer): string;
//  FmtStr(Result, '%.*x', [Digits, Value]);
asm
        CMP     EDX, 32        // Digits < buffer length?
        JBE     @A1
        XOR     EDX, EDX
@A1:    PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 32
        PUSH    ECX            // result ptr
        MOV     ECX, 16        // base 16     EDX = Digits = field width
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
        CALL    System.@LStrFromPCharLen
        ADD     ESP, 32
        POP     ESI
end;

{$IF Defined(WRITELOGDATA)}
procedure Log(MyApiData: TAPIRecord);
var
  res: LongBool;
  cbRead: Cardinal;
  pmSetData: TPipeMessage;
  cGetData: Cardinal;
  i       : Integer;
begin

  {Randomize;
  i := Random(100);
  if i < 10 then
    repeat
      i := Random(100);
      //MessageBeep(MB_ICONHAND);
    until i >= 10;

  Sleep(Random(100));
  Exit;}

  //MessageBox(0, 'Log.', '', 0);

  DO_NOT_LOG := True;

  if not WaitNamedPipe(szPipeName, 2500) then
  begin
    //MessageBox(0, 'Unable to connect to NamedPipe, pipe is not active!', 'Error', MB_OK or MB_ICONHAND);
    Exit;
  end;

  
  //SetLength(bArray, numBytes); //ReDim bArray(numBytes)  //Build the return buffer
  ZeroMemory(@pmSetData, SizeOf(pmSetData));
  with pmSetData do
  begin
    Id := pmiStatus;
    Size := SizeOf(pmSetData);
    with Data do
    begin
      ProcessID := GetCurrentProcessId;
      ProcessFileName := TrimString(GetModuleFileNameAW(0, false));
      LibraryFileName := MyApiData.LibraryFileName;
      APIFunction := MyApiData.APIFunction;
      {for i := Low(APIData) to High(APIData) do
        if Length(APIData[i][1]) > 255 then
          APIData[i][1] := Copy(AnsiString(APIData[i][1]), 1, 255);}
      APIData := MyApiData.APIData;
      APIHighLight := MyApiData.APIHighLight;
      APIResult := MyApiData.APIResult;
    end;
    Size := SizeOf(pmSetData);
  end;
  //Call CallNamedPipe to do the transaction all at once
  res := CallNamedPipe(szPipeName, @pmSetData, pmSetData.Size, @cGetData, SizeOf(cGetData), cbRead, 5000);

  {if not res then
    MessageBox(0, 'Error attempting to call CallNamedPipe.', '', 0);}

    //MsgBox "Error number " & Err.LastDllError & _
    //       " attempting to call CallNamedPipe.", vbOKOnly
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
{  if (lpValueName <> nil) then
  begin
    if lpValueName = '\DosDevices\G:' then
      Result := RegQueryValueExANextHook(Key, nil, Reserved, dwType, lpData, cbData)
    else
      Result := RegQueryValueExANextHook(Key, lpValueName, Reserved, dwType, lpData, cbData);
  end
  else}

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
    Log(APIData{, Result});
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
  //WSteam.dll
  //lpLibFileName

  Result := LoadLibraryExWNextHook(lpLibFileName, hFile, dwFlags);

  if (Pos(AnsiUpperCase(wSteamModule), AnsiUpperCase(WideCharToString(lpLibFileName))) > 0) then
  begin
    UnhookCode(@OpenProcessNextHook);
    UnhookCode(@WriteProcessMemoryNextHook);
    UnhookCode(@LoadLibraryExWNextHook);

    //MessageBox(GetDesktopWindow, 'UnloadLibrary();', 'UnHooked:', MB_OK);

    UnloadLibrary(GetCurrentProcessId, PAnsiChar(GetModuleFileNameAW(HInstance, false, 0)));

    //MessageBox(GetDesktopWindow, PAnsiChar(GetModuleFileNameAW(HInstance, false, 0)), 'UnHooked:', MB_OK);
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

    //APIData.APIData[0][0] := 'hProcess';
    //APIData.APIData[0][1] := '0x' + IntToHex(DWORD(hProcess), 8);

    //APIData.APIData[1][0] := 'lpBaseAddress';
    //APIData.APIData[1][1] := '0x' + IntToHex(DWORD(lpBaseAddress), 8);

    //APIData.APIData[2][0] := 'lpBuffer';
    //APIData.APIData[2][1] := '?';//'0x' + IntToHex(DWORD(lpBuffer), 8);

    //APIData.APIData[3][0] := 'nSize';
    //APIData.APIData[3][1] := IntToStr(nSize);

    //APIData.APIData[4][0] := 'lpNumberOfBytesWritten';
    //APIData.APIData[4][1] := IntToStr(lpNumberOfBytesWritten);

    APIData.APIResult := DWORD(Result);
    Log(APIData{, Result});
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

    //APIData.APIData[0][0] := 'hProcess';
    //APIData.APIData[0][1] := '0x' + IntToHex(DWORD(hProcess), 8);

    //APIData.APIData[1][0] := 'lpBaseAddress';
    //APIData.APIData[1][1] := '0x' + IntToHex(DWORD(lpBaseAddress), 8);

    //APIData.APIData[2][0] := 'lpBuffer';
    //APIData.APIData[2][1] := '?';//'0x' + IntToHex(DWORD(lpBuffer), 8);

    //APIData.APIData[3][0] := 'nSize';
    //APIData.APIData[3][1] := IntToStr(nSize);

    //APIData.APIData[4][0] := 'lpNumberOfBytesWritten';
    //APIData.APIData[4][1] := IntToStr(lpNumberOfBytesWritten);

    APIData.APIResult := DWORD(Result);
    Log(APIData{, Result});
  end;
{$IFEND}
end;

begin
  //WriteProcessMemoryOrigHook := GetProcAddress(LoadLibrary(kernel32),'WriteProcessMemory');
  //HookCode(@WriteProcessMemoryOrigHook, @WriteProcessMemoryHookProc, @WriteProcessMemoryNextHook);

  OpenProcessOrigHook := GetProcAddress(LoadLibrary(kernel32),'OpenProcess');
  HookCode(@OpenProcessOrigHook, @OpenProcessHookProc, @OpenProcessNextHook);

  //MessageBox(GetDesktopWindow, 'Welcome to the Real World!', 'Hooked:', MB_OK);
end.

