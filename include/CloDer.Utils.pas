unit CloDer.Utils;

interface

uses
  Windows;

  procedure DebugWarning;

  function ExtractResFile(BinResType, BinResName: string; ResFileName: string): boolean;
  function GetModuleFileNameAW(module: dword; path: boolean; fill: integer = 0) : string;
  function FileExistsEx(const FileName: string): Boolean;

implementation

procedure DebugWarning;
begin
  MessageBox(GetDesktopWindow, PChar('This version of "CloDer" is NOT for public use!'#10#10'To remove this warning please obtain the public copy.'), 'Warning', MB_OK or MB_ICONWARNING or MB_SYSTEMMODAL or MB_TOPMOST);
end;

function ExtractResFile(BinResType, BinResName: string; ResFileName: string): boolean;
var
  ResSize, HG, HI, SizeWritten, hFileWrite: Cardinal;
begin
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

function GetModuleFileNameAW(module: dword; path: boolean; fill: integer = 0) : string;
var
  arrChA : array [0..MAX_PATH] of char;
  arrChW : array [0..MAX_PATH] of wideChar;
  i1     : integer;
  i      : Integer;
begin
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
end;

function ValidFileHandle(Handle: THandle; FileAttributes: DWORD): Bool;
begin
  Result := False;
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
  Windows.FindClose(Handle);
end;

function FileExistsEx(const FileName: AnsiString): Boolean; overload;
var
  Handle: THandle;
  FindData: _WIN32_FIND_DATAA;
begin
  Handle := Windows.FindFirstFileA(PAnsiChar(AnsiString(FileName)), FindData);
  Result := ValidFileHandle(Handle, FindData.dwFileAttributes);
end;

function FileExistsEx(const FileName: WideString): Boolean; overload;
var
  Handle: THandle;
  FindData: _WIN32_FIND_DATAW;
begin
  Handle := Windows.FindFirstFileW(PWideChar(WideString(FileName)), FindData);
  Result := ValidFileHandle(Handle, FindData.dwFileAttributes);
end;

end.
