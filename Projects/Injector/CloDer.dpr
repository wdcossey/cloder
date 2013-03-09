program CloDer;

{$DEFINE DEBUG}

uses
  //Forms,
  //Unit1 in 'Unit1.pas' {Form1},
  uallHook, {uallProcess, uallDisasm, uallDisasmEx, uallKernel, uallProtect,
  uallRelocHook, uallTableHook, uallTrapHook,} uallUtil,

  Windows,
  MiniCommDlg,// in 'include\MiniCommDlg.pas',
  CreateProcessInternalApi;// in 'include\CreateProcessInternalApi.pas';

{.$R xpmanifest.res}
{$R manifest.res}
{$R version.res}
{.$R icon.res}

type
  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

  TSysLocale = packed record
    DefaultLCID: Integer;
    PriLangID: Integer;
    SubLangID: Integer;
    FarEast: Boolean;
    MiddleEast: Boolean;
  end;

const
  PathDelim  = '\';
  DriveDelim = ':';
  PathSep    = ';';

  sVendor  : WideString = '1C:SoftClub';
  sExecFile: WideString = 'Launcher.exe';

var
  sHookLib: string = 'CloDer.dll';

var
  LeadBytes: set of Char = [];
  SysLocale: TSysLocale;
  OFNFileW : array [0..MAX_PATH] of WideChar;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrPCopy(Dest: PChar; const Source: string): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), Length(Source));
end;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType;
var
  I: Integer;
begin
  Result := mbSingleByte;
  if (P = nil) or (P[Index] = #$0) then Exit;
  if (Index = 0) then
  begin
    if P[0] in LeadBytes then Result := mbLeadByte;
  end
  else
  begin
    I := Index - 1;
    while (I >= 0) and (P[I] in LeadBytes) do Dec(I);
    if ((Index - I) mod 2) = 0 then Result := mbTrailByte
    else if P[Index] in LeadBytes then Result := mbLeadByte;
  end;
end;

function ByteType(const S: string; Index: Integer): TMbcsByteType;
begin
  Result := mbSingleByte;
  if SysLocale.FarEast then
    Result := ByteTypeTest(PChar(S), Index-1);
end;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = PathDelim)
    and (ByteType(S, Index) = mbSingleByte);
end;

function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + PathDelim;
end;

(*procedure ExpireMe;
var
  hDll             : DWORD;
  SysTime          : _SYSTEMTIME;
  NtQuerySystemTime: function(SystemTime: LARGE_INTEGER): DWORD; stdcall;
begin
  Exit;
  {
  GetSystemTime(SysTime);

  if SysTime.wYear > 2009 then
    TerminateProcess(GetCurrentProcess, 0);

  if SysTime.wMonth > 11 then
    TerminateProcess(GetCurrentProcess, 0);

  if (SysTime.wMonth = 11) and (SysTime.wDay > 16) then
    TerminateProcess(GetCurrentProcess, 0);

  if (SysTime.wMonth < 11) and (SysTime.wDay <= 8) then
    TerminateProcess(GetCurrentProcess, 0);

   if (SysTime.wMonth = 11) and (SysTime.wDay <= 8) then
    TerminateProcess(GetCurrentProcess, 0);
  }
  {hDll := LoadLibrary('ntdll.dll');
  if hDll <> 0 then
  begin
    @NtQuerySystemTime := GetProcAddress(hDll, 'NtQuerySystemTime');
    if @NtQuerySystemTime <> nil then
    begin
      NtQuerySystemTime(SysTime);

    end;
    FreeLibrary(hDll);
  end;}
end;*)

procedure InitDllFile;
var i1 : integer;
begin
  if GetVersion and $80000000 = 0 then
  begin
    //for i1 := 0 to High(OFNFileW) do
    //  OFNFileW[i1] := #0;

    for i1 := 0 to Length(sExecFile) do
      OFNFileW[i1] := WideChar(sExecFile[i1+1]);

    for i1 := Length(sExecFile) to High(OFNFileW) do
      OFNFileW[i1] := #0;

    //OFNFileW[0] := 'L';
    //OFNFileW[1] := 'a';
    //OFNFileW[2] := 'u';
    //OFNFileW[3] := 'n';
    //OFNFileW[4] := 'c';
    //OFNFileW[5] := 'h';
    //OFNFileW[6] := 'e';
    //OFNFileW[7] := 'r';
    //OFNFileW[8] := '.';
    //OFNFileW[9] := 'e';
    //OFNFileW[10] := 'x';
    //OFNFileW[11] := 'e';
  end;
end;

function GetOpenFile(ParentWnd: dword) : Boolean;
var
  ofnW     : TOpenFilenameW;
  sFileName: string;
  i        : Integer;
  //FindData: TWin32FindDataW;
begin
  Result := False;
  try
    if GetVersion and $80000000 = 0 then
    begin
      ZeroMemory(@ofnW, sizeOf(ofnW));
      //if FindFirstFileW(OFNFileW, FindData) = ERROR_INVALID_HANDLE then
      InitDllFile;
      ofnW.lStructSize     := 19 * 4;
      ofnW.hWndOwner       := ParentWnd;
      ofnW.lpstrFilter     := PWideChar(sVendor + ' ' + sExecFile + #0 + sExecFile + #0);// '1C:SoftClub Launcher.exe'#0'Launcher.exe'#0;
      ofnW.nFilterIndex    := 1;

      {for i := 0 to Length(sFileName) do
      begin
        OFNFileW[i] := WideChar(sFileName[i+1]);
      end;}

      ofnW.lpstrFile       := OFNFileW;
      ofnW.nMaxFile        := MAX_PATH;
      ofnW.lpstrTitle      := nil;
      ofnW.Flags           := OFN_ENABLESIZING {or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT};
      Result := GetOpenFileNameW(ofnW);
    end;
  finally
    //ExpireMe;
  end;
end;

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

function ExtractResFile(BinResType, BinResName: string; ResFileName: string): boolean;
var
  ResSize, HG, HI, SizeWritten, hFileWrite: Cardinal;
begin

  {if FileExists(ResFileName) then
  begin
    if not DeleteFile(PChar(ResFileName)) then
      if not DeleteFile(PChar(ResFileName)) then
        if not DeleteFile(PChar(ResFileName)) then
        begin
          Result := True;
          Exit;
        end;
  end;}

  result := false;
  HI := FindResource(hInstance, PChar(BinResName), PChar(BinResType));
  if HI <> 0 then
  begin
    HG := LoadResource(hInstance, HI);
    if HG <> 0 then
    begin
      ResSize := SizeOfResource(hInstance, HI);
      hFileWrite := CreateFile(PChar(ResFileName), GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS,
        FILE_ATTRIBUTE_ARCHIVE, 0);
      if hFileWrite <> INVALID_HANDLE_VALUE then
      try
        result := (WriteFile(hFileWrite, LockResource(HG)^, ResSize,
          SizeWritten, nil) and (SizeWritten >= ResSize));
      finally
        CloseHandle(hFileWrite);
      end;
    end;
  end;
end;

{$IFDEF DEBUG}
procedure WriteDebugString(DebugMsg: string);
var
  length    : Cardinal;
  lastError : Cardinal;
  msgBuffer : PAnsiChar;
  strMessage: AnsiString;
begin
  lastError := GetLastError;

  length := FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
                nil,
                lastError,
                LANG_NEUTRAL,
                @msgBuffer,
                0,
                nil);

  strMessage := Copy(msgBuffer, 0, length - 1);

  OutputDebugStringW(PWideChar(WideString('CloDer(): ' + DebugMsg + '; LastError("' + strMessage + '" [0x' + IntToHex(lastError, 8) + '])')));
end;
{$ENDIF}

function CreateProcessInternalEx(AppFileName, AppRunPath, Parameters: string; {BitMask: Integer;} HookModule: string): Longword;
label
  lRetry;
var
  zAppName   : array[0..512] of Char;
  zAppHook   : array[0..512] of Char;
  zCurDir    : array[0..255] of Char;

  zArguments : PAnsiChar;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;

  findExec   : _WIN32_FIND_DATAW;
  hFindFile  : Cardinal;
begin
  //MessageBox(GetDesktopWindow, PChar('Executable: "' + AppFileName + '".'#10#10'Parameters: "' + Parameters + '".'#10#10'HookLib: "' + HookModule + '".'#10#10), nil, MB_OK or MB_ICONHAND);

  {$IFDEF DEBUG}
      WriteDebugString('CreateProcess()');
      WriteDebugString('Launcher("' + AppFileName + '")');
      WriteDebugString('Path("' + AppRunPath + '")');
      WriteDebugString('Parameters("' + Parameters + '")');
      WriteDebugString('HookLib("' + HookModule + '")');
  {$ENDIF}

  hFindFile := Windows.FindFirstFileW(PWideChar(WideString(AppFileName)), findExec);
{$IFDEF DEBUG}
  WriteDebugString('FindLauncher("' + AppFileName + '" [0x' + IntToHex(hFindFile, 8) + '])');
{$ENDIF}

  if (hFindFile = INVALID_HANDLE_VALUE) then
  begin
    MessageBox(GetDesktopWindow, PChar('Unable to locate the the specified executable.'#10#10'Executable: "' + AppFileName + '".'#10#10'Please ensure that your parameters are correct.'), nil, MB_OK or MB_ICONHAND);
    Exit;
  end
  else
    Windows.FindClose(hFindFile);

  StrPCopy(zAppName, AppFileName);
  StrPCopy(zAppHook, HookModule);

  StrPCopy(zCurDir, AppRunPath);
  zArguments := PChar(' ' + Parameters);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_NORMAL;

  //ZeroMemory(@p, SizeOf(p));

  //CreateProcessInternal
  if not CreateProcessInternal(0,
                               zAppName,
                               zArguments,
                               nil,
                               nil,
                               False,
                               CREATE_SUSPENDED or NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE,
                               nil,
                               zCurDir,
                               StartupInfo,
                               ProcessInfo,
                               nil) then
  begin
    Result := WAIT_FAILED;
{$IFDEF DEBUG}
    WriteDebugString('CreateProcess("Failed!")');
{$ENDIF}
  end
  else
  begin
    //SetProcessAffinityMask(ProcessInfo.hProcess, BitMask);
{$IFDEF DEBUG}
    WriteDebugString('CreateProcess("OK!")');
{$ENDIF}

  lRetry:
    if not InjectLibrary(ProcessInfo.dwProcessId, zAppHook) then
    begin
    {$IFDEF DEBUG}
      WriteDebugString('InjectLibrary("Failed!")');
    {$ENDIF}
      if MessageBox(GetDesktopWindow, PChar('Failed to inject the hook library into the remote process.'#10#10'Library: "' + zAppHook + '".'#10'Process: "' + AppFileName + '".'#10#10'Would you like to retry injection?'), nil, MB_YESNO or MB_ICONERROR OR MB_DEFBUTTON2) = IDYES then
      begin
        Sleep(127);
        goto lRetry;
        {$IFDEF DEBUG}
          WriteDebugString('InjectLibrary("Retry!")');
        {$ENDIF}
      end;
    end
  {$IFDEF DEBUG}
    else
    begin
      WriteDebugString('InjectLibrary("OK!")');
    end;
  {$ELSE}
    ;
  {$ENDIF}

    Sleep(127);

    ResumeThread(ProcessInfo.hThread);
{$IFDEF DEBUG}
    WriteDebugString('ResumeThread("0x' + IntToHex(ProcessInfo.hThread, 8) + '")');
{$ENDIF}

    {repeat
      //Application.ProcessMessages;
      Sleep(10);
    until (WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_OBJECT_0) and
          (DaughterProcessActive(DaughterPID) = 0);}

    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    //exit code of the launched process (0 if the process returned no error)
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;

end;

var
  i, n     : Integer;
  aTempPath: array[0..MAX_PATH-1] of Char;
  sTempPath: string;
  sFileName: string;

  aCurrPath: array[0..MAX_PATH-1] of Char;
  sCurrPath: string;

  findHook : _WIN32_FIND_DATAW;
  findExec : _WIN32_FIND_DATAW;
  hFindFile: Cardinal;

  sCmdExec : string;
  sCmdParam: string;

begin
{$IFDEF DEBUG}
  MessageBox(GetDesktopWindow, PChar('This version of "CloDer" is NOT for public use!'#10#10'To remove this warning please obtain the public copy.'), 'Warning', MB_OK or MB_ICONWARNING);

  WriteDebugString('Init()');
{$ENDIF}

  sHookLib := ExtractFileName(ParamStr(0)) + '.dll';
{$IFDEF DEBUG}
  WriteDebugString('HookLib("' + sHookLib + '")');
{$ENDIF}

  GetCurrentDirectory(SizeOf(aCurrPath), aCurrPath);
  sCurrPath := aCurrPath;
  sCurrPath := IncludeTrailingPathDelimiter(sCurrPath);
{$IFDEF DEBUG}
  WriteDebugString('CurrentDirectory("' + sCurrPath + '")');
{$ENDIF}

  sFileName := sHookLib;
  GetTempPath(SizeOf(aTempPath), aTempPath);
  sTempPath := IncludeTrailingPathDelimiter(AnsiString(aTempPath));
  sFileName := sTempPath + sFileName;
{$IFDEF DEBUG}
  WriteDebugString('TempFile("' + sFileName + '")');
{$ENDIF}

  hFindFile := Windows.FindFirstFileW(PWideChar(WideString(sCurrPath + sHookLib)), findHook);
{$IFDEF DEBUG}
  WriteDebugString('FindHookLib("' + sCurrPath + sHookLib + '" [0x' + IntToHex(hFindFile, 8) + '])');
{$ENDIF}

  if (hFindFile = INVALID_HANDLE_VALUE) then
  begin
    if not ExtractResFile('DLL', 'HOOK', sFileName) then
    begin
    {$IFDEF DEBUG}
      WriteDebugString('ExtractResFile("Failed!")');
    {$ENDIF}
      sFileName := IncludeTrailingPathDelimiter(sCurrPath) + sHookLib;

      hFindFile := Windows.FindFirstFileW(PWideChar(WideString(sFileName)), findHook);
      {$IFDEF DEBUG}
        WriteDebugString('FindHookLib("' + sFileName + '" [0x' + IntToHex(hFindFile, 8) + '])');
      {$ENDIF}

      if (hFindFile = INVALID_HANDLE_VALUE) then
      begin
        MessageBox(GetDesktopWindow, PChar('Unable to locate the the required hook library.'#10#10'Library: "' + sFileName + '".'), nil, MB_OK or MB_ICONHAND);
        {$IFDEF DEBUG}
          WriteDebugString('Terminate()');
        {$ENDIF}
        Exit;
      end
      else
        Windows.FindClose(hFindFile);
    end
    else
    begin
    {$IFDEF DEBUG}
      WriteDebugString('ExtractResFile("OK!")');
    {$ENDIF}
      Sleep(500);
    end;

  end
  else
  begin
    Windows.FindClose(hFindFile);
    sFileName := IncludeTrailingPathDelimiter(sCurrPath) + sHookLib;
  end;

  //if Pos('.EXE', AnsiUpperCase(ParamStr(0))) = (Length(ParamStr(0)) - 3) then
  //  MessageBox(GetDesktopWindow, PChar(ParamStr(0)), nil, MB_OK or MB_ICONHAND);

  if (ParamCount >= 1) then
  begin
    //for i := 1 to ParamCount do
    //  MessageBox(GetDesktopWindow, PChar(ParamStr(i)), nil, MB_OK or MB_ICONHAND);

    for i := 1 to ParamCount do
    begin
      //if Pos('.EXE', AnsiUpperCase(ParamStr(i))) > 0 then
      if (Pos('.EXE', AnsiUpperCase(ParamStr(i))) = (Length(ParamStr(i)) - 3)) and (Length(sCmdExec) <= 0) then
        sCmdExec := ParamStr(i)
      else
      begin
        if Length(sCmdParam) > 0 then
          sCmdParam := sCmdParam + ' ' + ParamStr(i)
        else
          sCmdParam := ParamStr(i);
      end;

    {$IFDEF DEBUG}
      WriteDebugString('Param("' + ParamStr(i) + '" [' + IntToStr(i-1) + '])');
    {$ENDIF}
    end;

    //MessageBox(GetDesktopWindow, PChar(sCmdExec + #10 + sCmdParam), nil, MB_OK or MB_ICONHAND);

    if (Length(sCmdExec) > 0) then
    begin
      CreateProcessInternalEx(sCmdExec, ExtractFilePath(sCmdExec), sCmdParam, {0,} sFileName);
      Exit;
    end;
  end;

  //MessageBox(GetDesktopWindow, PChar(sCmdExec + #10 + sCmdParam), nil, MB_OK or MB_ICONHAND);

  hFindFile := Windows.FindFirstFileW(PWideChar(sExecFile), findExec);
  if (not (hFindFile = INVALID_HANDLE_VALUE)) then
  begin
    Windows.FindClose(hFindFile);
    CreateProcessInternalEx(IncludeTrailingPathDelimiter(sCurrPath) + sExecFile, IncludeTrailingPathDelimiter(sCurrPath), sCmdParam, {0,} sFileName);
    Exit;
  end;

  if GetOpenFile(GetDesktopWindow) then
    CreateProcessInternalEx(WideCharToString(OFNFileW), ExtractFilePath(WideCharToString(OFNFileW)), sCmdParam, {0,} sFileName);

end.
