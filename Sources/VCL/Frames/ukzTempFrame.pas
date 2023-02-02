unit ukzTempFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  aOPCDataObject, uDCObjects,
  uOPCFrame,
  aCustomOPCSource, aOPCSource,
  aOPCShape, aOPCLabel;

type
  TkzTemp = class(TaOPCFrame)
    aOPCShape1: TaOPCShape;
    t1: TaOPCLabel;
    l1: TaOPCLabel;
    c1: TaOPCLabel;
    t2: TaOPCLabel;
    l2: TaOPCLabel;
    c2: TaOPCLabel;
    l3: TaOPCLabel;
    t3: TaOPCLabel;
    c3: TaOPCLabel;
    l4: TaOPCLabel;
    t4: TaOPCLabel;
    c4: TaOPCLabel;
    l5: TaOPCLabel;
    t5: TaOPCLabel;
    c5: TaOPCLabel;
    l6: TaOPCLabel;
    t6: TaOPCLabel;
    c6: TaOPCLabel;
    l7: TaOPCLabel;
    t7: TaOPCLabel;
    c7: TaOPCLabel;
    l8: TaOPCLabel;
    t8: TaOPCLabel;
    c8: TaOPCLabel;
    lCaption: TaOPCLabel;
    procedure t1DrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean);
  private
    FT1ID: string;
    FT2ID: string;
    FT3ID: string;
    FT6ID: string;
    FT7ID: string;
    FT4ID: string;
    FT5ID: string;
    FT8ID: string;
    FErrorBrushColor: TColor;
    FErrorFontColor: TColor;
    FOnClickLabel: TNotifyEvent;
    FOnDrawLabel: TaOPCOnDrawLabelEvent;
    function GetTempGroupName: string;
    procedure SetTempGroupName(const Value: string);
    procedure SetT1ID(const Value: string);
    procedure SetT2ID(const Value: string);
    procedure SetT3ID(const Value: string);
    procedure SetT4ID(const Value: string);
    procedure SetT5ID(const Value: string);
    procedure SetT6ID(const Value: string);
    procedure SetT7ID(const Value: string);
    procedure SetT8ID(const Value: string);
    procedure SetErrorBrushColor(const Value: TColor);
    procedure SetErrorFontColor(const Value: TColor);
    procedure SetOnClickLabel(const Value: TNotifyEvent);
    procedure SetOnDrawLabel(const Value: TaOPCOnDrawLabelEvent);

  protected
    procedure Loaded; override;

    procedure ClearIDs; override;

    procedure SetID(const Value: TPhysID); override;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); override;
    function GetOPCSource: TaCustomMultiOPCSource; override;
  public
    procedure LocalInit(aId: integer; aOPCObjects: TDCObjectList); override;
    procedure UpdateControls;
  published
    property TempGroupName: string read GetTempGroupName write SetTempGroupName;
    property T1ID: string read FT1ID write SetT1ID;
    property T2ID: string read FT2ID write SetT2ID;
    property T3ID: string read FT3ID write SetT3ID;
    property T4ID: string read FT4ID write SetT4ID;
    property T5ID: string read FT5ID write SetT5ID;
    property T6ID: string read FT6ID write SetT6ID;
    property T7ID: string read FT7ID write SetT7ID;
    property T8ID: string read FT8ID write SetT8ID;

    property ErrorBrushColor: TColor read FErrorBrushColor write SetErrorBrushColor;
    property ErrorFontColor: TColor read FErrorFontColor write SetErrorFontColor;

    property OnDrawLabel: TaOPCOnDrawLabelEvent read FOnDrawLabel write SetOnDrawLabel;
    property OnClickLabel: TNotifyEvent read FOnClickLabel write SetOnClickLabel;

  end;

implementation

uses
  DC.StrUtils;

{$R *.dfm}

{ TkzTemp }

procedure TkzTemp.ClearIDs;
begin
  T1ID := '';
  T2ID := '';
  T3ID := '';
  T4ID := '';
  T5ID := '';
  T6ID := '';
  T7ID := '';
  T8ID := '';
end;

function TkzTemp.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := t1.OPCSource as TaCustomMultiOPCSource;
end;


function TkzTemp.GetTempGroupName: string;
begin
  Result := lCaption.Caption;
end;

procedure TkzTemp.Loaded;
begin
  inherited;
  UpdateControls;
end;

procedure TkzTemp.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
var
  i: Integer;
  aOPCObject: TDCObject;
  ObjectName: string;
  id : string;
  aNumber: string;
begin
  ClearIDs;

  aOPCObject := aOPCObjects.FindObjectByID(aId);
  if not Assigned(aOPCObject) then
    exit;

  TempGroupName := aOPCObject.Name;
  for i := 0 to aOPCObject.Childs.Count - 1 do
  begin
    if Assigned(aOPCObject.Childs[i]) and (aOPCObject.Childs[i] is TDCObject) then
    begin
      ObjectName := TDCObject(aOPCObject.Childs[i]).Name;
      id         := TDCObject(aOPCObject.Childs[i]).IdStr;

      aNumber := Copy(ObjectName, 1, 1);
      if aNumber = '1' then
        T1ID   := id
      else if aNumber = '2' then
        T2ID   := id
      else if aNumber = '3' then
        T3ID   := id
      else if aNumber = '4' then
        T4ID   := id
      else if aNumber = '5' then
        T5ID   := id
      else if aNumber = '6' then
        T6ID   := id
      else if aNumber = '7' then
        T7ID   := id
      else if aNumber = '8' then
        T8ID   := id
      ;
    end;
  end;
  FID := IntToStr(aId);
  UpdateControls;

end;

procedure TkzTemp.SetErrorBrushColor(const Value: TColor);
begin
  FErrorBrushColor := Value;
end;

procedure TkzTemp.SetErrorFontColor(const Value: TColor);
begin
  FErrorFontColor := Value;
end;

procedure TkzTemp.SetID(const Value: TPhysID);
var
  aOPCSource: TaOPCSource;
  ALevel, i: Integer;
  CurrStr : string;
  ObjectName : string;
  Data: TStrings;
  aNumber: string;
begin
  if (FID = Value) or
    (not Assigned(OPCSource)) or
    (not (OPCSource is TaOPCSource)) then
    Exit;

  ClearIDs;

  aOPCSource := TaOPCSource(OPCSource);
  FID := Value;
  aOPCSource.FNameSpaceCash.Clear;
  aOPCSource.FNameSpaceTimeStamp := 0;
  aOPCSource.GetNameSpace(Value);
  for i := 0 to aOPCSource.FNameSpaceCash.Count - 1 do
  begin
    CurrStr := GetBufStart(PChar(aOPCSource.FNameSpaceCash[i]), ALevel);
    ObjectName := ExtractData(CurrStr);

    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if FID = Data.Strings[0] then
        TempGroupName := ObjectName;

      if Data.Strings[1] = '1' then
        Continue; // это не датчик

      aNumber := Copy(ObjectName, 1, 1);
      if aNumber = '1' then
        T1ID   := Data.Strings[0]
      else if aNumber = '2' then
        T2ID   := Data.Strings[0]
      else if aNumber = '3' then
        T3ID   := Data.Strings[0]
      else if aNumber = '4' then
        T4ID   := Data.Strings[0]
      else if aNumber = '5' then
        T5ID   := Data.Strings[0]
      else if aNumber = '6' then
        T6ID   := Data.Strings[0]
      else if aNumber = '7' then
        T7ID   := Data.Strings[0]
      else if aNumber = '8' then
        T8ID   := Data.Strings[0]
      ;
    finally
      FreeAndNil(Data);
    end;
  end;
  UpdateControls;
end;

procedure TkzTemp.SetOnClickLabel(const Value: TNotifyEvent);
var
  i: Integer;
  aLabel: TaCustomOPCLabel;
begin
  FOnClickLabel := Value;

  t1.OnClick := Value;
  t2.OnClick := Value;
  t3.OnClick := Value;
  t4.OnClick := Value;
  t5.OnClick := Value;
  t6.OnClick := Value;
  t7.OnClick := Value;
  t8.OnClick := Value;

  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i] is TaCustomOPCLabel then
    begin
      aLabel := TaCustomOPCLabel(Controls[i]);
      if Assigned(aLabel.OnClick) and (aLabel.PhysID <> '') then
        TaCustomOPCLabel(Controls[i]).Cursor := crHandPoint;
    end;
  end;

end;

procedure TkzTemp.SetOnDrawLabel(const Value: TaOPCOnDrawLabelEvent);
begin
  FOnDrawLabel := Value;

  t1.OnDrawLabel := Value;
  t2.OnDrawLabel := Value;
  t3.OnDrawLabel := Value;
  t4.OnDrawLabel := Value;
  t5.OnDrawLabel := Value;
  t6.OnDrawLabel := Value;
  t7.OnDrawLabel := Value;
  t8.OnDrawLabel := Value;
end;

procedure TkzTemp.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin
  t1.OPCSource := Value;
  t2.OPCSource := Value;
  t3.OPCSource := Value;
  t4.OPCSource := Value;
  t5.OPCSource := Value;
  t6.OPCSource := Value;
  t7.OPCSource := Value;
  t8.OPCSource := Value;
end;

procedure TkzTemp.SetT1ID(const Value: string);
begin
  FT1ID := Value;
  t1.PhysID := Value;
end;

procedure TkzTemp.SetT2ID(const Value: string);
begin
  FT2ID := Value;
  t2.PhysID := Value;
end;

procedure TkzTemp.SetT3ID(const Value: string);
begin
  FT3ID := Value;
  t3.PhysID := Value;
end;

procedure TkzTemp.SetT4ID(const Value: string);
begin
  FT4ID := Value;
  t4.PhysID := Value;
end;

procedure TkzTemp.SetT5ID(const Value: string);
begin
  FT5ID := Value;
  t5.PhysID := Value;
end;

procedure TkzTemp.SetT6ID(const Value: string);
begin
  FT6ID := Value;
  t6.PhysID := Value;
end;

procedure TkzTemp.SetT7ID(const Value: string);
begin
  FT7ID := Value;
  t7.PhysID := Value;
end;

procedure TkzTemp.SetT8ID(const Value: string);
begin
  FT8ID := Value;
  t8.PhysID := Value;
end;

procedure TkzTemp.SetTempGroupName(const Value: string);
begin
  lCaption.Caption := Value;
end;

procedure TkzTemp.t1DrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean);
begin
  aHandled := False;
  if not (Sender is TaOPCLabel) then
    Exit;

  if TaOPCLabel(Sender).ErrorCode = 0 then
    Exit;

  aCanvas.Brush.Color := ErrorBrushColor;  // clYellow;
  aCanvas.Font.Style := aCanvas.Font.Style + [fsStrikeOut];
  aCanvas.Font.Color := ErrorFontColor;

end;

procedure TkzTemp.UpdateControls;
//var
//  i: Integer;
//  aLabel: TaCustomOPCLabel;
begin
  l1.Visible := FT1ID <> '';
  t1.Visible := FT1ID <> '';
  c1.Visible := FT1ID <> '';
  l1.Caption := IntToStr(l1.Tag) + TempGroupName;
  t1.Params.Text := 'serie=' + l1.Caption + ',°C';

  l2.Visible := FT2ID <> '';
  t2.Visible := FT2ID <> '';
  c2.Visible := FT2ID <> '';
  l2.Caption := IntToStr(l2.Tag) + TempGroupName;
  t2.Params.Text := 'serie=' + l2.Caption + ',°C';

  l3.Visible := FT3ID <> '';
  t3.Visible := FT3ID <> '';
  c3.Visible := FT3ID <> '';
  l3.Caption := IntToStr(l3.Tag) + TempGroupName;
  t3.Params.Text := 'serie=' + l3.Caption + ',°C';


  l4.Visible := FT4ID <> '';
  t4.Visible := FT4ID <> '';
  c4.Visible := FT4ID <> '';
  l4.Caption := IntToStr(l4.Tag) + TempGroupName;
  t4.Params.Text := 'serie=' + l4.Caption + ',°C';

  l5.Visible := FT5ID <> '';
  t5.Visible := FT5ID <> '';
  c5.Visible := FT5ID <> '';
  l5.Caption := IntToStr(l5.Tag) + TempGroupName;
  t5.Params.Text := 'serie=' + l5.Caption + ',°C';

  l6.Visible := FT6ID <> '';
  t6.Visible := FT6ID <> '';
  c6.Visible := FT6ID <> '';
  l6.Caption := IntToStr(l6.Tag) + TempGroupName;
  t6.Params.Text := 'serie=' + l6.Caption + ',°C';

  l7.Visible := FT7ID <> '';
  t7.Visible := FT7ID <> '';
  c7.Visible := FT7ID <> '';
  l7.Caption := IntToStr(l7.Tag) + TempGroupName;
  t7.Params.Text := 'serie=' + l7.Caption + ',°C';

  l8.Visible := FT8ID <> '';
  t8.Visible := FT8ID <> '';
  c8.Visible := FT8ID <> '';
  l8.Caption := IntToStr(l8.Tag) + TempGroupName;
  t8.Params.Text := 'serie=' + l8.Caption + ',°C';

end;

end.
