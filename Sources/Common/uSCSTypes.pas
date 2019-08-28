unit uSCSTypes;

interface

uses
  System.SysUtils,
  SynCommons;

type
  TTrackerOperation = (Add, Update, Delete);

  TGPSTrackerType = (trtUndefined,
    trtTDC,
    trtTeltonika,
    trtRoadKey,
    trtGlobalSat,
    trtAndroid,
    trtCicada);

  TSID = packed record
  private
    FPrefix: string;
    FClientSID: string;
    FTrackerSID: string;
    function GetAsText: string;
    procedure SetAsText(const Value: string);
  public
    property AsText: string read GetAsText write SetAsText;
  end;

  ESIDConvertException = class(Exception)
  end;

  TAddTrackerParamsDTO = packed record
  private
    FTrackerSID: string;
    function GetTrackerSID: string;
  public
    Operation: TTrackerOperation;

    ClientName: string;               // Агро ЮГ1
    ClientSID: string;                // AgroSouth

    TrackerName: string;              // N123
    TrackerType: TGPSTrackerType;     // tdc, teltonika
    TrackerModel: string;             // TDC02, FMB125
    TrackerLogin: string;             // 357454071920571

    GPS, Ignition: Boolean;
    CAN300: Boolean;
    FLCount: Integer;

    DistanceTO: Boolean;
    DistanceTrip: Boolean;

    Location: Boolean;
    LocationFileName: string;

    function GetPass: string;
    function GetClientName: string;

    function GetFullTrackerSID: string;
    procedure SetFullTrackerSID(aFullSID: RawUTF8);

    procedure InitDef;

    property TrackerSID: string read GetTrackerSID write FTrackerSID;  // N123
  end;

  TTrackerSensorsRec = packed record
    GPS: Boolean;
    Ignition: Boolean;
    CAN300: Boolean;
    FLCount: Integer;
  end;



// functions
  function ExtractSID(aSID: string): string;



implementation

function ExtractSID(aSID: string): string;
begin
  Result := aSID;
  if Length(aSID) > 0 then
    if aSID[1] = '$' then
      Result := Copy(aSID, 2, Length(aSID) - 1);
end;


{ TTrackerParams }

function TAddTrackerParamsDTO.GetClientName: string;
begin
  if ClientName = '' then
    Result := ClientSID
  else
    Result := ClientName;
end;

function TAddTrackerParamsDTO.GetPass: string;
begin
  case TrackerType of
    trtUndefined, trtTeltonika, trtRoadKey, trtGlobalSat, trtCicada:
      Result := '';
    trtTDC:
      Result := '7';
    trtAndroid:
      Result := '20';
  end;
end;

function TAddTrackerParamsDTO.GetTrackerSID: string;
begin
  if FTrackerSID = '' then
    Result := TrackerName
  else
    Result := FTrackerSID;
end;

function TAddTrackerParamsDTO.GetFullTrackerSID: string;
begin
  if FTrackerSID = '' then
    Result := ClientSID + '.' + TrackerName
  else
    Result := ClientSID + '.' + FTrackerSID;
end;

procedure TAddTrackerParamsDTO.InitDef;
begin
  Operation := TTrackerOperation.Add;

  TrackerName := '';
  TrackerSID := '';
  TrackerType := trtUndefined;
  TrackerModel := '';
  ClientName := '';
  ClientSID := '';
  TrackerLogin := '';

  GPS := False;
  Ignition := False;
  CAN300 := False;
  FLCount := 0;

  DistanceTO := False;
  DistanceTrip := False;
end;

procedure TAddTrackerParamsDTO.SetFullTrackerSID(aFullSID: RawUTF8);
var
  s: string;
  p: Integer;
begin
  if Length(aFullSID) = 0 then
    Exit;

  if aFullSID[1] = '$' then
    s := Copy(aFullSID, 2, Length(aFullSID) - 1)
  else
    s := aFullSID;

  p := Pos('.', s);
  if p > 0 then
  begin
    ClientSID := Copy(s, 1, p - 1);
    TrackerSID := Copy(s, p + 1, Length(s) - p);
  end
  else
    TrackerSID := s;
end;

{ TSID }

function TSID.GetAsText: string;
begin
  if FPrefix <> '$' then          // числовая адресация : 625
    Result := FTrackerSID
  else if FClientSID = '' then    // трекер не использует родительский SID : $TrackerN125
    Result := FPrefix + FTrackerSID
  else                            // трекер использует родительский SID : $Client1.TrackerN125
    Result := FPrefix + FClientSID + '.' + FTrackerSID;
end;

procedure TSID.SetAsText(const Value: string);
var
  p: Integer;
  s: string;
  v: Integer;
begin
  if Length(Value) = 0 then
  begin
    FPrefix := '';
    FClientSID := '';
    FTrackerSID := '';
    Exit;
  end;

  if Value[1] = '$' then
  begin
    // значит это строковый адрес
    FPrefix := '$';
    s := Copy(Value, 2, Length(Value) - 1);
    p := Pos('.', s);
    if p > 0 then
    begin
      // $Client.Tracker
      FClientSID := Copy(s, 1, p - 1);
      FTrackerSID := Copy(s, p + 1, Length(s) - p);
    end
    else
    begin
      // $Tracker
      FClientSID := '';
      FTrackerSID := s;
    end;
  end
  else
  begin
    // это должно быть число (адерсация по ID)
    if TryStrToInt(Value, v) then
      s := Value
    else
      raise ESIDConvertException.CreateFmt('SID "%s" is not correct', [Value]);
  end;
end;

end.
