unit aOPCTCPSource_V33;

interface

uses
  Classes,
  aOPCTCPSource_V30,
  uSCSTypes;

type
  TaOPCTCPSource_V33 = class(TaOPCTCPSource_V30)
  public
    constructor Create(aOwner: TComponent); override;

    function CreateClient(aClientID: Integer): Integer;
    function CreateTracker(aClientID: Integer; const aTrackerSID, aTrackerLogin,
  aProtoSID: string; aInherit: Boolean): Integer;
    procedure AddOrUpdateSCSTracker(aParams: TAddTrackerParamsDTO);
    procedure DeleteSCSTracker(aSID: string);
  end;


implementation

uses
  System.SysUtils,
  SynCommons;

{ TaOPCTCPSource_V33 }

procedure TaOPCTCPSource_V33.AddOrUpdateSCSTracker(aParams: TAddTrackerParamsDTO);
var
  s: string;
begin
  //s :=  U2S(RecordSaveJSON(aParams, TypeInfo(TAddTrackerParamsDTO)));
  s :=  UTF8DecodeToUnicodeString(RecordSaveJSON(aParams, TypeInfo(TAddTrackerParamsDTO)));
  LockAndDoCommandFmt('AddOrUpdateSCSTracker %s', [s]);
end;

constructor TaOPCTCPSource_V33.Create(aOwner: TComponent);
begin
  inherited;
  ProtocolVersion := 33;
end;

function TaOPCTCPSource_V33.CreateClient(aClientID: Integer): Integer;
begin
  Result := StrToInt(LockDoCommandReadLnFmt('CreateClient %d', [aClientID]));
end;

function TaOPCTCPSource_V33.CreateTracker(aClientID: Integer; const aTrackerSID, aTrackerLogin,
  aProtoSID: string; aInherit: Boolean): Integer;
begin
  Result := StrToInt(LockDoCommandReadLnFmt('CreateTracker %d;%s;%s;%s;%s',
    [aClientID, aTrackerSID, aTrackerLogin, aProtoSID, BoolToStr(aInherit, False)]));
end;

procedure TaOPCTCPSource_V33.DeleteSCSTracker(aSID: string);
begin
  LockAndDoCommandFmt('DeleteSCSTracker %s', [aSID]);
end;

end.
