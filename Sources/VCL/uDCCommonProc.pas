unit uDCCommonProc;

interface

function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;

function GetSpecialPath(CSIDL: word): string;


implementation

uses
  Windows,
  Forms,
  SysUtils,
  ShellAPI,
  ShlObj;

function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..1024] of Char;
begin
  Result := ShellExecute(Application.Handle, nil,
    //Application.MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;

function GetSpecialPath(CSIDL: word): string;
var
  s:  string;
begin
  SetLength(s, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(s), CSIDL, true) then
    s := '';

  result := PChar(s);
end;


end.
