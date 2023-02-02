unit aOPCImage5In;

interface

uses Classes,
  aCustomOPCSource, aOPCDataObject, aOPCImage4In;

type
  TaOPCImage5In = class(TaOPCImage4In)
  private
    FDataLink5: TaOPCDataLink;
    FGraphicDataLink5: TaOPCGraphicDataLink;
    function GetPhysID5: TPhysID;
    procedure SetPhysID5(const Value: TPhysID);
    function GetDataLink5: TaCustomDataLink;
    function GetGraphicOPCSource5: TaCustomOPCDataObject;
    procedure SetGraphicOPCSource5(const Value: TaCustomOPCDataObject);
  protected
    procedure SetOPCSource(const Value: TaCustomOPCSource); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  public
    property DataLink5: TaCustomDataLink read GetDataLink5;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PhysID5: TPhysID read GetPhysID5 write SetPhysID5;
    property GraphicOPCSource5: TaCustomOPCDataObject read GetGraphicOPCSource5
      write SetGraphicOPCSource5;
  end;


implementation

{ TaOPCImage5In }

constructor TaOPCImage5In.Create(aOwner: TComponent);
begin
  inherited;
  FDataLink5 := TaOPCDataLink.Create(Self);
  FDataLink5.OnChangeData := ChangeData;
  FGraphicDataLink5 := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink5.OnChangeData := ChangeData;
end;

destructor TaOPCImage5In.Destroy;
begin
  GraphicOPCSource5 := nil;

  inherited;

  FGraphicDataLink5.Free;
  FDataLink5.Free;
end;

function TaOPCImage5In.GetDataLink5: TaCustomDataLink;
begin
  if GraphicOPCSource5 <> nil then
    Result := FGraphicDataLink5
  else
    Result := FDataLink5;
end;

function TaOPCImage5In.GetGraphicOPCSource5: TaCustomOPCDataObject;
begin
  Result := FGraphicDataLink5.OPCSource;
end;

function TaOPCImage5In.GetPhysID5: TPhysID;
begin
  Result := DataLink5.PhysID;
end;

function TaOPCImage5In.GetValue: string;
begin
  Result := inherited GetValue + DataLink5.Value;
end;

procedure TaOPCImage5In.SetGraphicOPCSource5(
  const Value: TaCustomOPCDataObject);
begin
  if FGraphicDataLink5.OPCSource <> Value then
    FGraphicDataLink5.OPCSource := Value;
  if Value <> nil then
    FDataLink5.OPCSource := nil;
end;

procedure TaOPCImage5In.SetOPCSource(const Value: TaCustomOPCSource);
begin
  inherited;
  if FDataLink5.OPCSource <> Value then
    FDataLink5.OPCSource := Value;
  if Value <> nil then
    FGraphicDataLink5.OPCSource := nil;
end;

procedure TaOPCImage5In.SetPhysID5(const Value: TPhysID);
begin
  FDataLink5.PhysID := Value;
end;

procedure TaOPCImage5In.SetValue(const Value: string);
begin
  inherited SetValue(Value);
  DataLink5.Value := Copy(Value, 5, 1);
end;

end.
