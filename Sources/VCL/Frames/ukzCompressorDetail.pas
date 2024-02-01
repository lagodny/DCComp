unit ukzCompressorDetail;

interface

uses
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, //aOPCDataObject, aOPCImage, aOPCImageList,
  aCustomOPCSource,
  uOPCFrame, aOPCDataObject, uDCObjects, aOPCSource,
  aOPCImage, aOPCImageList, aOPCLabel, aOPCGauge, aOPCLookupList;

type
  TkzCompressorDetail = class(TaOPCFrame)
    aOPCImageList1: TaOPCImageList;
    aOPCImage1: TaOPCImage;
    aOPCLabel1: TaOPCLabel;
    lSUCT_Pressure: TaOPCLabel;
    aOPCLabel23: TaOPCLabel;
    aOPCLabel2: TaOPCLabel;
    aOPCLabel3: TaOPCLabel;
    lSUCT_PressureSAT: TaOPCLabel;
    aOPCLabel5: TaOPCLabel;
    aOPCLabel6: TaOPCLabel;
    lSUCT_GAS_TI: TaOPCLabel;
    aOPCLabel8: TaOPCLabel;
    aOPCLabel9: TaOPCLabel;
    lSUCT_GAS_S_HEAT: TaOPCLabel;
    aOPCLabel11: TaOPCLabel;
    aOPCLabel12: TaOPCLabel;
    aOPCLabel13: TaOPCLabel;
    lOIL_PRES: TaOPCLabel;
    aOPCLabel15: TaOPCLabel;
    aOPCLabel16: TaOPCLabel;
    lOIL_TEMP: TaOPCLabel;
    aOPCLabel18: TaOPCLabel;
    aOPCLabel19: TaOPCLabel;
    lOIL_FILT_DIF_PRES: TaOPCLabel;
    aOPCLabel21: TaOPCLabel;
    aOPCLabel22: TaOPCLabel;
    aOPCLabel24: TaOPCLabel;
    lMotorCurrent: TaOPCLabel;
    aOPCLabel26: TaOPCLabel;
    aOPCLabel27: TaOPCLabel;
    lTIMER_RUN_HOURS: TaOPCLabel;
    aOPCLabel29: TaOPCLabel;
    aOPCLabel30: TaOPCLabel;
    lCompCtrl: TaOPCLabel;
    aOPCLabel32: TaOPCLabel;
    lCompMode: TaOPCLabel;
    aOPCLabel34: TaOPCLabel;
    aOPCLabel35: TaOPCLabel;
    aOPCLabel36: TaOPCLabel;
    aOPCLabel37: TaOPCLabel;
    aOPCLabel38: TaOPCLabel;
    aOPCLabel39: TaOPCLabel;
    lSUCT_PressureSAT_SP: TaOPCLabel;
    aOPCLabel41: TaOPCLabel;
    aOPCLabel42: TaOPCLabel;
    aOPCLabel43: TaOPCLabel;
    aOPCLabel44: TaOPCLabel;
    aOPCLabel45: TaOPCLabel;
    lRassol: TaOPCLabel;
    aOPCLabel47: TaOPCLabel;
    aOPCLabel48: TaOPCLabel;
    aOPCLabel49: TaOPCLabel;
    lDISHPressure: TaOPCLabel;
    aOPCLabel51: TaOPCLabel;
    aOPCLabel52: TaOPCLabel;
    lDISHPressureSAT: TaOPCLabel;
    aOPCLabel54: TaOPCLabel;
    aOPCLabel55: TaOPCLabel;
    lDISH_t: TaOPCLabel;
    aOPCLabel57: TaOPCLabel;
    aOPCLabel58: TaOPCLabel;
    lDISH_t2: TaOPCLabel;
    aOPCLabel60: TaOPCLabel;
    aOPCLabel61: TaOPCLabel;
    aOPCLabel62: TaOPCLabel;
    gPerfomance: TaOPCGauge;
    aOPCLabel63: TaOPCLabel;
    gPosition: TaOPCGauge;
    aOPCLabel64: TaOPCLabel;
    aOPCLabel65: TaOPCLabel;
    lSystemNo: TaOPCLabel;
    CompMode: TaOPCImage;
    lCompressorName: TaOPCLabel;
    aOPCLabel7: TaOPCLabel;
    llCtrlMode: TaOPCLookupList;
    llStateMode: TaOPCLookupList;
    procedure lSUCT_PressureDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string;
      var aHandled: Boolean);
  private
    function GetCompCtrlID: string;
    function GetCompModeID: string;
    function GetDISH_t2ID: string;
    function GetDISH_tID: string;
    function GetDISHPressureID: string;
    function GetDISHPressureSATID: string;
    function GetMotorCurrentID: string;
    function GetOIL_FILT_DIF_PRESID: string;
    function GetOIL_PRESID: string;
    function GetOIL_TEMPID: string;
    function GetPerfomanceID: string;
    function GetPositionID: string;
    function GetRassolID: string;
    function GetSUCT_GAS_S_HEATID: string;
    function GetSUCT_GAS_TIID: string;
    function GetSUCT_PressureID: string;
    function GetSUCT_PressureSATID: string;
    function GetTIMER_RUN_HOURSID: string;
    procedure SetCompCtrlID(const Value: string);
    procedure SetCompModeID(const Value: string);
    procedure SetDISH_t2ID(const Value: string);
    procedure SetDISH_tID(const Value: string);
    procedure SetDISHPressureID(const Value: string);
    procedure SetDISHPressureSATID(const Value: string);
    procedure SetMotorCurrentID(const Value: string);
    procedure SetOIL_FILT_DIF_PRESID(const Value: string);
    procedure SetOIL_PRESID(const Value: string);
    procedure SetOIL_TEMPID(const Value: string);
    procedure SetPerfomanceID(const Value: string);
    procedure SetPositionID(const Value: string);
    procedure SetRassolID(const Value: string);
    procedure SetSUCT_GAS_S_HEATID(const Value: string);
    procedure SetSUCT_GAS_TIID(const Value: string);
    procedure SetSUCT_PressureID(const Value: string);
    procedure SetSUCT_PressureSATID(const Value: string);
    procedure SetTIMER_RUN_HOURSID(const Value: string);
    function GetCompName: string;
    procedure SetCompName(const Value: string);
    function GetSUCT_PressureSAT_SP_ID: string;
    procedure SetSUCT_PressureSAT_SP_ID(const Value: string);
    { Private declarations }
  protected
    procedure ClearIDs; override;
    procedure SetID(const Value: TPhysID); override;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); override;
    function GetOPCSource: TaCustomMultiOPCSource; override;

  public
    procedure LocalInit(aId: integer; aOPCObjects: TDCObjectList); override;
  published
    property SUCT_PressureID: string read GetSUCT_PressureID write SetSUCT_PressureID;
    property SUCT_PressureSATID: string  read GetSUCT_PressureSATID write SetSUCT_PressureSATID;
    property SUCT_PressureSAT_SP_ID: string  read GetSUCT_PressureSAT_SP_ID write SetSUCT_PressureSAT_SP_ID;
    property SUCT_GAS_TIID: string  read GetSUCT_GAS_TIID write SetSUCT_GAS_TIID;
    property SUCT_GAS_S_HEATID: string  read GetSUCT_GAS_S_HEATID write SetSUCT_GAS_S_HEATID;
    property OIL_PRESID: string  read GetOIL_PRESID write SetOIL_PRESID;
    property OIL_TEMPID: string  read GetOIL_TEMPID write SetOIL_TEMPID;
    property OIL_FILT_DIF_PRESID: string  read GetOIL_FILT_DIF_PRESID write SetOIL_FILT_DIF_PRESID;
    property MotorCurrentID: string  read GetMotorCurrentID write SetMotorCurrentID;
    property TIMER_RUN_HOURSID: string  read GetTIMER_RUN_HOURSID write SetTIMER_RUN_HOURSID;
    property CompCtrlID: string  read GetCompCtrlID write SetCompCtrlID;
    property CompModeID: string  read GetCompModeID write SetCompModeID;
    property RassolID: string  read GetRassolID write SetRassolID;
    property DISHPressureID: string  read GetDISHPressureID write SetDISHPressureID;
    property DISHPressureSATID: string  read GetDISHPressureSATID write SetDISHPressureSATID;
    property DISH_tID: string  read GetDISH_tID write SetDISH_tID;
    property DISH_t2ID: string  read GetDISH_t2ID write SetDISH_t2ID;
    property PerfomanceID: string  read GetPerfomanceID write SetPerfomanceID;
    property PositionID: string  read GetPositionID write SetPositionID;

    property CompressorName: string read GetCompName write SetCompName;
  end;

implementation

uses
  aOPCConsts,
  DC.StrUtils;

{$R *.dfm}

{ TkzCompressorDetail }

procedure TkzCompressorDetail.ClearIDs;
begin
{
  lSUCT_Pressure
  lSUCT_PressureSAT
  lSUCT_GAS_TI
  lSUCT_GAS_S_HEAT
  lOIL_PRES
  lOIL_TEMP
  lOIL_FILT_DIF_PRES
  lMotorCurrent
  lTIMER_RUN_HOURS
  lCompCtrl
  lCompMode
  lRassol
  lDISHPressure
  lDISHPressureSAT
  lDISH_t
  lDISH_t2
  gPerfomance
  gPosition
  CompMode
}
  lSUCT_Pressure.PhysID := '';
  lSUCT_PressureSAT.PhysID := '';
  lSUCT_GAS_TI.PhysID := '';
  lSUCT_GAS_S_HEAT.PhysID := '';
  lOIL_PRES.PhysID := '';
  lOIL_TEMP.PhysID := '';
  lOIL_FILT_DIF_PRES.PhysID := '';
  lMotorCurrent.PhysID := '';
  lTIMER_RUN_HOURS.PhysID := '';
  lCompCtrl.PhysID := '';
  lCompMode.PhysID := '';
  lRassol.PhysID := '';
  lDISHPressure.PhysID := '';
  lDISHPressureSAT.PhysID := '';
  lDISH_t.PhysID := '';
  lDISH_t2.PhysID := '';
  gPerfomance.PhysID := '';
  gPosition.PhysID := '';
  CompMode.PhysID := '';
  lSUCT_PressureSAT_SP.PhysID := '';

  lSUCT_Pressure.Value := '';
  lSUCT_PressureSAT.Value := '';
  lSUCT_GAS_TI.Value := '';
  lSUCT_GAS_S_HEAT.Value := '';
  lOIL_PRES.Value := '';
  lOIL_TEMP.Value := '';
  lOIL_FILT_DIF_PRES.Value := '';
  lMotorCurrent.Value := '';
  lTIMER_RUN_HOURS.Value := '';
  lCompCtrl.Value := '';
  lCompMode.Value := '';
  lRassol.Value := '';
  lDISHPressure.Value := '';
  lDISHPressureSAT.Value := '';
  lDISH_t.Value := '';
  lDISH_t2.Value := '';
  gPerfomance.Value := '';
  gPosition.Value := '';
  CompMode.Value := '1';
  lSUCT_PressureSAT_SP.Value := '';

end;

function TkzCompressorDetail.GetCompCtrlID: string;
begin
  Result := lCompCtrl.PhysID;
end;

function TkzCompressorDetail.GetCompModeID: string;
begin
  Result := lCompMode.PhysID;
end;

function TkzCompressorDetail.GetCompName: string;
begin
  Result := lCompressorName.Value;
end;

function TkzCompressorDetail.GetDISHPressureID: string;
begin
  Result := lDISHPressure.PhysID;
end;

function TkzCompressorDetail.GetDISHPressureSATID: string;
begin
  Result := lDISHPressureSAT.PhysID;
end;

function TkzCompressorDetail.GetDISH_t2ID: string;
begin
  Result := lDISH_t2.PhysID;
end;

function TkzCompressorDetail.GetDISH_tID: string;
begin
  Result := lDISH_t.PhysID;
end;

function TkzCompressorDetail.GetMotorCurrentID: string;
begin
  Result := lMotorCurrent.PhysID;
end;

function TkzCompressorDetail.GetOIL_FILT_DIF_PRESID: string;
begin
  Result := lOIL_FILT_DIF_PRES.PhysID;
end;

function TkzCompressorDetail.GetOIL_PRESID: string;
begin
  Result := lOIL_PRES.PhysID;
end;

function TkzCompressorDetail.GetOIL_TEMPID: string;
begin
  Result := lOIL_TEMP.PhysID;
end;

function TkzCompressorDetail.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := TaCustomMultiOPCSource(lSUCT_Pressure.OPCSource);
end;

function TkzCompressorDetail.GetPerfomanceID: string;
begin
  Result := gPerfomance.PhysID;
end;

function TkzCompressorDetail.GetPositionID: string;
begin
  Result := gPosition.PhysID;
end;

function TkzCompressorDetail.GetRassolID: string;
begin
  Result := lRassol.PhysID;
end;

function TkzCompressorDetail.GetSUCT_GAS_S_HEATID: string;
begin
  Result := lSUCT_GAS_S_HEAT.PhysID;
end;

function TkzCompressorDetail.GetSUCT_GAS_TIID: string;
begin
  Result := lSUCT_GAS_TI.PhysID;
end;

function TkzCompressorDetail.GetSUCT_PressureID: string;
begin
  Result := lSUCT_Pressure.PhysID;
end;

function TkzCompressorDetail.GetSUCT_PressureSATID: string;
begin
  Result := lSUCT_PressureSAT.PhysID;
end;

function TkzCompressorDetail.GetSUCT_PressureSAT_SP_ID: string;
begin
  Result := lSUCT_PressureSAT_SP.PhysID;
end;

function TkzCompressorDetail.GetTIMER_RUN_HOURSID: string;
begin
  Result := lTIMER_RUN_HOURS.PhysID;
end;

procedure TkzCompressorDetail.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
var
  i, j: Integer;
  aOPCObject: TDCObject;
  ObjectName: string;
  aSensorID : string;
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
      aSensorID         := TDCObject(aOPCObject.Childs[i]).IdStr;

      if AnsiSameText(ObjectName, 'Нагнетание') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Давление') then
            DISHPressureID := aSensorID
          else if AnsiSameText(ObjectName, 'Температура пара') then
            DISH_tID := aSensorID
          else if AnsiSameText(ObjectName, 'Давление 2 (SAT)') then
            DISHPressureSATID := aSensorID
          else if AnsiSameText(ObjectName, 'Перегрев пара') then
            DISH_t2ID := aSensorID
        end;
      end

      else if AnsiSameText(ObjectName, 'Всасывание') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Давление всасывания') then
            SUCT_PressureID := aSensorID
          else if AnsiSameText(ObjectName, 'Перегрев всасываемого газа') then
            SUCT_GAS_TIID := aSensorID
          else if AnsiSameText(ObjectName, 'Давление на всасывании (SAT)') then
            SUCT_PressureSATID := aSensorID
          else if AnsiSameText(ObjectName, 'Перегрев при всасывании') then
            SUCT_GAS_S_HEATID := aSensorID
          else if AnsiSameText(ObjectName, 'Реальная уставка (SAT)') then
            SUCT_PressureSAT_SP_ID := aSensorID
        end
      end

      else if AnsiSameText(ObjectName, 'Производительность') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Позиция золотника производ.') then
            PositionID := aSensorID
          else if AnsiSameText(ObjectName, 'Производительность') then
//          else if AnsiSameText(ObjectName, 'Продуктивность') then
            PerfomanceID := aSensorID
        end;
      end

//      else if AnsiSameText(ObjectName, 'temp') then
//      begin
//        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
//        begin
//          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
//          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;
//
//          if AnsiSameText(ObjectName, 'COMP_MODE') then
//            CompModeID := aSensorID
//          else if AnsiSameText(ObjectName, 'CTRL_MODE') then
//            CompCtrlID := aSensorID
//        end;
//      end

      else if AnsiSameText(ObjectName, 'Статус') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'OPERATE_STATUS') then
            CompModeID := aSensorID
          else if AnsiSameText(ObjectName, 'OPERATE_MULTISAB_STATUS') then
            CompCtrlID := aSensorID
        end;
      end

      else if AnsiSameText(ObjectName, 'Рассол') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Температура') then
            RassolID := aSensorID
        end;
      end

      else if AnsiSameText(ObjectName, 'Двигатель') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Ток двигателя') then
            MotorCurrentID := aSensorID
          else if AnsiSameText(ObjectName, 'Часы наработки') then
            TIMER_RUN_HOURSID := aSensorID
        end;
      end

      else if AnsiSameText(ObjectName, 'Маслосистема') then
      begin
        for j := 0 to TDCObject(aOPCObject.Childs[i]).Childs.Count - 1 do
        begin
          ObjectName := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).Name;
          aSensorID         := TDCObject(TDCObject(aOPCObject.Childs[i]).Childs[j]).IdStr;

          if AnsiSameText(ObjectName, 'Перепад давления на масл. фильтре') then
            OIL_FILT_DIF_PRESID := aSensorID
          else if AnsiSameText(ObjectName, 'Давление масла') then
            OIL_PRESID := aSensorID
          else if AnsiSameText(ObjectName, 'Температура масла') then
            OIL_TEMPID := aSensorID
        end;
      end;
    end;
  end;

  FID := IntToStr(aId);
  //UpdateControls;

end;


procedure TkzCompressorDetail.lSUCT_PressureDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string;
  var aHandled: Boolean);
begin
  aHandled := False;
  if not (Sender is TaOPCLabel) then
    Exit;

  if TaOPCLabel(Sender).ErrorCode = 0 then
    Exit;

  aCanvas.Brush.Color := сOPCErrorBrushColor;  // clYellow;
  aCanvas.Font.Style := aCanvas.Font.Style + [fsStrikeOut];
  aCanvas.Font.Color := cOPCErrorFontColor;

end;

procedure TkzCompressorDetail.SetCompCtrlID(const Value: string);
begin
  lCompCtrl.PhysID := Value;
end;

procedure TkzCompressorDetail.SetCompModeID(const Value: string);
begin
  CompMode.PhysID := Value;
  lCompMode.PhysID := Value;
end;

procedure TkzCompressorDetail.SetCompName(const Value: string);
begin
  lCompressorName.Value := Value;
  lSystemNo.Value := Value;
end;

procedure TkzCompressorDetail.SetDISHPressureID(const Value: string);
begin
  lDISHPressure.PhysID := Value;
end;

procedure TkzCompressorDetail.SetDISHPressureSATID(const Value: string);
begin
  lDISHPressureSAT.PhysID := Value;
end;

procedure TkzCompressorDetail.SetDISH_t2ID(const Value: string);
begin
  lDISH_t2.PhysID := Value;
end;

procedure TkzCompressorDetail.SetDISH_tID(const Value: string);
begin
  lDISH_t.PhysID := Value;
end;

procedure TkzCompressorDetail.SetID(const Value: TPhysID);
var
  aOPCSource: TaOPCSource;
  ALevel, i: Integer;
  CurrStr : string;
  ObjectName : string;
  Data: TStrings;
  aNumber: string;
  aSensorID: string;
  aSaveActive: Boolean;
begin
  if (FID = Value) or
    (not Assigned(OPCSource)) or
    (not (OPCSource is TaOPCSource)) then
    Exit;

  aOPCSource := TaOPCSource(OPCSource);
  if not aOPCSource.Connected then
    Exit;

  aSaveActive := aOPCSource.Active;
  aOPCSource.Active := False;
  try
    ClearIDs;

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

        aSensorID := Data.Strings[0];

        if FID = aSensorID then
          CompressorName := ObjectName;

        if Data.Strings[1] = '1' then
          Continue; // это не датчик

        if AnsiSameText(ObjectName, 'Давление') then
          DISHPressureID := aSensorID
        else if AnsiSameText(ObjectName, 'Температура пара') then
          DISH_tID := aSensorID
        else if AnsiSameText(ObjectName, 'Давление 2 (SAT)') then
          DISHPressureSATID := aSensorID
        else if AnsiSameText(ObjectName, 'Перегрев пара') then
          DISH_t2ID := aSensorID

        else if AnsiSameText(ObjectName, 'Давление всасывания') then
          SUCT_PressureID := aSensorID
        else if AnsiSameText(ObjectName, 'Перегрев всасываемого газа') then
          SUCT_GAS_TIID := aSensorID
        else if AnsiSameText(ObjectName, 'Давление на всасывании (SAT)') then
          SUCT_PressureSATID := aSensorID
        else if AnsiSameText(ObjectName, 'Перегрев при всасывании') then
          SUCT_GAS_S_HEATID := aSensorID
        else if AnsiSameText(ObjectName, 'Реальная уставка (SAT)') then
          SUCT_PressureSAT_SP_ID := aSensorID

        else if AnsiSameText(ObjectName, 'Позиция золотника производ.') then
          PositionID := aSensorID
        else if AnsiSameText(ObjectName, 'Производительность') then
          PerfomanceID := aSensorID

        else if AnsiSameText(ObjectName, 'COMP_MODE') or AnsiSameText(ObjectName, 'OPERATE_STATUS') then
          CompModeID := aSensorID
        else if AnsiSameText(ObjectName, 'CTRL_MODE') or AnsiSameText(ObjectName, 'OPERATE_OPERATION_MODE') then
          CompCtrlID := aSensorID

        else if AnsiSameText(ObjectName, 'Температура') then
          RassolID := aSensorID

        else if AnsiSameText(ObjectName, 'Ток двигателя') then
          MotorCurrentID := aSensorID
        else if AnsiSameText(ObjectName, 'Часы наработки') then
          TIMER_RUN_HOURSID := aSensorID

        else if AnsiSameText(ObjectName, 'Перепад давления на масл. фильтре') then
          OIL_FILT_DIF_PRESID := aSensorID
        else if AnsiSameText(ObjectName, 'Давление масла') then
          OIL_PRESID := aSensorID
        else if AnsiSameText(ObjectName, 'Температура масла') then
          OIL_TEMPID := aSensorID

      finally
        FreeAndNil(Data);
      end;
    end;
    //UpdateControls;
    aOPCImage1.Value := '0';
  finally
    aOPCSource.Active := aSaveActive;
  end;

end;

procedure TkzCompressorDetail.SetMotorCurrentID(const Value: string);
begin
  lMotorCurrent.PhysID := Value;
end;

procedure TkzCompressorDetail.SetOIL_FILT_DIF_PRESID(const Value: string);
begin
  lOIL_FILT_DIF_PRES.PhysID := Value;
end;

procedure TkzCompressorDetail.SetOIL_PRESID(const Value: string);
begin
  lOIL_PRES.PhysID := Value;
end;

procedure TkzCompressorDetail.SetOIL_TEMPID(const Value: string);
begin
  lOIL_TEMP.PhysID := Value;
end;

procedure TkzCompressorDetail.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin
  lSUCT_Pressure.OPCSource := Value;
  lSUCT_PressureSAT.OPCSource := Value;
  lSUCT_GAS_TI.OPCSource := Value;
  lSUCT_GAS_S_HEAT.OPCSource := Value;
  lOIL_PRES.OPCSource := Value;
  lOIL_TEMP.OPCSource := Value;
  lOIL_FILT_DIF_PRES.OPCSource := Value;
  lMotorCurrent.OPCSource := Value;
  lTIMER_RUN_HOURS.OPCSource := Value;
  lCompCtrl.OPCSource := Value;
  lCompMode.OPCSource := Value;
  lRassol.OPCSource := Value;
  lDISHPressure.OPCSource := Value;
  lDISHPressureSAT.OPCSource := Value;
  lDISH_t.OPCSource := Value;
  lDISH_t2.OPCSource := Value;
  gPerfomance.OPCSource := Value;
  gPosition.OPCSource := Value;
  CompMode.OPCSource := Value;
  lSUCT_PressureSAT_SP.OPCSource := Value;
end;


procedure TkzCompressorDetail.SetPerfomanceID(const Value: string);
begin
  gPerfomance.PhysID := Value;
end;

procedure TkzCompressorDetail.SetPositionID(const Value: string);
begin
  gPosition.PhysID := Value;
end;

procedure TkzCompressorDetail.SetRassolID(const Value: string);
begin
  lRassol.PhysID := Value;
end;

procedure TkzCompressorDetail.SetSUCT_GAS_S_HEATID(const Value: string);
begin
  lSUCT_GAS_S_HEAT.PhysID := Value;
end;

procedure TkzCompressorDetail.SetSUCT_GAS_TIID(const Value: string);
begin
  lSUCT_GAS_TI.PhysID := Value;
end;

procedure TkzCompressorDetail.SetSUCT_PressureID(const Value: string);
begin
  lSUCT_Pressure.PhysID := Value;
end;

procedure TkzCompressorDetail.SetSUCT_PressureSATID(const Value: string);
begin
  lSUCT_PressureSAT.PhysID := Value;
end;

procedure TkzCompressorDetail.SetSUCT_PressureSAT_SP_ID(const Value: string);
begin
  lSUCT_PressureSAT_SP.PhysID := Value;
end;

procedure TkzCompressorDetail.SetTIMER_RUN_HOURSID(const Value: string);
begin
  lTIMER_RUN_HOURS.PhysID := Value;
end;

end.
