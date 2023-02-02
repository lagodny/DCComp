{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2013 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aOPCImage2In;

interface

uses Classes,
  aCustomOPCSource, aOPCDataObject, aOPCImage;

type
  TaOPCImage2In = class(TaOPCImage)
  private
    fDataLink2: TaOPCDataLink;
    fGraphicDataLink2: TaOPCGraphicDataLink;
    function GetPhysID2: TPhysID;
    procedure SetPhysID2(const Value: TPhysID);
    function GetDataLink2: TaCustomDataLink;
    function GetGraphicOPCSource2: TaCustomOPCDataObject;
    procedure SetGraphicOPCSource2(const Value: TaCustomOPCDataObject);
  protected
    procedure SetOPCSource(const Value: TaCustomOPCSource); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  public
    property DataLink2: TaCustomDataLink read GetDataLink2;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PhysID2: TPhysID read GetPhysID2 write SetPhysID2;
    property GraphicOPCSource2: TaCustomOPCDataObject read GetGraphicOPCSource2
      write SetGraphicOPCSource2;
  end;

implementation

{ TaOPCImage2In }

constructor TaOPCImage2In.Create(aOwner: TComponent);
begin
  inherited;
  FDataLink2 := TaOPCDataLink.Create(Self);
  FDataLink2.OnChangeData := ChangeData;
  FGraphicDataLink2 := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink2.OnChangeData := ChangeData;
end;

destructor TaOPCImage2In.Destroy;
begin
  GraphicOPCSource2 := nil;

  inherited;

  FGraphicDataLink2.Free;
  FDataLink2.Free;
end;

function TaOPCImage2In.GetDataLink2: TaCustomDataLink;
begin
  if GraphicOPCSource2 <> nil then
    Result := fGraphicDataLink2
  else
    Result := fDataLink2;

end;

function TaOPCImage2In.GetGraphicOPCSource2: TaCustomOPCDataObject;
begin
  Result := fGraphicDataLink2.OPCSource;
end;

function TaOPCImage2In.GetPhysID2: TPhysID;
begin
  Result := DataLink2.PhysID;
end;

function TaOPCImage2In.GetValue: string;
begin
  Result := DataLink.Value + DataLink2.Value;
end;

procedure TaOPCImage2In.SetGraphicOPCSource2(
  const Value: TaCustomOPCDataObject);
begin
  if fGraphicDataLink2.OPCSource <> Value then
    fGraphicDataLink2.OPCSource := Value;
  if Value <> nil then
    fDataLink2.OPCSource := nil;
end;

procedure TaOPCImage2In.SetOPCSource(const Value: TaCustomOPCSource);
begin
  inherited;
  if fDataLink2.OPCSource <> Value then
    fDataLink2.OPCSource := Value;
  if Value <> nil then
    fGraphicDataLink2.OPCSource := nil;

end;

procedure TaOPCImage2In.SetPhysID2(const Value: TPhysID);
begin
  fDataLink2.PhysID := Value;
end;

procedure TaOPCImage2In.SetValue(const Value: string);
begin
  DataLink.Value := Copy(Value, 1, 1);
  DataLink2.Value := Copy(Value, 2, 1);
end;


end.

