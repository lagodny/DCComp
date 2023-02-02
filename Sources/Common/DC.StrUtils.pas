unit DC.StrUtils;

interface

function GetStrStart(str: string; var Level: Integer): string;
function GetBufStart(Buffer: PChar; var Level: Integer): PChar;
function ExtractData(var str:string):string;
function IsNumericDisplayFormat(aDisplayFormat: string):boolean;

function StrToHex(Str: string; aDelimiter: string = ' '): string; overload;
function StrToHex(Str: RawByteString; aDelimiter: string = ' '): string; overload;
function HexToStr(Hex: string; aDelimiter: string = ' '): string;
function XORStr(Str: string): byte;


function EncodeStr(aStr: string): string;
function DecodeStr(aStr: string): string;

function ConvertStrToBin(S: string): string;
function ConvertBinToStr(S: string): string;

function RemoveNonprintingSymbols(S: string): string;
function RemoveBadSymbols(S: string): string;


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
  while CharInSet(Buffer^, [' ', #9]) do
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
//  i: integer;
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


function EncodeStr(aStr: string): string;
begin
  Result := StrToHex(aStr);
end;

function DecodeStr(aStr: string): string;
begin
  Result := HexToStr(aStr);
end;


function StrToHex(Str: string; aDelimiter: string): string;
var
  i: Integer;
  b: TBytes;
begin
  Result := '';
  b := TEncoding.ANSI.GetBytes(Str);
  for I := 0 to Length(b) - 1 do
    Result := Result + IntToHex(b[i], 2) + aDelimiter;
end;

function StrToHex(Str: RawByteString; aDelimiter: string = ' '): string;
var
  i: Integer;
  b: TBytes;
begin
  Result := '';
  b := BytesOf(Str);
  for I := 0 to Length(b) - 1 do
    Result := Result + IntToHex(b[i], 2) + aDelimiter;
end;


function HexToStr(Hex: string; aDelimiter: string): string;
var
  str: string;
  a: String;
  p: Integer;
begin
  SetLength(a, 0);
  str := Trim(Hex);
  while str <> '' do
  begin
    a := a + Char(StrToInt('$' + Copy(str, 1, 2)));
    p := 3;
    while p <= Length(str) do
    begin
      if (str[p] <> aDelimiter) then
        Break
      else
        Inc(p);
    end;
    str := Trim(Copy(str, p, length(str)));
  end;
  Result := a;
end;

function XORStr(Str: string): byte;
var
  i: Integer;
  b: TBytes;
begin
  Result := 0;
  b := TEncoding.ANSI.GetBytes(Str);
  for i := 0 to Length(b) - 1 do
    Result := Result xor b[i];
end;

/// на входе строка вида 'Строка'#13#10
/// на выходе внутреннее представление этой строки (D1 F2 F0 EE EA E0 0D 0A)
function ConvertStrToBin(S: string): string;
var
  L: integer;
  I, J: integer;
begin
  Result := '';
  S := Trim(S);
  L := Length(S);
  if L = 0 then
    exit;

  I := 1;
  repeat
    if S[I] = '''' then
    begin
      J := I + 1;
      repeat
        Inc(I);
      until (I > L) or (S[I] = '''');
      Result := Result + Copy(S, J, I - J);
      Inc(I);
    end
    else if S[I] = '#' then
    begin
      J := I + 1;
      repeat
        Inc(I);
      until (I > L) or (S[I] = '''') or (S[I] = '#');
      Result := Result + Chr(StrToInt(Copy(S, J, I - J)));
    end
    else
      raise EConvertError.CreateFmt('Can not convert %s to bin', [S]);
  until I > L;
end;

/// на входе внутреннее представление строки (D1 F2 F0 EE EA E0 0D 0A)
/// на выходе строка вида 'Строка'#13#10
function ConvertBinToStr(S: string): string;
var
  L: integer;
  I, J: integer;
begin
  Result := '';
  L := Length(S);
  if L = 0 then
    Result := ''''''
  else
  begin
    I := 1;
    repeat
      if (S[I] >= ' ') and (S[I] <> '''') and (S[I] <> '=') then
      begin
        J := I;
        repeat
          Inc(I)
        until (I > L) or (S[I] < ' ') or (S[I] = '''') or (S[I] = '=');
        Result := Result + '''';
        Result := Result + Copy(S, J, I - J);
        Result := Result + '''';
      end
      else
      begin
        Result := Result + '#';
        Result := Result + (IntToStr(Ord(S[I])));
        Inc(I);
      end;
    until I > L;
  end;

end;

function RemoveNonprintingSymbols(S: string): string;
var
  L, I, J: integer;
begin
  Result := '';
  L := Length(S);
  if L = 0 then
    Result := ''
  else
  begin
    I := 1;
    repeat
      if (S[I] >= ' ') then
      begin
        J := I;
        repeat
          Inc(I)
        until (I > L) or (S[I] < ' ');
        Result := Result + Copy(S, J, I - J);
      end
      else
      begin
        Result := Result + ' ';
        Inc(I);
      end;
    until I > L;
  end;
end;


function RemoveBadSymbols(S: string): string;
const
  aBadSymbols = [#0..' ', '='];
var
  L, I, J: integer;
begin
  Result := '';
  L := Length(S);
  if L = 0 then
    Result := ''
  else
  begin
    I := 1;
    repeat
      if not CharInSet(S[I], aBadSymbols) then
      begin
        J := I;
        repeat
          Inc(I)
        until (I > L) or CharInSet(S[I], aBadSymbols);
        Result := Result + Copy(S, J, I - J);
      end
      else
      begin
        Result := Result + ' ';
        Inc(I);
      end;
    until I > L;
  end;
  Result := Trim(Result);
end;





end.
