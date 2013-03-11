program CloDer;

{$DEFINE DEBUG}

uses
  uallHook,
  uallUtil,
  Windows,
  MiniCommDlg,
  CreateProcessInternalApi,
{$IFDEF DEBUG}
  DebugWriter,
{$ENDIF}
  CloDer.Common,
  CloDer.Utils;

{.$R manifest.res}
{$R 'manifest.res' 'manifest.rc'}

{.$R version.res}
{$R 'version.res' 'version.rc'}

{.$R icon.res}
{.$R 'icon.res' 'icon.rc'}

const
  VENDOR_STRING   : WideString = '1C:SoftClub';
  DEFAULT_FILENAME: WideString = 'Launcher.exe';

var
  sHookLib: string = 'CloDer.dll';

type
  TDialogFileName = array [0..MAX_PATH] of WideChar;

function CreateProcessInternalEx(AppFileName, AppRunPath, Parameters: string; {BitMask: Integer;} hookAssembly: string): Longword;
label
  lRetry;
var
  zAppName   : array[0..512] of Char;
  zAppHook   : array[0..512] of Char;
  zCurDir    : array[0..255] of Char;

  zArguments : PAnsiChar;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
{$IFDEF DEBUG}
  WriteDebugString('CreateProcess()');
  WriteDebugString('Launcher("' + AppFileName + '")');
  WriteDebugString('Path("' + AppRunPath + '")');
  WriteDebugString('Parameters("' + Parameters + '")');
  WriteDebugString('HookLib("' + hookAssembly + '")');

  WriteDebugString('FindLauncher("' + AppFileName + '")');
{$ENDIF}

  if not FileExistsEx(AppFileName) then
  begin
    MessageBox(GetDesktopWindow, PChar('Unable to locate the the specified executable.'#10#10'Executable: "' + AppFileName + '".'#10#10'Please ensure that your parameters are correct.'), nil, MB_OK or MB_ICONHAND);
    Exit;
  end;

  StrPCopy(zAppName, AppFileName);
  StrPCopy(zAppHook, hookAssembly);

  StrPCopy(zCurDir, AppRunPath);
  zArguments := PChar(' ' + Parameters);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_NORMAL;

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
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;

end;

function GetDialogFileName(): TDialogFileName;// PWideChar;
var
  i       : integer;
begin
  FillMemory(@Result, SizeOf(Result), 0);

  if GetVersion and $80000000 = 0 then
    for i := 0 to Length(DEFAULT_FILENAME) do
      Result[i] := WideChar(DEFAULT_FILENAME[i+1]);
end;

function GetOpenFile(ParentWnd: dword; out fileName: TDialogFileName) : Boolean;
var
  oFileNameW : TOpenFilenameW;
begin
  Result := False;

  try
    if GetVersion and $80000000 = 0 then
    begin
      ZeroMemory(@oFileNameW, sizeOf(oFileNameW));

      fileName := GetDialogFileName();

      oFileNameW.lStructSize  := SizeOf(TOpenFilenameW);// 19 * 4;
      oFileNameW.hWndOwner    := ParentWnd;
      oFileNameW.lpstrFilter  := PWideChar(VENDOR_STRING + ' ' + DEFAULT_FILENAME + #0 + DEFAULT_FILENAME + #0 + 'All Executable Files (*.exe)' + #0'*.exe'#0);// '1C:SoftClub Launcher.exe'#0'Launcher.exe'#0;
      oFileNameW.nFilterIndex := 1;
      oFileNameW.lpstrFile    := fileName;//dialogFileName;
      oFileNameW.nMaxFile     := MAX_PATH;
      oFileNameW.lpstrTitle   := nil;
      oFileNameW.Flags        := OFN_ENABLESIZING or OFN_FILEMUSTEXIST {or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT};
      Result := GetOpenFileNameW(oFileNameW);
    end;
  finally

  end;

end;

procedure ExecOpenFileDialog(parameters: string; hookAssembly: string);
var
  fileName: TDialogFileName;
begin
  if GetOpenFile(GetDesktopWindow, fileName) then
    CreateProcessInternalEx(WideCharToString(fileName), ExtractFilePath(WideCharToString(fileName)), parameters, hookAssembly);
end;

var
  i        : Integer;
  aTempPath: array[0..MAX_PATH-1] of Char;
  sTempPath: string;
  hookLibrary: string;

  aCurrPath: array[0..MAX_PATH-1] of Char;
  sCurrPath: string;

  sCmdExec : string;
  sCmdParam: string;
begin
{$IFDEF DEBUG}
  DebugWarning;
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

  hookLibrary := sHookLib;
  GetTempPath(SizeOf(aTempPath), aTempPath);
  sTempPath := IncludeTrailingPathDelimiter(AnsiString(aTempPath));
  hookLibrary := sTempPath + hookLibrary;
{$IFDEF DEBUG}
  WriteDebugString('TempFile("' + hookLibrary + '")');
{$ENDIF}

{$IFDEF DEBUG}
  WriteDebugString('FindHookLib("' + sCurrPath + sHookLib + '")');
{$ENDIF}

  if not FileExistsEx(sCurrPath + sHookLib) then
  begin
    if not ExtractResFile('DLL', 'HOOK', hookLibrary) then
    begin
    {$IFDEF DEBUG}
      WriteDebugString('ExtractResFile("Failed!")');
    {$ENDIF}
      hookLibrary := IncludeTrailingPathDelimiter(sCurrPath) + sHookLib;

      {$IFDEF DEBUG}
        WriteDebugString('FindHookLib("' + hookLibrary + '")');
      {$ENDIF}

      if not FileExistsEx(hookLibrary) then
      begin
        MessageBox(GetDesktopWindow, PChar('Unable to locate the the required hook library.'#10#10'Library: "' + hookLibrary + '".'), nil, MB_OK or MB_ICONHAND);
        {$IFDEF DEBUG}
          WriteDebugString('Terminate()');
        {$ENDIF}
        Exit;
      end;

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
    hookLibrary := IncludeTrailingPathDelimiter(sCurrPath) + sHookLib;
  end;

  if (ParamCount >= 1) then
  begin

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

    if (Length(sCmdExec) > 0) then
    begin
      CreateProcessInternalEx(sCmdExec, ExtractFilePath(sCmdExec), sCmdParam, {0,} hookLibrary);
      Exit;
    end;

  end;

  //Local "Launcher.exe" file
  if FileExistsEx(DEFAULT_FILENAME) then
  begin
    CreateProcessInternalEx(IncludeTrailingPathDelimiter(sCurrPath) + DEFAULT_FILENAME, IncludeTrailingPathDelimiter(sCurrPath), sCmdParam, {0,} hookLibrary);
    Exit;
  end;

  //Browse for "Launcher.exe"
  ExecOpenFileDialog(sCmdParam, hookLibrary);

end.
