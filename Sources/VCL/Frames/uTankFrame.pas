{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2007 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit uTankFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, aOPCLabel, ExtCtrls,
  uDCObjects,
  aCustomOPCSource,aOPCSource,aOPCLookupList, aOPCGauge,
  uOPCFrame, aOPCDataObject, aOPCImage, aOPCImage2In, aOPCImageList,
  aOPCStateLine;

type
  TfrTank = class(TaOPCFrame)
    Panel1: TPanel;
    Shape1: TShape;
    gMassa: TaOPCGauge;
    lTemperature: TaOPCLabel;
    lProduct: TaOPCLabel;
    lTankName: TaOPCLabel;
    lMin: TaOPCLabel;
    lMax: TaOPCLabel;
    lMassa: TaOPCLabel;
    lData: TaOPCLabel;
    MaxSize: TaOPCLabel;
    Label1: TaOPCLabel;
    Label2: TaOPCLabel;
    lSv: TaOPCLabel;
    lSVCaption: TaOPCLabel;
    lStoreTimeCaption: TaOPCLabel;
    lStoreTime: TaOPCLabel;
    MassaGif: TaOPCImage;
    TempGif: TaOPCImage;
    lTKCaption: TaOPCLabel;
    lTK: TaOPCLabel;
    CoolSystem: TShape;
    Pump: TaOPCImage;
    Mixer: TaOPCImage2In;
    Cooling: TaOPCImage;
    MixerStateLine: TaOPCStateLine;
    procedure Shape1StartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lProductDblClick(Sender: TObject);
    procedure UpdateTankStatus(Sender: TObject);
    procedure lMaxDblClick(Sender: TObject);
    procedure lMinDblClick(Sender: TObject);
    procedure lSvDblClick(Sender: TObject);
    procedure lDataDblClick(Sender: TObject);
    procedure lStoreTimeDblClick(Sender: TObject);
    procedure lTKDblClick(Sender: TObject);
    procedure CoolingChange(Sender: TObject);
    procedure MixerStateLineClick(Sender: TObject);
    procedure MixerClick(Sender: TObject);
  private
    //FCaptionColor: TColor;
    FTankMinMassa: integer;
    FAlowAnimation: boolean;
    FShowMixerStateLine: boolean;
    procedure SetOPCLookupList(const Value: taOPCLookupList);
    function GetLookupList: taOPCLookupList;
    function GetSensorMin: TPhysID;
    procedure SetSensorMin(const Value: TPhysID);
    function GetSensorMassa: TPhysID;
    function GetSensorMax: TPhysID;
    function GetSensorProduct: TPhysID;
    function GetSensorTemperatura: TPhysID;
    function GetTankName: string;
    function GetTankMaxMassa: integer;
    procedure SetSensorMassa(const Value: TPhysID);
    procedure SetSensorMax(const Value: TPhysID);
    procedure SetSensorProduct(const Value: TPhysID);
    procedure SetSensorTemperatura(const Value: TPhysID);
    procedure SetTankName(const Value: string);
    procedure SetTankMaxMassa(const Value: integer);
    function GetSensorDate: TPhysID;
    function GetSensorSV: TPhysID;
    procedure SetSensorDate(const Value: TPhysID);
    procedure SetSensorSV(const Value: TPhysID);
    function GetCaptionColor: TColor;
    procedure SetCaptionColor(const Value: TColor);
    function GetSensorStoreTime: TPhysID;
    procedure SetSensorStoreTime(const Value: TPhysID);
    procedure SetTankMinMassa(const Value: integer);
    function GetOPCImageList: TaOPCImageList;
    procedure SetImageList(const Value: TaOPCImageList);
    function GetSensorTK: TPhysID;
    procedure SetSensorTK(const Value: TPhysID);
    function GetCoolingID: TPhysID;
    function GetMixerInID: TPhysID;
    function GetPumpID: TPhysID;
    procedure SetCoolingID(const Value: TPhysID);
    procedure SetMixerInID(const Value: TPhysID);
    procedure SetPumpID(const Value: TPhysID);
    function GetMixerOutID: TPhysID;
    procedure SetMixerOutID(const Value: TPhysID);
    procedure SetAlowAnimation(const Value: boolean);
    procedure SetShowMixerStateLine(const Value: boolean);
  protected
    procedure SetID(const Value: TPhysID);override;
    procedure SetOPCSource(const Value: TaCustomMultiOPCSource);override;
    function GetOPCSource: TaCustomMultiOPCSource;override;
  public
    procedure CheckStoreTime;
    procedure LocalInit(aId:integer; aOPCObjects:TDCObjectList);override;
  published
    property OPCSource;//:TaCustomMultiOPCSource read GetOPCSource write SetOPCSource;
    property OPCLookupList:taOPCLookupList read GetLookupList write SetOPCLookupList;
    property SensorMin : TPhysID read GetSensorMin write SetSensorMin;
    property SensorMax : TPhysID read GetSensorMax write SetSensorMax;
    property SensorProduct : TPhysID read GetSensorProduct write SetSensorProduct;
    property SensorMassa : TPhysID read GetSensorMassa write SetSensorMassa;
    property SensorTemperatura : TPhysID read GetSensorTemperatura write SetSensorTemperatura;
    property SensorSV : TPhysID read GetSensorSV write SetSensorSV;
    property SensorTK : TPhysID read GetSensorTK write SetSensorTK;
    property SensorStoreTime : TPhysID read GetSensorStoreTime write SetSensorStoreTime;
    property SensorDate : TPhysID read GetSensorDate write SetSensorDate;
    property MixerInID: TPhysID read GetMixerInID write SetMixerInID;
    property MixerOutID: TPhysID read GetMixerOutID write SetMixerOutID;
    property PumpID: TPhysID read GetPumpID write SetPumpID;
    property CoolingID: TPhysID read GetCoolingID write SetCoolingID;
    property TankName : string read GetTankName write SetTankName;
    property TankMaxMassa : integer read GetTankMaxMassa write SetTankMaxMassa;
    property TankMinMassa : integer read FTankMinMassa write SetTankMinMassa;
    property CaptionColor: TColor read GetCaptionColor write SetCaptionColor;
    property OPCImageList: TaOPCImageList read GetOPCImageList write SetImageList;
    property AlowAnimation: boolean read FAlowAnimation write SetAlowAnimation default false;
    property ShowMixerStateLine: boolean read FShowMixerStateLine write SetShowMixerStateLine default false;
  end;


//function GetBufStart(Buffer: PChar; var Level: Integer): PChar;


implementation

uses
  DC.StrUtils,
  //ChoiceProduct,
  uChoiceValue,
  Math, DateUtils,
  aOPCLog;

{$R *.dfm}

procedure TfrTank.lProductDblClick(Sender: TObject);
var
  aOPCSource : TaOPCSource;

  ChoiceValueForm: TChoiceValue;
  aSetValue : string;
  aMoment: TDateTime;

//  ItInd,i:integer;
//  cp:TChoiceProductForm;
//  dt:TDateTime;
//  aNewValue  : string;
begin
  if not Assigned(lProduct.LookupList) or  //(OPCLookupList = nil) or
    (OPCSource = nil) or not (OPCSource is TaOPCSource) then
    Exit;

  aOPCSource := TaOPCSource(OPCSource);

  ChoiceValueForm := TChoiceValue.Create(nil);
  try
    ChoiceValueForm.sl := TStringList(lProduct.LookupList.Items);
    ChoiceValueForm.ComboBox.Style := csDropDown;     //разрешим ввести новый элемент

    ChoiceValueForm.Edit.Text := lProduct.Value;
    ChoiceValueForm.ShowModal;
    if ChoiceValueForm.ModalResult = mrOk then
    begin
      if ChoiceValueForm.cbUseDate.Checked then
        aMoment := ChoiceValueForm.TimeStamp
      else
        aMoment := 0;

      aSetValue := ChoiceValueForm.ComboBox.Text;

      aOPCSource.SetSensorValue(lProduct.PhysID, aSetValue, aMoment);

      if (aSetValue = '') and (aMoment = 0) then
      begin
        aOPCSource.SetSensorValue(SensorSV,'0',0);
        if SensorTK<>'' then
          aOPCSource.SetSensorValue(SensorTK,'0',0);
        aOPCSource.SetSensorValue(SensorStoreTime,'0',0);
        aOPCSource.SetSensorValue(SensorDate,'0',0);
      end;
      if ChoiceValueForm.ComboBox.Items.IndexOf(ChoiceValueForm.ComboBox.Text) < 0 then
        lProduct.LookupList.GetLookup;

    end;
  finally
    ChoiceValueForm.Free;
  end;

//  cp:=TChoiceProductForm.Create(nil);
//  try
//    ItInd:=lProduct.LookupList.Items.IndexOfName(lProduct.Value);
//    for i := 0 to lProduct.LookupList.Items.Count - 1 do
//    begin
//      cp.ListBox1.Items.Add(lProduct.LookupList.Items.ValueFromIndex[i]);
//    end;
//    cp.ListBox1.ItemIndex:=ItInd;
//    if cp.ShowModal=mrOk then
//    begin
//      if cp.rbNow.Checked then
//        dt:=0
//      else
//        dt:=Trunc(cp.dtpDate.DateTime)+frac(cp.dtpTime.DateTime);
//
//      aNewValue := lProduct.LookupList.Items.Names[cp.ListBox1.ItemIndex];
//      aOPCSource.SetSensorValue(lProduct.PhysID, aNewValue, dt);
//      if (aNewValue = '0') and (cp.rbNow.Checked) then
//      begin
//        aOPCSource.SetSensorValue(SensorSV,'0',0);
//        if SensorTK<>'' then
//          aOPCSource.SetSensorValue(SensorTK,'0',0);
//        aOPCSource.SetSensorValue(SensorStoreTime,'0',0);
//        aOPCSource.SetSensorValue(SensorDate,'0',0);
//      end;
//    end;
//  finally
//    cp.Free;
//  end;
end;

procedure TfrTank.UpdateTankStatus(Sender: TObject);
var
  v:Double;
  vmax,vmin:double;
  massa:double;
begin
  try
    lProduct.Hint:=lProduct.Caption+#10+ //#13#10+
      'c '+DateTimeToStr(lProduct.Moment);
    if lData.PhysID='' then
      lData.Caption:=DateToStr(lProduct.Moment);
    lMin.Hint:=lMin.Caption+'°C c '+DateTimeToStr(lMin.Moment);
    lMax.Hint:=lMax.Caption+'°C c '+DateTimeToStr(lMax.Moment);

    if lProduct.Value='0' then
    begin
      lTankName.Color:=$00E1E1E1;
      gMassa.BackColor          := $00EAEAEA;
      lData.Visible := false;
      lStoreTime.Visible := false;
      lSv.Visible   := false;
      lTK.Visible   := false;
      lStoreTimeCaption.Visible := false;
      lSVCaption.Visible := false;
      lTKCaption.Visible := false;
      lMin.Visible       := False;
      lMax.Visible       := False;
    end
    else
    begin
      lTankName.Color:=clSkyBlue;
      gMassa.BackColor          := clWhite;
      lData.Visible             := true;
      lStoreTime.Visible        := SensorStoreTime<>'';
      lSv.Visible               := SensorSV<>'';
      lTK.Visible               := SensorTK<>'';
      lStoreTimeCaption.Visible := SensorStoreTime<>'';
      lSVCaption.Visible        := SensorSV<>'';
      lTKCaption.Visible        := SensorTK<>'';
      lMin.Visible              := SensorMin<>'';
      lMax.Visible              := SensorMax<>'';
    end;

    v:=StrToFloatDef(lTemperature.Value,0);
    vmin:=StrToFloatDef(lMin.Value,0);
    vmax:=StrToFloatDef(lMax.Value,0);

    massa := StrToFloatDef(lMassa.Value,0);

    if (lProduct.Value='0') or (massa < 50) then
    begin
      lTemperature.Font.Color:=clBlack;
      TempGif.Value := '0';
    end
    else
    begin
      if v>vmax then
      begin
        lTemperature.Font.Color:=clRed;
        TempGif.Value := '2';
      end
      else if v<vmin then
        begin
          lTemperature.Font.Color:=clBlue;
          TempGif.Value := '3';
        end
        else
        begin
          lTemperature.Font.Color:=clBlack;
          TempGif.Value := '0';
        end;
    end;

    if massa<=50 then
    begin  //меньше 50 кг не учитываем
      lMassa.Font.Color := clGray;
      MassaGif.Value := '0';
    end
    else if (massa<TankMinMassa) then
    begin  //меньше допустимого предела
      lMassa.Font.Color := clMaroon;
      MassaGif.Value := '2';
    end
    else
    begin   //все нормально
      lMassa.Font.Color := clBlack;
      MassaGif.Value := '0';
    end;
  except
    on e:Exception do
      OPCLog.WriteToLog('UpdateTankStatus: '+e.Message);
  end;

end;

procedure TfrTank.SetOPCSource(const Value: TaCustomMultiOPCSource);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TaOPCLabel then
      TaOPCLabel(Components[i]).OPCSource:=Value
    else if Components[i] is TaOPCImage then
      TaOPCImage(Components[i]).OPCSource:=Value
    else if Components[i] is TaOPCStateLine then
      TaOPCStateLine(Components[i]).OPCSource:=Value
    else if Components[i] is TaOPCGauge then
      TaOPCGauge(Components[i]).OPCSource:=Value;
  end;
end;

procedure TfrTank.SetPumpID(const Value: TPhysID);
begin
  Pump.PhysID := Value;
  Pump.Visible := (Value <> '');
end;

procedure TfrTank.SetOPCLookupList(const Value: taOPCLookupList);
begin
  lProduct.LookupList:=Value;
end;

function TfrTank.GetLookupList: taOPCLookupList;
begin
  Result:=lProduct.LookupList;
end;

function TfrTank.GetMixerInID: TPhysID;
begin
  Result := Mixer.PhysID;
end;

function TfrTank.GetMixerOutID: TPhysID;
begin
  Result := Mixer.PhysID2;
end;

procedure TfrTank.lMaxDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil)
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lMax.Value;
  if InputQuery('Укажите максимальное значение температуры',
    'Укажите максимальное значение температуры',v) then
  begin
    dt:=0;
    v:=StringReplace(v,'.',',',[]);
    TaOPCSource(lMax.OPCSource).SetSensorValue(lMax.PhysID,
      v, dt);
  end;
end;

procedure TfrTank.lMinDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil)
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lMin.Value;
  if InputQuery('Укажите минимальное значение температуры',
    'Укажите минимальное значение температуры',v) then
  begin
    dt:=0;
    v:=StringReplace(v,'.',',',[]);
    TaOPCSource(lMin.OPCSource).SetSensorValue(lMin.PhysID, v, dt);
  end;
end;

procedure TfrTank.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
var
  aOPCObject: TDCObject;
  ObjectName: string;
  id : string;
  i: Integer;
begin
  aOPCObject := aOPCObjects.FindObjectByID(aId);
  if not Assigned(aOPCObject) then
    exit;

  TankName := aOPCObject.Name;
  for i := 0 to aOPCObject.Childs.Count - 1 do
  begin
    if Assigned(aOPCObject.Childs[i]) and (aOPCObject.Childs[i] is TDCObject) then
    begin
      ObjectName := TDCObject(aOPCObject.Childs[i]).Name;
      id         := TDCObject(aOPCObject.Childs[i]).IdStr;

      if ObjectName = 'Масса' then
        SensorMassa   := id
      else if ObjectName = 'Продукт' then
        SensorProduct := id
      else if ObjectName = 't min' then
        SensorMin     := id
      else if ObjectName = 't max' then
        SensorMax     := id
      else if ObjectName = 'Температура' then
        SensorTemperatura := id
      else if ObjectName = 'Содержание с/в' then
        SensorSV      := id
      else if ObjectName = 'Содержание т/к' then
        SensorTK      := id
      else if ObjectName = 'Срок хранения' then
        SensorStoreTime := id
      else if ObjectName = 'Дата партии' then
        SensorDate    := id
      else if ObjectName = 'Мешалка (выход)' then
        MixerInID := id
      else if ObjectName = 'Мешалка (датчик)' then
        MixerOutID := id
      else if ObjectName = 'Насос' then
        PumpID  := id
      else if ObjectName = 'Охлаждение' then
        CoolingID := id
      ;
    end;
  end;
  FID := IntToStr(aId);
end;

function TfrTank.GetSensorMin: TPhysID;
begin
  Result:=lMin.PhysID;
end;

procedure TfrTank.SetSensorMin(const Value: TPhysID);
begin
  lMin.PhysID:=Value;
end;

function TfrTank.GetSensorMassa: TPhysID;
begin
  Result:=lMassa.PhysID;
end;

function TfrTank.GetSensorMax: TPhysID;
begin
  Result:=lMax.PhysID;
end;

function TfrTank.GetSensorProduct: TPhysID;
begin
  Result:=lProduct.PhysID;
end;

function TfrTank.GetSensorTemperatura: TPhysID;
begin
  Result:=lTemperature.PhysID;
end;

function TfrTank.GetTankName: string;
begin
  Result:=lTankName.Caption;
end;

procedure TfrTank.SetSensorMassa(const Value: TPhysID);
begin
  lMassa.PhysID:=Value;
  gMassa.PhysID:=Value;
end;

procedure TfrTank.SetSensorMax(const Value: TPhysID);
begin
  lMax.PhysID:=Value;
end;

procedure TfrTank.SetSensorProduct(const Value: TPhysID);
begin
  lProduct.PhysID:=Value;
end;

procedure TfrTank.SetSensorTemperatura(const Value: TPhysID);
begin
  lTemperature.PhysID:=Value;
end;

procedure TfrTank.SetTankName(const Value: string);
begin
  lTankName.Caption:=Value;
  if Length(Value)>=2 then
  begin
    case Value[2] of
      'M','m','М','м':MaxSize.Caption := '10';
      'K','k','К','к':MaxSize.Caption := '18';
      'P','p','П','п':MaxSize.Caption := '25';
      'A','a','А','а':MaxSize.Caption := '25';
    end;
  end;
end;

procedure TfrTank.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  p := (Sender as TControl).ClientToParent(Point(x,y),Self);
  FMouseDownX := p.X;
  FMouseDownY := p.Y;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self,Button, Shift, FMouseDownX, FMouseDownY);
end;

procedure TfrTank.Shape1StartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  if Assigned(OnStartDrag) then
    OnStartDrag(Self,DragObject);
end;

procedure TfrTank.SetTankMaxMassa(const Value: integer);
begin
  gMassa.MaxValue:=Value;
end;

function TfrTank.GetTankMaxMassa: integer;
begin
  Result := gMassa.MaxValue;
end;

procedure TfrTank.SetID(const Value: TPhysID);
var
  aOPCSource: TaOPCSource;
  ALevel, i: Integer;
  CurrStr : string;
  ObjectName : string;
//  ObjectKind : string;
  Data: TStrings;
begin
  if (FID = Value) or
    (not Assigned(OPCSource)) or
    (not (OPCSource is TaOPCSource)) then
    exit;
  aOPCSource := TaOPCSource(OPCSource);
  FID := Value;
  aOPCSource.FNameSpaceCash.Clear;
  aOPCSource.FNameSpaceTimeStamp := 0;
//  aOPCSource.GetNameSpace(StrToIntDef(Value,0));
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
        TankName := ObjectName;

      if Data.Strings[1] = '1' then
        Continue; // это не датчик

      if ObjectName = 'Масса' then
        SensorMassa   := Data.Strings[0]
      else if ObjectName = 'Продукт' then
        SensorProduct := Data.Strings[0]
      else if ObjectName = 't min' then
        SensorMin     := Data.Strings[0]
      else if ObjectName = 't max' then
        SensorMax     := Data.Strings[0]
      else if ObjectName = 'Температура' then
        SensorTemperatura := Data.Strings[0]
      else if ObjectName = 'Содержание с/в' then
        SensorSV      := Data.Strings[0]
      else if ObjectName = 'Содержание т/к' then
        SensorTK      := Data.Strings[0]
      else if ObjectName = 'Срок хранения' then
        SensorStoreTime := Data.Strings[0]
      else if ObjectName = 'Дата партии' then
        SensorDate    := Data.Strings[0]
      else if ObjectName = 'Мешалка (выход)' then
        MixerInID := Data.Strings[0]
      else if ObjectName = 'Мешалка (датчик)' then
        MixerOutID := Data.Strings[0]
      else if ObjectName = 'Насос' then
        PumpID  := Data.Strings[0]
      else if ObjectName = 'Охлаждение' then
        CoolingID := Data.Strings[0]
      ;
    finally
      FreeAndNil(Data);
    end;
  end;
end;

function TfrTank.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result:=(gMassa.OPCSource as TaCustomMultiOPCSource);
end;

function TfrTank.GetPumpID: TPhysID;
begin
  Result := Pump.PhysID;
end;

function TfrTank.GetSensorDate: TPhysID;
begin
  Result := lData.PhysID;
end;

function TfrTank.GetSensorSV: TPhysID;
begin
  Result := lSv.PhysID;
end;

procedure TfrTank.SetSensorDate(const Value: TPhysID);
begin
  lData.PhysID := Value;
  lData.Cursor := IfThen(lData.PhysID<>'',crHandPoint,crDefault);
end;

procedure TfrTank.SetSensorSV(const Value: TPhysID);
begin
  lSv.PhysID := Value;
  lSv.Visible := lSv.PhysID<>'';
  lSVCaption.Visible := lSv.PhysID<>'';
  lSv.Cursor := IfThen(lSv.PhysID<>'',crHandPoint,crDefault);
end;

procedure TfrTank.lSvDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil) or (lSv.PhysID='')
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lSv.Value;
  if InputQuery('Укажите содержание с/в,%',
    'Укажите содержание с/в,%',v) then
  begin
    dt:=0;
    v:=StringReplace(v,'.',',',[]);
    TaOPCSource(lSv.OPCSource).SetSensorValue(lSv.PhysID,
      v, dt);
  end;

end;

procedure TfrTank.lDataDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil) or (lData.PhysID='')
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lData.Caption;
  if InputQuery('Укажите дату партии',
    'Укажите дату партии',v) then
  begin
    dt:=0;
    v:=StringReplace(v,',','.',[rfReplaceAll]);
    TaOPCSource(lData.OPCSource).SetSensorValue(lData.PhysID,
      FloatToStr(StrToDateTime(v)), dt);
  end;

end;


procedure TfrTank.SetAlowAnimation(const Value: boolean);
begin
  FAlowAnimation := Value;
  MassaGif.Animate := Value;
  MassaGif.Visible := Value;
  TempGif.Animate := Value;
  TempGif.Visible := Value;
end;

procedure TfrTank.SetCaptionColor(const Value: TColor);
begin
  Shape1.Brush.Color := Value;
end;

procedure TfrTank.SetCoolingID(const Value: TPhysID);
begin
  Cooling.PhysID := Value;
  Cooling.Visible := (Value <> '');
end;

procedure TfrTank.CoolingChange(Sender: TObject);
begin
  CoolSystem.Visible := (Cooling.Value = '1');	
end;

function TfrTank.GetCaptionColor: TColor;
begin
  Result := Shape1.Brush.Color;
end;

function TfrTank.GetCoolingID: TPhysID;
begin
  Result := Cooling.PhysID;
end;

procedure TfrTank.lStoreTimeDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil) or (lStoreTime.PhysID='')
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lStoreTime.Value;
  if InputQuery('Укажите срок хранения, дней',
    'Укажите срок хранения, дней',v) then
  begin
    dt:=0;
    //v:=StringReplace(v,'.',',',[]);
    TaOPCSource(OPCSource).SetSensorValue(lStoreTime.PhysID,
      v, dt);
  end;
end;

function TfrTank.GetSensorStoreTime: TPhysID;
begin
  Result := lStoreTime.PhysID;
end;

procedure TfrTank.SetSensorStoreTime(const Value: TPhysID);
begin
  lStoreTime.PhysID := Value;
  lStoreTime.Visible := lStoreTime.PhysID<>'';
  lStoreTimeCaption.Visible := lStoreTime.PhysID<>'';
  lStoreTime.Cursor := IfThen(lStoreTime.PhysID<>'',crHandPoint,crDefault);
end;

procedure TfrTank.CheckStoreTime;
var
  dt1,dt2:TDate;
  StoreTime: integer;
begin
  if not Assigned(OPCSource) or (lStoreTime.PhysID='') or
    ((lData.PhysID='') and (lProduct.PhysID='')) then
    exit;

  if lData.PhysID<>'' then
    dt1 := StrToFloat(lData.Value)
  else
    dt1 := lProduct.Moment;
  dt2 := OPCSource.CurrentMoment;
  StoreTime := StrToIntDef(lStoreTime.Value,0);
  if (lProduct.Value<>'0') and (StrToFloatDef(lMassa.Value,0)>50) and
    (StoreTime>0) and (DaysBetween(dt2,dt1) > StoreTime) then
  begin // превышен срок хранения
    gMassa.ForeColor := $0000A4A4;
    lStoreTime.Font.Color := clRed;
    //StoreGif.Value := '1';
  end
  else
  begin
    gMassa.ForeColor := $00FFDE88;
    lStoreTime.Font.Color := clBlack;
    //StoreGif.Value := '0';
  end;
end;

procedure TfrTank.SetTankMinMassa(const Value: integer);
begin
  FTankMinMassa := Value;
end;

function TfrTank.GetOPCImageList: TaOPCImageList;
begin
  Result := MassaGif.OPCImageList;
end;

procedure TfrTank.SetImageList(const Value: TaOPCImageList);
begin
  MassaGif.OPCImageList := Value;
  TempGif.OPCImageList  := Value;
  Pump.OPCImageList     := Value;
  Cooling.OPCImageList  := Value;
  Mixer.OPCImageList    := Value;
  //StoreGif.OPCImageList := Value;
end;

procedure TfrTank.SetMixerInID(const Value: TPhysID);
begin
  Mixer.PhysID := Value;
  Mixer.Visible := (Mixer.PhysID <> '') and (Mixer.PhysID2 <> '');
  MixerStateLine.PhysID := Mixer.PhysID;
  MixerStateLine.Visible := Mixer.Visible and ShowMixerStateLine;
end;

procedure TfrTank.SetMixerOutID(const Value: TPhysID);
begin
  Mixer.PhysID2 := Value;
  Mixer.Visible := (Mixer.PhysID <> '') and (Mixer.PhysID2 <> '');
  MixerStateLine.Visible := Mixer.Visible and ShowMixerStateLine;
end;

procedure TfrTank.lTKDblClick(Sender: TObject);
var
  v:string;
  dt:TDateTime;
begin
  if (OPCSource=nil) or (lTK.PhysID='')
    or not (OPCSource is TaOPCSource) then
    exit;

  v:=lTK.Value;
  if InputQuery('Укажите титруемую кислотность',
    'Укажите титруемую кислотность',v) then
  begin
    dt:=0;
    v:=StringReplace(v,'.',',',[]);
    TaOPCSource(lTK.OPCSource).SetSensorValue(lTK.PhysID,
      v, dt);
  end;
end;

procedure TfrTank.MixerClick(Sender: TObject);
begin
  if ShowMixerStateLine then
    MixerStateLine.Visible := not MixerStateLine.Visible;
end;

procedure TfrTank.MixerStateLineClick(Sender: TObject);
begin
  if MixerStateLine.Interval.TimeShift < 1 then
    MixerStateLine.Interval.TimeShift := 12
  else
    MixerStateLine.Interval.TimeShift := MixerStateLine.Interval.TimeShift/10;

  if MixerStateLine.Interval.TimeShift = 12 then
    MixerStateLine.Height := 12
  else if Round(MixerStateLine.Interval.TimeShift*10) = 12 then
    MixerStateLine.Height := 10
  else if Round(MixerStateLine.Interval.TimeShift*100) = 12 then
    MixerStateLine.Height := 8;


    
  MixerStateLine.Hint := Format('Работа мешалки за последние %s ч.',[FormatFloat('0.##',MixerStateLine.Interval.TimeShift)]);

end;

function TfrTank.GetSensorTK: TPhysID;
begin
  Result := lTK.PhysID;
end;

procedure TfrTank.SetSensorTK(const Value: TPhysID);
begin
  lTK.PhysID := Value;
  lTK.Visible := lTK.PhysID<>'';
  lTKCaption.Visible := lTK.PhysID<>'';
  lTK.Cursor := IfThen(lTK.PhysID<>'',crHandPoint,crDefault);
end;

procedure TfrTank.SetShowMixerStateLine(const Value: boolean);
begin
  FShowMixerStateLine := Value;
  MixerStateLine.Visible := Mixer.Visible and ShowMixerStateLine;
end;

initialization
  RegisterClasses([TfrTank]);


end.
