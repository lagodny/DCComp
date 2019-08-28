{*******************************************************}
{                                                       }
{     –абота со строками                                }
{     Copyright (c) 2001-2019 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit uStrFunc;

interface

uses
  Classes, SysUtils, DB;

function DC_StrToAnsi(const aStr: string): AnsiString;
function DC_AnsiToStr(const aStr: AnsiString): string;
function DC_BufToStr(const aBuffer; const aCount: Integer): string;
function DC_BufToAnsi(const aBuffer; const aCount: Integer): AnsiString;
//function StrToAnsi(aStr: string): AnsiString;

procedure MoveBytes2ToBytes1(var aBytes1: TBytes; const aBytes2: TBytes);
procedure AddBytes2ToBytes1(var aBytes1: TBytes; const aBytes2: TBytes);
function BytesEqual(aBytes1, aBytes2: TBytes): Boolean;
function Bytes(const A: array of Byte): TBytes;


function BytesToHexStr(const aBytes: TBytes; const aDelimiter: string = ' '): string;
function HexStrToBytes(const aHexStr: string; const aDelimiter: string = ' '): TBytes;
function XORBytes(const aBytes: TBytes): Byte;

function IndexOfBytes(const aSignature: TBytes; const aData: TBytes): Integer;

function BytesToStr(const aBytes: TBytes): string;


//function BytesToPrintableStr(aBytes: TBytes): string;
//function PrintableStrToBytes(aStr: string): TBytes;

function HexToAnsiStr(const Hex: string; const aDelimiter: string): AnsiString;
function AnsiStrToHex(const Str: AnsiString; const aDelimiter: string): string;

function StrToHex(const aStr: AnsiString; const aDelimiter: string = ' '): string;
function HexToStr(Hex: string; const aDelimiter: string = ' '): string;
function XORStr(Str: string): byte;

function EncodeStr(const aStr: string): string;
function DecodeStr(const aStr: string): string;
//
function ConvertStrToBin(const S: string): string;
function ConvertBinToStr(const S: string): string;

function RemoveNonprintingSymbols(const S: string): string;
function RemoveBadSymbols(const S: string): string;

procedure ParseCommandParams(const AUnparsedStr: string; AStrings: TStrings; const ADelim: string;
  const ATrim: Boolean; const AAllowEmpty: Boolean);

procedure SetFieldFromStr(aField: TField; aEncoded: Boolean; const aStr: string);

function ExtendedToStrLocal(Value: Extended; const AFormatSettings: TFormatSettings): string; //overload; inline;
function DC_ExtendedToStr(Value: Extended): string; //overload;



implementation

uses
  IdGlobal;

function IndexOfBytes(const aSignature: TBytes; const aData: TBytes): Integer;
var
  i, L: Integer;
begin
  Result := -1;
  if Length(aSignature) = 0 then
    Exit;

  i := 0;
  L := Length(aData) - Length(aSignature);
  while i <= L do
  begin
    if aData[i] = aSignature[0] then
    begin
      if CompareMem(@aData[i], @aSignature[0], Length(aSignature)) then
        Exit(i);
    end;
    Inc(i);
  end;
end;


function ExtendedToStrLocal(Value: Extended; const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..63] of Char;
begin
  try
    SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended, ffGeneral, 20, 0, AFormatSettings));
  except
    Result := '0';
  end;
end;

function DC_ExtendedToStr(Value: Extended): string;
begin
  Result := ExtendedToStrLocal(Value, FormatSettings);
end;


function DC_StrToAnsi(const aStr: string): AnsiString;
var
  i: Integer;
begin
  Result := '';
  SetLength(Result, Length(aStr));
  for i := 1 to Length(aStr) do
    Result[i] := AnsiChar(Byte(aStr[i]))
end;

function DC_AnsiToStr(const aStr: AnsiString): string;
var
  i: Integer;
begin
  Result := '';
  SetLength(Result, Length(aStr));
  for i := 1 to Length(aStr) do
    Result[i] := Char(Byte(aStr[i]))
end;

function DC_BufToStr(const aBuffer; const aCount: Integer): string;
var
  i: Integer;
begin
  SetLength(Result, aCount);
  for i := 1 to aCount do
    Result[i] := Char((PByte(@aBuffer) + i - 1)^);
end;

function DC_BufToAnsi(const aBuffer; const aCount: Integer): AnsiString;
var
  i: Integer;
begin
  SetLength(Result, aCount);
  for i := 1 to aCount do
    Result[i] := AnsiChar((PByte(@aBuffer) + i - 1)^);
end;


function HexToAnsiStr(const Hex: string; const aDelimiter: string): AnsiString;
var
  b: TBytes;
begin
  b := HexStrToBytes(Hex, aDelimiter);
  SetLength(Result, Length(b));
  Move(b[0], Result[1], Length(b));
end;

function AnsiStrToHex(const Str: AnsiString; const aDelimiter: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
    Result := Result + IntToHex(ord(str[i]), 2) + aDelimiter;
end;

procedure MoveBytes2ToBytes1(var aBytes1: TBytes; const aBytes2: TBytes);
var
  Len2: Integer;
begin
  Len2 := Length(aBytes2);
  SetLength(aBytes1, Len2);
  Move(aBytes2[0], aBytes1[0], Len2);
end;

procedure AddBytes2ToBytes1(var aBytes1: TBytes; const aBytes2: TBytes);
var
  Len1, Len2: Integer;
begin
  Len1 := Length(aBytes1);
  Len2 := Length(aBytes2);
  SetLength(aBytes1, Len1 + Len2);
  Move(aBytes2[0], aBytes1[Len1], Len2);
end;

function BytesEqual(aBytes1, aBytes2: TBytes): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Length(aBytes1) <> Length(aBytes2) then
    Exit;

  for i := 0 to Length(aBytes1) - 1 do
    if aBytes1[i] <> aBytes2[i] then
      Exit;

  Result := True;
end;

function Bytes(const A: array of Byte): TBytes;
var
  i: Integer;
begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := A[i];
end;

function BytesToHexStr(const aBytes: TBytes; const aDelimiter: string = ' '): string;
var
  i: Integer;
begin
  Result := '';
  if Length(aBytes) = 0 then
    Exit;

  Result := IntToHex(aBytes[0], 2);
  for i := Low(aBytes) + 1 to High(aBytes) do
    Result := Result + aDelimiter + IntToHex(aBytes[i], 2);
end;

function HexStrToBytes(const aHexStr: string; const aDelimiter: string = ' '): TBytes;
var
  i, p: Integer;
  L: Integer;
begin
  i := 0;
  p := 1;

  L := Length(aHexStr);
  SetLength(Result, L);

  while p <= L do
  begin
    // если нет разделител€ - то 2 символа на каждый байт
    if aDelimiter = '' then
    begin
      //Inc(p, 2)
    end
    // иначе ищем разделитель
    else
    begin
      while (p <= L) and (aHexStr[p] = aDelimiter) do
        Inc(p);
    end;

    if p > L then
      Break;

    Result[i] := Byte(StrToInt('$' + Copy(aHexStr, p, 2)));
    Inc(i);
    p := p + 2;
  end;
  SetLength(Result, i);
end;

function XORBytes(const aBytes: TBytes): Byte;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(aBytes) to High(aBytes) do
    Result := Result xor aBytes[i];
end;

function BytesToStr(const aBytes: TBytes): string;
var
  i: Integer;
begin
  Result := '';
  if Length(aBytes) = 0 then
    Exit;

  for i := Low(aBytes) to High(aBytes) do
    Result := Result + Chr(aBytes[i]);
end;

/// на входе внутреннее представление строки (D1 F2 F0 EE EA E0 0D 0A)
/// на выходе строка вида '—трока'#13#10
{function BytesToPrintableStr(aBytes: TBytes): string;
var
  L: integer;
  I, J: integer;
begin
  Result := '';
  L := Length(aBytes);
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

/// на входе строка вида '—трока'#13#10
/// на выходе внутреннее представление этой строки (D1 F2 F0 EE EA E0 0D 0A)
function PrintableStrToBytes(aStr: string): TBytes;
var
  L: integer;
  I, J: integer;
  r: RawByteString;
begin
  r := '';
  aStr := Trim(aStr);
  L := Length(aStr);
  if L = 0 then
    exit;

  I := 1;
  repeat
    if aStr[I] = '''' then
    begin
      J := I + 1;
      repeat
        Inc(I);
      until (I > L) or (aStr[I] = '''');
      r := r + Copy(aStr, J, I - J);
      Inc(I);
    end
    else if aStr[I] = '#' then
    begin
      J := I + 1;
      repeat
        Inc(I);
      until (I > L) or (aStr[I] = '''') or (aStr[I] = '#');
      r := r + Chr(StrToInt(Copy(aStr, J, I - J)));
    end
    else
      raise EConvertError.CreateFmt('Can not convert %s to bin', [S]);
  until I > L;
  Result := BytesOf(r);
end;
}

function EncodeStr(const aStr: string): string;
begin
  Result := StrToHex(AnsiString(aStr));
end;

function DecodeStr(const aStr: string): string;
begin
  Result := HexToStr(aStr);
end;



function StrToHex(const aStr: AnsiString; const aDelimiter: string): string;
var
  I: Integer;
  res: string;
begin
  res := '';
  for I := 1 to Length(aStr) do
  begin
    res := res + IntToHex(Byte(aStr[i]), 2) + aDelimiter;
  end;
  Result := res;
end;

function HexToStr(Hex: string; const aDelimiter: string): string;
//var
//  str: string;
//  p: Integer;
//  b: TBytes;
//  bCount: integer;
begin
//  Result := '';
//  SetLength(b, Length(Hex));
//  str := Trim(Hex);
//  bCount := 0;
//  while str <> '' do
//  begin
//    //Result := Result + Chr(StrToInt('$' + Copy(str, 1, 2)));
//    b[bCount] := StrToInt('$' + Copy(str, 1, 2));
//    inc(bCount);
//    p := 3;
//    while p <= Length(str) do
//    begin
//      if (str[p] <> aDelimiter) then
//        Break
//      else
//        Inc(p);
//    end;
//    str := Trim(Copy(str, p, length(str)));
//  end;
//  SetLength(b, bCount);

  Result := TEncoding.ANSI.GetString(HexStrToBytes(Hex, aDelimiter));
end;

function XORStr(Str: string): byte;
begin
  Result := XORBytes(BytesOf(Str));
end;


/// на входе строка вида '—трока'#13#10
/// на выходе внутреннее представление этой строки (D1 F2 F0 EE EA E0 0D 0A)

function ConvertStrToBin(const S: string): string;
var
  L: integer;
  I, J: integer;
begin
  Result := '';
  //S := Trim(S);
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
/// на выходе строка вида '—трока'#13#10

function ConvertBinToStr(const S: string): string;
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

function RemoveNonprintingSymbols(const S: string): string;
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


function RemoveBadSymbols(const S: string): string;
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


procedure ParseCommandParams(const AUnparsedStr: string; AStrings: TStrings; const ADelim: string;
  const ATrim: Boolean; const AAllowEmpty: Boolean);
var
  i: Integer;
  LDelim: Integer; //delim len
  LLeft: string;
  LLastPos: PtrInt;
begin
  Assert(Assigned(AStrings));
  AStrings.Clear;
  LDelim := Length(ADelim);
  LLastPos := 1;

  i := Pos(ADelim, AUnparsedStr);
  while I > 0 do begin
    LLeft := Copy(AUnparsedStr, LLastPos, I - LLastPos); //'abc d' len:=i(=4)-1    {Do not Localize}
    if ATrim then
      LLeft := Trim(LLeft);

    if (LLeft <> '') or AAllowEmpty then
      AStrings.AddObject(LLeft, TObject(NativeInt(LLastPos)));

    LLastPos := I + LDelim; //first char after Delim
    i := PosIdx(ADelim, AUnparsedStr, LLastPos);
  end;

  if LLastPos <= Length(AUnparsedStr) then
    AStrings.AddObject(Copy(AUnparsedStr, LLastPos, MaxInt), TObject(PtrInt(LLastPos)));
end;

procedure SetFieldFromStr(aField: TField; aEncoded: Boolean; const aStr: string);
var
  aVal: string;
begin
  if not Assigned(aField) then
    Exit;

  if aEncoded then
    aVal := DecodeStr(aStr)
  else
    aVal := aStr;

  if aField is TStringField then
    aField.AsString := Copy(aVal, 1, aField.Size)
  else if aField is TNumericField then
    aField.AsString := aVal;

end;

end.

