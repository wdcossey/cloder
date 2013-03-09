unit CreateProcessInternalApi;

interface

uses Windows;

function CreateProcessInternal(hToken: THANDLE; lpApplicationName: PAnsiChar; lpCommandLine: PAnsiChar; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PAnsiChar; const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation; hNewToken: PHANDLE): BOOL; stdcall;

function CreateProcessInternalA(hToken: THANDLE; lpApplicationName: PAnsiChar; lpCommandLine: PAnsiChar; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PAnsiChar; const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation; hNewToken: PHANDLE): BOOL; stdcall;

{function CreateProcessInternalW(lpApplicationName: PWideChar; lpCommandLine: PWideChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;}

implementation

  function CreateProcessInternal; external 'kernel32.dll' name 'CreateProcessInternalA';
  function CreateProcessInternalA; external 'kernel32.dll' name 'CreateProcessInternalA';
  //function CreateProcessInternalW; external 'kernel32.dll' name 'CreateProcessInternalW';

end.

