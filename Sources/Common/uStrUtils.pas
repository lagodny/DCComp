unit uStrUtils;

interface

function GetStrStart(str: string; var Level: Integer): string;
function GetBufStart(Buffer: PChar; var Level: Integer): PChar;
function ExtractData(var str:string):string;
function IsNumericDisplayFormat(aDisplayFormat: string):boolean;

implementation

uses
  System.SysUtils;

function GetStrStart(str: string; var Level: Integer): string;
var
  i: Integer;
begin
  Level := 0;
  i := Low(string);
  if Length(str) = 0 then
    Exit;

  while str[i] <> '@' do
    inc(i);

  Inc(i);
  while CharInSet(str[i], [' ', #9]) do
  begin
    Inc(i);
    Inc(Level);
  end;

  Result := str.Substring(i, str.Length);
end;

function GetBufStart(Buffer: PChar; var Level: Integer): PChar;
//var
//  Flag:boolean;
begin
  Level := 0;
  while Buffer^<>'@' do
    Inc(Buffer);

  Inc(Buffer);
  while Buffer^ in [' ', #9] do
  begin
    Inc(Buffer);
    Inc(Level);
  end;
  Result := Buffer;
end;

function ExtractData(var str:string):string;
const
  Delimiter = '@';
var
  p:integer;
begin
  p := str.IndexOf(Delimiter);// pos(Delimiter, str);
  if p = -1 then
  begin
    Result := str;
    str := '';
  end
  else
  begin
    Result := str.Substring(0, p);// copy(str,1,p-1);
    str := str.Substring(p + 1, str.Length); // copy(str,p+1,length(str));
  end;
end;

function IsNumericDisplayFormat(aDisplayFormat: string):boolean;
var
  i: integer;
  ch: Char;
begin
  Result := true;
  //for i := Low( to Length(aDisplayFormat) do
  for ch in aDisplayFormat do
  begin
    //if not (aDisplayFormat[i] in ['0'..'9','#','.',',',' ']) then
    if not CharInSet(ch, ['0'..'9','#','.',',',' ']) then
    begin
      Result := false;
      exit;
    end;
  end;

end;



end.
