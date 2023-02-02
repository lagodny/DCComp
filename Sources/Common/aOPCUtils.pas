unit aOPCUtils;

interface

uses
  SysUtils;

  function FormatValue(aValue:Extended; FormatString:string):string;
  function TryStrToFloat(aValue: string; OpcFS: TFormatSettings): extended;
  function TryStrToFloatDef(aValue: string; OpcFS: TFormatSettings; aDefault: extended = 0): extended;
  function RemoveNonNumbers(aStr: string): string;
  function DeltaTimeToHuman(aDelta: Double): string;

var
  dotFS: TFormatSettings;

implementation

uses
  aCustomOPCSource;

function DeltaTimeToHuman(aDelta: Double): string;
var
  hh,mm,ss, ms: Word;
begin
  Result := '';
  if aDelta >= 1 then
    Result := FormatFloat('# ##0.## д.', aDelta)
  else
  begin
    DecodeTime(aDelta, hh, mm, ss, ms);
    if hh > 0 then
      Result := Format('%dч %dм', [hh, mm])
    else if mm > 0 then
      Result := Format('%dм %dс', [mm, ss])
    else
      Result := Format('%dс', [ss])
  end;
end;



  function RemoveNonNumbers(aStr: string): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(aStr) do
      if CharInSet(aStr[i], ['.', ',', ' ', '#', '0'..'9']) then
        Result := Result + aStr[i];

    Result := Trim(Result);
  end;



  function FormatValue(aValue:Extended; FormatString:string):string;
  const
    cDividerSymbol = ';';
    cDateString = 'DATE';
  var
    aFormat    : string;
    aDividerPos: integer;
  begin
    if SameText(Copy(FormatString, 1, 4), cDateString) then
    begin
      // формат начинается с 'DATE'
      // FormatDateTime не умеет обрабатывать значения >0, =0, <0
      // сделаем это сами
      aFormat := Copy(FormatString, Length(cDateString)+1, length(FormatString));
      aDividerPos := Pos(cDividerSymbol, aFormat);
      if (aDividerPos > 0) then
      begin
        if aValue > 0 then
          aFormat := Copy(aFormat,1,aDividerPos-1)
        else
        begin
          aFormat := Copy(aFormat, aDividerPos+1, Length(aFormat) - aDividerPos);
          aDividerPos := Pos(cDividerSymbol, aFormat);
          if aDividerPos > 0 then
          begin
            if aValue = 0 then
              aFormat := Copy(aFormat,1,aDividerPos-1)
            else
              aFormat := Copy(aFormat, aDividerPos+1, Length(aFormat) - aDividerPos);
          end;
        end;
      end;
      Result := FormatDateTime(aFormat,aValue);
    end
    else
      Result := FormatFloat(FormatString,aValue);
  end;

  function TryStrToFloat(aValue: string; OpcFS: TFormatSettings): extended;
  begin
    if pos(FormatSettings.DecimalSeparator, aValue) > 0 then
      Result := StrToFloat(aValue)
    else
      Result := StrToFloat(aValue, OpcFS);
  end;

  function TryStrToFloatDef(aValue: string; OpcFS: TFormatSettings; aDefault: extended = 0): extended;
  begin
    if pos(FormatSettings.DecimalSeparator, aValue) > 0 then
      Result := StrToFloatDef(aValue, aDefault)
    else
      Result := StrToFloatDef(aValue, aDefault,OpcFS);
  end;

initialization
  dotFS := TFormatSettings.Create;
  dotFS.DecimalSeparator := '.';


end.
