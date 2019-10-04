unit uMemIniFileEx;

interface

uses
  Classes, IniFiles, SysUtils;

type
  TMemIniFileEx = class (TMemIniFile)
  private
    FReadFormatSettings: TFormatSettings;
    FWriteFormatSettings: TFormatSettings;
  public
    constructor Create(const FileName: string);
    constructor CreateFromStream(aStream: TStream);
    constructor CreateFromText(aText: string);

    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;

    procedure AddStrings(aStrings: TStrings);
  end;

implementation

{ TMemIniFileEx }

procedure TMemIniFileEx.AddStrings(aStrings: TStrings);
var
  s: TStrings;
begin
  s := TStringList.Create;
  try
    GetStrings(s);
    s.AddStrings(aStrings);
    SetStrings(s);
  finally
    s.Free;
  end;
end;

constructor TMemIniFileEx.Create(const FileName: string);
begin
  inherited Create(FileName);
  //GetLocaleFormatSettings(0,
  FReadFormatSettings := FormatSettings;
  FReadFormatSettings.DecimalSeparator := '.';
  FReadFormatSettings.DateSeparator := '.';
  FReadFormatSettings.TimeSeparator := ':';

  FWriteFormatSettings := FReadFormatSettings;
{
  GetLocaleFormatSettings(0, FWriteFormatSettings);
  FWriteFormatSettings.DecimalSeparator := FReadFormatSettings.DecimalSeparator;
  FReadFormatSettings.DateSeparator := FReadFormatSettings.DateSeparator;
  FReadFormatSettings.TimeSeparator := FReadFormatSettings.TimeSeparator;
}
end;

constructor TMemIniFileEx.CreateFromStream(aStream: TStream);
var
  List: TStringList;
begin
  Create('');

  List := TStringList.Create;
  try
    List.LoadFromStream(aStream);
    SetStrings(List);
  finally
    List.Free;
  end;
end;

constructor TMemIniFileEx.CreateFromText(aText: string);
var
  List: TStringList;
begin
  Create('');

  List := TStringList.Create;
  try
    List.Text := aText;
    SetStrings(List);
  finally
    List.Free;
  end;
end;

function TMemIniFileEx.ReadFloat(const Section, Name: string;
  Default: Double): Double;
var
  FloatStr: string;
begin
  FloatStr := ReadString(Section, Name, '');
  Result := Default;
  if FloatStr <> '' then
  try
    Result := StrToFloat(FloatStr, FReadFormatSettings);
  except
    on EConvertError do
    begin
      try
        // меняем разделитель целой и дробной части на другой
        if FReadFormatSettings.DecimalSeparator = '.' then
          FReadFormatSettings.DecimalSeparator := ','
        else
          FReadFormatSettings.DecimalSeparator := '.';
        // и повторяем попытку
        Result := StrToFloat(FloatStr, FReadFormatSettings);
      except
        on EConvertError do
          // Ignore EConvertError exceptions
        else
          raise;
      end;
    end
    else
      raise;
  end;
end;

procedure TMemIniFileEx.WriteFloat(const Section, Name: string; Value: Double);
begin
  // используем свои параметры для преобразования числа в строку
  WriteString(Section, Name, FloatToStr(Value, FWriteFormatSettings));
end;


end.
