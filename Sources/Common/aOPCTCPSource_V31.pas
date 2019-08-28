unit aOPCTCPSource_V31;

interface

uses
  Classes, SysUtils,
  aOPCSource, aOPCTCPSource_V30,
  uDCObjects, uUserMessage, aCustomOPCSource, aCustomOPCTCPSource;

type
  TaOPCTCPSource_V31 = class(TaOPCTCPSource_V30)
  public
    constructor Create(aOwner: TComponent); override;

    function GetCards: string;
    procedure AddCard(aCardNo: string);
    procedure DelCard(aCardNo: string);
    procedure AddSum(aCardNo: string; aSum: Double);

  end;


implementation

{ TaOPCTCPSource_V31 }

procedure TaOPCTCPSource_V31.AddCard(aCardNo: string);
begin
  LockAndDoCommandFmt('AddCard %s', [aCardNo]);
end;

procedure TaOPCTCPSource_V31.AddSum(aCardNo: string; aSum: Double);
begin
  LockAndDoCommandFmt('AddSum %s;%s', [aCardNo, FloatToStr(aSum, OpcFS)]);
end;

constructor TaOPCTCPSource_V31.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  ProtocolVersion := 31;
end;

procedure TaOPCTCPSource_V31.DelCard(aCardNo: string);
begin
  LockAndDoCommandFmt('DelCard %s', [aCardNo]);
end;

function TaOPCTCPSource_V31.GetCards: string;
begin
  Result := LockAndGetStringsCommand('GetCards');
end;

end.
