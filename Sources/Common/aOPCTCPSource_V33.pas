unit aOPCTCPSource_V33;

interface

//uses
//  Classes, SysUtils,
//  IdComponent,
//  uStrFunc,
//  aOPCSource, aOPCTCPSource_V30,
//  uDCObjects, uUserMessage, aCustomOPCSource, aCustomOPCTCPSource;

uses
  Classes,
  aOPCTCPSource_V30,
  uSCSTypes;

type
  TaOPCTCPSource_V33 = class(TaOPCTCPSource_V30)
  public
    constructor Create(aOwner: TComponent); override;

    procedure AddOrUpdateSCSTracker(aParams: TAddTrackerParamsDTO);
    procedure DeleteSCSTracker(aSID: string);
  end;


implementation

uses
  SynCommons;//, mORMoti18n;

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

procedure TaOPCTCPSource_V33.DeleteSCSTracker(aSID: string);
begin
  LockAndDoCommandFmt('DeleteSCSTracker %s', [aSID]);
end;

end.
