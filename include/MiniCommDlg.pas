unit MiniCommDlg;

{$WEAKPACKAGEUNIT}

{$HPPEMIT '#include <commdlg.h>'}

interface

uses Windows;

type
  POpenFilenameA = ^TOpenFilenameA;
  POpenFilenameW = ^TOpenFilenameW;
  POpenFilename = POpenFilenameA;
  {$EXTERNALSYM tagOFNA}
  tagOFNA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  {$EXTERNALSYM tagOFNW}
  tagOFNW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PWideChar;
    lpstrCustomFilter: PWideChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PWideChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PWideChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PWideChar;
    lpstrTitle: PWideChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PWideChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PWideChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  {$EXTERNALSYM tagOFN}
  tagOFN = tagOFNA;
  TOpenFilenameA = tagOFNA;
  TOpenFilenameW = tagOFNW;
  TOpenFilename = TOpenFilenameA;
  {$EXTERNALSYM OPENFILENAMEA}
  OPENFILENAMEA = tagOFNA;
  {$EXTERNALSYM OPENFILENAMEW}
  OPENFILENAMEW = tagOFNW;
  {$EXTERNALSYM OPENFILENAME}
  OPENFILENAME = OPENFILENAMEA;

{$EXTERNALSYM GetOpenFileName}
function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall;
{$EXTERNALSYM GetOpenFileNameA}
function GetOpenFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
{$EXTERNALSYM GetOpenFileNameW}
function GetOpenFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;
{$EXTERNALSYM GetSaveFileName}
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall;
{$EXTERNALSYM GetSaveFileNameA}
function GetSaveFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
{$EXTERNALSYM GetSaveFileNameW}
function GetSaveFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;

const
  {$EXTERNALSYM OFN_READONLY}
  OFN_READONLY = $00000001;
  {$EXTERNALSYM OFN_OVERWRITEPROMPT}
  OFN_OVERWRITEPROMPT = $00000002;
  {$EXTERNALSYM OFN_HIDEREADONLY}
  OFN_HIDEREADONLY = $00000004;
  {$EXTERNALSYM OFN_NOCHANGEDIR}
  OFN_NOCHANGEDIR = $00000008;
  {$EXTERNALSYM OFN_SHOWHELP}
  OFN_SHOWHELP = $00000010;
  {$EXTERNALSYM OFN_ENABLEHOOK}
  OFN_ENABLEHOOK = $00000020;
  {$EXTERNALSYM OFN_ENABLETEMPLATE}
  OFN_ENABLETEMPLATE = $00000040;
  {$EXTERNALSYM OFN_ENABLETEMPLATEHANDLE}
  OFN_ENABLETEMPLATEHANDLE = $00000080;
  {$EXTERNALSYM OFN_NOVALIDATE}
  OFN_NOVALIDATE = $00000100;
  {$EXTERNALSYM OFN_ALLOWMULTISELECT}
  OFN_ALLOWMULTISELECT = $00000200;
  {$EXTERNALSYM OFN_EXTENSIONDIFFERENT}
  OFN_EXTENSIONDIFFERENT = $00000400;
  {$EXTERNALSYM OFN_PATHMUSTEXIST}
  OFN_PATHMUSTEXIST = $00000800;
  {$EXTERNALSYM OFN_FILEMUSTEXIST}
  OFN_FILEMUSTEXIST = $00001000;
  {$EXTERNALSYM OFN_CREATEPROMPT}
  OFN_CREATEPROMPT = $00002000;
  {$EXTERNALSYM OFN_SHAREAWARE}
  OFN_SHAREAWARE = $00004000;
  {$EXTERNALSYM OFN_NOREADONLYRETURN}
  OFN_NOREADONLYRETURN = $00008000;
  {$EXTERNALSYM OFN_NOTESTFILECREATE}
  OFN_NOTESTFILECREATE = $00010000;
  {$EXTERNALSYM OFN_NONETWORKBUTTON}
  OFN_NONETWORKBUTTON = $00020000;
  {$EXTERNALSYM OFN_NOLONGNAMES}
  OFN_NOLONGNAMES = $00040000;
  {$EXTERNALSYM OFN_EXPLORER}
  OFN_EXPLORER = $00080000;
  {$EXTERNALSYM OFN_NODEREFERENCELINKS}
  OFN_NODEREFERENCELINKS = $00100000;
  {$EXTERNALSYM OFN_LONGNAMES}
  OFN_LONGNAMES = $00200000;
  {$EXTERNALSYM OFN_ENABLEINCLUDENOTIFY}
  OFN_ENABLEINCLUDENOTIFY = $00400000;
  {$EXTERNALSYM OFN_ENABLESIZING}
  OFN_ENABLESIZING = $00800000;
  { #if (_WIN32_WINNT >= 0x0500) }
  {$EXTERNALSYM OFN_DONTADDTORECENT}
  OFN_DONTADDTORECENT = $02000000;
  {$EXTERNALSYM OFN_FORCESHOWHIDDEN}
  OFN_FORCESHOWHIDDEN = $10000000;    // Show All files including System and hidden files
  { #endif // (_WIN32_WINNT >= 0x0500) }

  { FlagsEx Values }
  { #if (_WIN32_WINNT >= 0x0500) }
  {$EXTERNALSYM OFN_EX_NOPLACESBAR}
  OFN_EX_NOPLACESBAR = $00000001;
  { #endif // (_WIN32_WINNT >= 0x0500) }

{ Return values for the registered message sent to the hook function
  when a sharing violation occurs.  OFN_SHAREFALLTHROUGH allows the
  filename to be accepted, OFN_SHARENOWARN rejects the name but puts
  up no warning (returned when the app has already put up a warning
  message), and OFN_SHAREWARN puts up the default warning message
  for sharing violations.

  Note:  Undefined return values map to OFN_SHAREWARN, but are
         reserved for future use. }

  {$EXTERNALSYM OFN_SHAREFALLTHROUGH}
  OFN_SHAREFALLTHROUGH = 2;
  {$EXTERNALSYM OFN_SHARENOWARN}
  OFN_SHARENOWARN = 1;
  {$EXTERNALSYM OFN_SHAREWARN}
  OFN_SHAREWARN = 0;

implementation

const
  commdlg32 = 'comdlg32.dll';

function GetOpenFileName;      external commdlg32  name 'GetOpenFileNameA';
function GetOpenFileNameA;      external commdlg32  name 'GetOpenFileNameA';
function GetOpenFileNameW;      external commdlg32  name 'GetOpenFileNameW';
function GetSaveFileName;   external commdlg32  name 'GetSaveFileNameA';
function GetSaveFileNameA;   external commdlg32  name 'GetSaveFileNameA';
function GetSaveFileNameW;   external commdlg32  name 'GetSaveFileNameW';
end.

