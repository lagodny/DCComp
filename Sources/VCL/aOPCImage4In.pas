unit aOPCImage4In;

interface

uses Classes,
  aCustomOPCSource, aOPCDataObject, aOPCImage3In;

type
  TaOPCImage4In = class(TaOPCImage3In)
  private
    FDataLink4: TaOPCDataLink;
    FGraphicDataLink4: TaOPCGraphicDataLink;
    function GetPhysID4: TPhysID;
    procedure SetPhysID4(const Value: TPhysID);
    function GetDataLink4: TaCustomDataLink;
    function GetGraphicOPCSource4: TaCustomOPCDataObject;
    procedure SetGraphicOPCSource4(const Value: TaCustomOPCDataObject);
  protected
    procedure SetOPCSource(const Value: TaCustomOPCSource); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  public
    property DataLink4: TaCustomDataLink read GetDataLink4;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PhysID4: TPhysID read GetPhysID4 write SetPhysID4;
    property GraphicOPCSource4: TaCustomOPCDataObject read GetGraphicOPCSource4
      write SetGraphicOPCSource4;
  end;


implementation

{ TaOPCImage4In }

constructor TaOPCImage4In.Create(aOwner: TComponent);
begin
  inherited;
  FDataLink4 := TaOPCDataLink.Create(Self);
  FDataLink4.OnChangeData := ChangeData;
  FGraphicDataLink4 := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink4.OnChangeData := ChangeData;
end;

destructor TaOPCImage4In.Destroy;
begin
  GraphicOPCSource4 := nil;

  inherited;

  FGraphicDataLink4.Free;
  FDataLink4.Free;
end;

function TaOPCImage4In.GetDataLink4: TaCustomDataLink;
begin
  if GraphicOPCSource4 <> nil then
    Result := FGraphicDataLink4
  else
    Result := FDataLink4;
end;

function TaOPCImage4In.GetGraphicOPCSource4: TaCustomOPCDataObject;
begin
  Result := FGraphicDataLink4.OPCSource;
end;

function TaOPCImage4In.GetPhysID4: TPhysID;
begin
  Result := DataLink4.PhysID;
end;

function TaOPCImage4In.GetValue: string;
begin
  Result := inherited GetValue + DataLink4.Value;
end;

procedure TaOPCImage4In.SetGraphicOPCSource4(
  const Value: TaCustomOPCDataObject);
begin
  if FGraphicDataLink4.OPCSource <> Value then
    FGraphicDataLink4.OPCSource := Value;
  if Value <> nil then
    FDataLink4.OPCSource := nil;
end;

procedure TaOPCImage4In.SetOPCSource(const Value: TaCustomOPCSource);
begin
  inherited;
  if FDataLink4.OPCSource <> Value then
    FDataLink4.OPCSource := Value;
  if Value <> nil then
    FGraphicDataLink4.OPCSource := nil;
end;

procedure TaOPCImage4In.SetPhysID4(const Value: TPhysID);
begin
  FDataLink4.PhysID := Value;
end;

procedure TaOPCImage4In.SetValue(const Value: string);
begin
  inherited SetValue(Value);
  DataLink4.Value := Copy(Value, 4, 1);
end;

end.
