{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2010 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aOPCImage3In;

interface

uses Classes,
  aCustomOPCSource, aOPCDataObject, aOPCImage2In;

type
  TaOPCImage3In = class(TaOPCImage2In)
  private
    fDataLink3: TaOPCDataLink;
    fGraphicDataLink3: TaOPCGraphicDataLink;
    function GetPhysID3: TPhysID;
    procedure SetPhysID3(const Value: TPhysID);
    function GetDataLink3: TaCustomDataLink;
    function GetGraphicOPCSource3: TaCustomOPCDataObject;
    procedure SetGraphicOPCSource3(const Value: TaCustomOPCDataObject);
  protected
    procedure SetOPCSource(const Value: TaCustomOPCSource); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  public
    property DataLink3: TaCustomDataLink read GetDataLink3;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PhysID3: TPhysID read GetPhysID3 write SetPhysID3;
    property GraphicOPCSource3: TaCustomOPCDataObject read GetGraphicOPCSource3
      write SetGraphicOPCSource3;
  end;


implementation

{ TaOPCImage3In }

constructor TaOPCImage3In.Create(aOwner: TComponent);
begin
  inherited;
  FDataLink3 := TaOPCDataLink.Create(Self);
  FDataLink3.OnChangeData := ChangeData;
  FGraphicDataLink3 := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink3.OnChangeData := ChangeData;

end;

destructor TaOPCImage3In.Destroy;
begin
  GraphicOPCSource3 := nil;

  inherited;

  FGraphicDataLink3.Free;
  FDataLink3.Free;
end;

function TaOPCImage3In.GetDataLink3: TaCustomDataLink;
begin
  if GraphicOPCSource3 <> nil then
    Result := fGraphicDataLink3
  else
    Result := FDataLink3;
end;

function TaOPCImage3In.GetGraphicOPCSource3: TaCustomOPCDataObject;
begin
  Result := FGraphicDataLink3.OPCSource;
end;

function TaOPCImage3In.GetPhysID3: TPhysID;
begin
  Result := DataLink3.PhysID;
end;

function TaOPCImage3In.GetValue: string;
begin
  Result := inherited GetValue + DataLink3.Value;
end;

procedure TaOPCImage3In.SetGraphicOPCSource3(
  const Value: TaCustomOPCDataObject);
begin
  if FGraphicDataLink3.OPCSource <> Value then
    FGraphicDataLink3.OPCSource := Value;
  if Value <> nil then
    FDataLink3.OPCSource := nil;
end;

procedure TaOPCImage3In.SetOPCSource(const Value: TaCustomOPCSource);
begin
  inherited;
  if FDataLink3.OPCSource <> Value then
    FDataLink3.OPCSource := Value;
  if Value <> nil then
    FGraphicDataLink3.OPCSource := nil;
end;

procedure TaOPCImage3In.SetPhysID3(const Value: TPhysID);
begin
  FDataLink3.PhysID := Value;
end;

procedure TaOPCImage3In.SetValue(const Value: string);
begin
  inherited SetValue(Value);
  DataLink3.Value := Copy(Value, 3, 1);
end;

end.
