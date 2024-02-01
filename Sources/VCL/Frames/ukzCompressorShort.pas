unit ukzCompressorShort;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs,
  aCustomOPCSource, aOPCSource, uDCObjects,
  aOPCImageList,
  uOPCFrame, aOPCImage, aOPCGauge, aOPCDataObject, aOPCLabel;

type
  TkzCompressorShort = class(TaOPCFrame)
    lName: TaOPCLabel;
    K_Perfomance: TaOPCGauge;
    K_DISH_P: TaOPCLabel;
    K_DISH_t: TaOPCLabel;
    K_DISH_t_Unit: TaOPCLabel;
    K_DISH_P_Unit: TaOPCLabel;
    K_SUCT_P: TaOPCLabel;
    K_SUCT_P_Unit: TaOPCLabel;
    K_SUCT_t_Unit: TaOPCLabel;
    K_SUCT_t: TaOPCLabel;
    K: TaOPCImage;
    K_Fon: TaOPCImage;
    K_OIL_T: TaOPCLabel;
    aOPCLabel2: TaOPCLabel;
    procedure KClick(Sender: TObject);
    procedure K_DISH_PDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean);
  private
    function GetImageList: TaOPCImageList;
    procedure SetImageList(const Value: TaOPCImageList);
    function GetCompressorName: string;
    function GetDISH_PID: string;
    function GetDISH_tID: string;
    function GetPerfomanceID: string;
    function GetSUCT_PID: string;
    function GetSUCT_tID: string;
    procedure SetCompressorName(const Value: string);
    procedure SetDISH_PID(const Value: string);
    procedure SetDISH_tID(const Value: string);
    procedure SetPerfomanceID(const Value: string);
    procedure SetSUCT_PID(const Value: string);
    procedure SetSUCT_tID(const Value: string);

    procedure UpdateControls;
    function GetK_ID: string;
    procedure SetK_ID(const Value: string);
    function GetOIL_tID: TPhysID;
    procedure SetOIL_tID(const Value: TPhysID);

  protected
    procedure ClearIDs; override;
    procedure SetID(const Value: TPhysID); override;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); override;
    function GetOPCSource: TaCustomMultiOPCSource; override;
  public
    procedure LocalInit(aId: integer; aOPCObjects: TDCObjectList); override;

  published
    property ImageList: TaOPCImageList read GetImageList write SetImageList;

    property CompressorName: string read GetCompressorName write SetCompressorName;
    property K_ID: string read GetK_ID write SetK_ID;
    property PerfomanceID: string read GetPerfomanceID write SetPerfomanceID;
    property DISH_PID: string read GetDISH_PID write SetDISH_PID;
    property DISH_tID: string read GetDISH_tID write SetDISH_tID;
    property SUCT_PID: string read GetSUCT_PID write SetSUCT_PID;
    property SUCT_tID: string read GetSUCT_tID write SetSUCT_tID;
    property OIL_tID: TPhysID read GetOIL_tID write SetOIL_tID;
  end;

implementation

uses
  aOPCConsts,
  DC.StrUtils;

{$R *.dfm}

{ TCompressorShortFrame }

procedure TkzCompressorShort.ClearIDs;
begin
  inherited;
  K.PhysID := '';
  K_Perfomance.PhysID := '';
  K_DISH_P.PhysID := '';
  K_DISH_t.PhysID := '';
  K_SUCT_P.PhysID := '';
  K_SUCT_t.PhysID := '';
  K_OIL_T.PhysID := '';
end;

function TkzCompressorShort.GetCompressorName: string;
begin
  Result := lName.Caption;
end;

function TkzCompressorShort.GetDISH_PID: string;
begin
  Result := K_DISH_P.PhysID;
end;

function TkzCompressorShort.GetDISH_tID: string;
begin
  Result := K_DISH_t.PhysID;
end;

function TkzCompressorShort.GetImageList: TaOPCImageList;
begin
  Result := K.OPCImageList;
end;

function TkzCompressorShort.GetK_ID: string;
begin
  Result := K.PhysID;
end;

function TkzCompressorShort.GetOIL_tID: TPhysID;
begin
  Result := K_OIL_T.PhysID;
end;

function TkzCompressorShort.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := TaCustomMultiOPCSource(k.OPCSource);
end;

function TkzCompressorShort.GetPerfomanceID: string;
begin
  Result := K_Perfomance.PhysID;
end;

function TkzCompressorShort.GetSUCT_PID: string;
begin
  Result := K_SUCT_P.PhysID;
end;

function TkzCompressorShort.GetSUCT_tID: string;
begin
  Result := K_SUCT_t.PhysID;
end;

procedure TkzCompressorShort.KClick(Sender: TObject);
begin
  inherited;
  if Assigned(OnClick) then
    OnClick(Sender);
  //ShowMessage('KClick');
end;

procedure TkzCompressorShort.K_DISH_PDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string;
  var aHandled: Boolean);
begin
  inherited;

  aHandled := False;
  if not (Sender is TaOPCLabel) then
    Exit;

  if TaOPCLabel(Sender).ErrorCode = 0 then
    Exit;

  aCanvas.Brush.Color := сOPCErrorBrushColor;  // clYellow;
  aCanvas.Font.Style := aCanvas.Font.Style + [fsStrikeOut];
  aCanvas.Font.Color := cOPCErrorFontColor;
end;

procedure TkzCompressorShort.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
var
  i, j: Integer;
  aOPCObject: TDCObject;
  ObjectName: string;
  id : string;
  aNumber: string;
begin
  ClearIDs;

  aOPCObject := aOPCObjects.FindObjectByID(aId);
  if not Assigned(aOPCObject) then
    exit;

  CompressorName := aOPCObject.Name;
  for i := 0 to aOPCObject.Childs.Count - 1 do
  begin
    if Assigned(aOPCObject.Childs[i]) and (aOPCObject.Childs[i] is TDCObject) then
    begin
      ObjectName := TDCObject(aOPCObject.Childs[i]).Name;
      id         := TDCObject(aOPCObject.Childs[i]).IdStr;

      if AnsiSameText(ObjectName, 'Всасывание') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          id         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Давление') then
            DISH_PID := id
          else if AnsiSameText(ObjectName, 'Температура пара') then
            DISH_tID := id
        end;
      end

      else if AnsiSameText(ObjectName, 'Нагнетание') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          id         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Давление всасывания') then
            SUCT_PID := id
          else if AnsiSameText(ObjectName, 'Перегрев всасываемого газа') then
            SUCT_tID := id
        end
      end

      else if AnsiSameText(ObjectName, 'Маслосистема') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          id         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Температура масла') then
            OIL_tID := id;
        end;
      end

      else if AnsiSameText(ObjectName, 'Производительность') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          id         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

//          if AnsiSameText(ObjectName, 'Позиция золотника производ.') then
//            PositionID := id
          if AnsiSameText(ObjectName, 'Производительность') then
            PerfomanceID := id
        end;
      end

      else if AnsiSameText(ObjectName, 'temp') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          id         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'COMP_MODE') then
            K_ID := id
        end;
      end;
    end;
  end;

  FID := IntToStr(aId);
  UpdateControls;

end;

procedure TkzCompressorShort.SetCompressorName(const Value: string);
begin
  lName.Caption := Value;
end;

procedure TkzCompressorShort.SetDISH_PID(const Value: string);
begin
  K_DISH_P.PhysID := Value;
end;

procedure TkzCompressorShort.SetDISH_tID(const Value: string);
begin
  K_DISH_t.PhysID := Value;
end;

procedure TkzCompressorShort.SetID(const Value: TPhysID);
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
      while CurrStr <> '' do
        Data.Add(ExtractData(CurrStr));

      if FID = Data.Strings[0] then
        CompressorName := ObjectName;

      if Data.Strings[1] = '1' then
        Continue; // это не датчик

      if AnsiSameText(ObjectName, 'Давление') then
        DISH_PID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'Температура пара') then
        DISH_tID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'Давление всасывания') then
        SUCT_PID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'Перегрев всасываемого газа') then
        SUCT_tID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'Температура масла') then
        OIL_tID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'Производительность') then
        PerfomanceID := Data.Strings[0]
      else if AnsiSameText(ObjectName, 'COMP_MODE') or AnsiSameText(ObjectName, 'OPERATE_STATUS') then
        K_ID := Data.Strings[0]
      ;
    finally
      FreeAndNil(Data);
    end;
  end;
  UpdateControls;
end;

procedure TkzCompressorShort.SetImageList(const Value: TaOPCImageList);
begin
  K.OPCImageList := Value;
  K_Fon.OPCImageList := Value;
end;

procedure TkzCompressorShort.SetK_ID(const Value: string);
begin
  K.PhysID := Value;
end;

procedure TkzCompressorShort.SetOIL_tID(const Value: TPhysID);
begin
  K_OIL_T.PhysID := Value;
end;

procedure TkzCompressorShort.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin
  K.OPCSource := Value;
  K_Perfomance.OPCSource := Value;
  K_DISH_P.OPCSource := Value;
  K_DISH_t.OPCSource := Value;
  K_SUCT_P.OPCSource := Value;
  K_SUCT_t.OPCSource := Value;
  K_OIL_T.OPCSource := Value;
end;

procedure TkzCompressorShort.SetPerfomanceID(const Value: string);
begin
  K_Perfomance.PhysID := Value;
end;

procedure TkzCompressorShort.SetSUCT_PID(const Value: string);
begin
  K_SUCT_P.PhysID := Value;
end;

procedure TkzCompressorShort.SetSUCT_tID(const Value: string);
begin
  K_SUCT_t.PhysID := Value;
end;

procedure TkzCompressorShort.UpdateControls;
begin

end;

end.
