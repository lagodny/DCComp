unit uCommandLine;

interface

uses
  Classes, SysUtils;

const
  sCommandLineUser = 'USER';
  sCommandLinePassword = 'PASSWORD';
  sCommandLineProject = 'PROJECT';
  sCommandLineCommandFile = 'COMMANDFILE';
  sCommandLineSingleInstance = 'SINGLEINSTANCE';



function CommandLineStrings: TStringList;

implementation

var
  FCommandLineStrings: TStringList;

function CommandLineStrings: TStringList;
var
  i: integer;
  str: string;
  p: integer;
  Name, Value: string;
begin
  if not Assigned(FCommandLineStrings) then
  begin
    FCommandLineStrings := TStringList.Create;
    for i := 1 to ParamCount do
    begin
      str := ParamStr(i);
      p := Pos('=', str);
      if p > 0 then
      begin
        Name := UpperCase(Copy(str, 1, p-1));
        Value := Copy(str, p+1, Length(str) - p);
        FCommandLineStrings.Add(Name + '=' + Value);
      end
      else
        FCommandLineStrings.Add(ParamStr(i));
    end;
  end;

  Result := FCommandLineStrings;
end;

initialization
  FCommandLineStrings := nil;

finalization
  if Assigned(FCommandLineStrings) then
    FCommandLineStrings.Free;

end.
