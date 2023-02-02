unit uChartFrame;

interface

{$I VCL.DC.inc}

uses
//  {$IFDEF HAS_UNIT_SYSTEM_ACTIONS}
  System.Actions, System.ImageList,
//  {$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, ExtCtrls, AppEvnts,
  System.IniFiles,
  SpTBXItem, TB2Dock, TB2Toolbar, TB2Item, SpTBXCustomizer, uOPCFrame,
//  Vcl.ImgList, System.Actions, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, aOPCChart,
//{$IFDEF TEEVCL}
  VclTee.TeeGDIPlus, Vcl.Touch.GestureMgr,
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.TeeStore, VCLTee.Chart, VCLTee.Series,
  VCLTee.TeeEdit, VCLTee.TeeEditCha, VCLTee.TeeRussian, VCLTee.TeeTools,
//{$ELSE}
//  TeEngine, TeeProcs, TeeStore, Chart, Series,
//{$ENDIF}
  aOPCChart,
  aCustomOPCSource, aOPCSource,
  uOPCIntervalForm, uOPCInterval,
  aOPCDataObject, aOPCLabel,
  uOPCSeriesTypes, aOPCLineSeries, uOPCGanttSeries,
  uDCTeeTools,
  uDCObjects, aOPCLookupList,
  aOPCConnectionList, aOPCLog, aOPCUtils, Vcl.ImgList;

type
  TSavePosition = record
    Left, Top, Width, Height: Integer;
    Align: TAlign;
  end;

  TChartFrame = class(TaOPCFrame)
    ApplicationEvents1: TApplicationEvents;
    Chart: TaOPCChart;
    ChartFormActions: TActionList;
    aBuild: TAction;
    aSeriesShowValue: TAction;
    aUpdate: TAction;
    aDeleteSeries: TAction;
    aClear: TAction;
    aRuning: TAction;
    aInterval: TAction;
    a3D: TAction;
    aLegend: TAction;
    aAutoScaleY: TAction;
    aFullName: TAction;
    aCopy: TAction;
    aLoad: TAction;
    aSave: TAction;
    aPrint: TAction;
    aEditor: TAction;
    aSerieScale: TAction;
    aSerieStatistic: TAction;
    aZoomOut: TAction;
    aReset: TAction;
    aAnalyse: TAction;
    aSerieState: TAction;
    aSerieShift: TAction;
    aNoiseRemove: TAction;
    aFilter: TAction;
    aShowOnMap: TAction;
    aAxisForEachSeries: TAction;
    aShowZero: TAction;
    pmChart: TSpTBXPopupMenu;
    SpTBXItem1: TSpTBXItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    SpTBXItem4: TSpTBXItem;
    SpTBXSeparatorItem12: TSpTBXSeparatorItem;
    SpTBXItem27: TSpTBXItem;
    SpTBXItem2: TSpTBXItem;
    SpTBXSeparatorItem16: TSpTBXSeparatorItem;
    SpTBXItem3: TSpTBXItem;
    SpTBXSeparatorItem11: TSpTBXSeparatorItem;
    SpTBXItem20: TSpTBXItem;
    SpTBXItem21: TSpTBXItem;
    SpTBXItem37: TSpTBXItem;
    SpTBXItem22: TSpTBXItem;
    SpTBXItem23: TSpTBXItem;
    SpTBXSeparatorItem7: TSpTBXSeparatorItem;
    SpTBXItem24: TSpTBXItem;
    SpTBXItem36: TSpTBXItem;
    SpTBXSeparatorItem18: TSpTBXSeparatorItem;
    SpTBXItem15: TSpTBXItem;
    pmSeries: TSpTBXPopupMenu;
    tbSeriesDelete: TSpTBXItem;
    SpTBXSeparatorItem2: TSpTBXSeparatorItem;
    tbSeriesShowValue: TSpTBXItem;
    tbSeriesShowOnMap: TSpTBXItem;
    tbSeriesStatistic: TSpTBXItem;
    SpTBXSeparatorItem3: TSpTBXSeparatorItem;
    tbScale: TSpTBXItem;
    tbShift: TSpTBXItem;
    SpTBXCustomizer: TSpTBXCustomizer;
    SpTBXPopupMenu1: TSpTBXPopupMenu;
    TBGroupItem1: TTBGroupItem;
    SpTBXSeparatorItem10: TSpTBXSeparatorItem;
    pCustomize: TSpTBXItem;
    tbDockBottom: TSpTBXDock;
    tbDockLeft: TSpTBXDock;
    tbDockRight: TSpTBXDock;
    tbDockTop: TSpTBXDock;
    tbChartActions: TSpTBXToolbar;
    tbiClear: TSpTBXItem;
    SpTBXSeparatorItem13: TSpTBXSeparatorItem;
    tbiBuild: TSpTBXItem;
    tbiUpdate: TSpTBXItem;
    SpTBXSeparatorItem15: TSpTBXSeparatorItem;
    tbiRuning: TSpTBXItem;
    SpTBXSeparatorItem14: TSpTBXSeparatorItem;
    tbiAutoScaleY: TSpTBXItem;
    tbiShowZero: TSpTBXItem;
    tbiAxisForEachSeries: TSpTBXItem;
    tbi3D: TSpTBXItem;
    tbiLegend: TSpTBXItem;
    SpTBXSeparatorItem5: TSpTBXSeparatorItem;
    tbiCopy: TSpTBXItem;
    tbiZoomOut: TSpTBXItem;
    SpTBXSeparatorItem6: TSpTBXSeparatorItem;
    tbiEditor: TSpTBXItem;
    SpTBXSeparatorItem4: TSpTBXSeparatorItem;
    tbiInterval: TSpTBXItem;
    smiInterval: TSpTBXSubmenuItem;
    SpTBXItem28: TSpTBXItem;
    SpTBXItem29: TSpTBXItem;
    SpTBXItem30: TSpTBXItem;
    SpTBXItem31: TSpTBXItem;
    SpTBXItem32: TSpTBXItem;
    SpTBXItem33: TSpTBXItem;
    SpTBXSeparatorItem17: TSpTBXSeparatorItem;
    SpTBXItem34: TSpTBXItem;
    tbSeriesPopup: TSpTBXToolbar;
    tbItemClickedSerie: TSpTBXSubmenuItem;
    SpTBXItem5: TSpTBXItem;
    SpTBXSeparatorItem8: TSpTBXSeparatorItem;
    SpTBXItem6: TSpTBXItem;
    SpTBXItem7: TSpTBXItem;
    SpTBXSeparatorItem9: TSpTBXSeparatorItem;
    SpTBXItem8: TSpTBXItem;
    SpTBXItem9: TSpTBXItem;
    CommonImages: TImageList;
    aAllClient: TAction;
    tbiAllClient: TSpTBXItem;
    SpTBXSeparatorItem19: TSpTBXSeparatorItem;
    SpTBXItem10: TSpTBXItem;
    SpTBXSeparatorItem20: TSpTBXSeparatorItem;
    aAddMessure: TAction;
    aClearMessures: TAction;
    SpTBXItem11: TSpTBXItem;
    SpTBXItem12: TSpTBXItem;
    SpTBXSeparatorItem21: TSpTBXSeparatorItem;
    SpTBXSeparatorItem22: TSpTBXSeparatorItem;
    SpTBXItem13: TSpTBXItem;
    SpTBXItem14: TSpTBXItem;
    GestureManager1: TGestureManager;
    aAddMessureBand: TAction;
    SpTBXItem16: TSpTBXItem;
    aDelTool: TAction;
    pmBandTools: TSpTBXPopupMenu;
    SpTBXItem17: TSpTBXItem;
    aDelSensorValues: TAction;
    SpTBXItem18: TSpTBXItem;
    SpTBXSeparatorItem23: TSpTBXSeparatorItem;
    pmLineTools: TSpTBXPopupMenu;
    SpTBXItem19: TSpTBXItem;
    Series1: TLineSeries;
    SpTBXItem25: TSpTBXItem;
    smiLineWidth: TSpTBXSubmenuItem;
    miThin: TSpTBXItem;
    miThick: TSpTBXItem;
    procedure ChartBeforeDrawAxes(Sender: TObject);
    procedure ChartDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChartDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ChartClickLegend(Sender: TCustomChart; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChartClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ChartContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure aUpdateExecute(Sender: TObject);
    procedure aClearExecute(Sender: TObject);
    procedure aRuningExecute(Sender: TObject);
    procedure aIntervalExecute(Sender: TObject);
    procedure ApplicationEvents1ShowHint(var HintStr: string;
      var CanShow: Boolean; var HintInfo: THintInfo);
    procedure aSeriesShowValueExecute(Sender: TObject);
    procedure aDeleteSeriesExecute(Sender: TObject);
    procedure aSerieScaleExecute(Sender: TObject);
    procedure aSerieStatisticExecute(Sender: TObject);
    procedure aSerieShiftExecute(Sender: TObject);
    procedure aEditorExecute(Sender: TObject);
    procedure aAutoScaleYExecute(Sender: TObject);
    procedure aLegendExecute(Sender: TObject);
    procedure a3DExecute(Sender: TObject);
    procedure aAxisForEachSeriesExecute(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure ChartScroll(Sender: TObject);
    procedure aBuildExecute(Sender: TObject);
    procedure lIntervalClick(Sender: TObject);
    procedure smiIntervalClick(Sender: TObject);
    procedure SpTBXItem28Click(Sender: TObject);
    procedure SpTBXItem34Click(Sender: TObject);
    procedure aZoomOutExecute(Sender: TObject);
    procedure ChartZoom(Sender: TObject);
    procedure ChartFormActionsUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure ChartUndoZoom(Sender: TObject);
    procedure ChartKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure aShowZeroExecute(Sender: TObject);
    procedure smiIntervalPopup(Sender: TTBCustomItem; FromLink: Boolean);
    procedure aAllClientExecute(Sender: TObject);
    procedure tbDockTopRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure aAddMessureExecute(Sender: TObject);
    procedure aClearMessuresExecute(Sender: TObject);
    procedure aAddMessureBandExecute(Sender: TObject);
    procedure aDelToolExecute(Sender: TObject);
    procedure aDelSensorValuesExecute(Sender: TObject);
    procedure miThinClick(Sender: TObject);
    procedure miThickClick(Sender: TObject);
  private

    FMouseDownX: Integer;
    FMouseDownY: Integer;

    //FClickedSerie: TaOPCLineSeries;
    FClickedSerie: TCustomSeries;
    FVertDelta: extended;
    FSerieShift: extended;

    FShowFullSeriesName: boolean;
    FAxisForEachSeries: Boolean;
    //FInterval: TOPCInterval;

    FAllClient: Boolean;
    FSavePosition: TSavePosition;
    FClickedTool: TTeeCustomTool;
    FSeriesWidth: Integer;

    procedure StorePosition;
    procedure RestorePosition;

    procedure SetSeriesWidth(aWidth: Integer);

    procedure SetShowFullSeriesName(const Value: boolean);
    procedure ClickSeries(Sender: TCustomChart;
      Series: TChartSeries; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer;
      LegendClicked: boolean = false);

    procedure CalcLabelsFormat;
    function CheckMouseMove(x, y: integer): Boolean;

    procedure CreateAxis(aSerie: TChartSeries; aIndex: integer);
    //procedure UpdateChartAfterLoad;

    function FindSerie(aDataLink: TaCustomDataLink): TCustomSeries;
    function FindSerieByParam(aPhysID: string; aSource: TaCustomOPCSource): TCustomSeries;

    //procedure BlinkSeries(aSeries: TLineSeries);
    procedure BlinkSeries(aSeries: TCustomSeries);

    function BlinkSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;

    function CreateOPCSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;

    function CreateOPCSerieByParam(aPhysID: string; aSource: TaCustomOPCSource; aStairsOptions: TDCStairsOptionsSet;
      aTag: Integer = 0; aControl: TObject = nil; aColor: TColor = clNone): TaOPCLineSeries;

    function CreateOPCGanttSerieByParam(aPhysID: string; aSource: TaCustomOPCSource;
      aTag: Integer = 0; aControl: TObject = nil; aColor: TColor = clNone): TaOPCGanttSeries;

    //procedure SetClickedSerie(const Value: TaOPCLineSeries);
    procedure SetClickedSerie(const Value: TCustomSeries);

    function GetInterval: TOPCInterval;
    procedure SetInterval(const Value: TOPCInterval);
    procedure SetAxisForEachSeries(const Value: Boolean);
    procedure SetClickedTool(const Value: TTeeCustomTool);

  protected
    procedure UpdateCaption;
    procedure DoIntervalChanged(Sender: TObject);

    procedure DoLoadSettings;
    procedure DoSaveSettings;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); override;
    function GetOPCSource: TaCustomMultiOPCSource; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateSeriesTitle;

    procedure RestoreFrom(aStore: TCustomIniFile; aSectionName: string);
    procedure StoreTo(aStore: TCustomIniFile; aSectionName: string);

    function SerieExists(aDataLink: TaOPCDataLink): Boolean;
    procedure UpdateClientActions;

    procedure ClearData;
    procedure ClearChart;

    procedure CheckAnimated;
    procedure UpdateSeriesData;
    function AddSerie(aDataLink: TaCustomDataLink; aDelIfExist: Boolean): TaOPCLineSeries; virtual;

    function AddSerieByParam(aPhysID: TPhysID; aStairs: TDCStairsOptionsSet;
      OPCSource: TaCustomOPCSource; aTitle: string; aColor: TColor; aDelIfExist: Boolean;
      aFilter: string; aLookupList: TaOPCLookupList = nil; aDisplayFormat: string = ''): TaOPCLineSeries;
    function AddGantSerieByParam(aPhysID: TPhysID; OPCSource: TaCustomOPCSource;
      aTitle: string; aColor: TColor; aDelIfExist: Boolean; aFilter: string): TaOPCGanttSeries;

    function AddSerieLine(aTitle: string; aValue: Double; aColor: TColor): TLineSeries;

    property Interval: TOPCInterval read GetInterval write SetInterval;

    property ShowFullSeriesName: boolean read FShowFullSeriesName write SetShowFullSeriesName;
    property AxisForEachSeries: Boolean read FAxisForEachSeries write SetAxisForEachSeries;

    //property ClickedSerie: TaOPCLineSeries read FClickedSerie write SetClickedSerie;
    property ClickedSerie: TCustomSeries read FClickedSerie write SetClickedSerie;
    property ClickedTool: TTeeCustomTool read FClickedTool write SetClickedTool;
  published
    property SeriesWidth: Integer read FSeriesWidth write SetSeriesWidth;
  end;

implementation

uses
  StrUtils,
  aOPCSeries,
  aOPCChartMessureTool,
  uDataLinkedClasses;

{$R *.dfm}

const
  cIntervalHelpContext = 0;

const
  cDayColors: array of TColor = [
    clRed,
    clGreen,
    $2300B0, // темно синий
    $FFC11E, // оранжевый
    $FE9E76, // розовый
    $A854A5, // фиоленовый
    $64C7FF, // голубой
    $A771FE // светло фиолетовый

//    $0260E8,
//    $45D09E,
//    $FFC11E,
//    $F85C50,
//    $EF2FA2,
//    $3F0B81
  ];

procedure TChartFrame.a3DExecute(Sender: TObject);
begin
  Chart.View3D := not Chart.View3D;
  a3D.Checked := Chart.View3D;
end;

procedure TChartFrame.aAddMessureBandExecute(Sender: TObject);
var
  m: TaOPCMessureBandTool;
begin
  m := TaOPCMessureBandTool(Chart.Tools.Add(TaOPCMessureBandTool.Create(Self)));
  m.Axis := Chart.BottomAxis;

  m.Position := ppRightTop;
  m.Text := 'Messure';
  m.Active := True;
  m.Band.Active := True;
  m.Band.StartValue := (m.Axis.Minimum + m.Axis.Maximum)/2;
  m.Band.EndValue := m.Band.StartValue + (m.Axis.Maximum - m.Axis.Minimum)/10;
  //m.AutoSize := True;
  m.Band.StartLine.Active := True;
  m.Band.EndLine.Active := True;

  m.Band.Pen.Style := psClear;
  m.Band.Color := $00FFF3E8;


  UpdateClientActions;
end;

procedure TChartFrame.aAddMessureExecute(Sender: TObject);
var
  m: TaOPCMessureTool;
begin
  m := TaOPCMessureTool(Chart.Tools.Add(TaOPCMessureTool.Create(Self)));
  m.Axis := Chart.BottomAxis;

  m.Position := ppRightTop;
  m.Text := 'Messure';
  m.Active := True;
  m.Line.Active := True;
  m.Line.Value := (m.Axis.Minimum + m.Axis.Maximum)/2;
  //m.AutoSize := True;

  UpdateClientActions;
end;

procedure TChartFrame.aAllClientExecute(Sender: TObject);
begin
  if FAllClient then
  begin
    aAllClient.ImageIndex := 69;
    aAllClient.Caption := 'Развернуть';
    RestorePosition;
  end
  else
  begin
    StorePosition;
    Align := alClient;
    FAllClient := True;
    aAllClient.ImageIndex := 70;
    aAllClient.Caption := 'Свернуть';
  end;
end;

procedure TChartFrame.aAutoScaleYExecute(Sender: TObject);
//var
//  i: Integer;
begin
  //  for i := 0 to Chart.Axes.Count - 1 do
  //    if not Chart.Axes[i].Horizontal then
  //      Chart.Axes[i].Automatic := aAutoScaleY.Checked;
  Chart.AutoScaleY := not Chart.AutoScaleY;
  aAutoScaleY.Checked := Chart.AutoScaleY;
end;

procedure TChartFrame.aAxisForEachSeriesExecute(Sender: TObject);
//var
//  i: integer;
begin
  AxisForEachSeries := not AxisForEachSeries;
//  aAxisForEachSeries.Checked := not aAxisForEachSeries.Checked;
//  for i := 0 to Chart.SeriesCount - 1 do
//  begin
//    if aAxisForEachSeries.Checked then
//    begin
//      Chart.Series[i].VertAxis := aCustomVertAxis;
//      if not Assigned(Chart.Series[i].CustomVertAxis) then
//        CreateAxis(Chart.Series[i], i);
//    end
//    else
//    begin
//      if Assigned(Chart.Series[i].CustomVertAxis) then
//        Chart.Series[i].CustomVertAxis.Free;
//      Chart.Series[i].VertAxis := aLeftAxis;
//    end;
//  end;
end;

procedure TChartFrame.aClearExecute(Sender: TObject);
begin
  //  if DockingControl.Focused then
  //  if ActiveControl = Chart then
  ClearData;
end;

procedure TChartFrame.aClearMessuresExecute(Sender: TObject);
var
  i: Integer;
begin
//  Chart.Tools.Clear;
  for i := Chart.Tools.Count - 1 downto 0 do
    if (Chart.Tools.Items[i] is TaOPCMessureTool)
      or (Chart.Tools.Items[i] is TaOPCMessureBandTool) then
      Chart.Tools.Items[i].Free;
end;

procedure TChartFrame.aCopyExecute(Sender: TObject);
begin
  Chart.CopyToClipboardBitmap;
end;

function TChartFrame.AddGantSerieByParam(aPhysID: TPhysID; OPCSource: TaCustomOPCSource; aTitle: string; aColor: TColor;
  aDelIfExist: Boolean; aFilter: string): TaOPCGanttSeries;
var
  r: TCustomSeries;
  //aSerie: TaOPCGanttSeries;
begin
  Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  // ищем график
  r := FindSerieByParam(aPhysID, OPCSource); // BlinkSerie(aDataLink);

  // создаем, если такого нет (моргать не нужно)
  if not Assigned(r) then
  begin
    Result := CreateOPCGanttSerieByParam(aPhysID, OPCSource, 0, nil, aColor);
    Result.ShortName := aTitle;
    Result.FullName := aTitle;
    Result.OutLine.Visible := False;
    if aFilter <> '' then
      Result.Filter.Expression := aFilter;

  end

  // удаляем, если нужно
  else if aDelIfExist then
  begin
    ClickedSerie := r;
    aDeleteSeriesExecute(Self);
    Exit;
  end

  // или моргаем если не нужно удалять
  else
  begin
    BlinkSeries(r);

    if r is TaOPCGanttSeries then
      Result := TaOPCGanttSeries(r)
    else
      Exit;
  end;

  Result.FillSerie(Interval.Kind = ikShift);
  ClickedSerie := Result;
  //Result := aSerie;

  CheckAnimated;
  UpdateClientActions;
end;

function TChartFrame.AddSerie(aDataLink: TaCustomDataLink; aDelIfExist: Boolean): TaOPCLineSeries;
var
  aSerie: TCustomSeries;
begin
  Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  // ищем график
  aSerie := FindSerie(aDataLink); // BlinkSerie(aDataLink);

  // создаем, если такого нет (моргать не нужно)
  if not Assigned(aSerie) then
    Result := CreateOPCSerie(aDataLink)

  // удаляем, если нужно
  else if aDelIfExist then
  begin
    ClickedSerie := aSerie;
    aDeleteSeriesExecute(Self);
    Exit;
  end

  // или моргаем если не нужно удалять
  else
  begin
    BlinkSeries(aSerie);
    if aSerie is TaOPCLineSeries then
      Result := TaOPCLineSeries(aSerie)
    else
      Exit;
  end;

  Result.FillOPCData(Interval.Kind = ikShift);
  ClickedSerie := Result;//aSerie;
  //Result := aSerie;

  CheckAnimated;
  UpdateClientActions;
end;

function TChartFrame.AddSerieByParam(aPhysID: TPhysID; aStairs: TDCStairsOptionsSet;
      OPCSource: TaCustomOPCSource; aTitle: string; aColor: TColor; aDelIfExist: Boolean;
      aFilter: string; aLookupList: TaOPCLookupList = nil; aDisplayFormat: string = ''): TaOPCLineSeries;
var
  //  aSerie: TaOPCLineSeries;
  r: TCustomSeries;
begin
  Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  // ищем график
  r := FindSerieByParam(aPhysID, OPCSource); // BlinkSerie(aDataLink);

  // создаем, если такого нет (моргать не нужно)
  if not Assigned(r) then
  begin
    Result := CreateOPCSerieByParam(aPhysID, OPCSource, aStairs, 0, nil, aColor);
    Result.ShortName := aTitle;
    Result.FullName := aTitle;
    Result.DisplayFormat := aDisplayFormat;
    if aFilter <> '' then
      Result.Filter.Expression := aFilter;
    if Assigned(aLookupList) then
    begin
      Result.LookupList := aLookupList;
      Result.Marks.Visible := True;
    end;
  end

  // удаляем, если нужно
  else if aDelIfExist then
  begin
    ClickedSerie := r;
    aDeleteSeriesExecute(Self);
    Exit;
  end

  // или моргаем если не нужно удалять
  else
  begin
    BlinkSeries(r);
    if r is TaOPCLineSeries then
      Result := TaOPCLineSeries(r)
    else
      Exit;
  end;

  Result.FillOPCData(Interval.Kind = ikShift);
  ClickedSerie := Result;
  //Result := aSerie;

  CheckAnimated;
  UpdateClientActions;
end;

function TChartFrame.AddSerieLine(aTitle: string; aValue: Double; aColor: TColor): TLineSeries;
begin
  //Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  Result := TLineSeries.Create(Chart);// CreateOPCSerieByParam(aPhysID, OPCSource, aStairs, 0, nil, aColor);
  Result.Title := aTitle;
  Result.Color := aColor;

  Result.AddXY(Chart.BottomAxis.Minimum, aValue, '', aColor);
  Result.AddXY(Chart.BottomAxis.Maximum, aValue, '', aColor);

  Chart.AddSeries(Result);

  CheckAnimated;
  UpdateClientActions;
end;

procedure TChartFrame.aDeleteSeriesExecute(Sender: TObject);
var
  s: IaOPCSeries;
begin
  if Assigned(ClickedSerie) then
  begin
    if Assigned(ClickedSerie.CustomVertAxis) then
      ClickedSerie.CustomVertAxis.Free;

    FClickedSerie.Free;
    ClickedSerie := nil;
  end;

  if Chart.SeriesList.Count > 0 then
  begin
    if Supports(Chart.Series[0], IaOPCSeries, s) and (Chart.Series[0] is TCustomSeries) then
      ClickedSerie := TCustomSeries(Chart.Series[0]);

//    if Chart.SeriesList.Items[0] is TaOPCLineSeries then
//      ClickedSerie := TaOPCLineSeries(Chart.SeriesList.Items[0]);
  end;

  CheckAnimated;
  UpdateClientActions;
end;

procedure TChartFrame.aDelSensorValuesExecute(Sender: TObject);
var
  i: Integer;
  aSeries: TaOPCLineSeries;
  aTool: TaOPCMessureBandTool;
begin
  if not (Assigned(ClickedTool) and (ClickedTool is TaOPCMessureBandTool)) then
    Exit;

  aTool := TaOPCMessureBandTool(ClickedTool);

  for i := 0 to Chart.SeriesList.Count - 1 do
  begin
    if not (Chart.Series[i] is TaOPCLineSeries) then
      Continue;

    aSeries := TaOPCLineSeries(Chart.Series[i]);
    if Assigned(aSeries.OPCSource) and (aSeries.OPCSource is TaOPCSource) then
      TaOPCSource(aSeries.OPCSource).DelSensorValues(aSeries.PhysID, aTool.Band.StartValue, aTool.Band.EndValue);

  end;
end;

procedure TChartFrame.aDelToolExecute(Sender: TObject);
begin
  if Assigned(ClickedTool) then
  begin
    ClickedTool.Free;
    ClickedTool := nil;
  end;
end;

procedure TChartFrame.aEditorExecute(Sender: TObject);
begin
{$IFDEF TEECHARTEDITOR}
  with TChartEditor.Create(Self) do
  begin
    try
      TeeSetRussian;
      Options := [
        //ceAdd,
      //ceDelete,
      ceChange,
        //ceClone,
      ceDataSource,
        ceTitle,
        // ceHelp,
      ceGroups, // 6.02
        ceGroupAll, // 6.02
        ceOrderSeries // 7.06      ;
        ];
      Title := Caption;
      Chart := Self.Chart;
      Execute;
    finally
      Free;
    end;
  end;
{$ENDIF}
end;

procedure TChartFrame.aIntervalExecute(Sender: TObject);
begin
  ShowIntervalForm(Interval, cIntervalHelpContext, GetParentForm(Self));
end;

procedure TChartFrame.aLegendExecute(Sender: TObject);
begin
  Chart.Legend.Visible := not Chart.Legend.Visible;
  aLegend.Checked := Chart.Legend.Visible;
end;

procedure TChartFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  mp: TPoint;
  c: TControl;
  //  Key: Word;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    if WindowFromPoint(Msg.pt) = Chart.Handle then
    begin
      mp := ScreenToClient(Msg.pt); // MousePos);
      c := ControlAtPos(mp, false, true);
      if (c <> nil) and (c is TChart) then
      begin
        c.Perform(CM_MOUSEWHEEL, Msg.WParam, Msg.LParam);
        Handled := true;
      end;
    end;
  end;
  //  else if Msg.message = WM_KEYDOWN then
  //  begin
  //    Key := Msg.wParam;
  //    case Key of
  //      vk_Delete: aClearExecute(Self);
  //    end;
  //  end;

end;

procedure TChartFrame.ApplicationEvents1ShowHint(var HintStr: string;
  var CanShow: Boolean; var HintInfo: THintInfo);
var
  v: Integer;
  i, vi: integer;
  P: TPoint;

  x, y: double;
  x1, y1, y21, x21: double;
  x2, y2: double;
  xt, yt: double;
  k, dxa, dya, dxp, dyp: double;

  Chart: TChart;
  s: TCustomSeries;
  Serie: TaOPCLineSeries;
  aTool: TDCTextColorBandTool;
  yStr: string;
  vertAxis: TChartAxis;
begin

  with HIntInfo do
  begin
    if HintControl is TChart then
    begin
      try
        Chart := TChart(HintControl);
        P := Chart.ScreenToClient(Mouse.CursorPos);
        for i := Chart.SeriesList.Count - 1 downto 0 do
        begin

//          if not (Chart.SeriesList.Items[i] is TaOPCLineSeries) then
//            Continue;

          if not Supports(Chart.Series[i], IaOPCSeries) then
            Continue;

          //Serie := Chart.SeriesList.Items[i] as TaOPCLineSeries;
          //v := Serie.Clicked(P.x, P.y);
          v := Chart.Series[i].Clicked(P.X, P.Y);
          if v <> -1 then
          begin
            // все кроме Line
            if not (Chart.Series[i] is TaOPCLineSeries) then
            begin
              CanShow := true;
              HintStr := Chart.Series[i].Title;
              HintPos.X := Mouse.CursorPos.X + 16;
              HintPos.Y := Mouse.CursorPos.Y + 16;
              CursorRect := Rect(p.X, p.Y, p.X + 1, P.y + 1);
              Break;
            end;

            // Line
            Serie := Chart.Series[i] as TaOPCLineSeries;

            Serie.GetCursorValues(x, y);

            vi := Serie.GetCursorValueIndex;
            if vi < 0 then
              Exit;

            // если есть возможность определим точно x (время)
            if vi < (Serie.Count - 1) then
            begin
              x1 := Serie.XValue[vi];
              y1 := Serie.YValue[vi];
              x2 := Serie.XValue[vi + 1];
              y2 := Serie.YValue[vi + 1];
              x21 := x2 - x1;
              y21 := y2 - y1;
              xt := x;
              yt := y;

              try
                //if x21 <> 0 then
                if (y21 <> 0) and (x21 <> 0) then
                begin
                  if Serie.VertAxis = aCustomVertAxis then
                    vertAxis := Serie.CustomVertAxis
                  else if Serie.VertAxis = aLeftAxis then
                    vertAxis := Chart.LeftAxis
                  else if Serie.VertAxis = aRightAxis then
                    vertAxis := Chart.RightAxis
                  else
                    raise Exception.Create('Unknown Serie.VertAxis');

                  dxa := Chart.BottomAxis.Maximum - Chart.BottomAxis.Minimum;
                  dya := vertAxis.Maximum - vertAxis.Minimum;

                  dxp := Chart.ChartRect.Right - Chart.ChartRect.Left;
                  dyp := Chart.ChartRect.Bottom - Chart.ChartRect.Top;

                  if (dxa <> 0) and (dyp <> 0) then 
                  begin
                    k := (dya * dxp) / (dxa * dyp);

                    x := (x2 * y21 / x21 - y2 + yt - k * xt) / (y21 / x21 - k);
                    y := k * x + yt - k * xt;
                  end;

                end;
              except
                on e: Exception do
                  ;
              end;
            end;
            if Serie is TaOPCLineSeries then
            begin
              if Serie.IsState and Assigned(Serie.StateLookupList) then
              begin
                y := Serie.YValue[vi];
                yStr := Serie.StateLookupList.Items.Values[FloatToStr(y * TaOPCLineSeries(Serie).Scale -
                  TaOPCLineSeries(Serie).Shift)];
              end
              else if Serie.ColorEachLine and Serie.ColorEachPoint and
                (Serie.ValueColor[vi] = cErrorSerieColor) then
              begin
                yStr := Serie.Labels[vi];
              end
              else if Assigned(Serie.LookupList) then
              begin
                y := Serie.YValue[vi];
                yStr := Serie.LookupList.Items.Values[FloatToStr(y * TaOPCLineSeries(Serie).Scale -
                  TaOPCLineSeries(Serie).Shift)];
              end
              else
              begin
                yStr := FormatValue(
                  y * TaOPCLineSeries(Serie).Scale - TaOPCLineSeries(Serie).Shift,
                  Serie.ValueFormat) + ' ' + Serie.SensorUnitName;

                if TaOPCLineSeries(Serie).Shift <> 0 then
                  yStr := yStr + #13#10 +
                    'значение после сдвига = ' +
                    FormatValue(y, Serie.ValueFormat) + ' ' + Serie.SensorUnitName

              end;
            end
            else
              yStr := FloatToStr(Serie.YValue[vi]);

            CanShow := true;
            HintStr := Serie.Title + #13#10 +
              'время = ' + DateTimeToStr(x) + #13#10 +
              'значение = ' + yStr;
            //            if Serie.Shift <> 0 then
            //              HintStr := HintStr + #13#10 +
            //                'значение после сдвига = ' +
            HintPos.X := Mouse.CursorPos.X + 16;
            HintPos.Y := Mouse.CursorPos.Y + 16;
            CursorRect := Rect(p.X, p.Y, p.X + 1, P.y + 1);
            Break;
          end;
        end;

        if HintStr = '' then
        begin
          for i := Chart.Tools.Count - 1 downto 0 do
          begin
            if not (Chart.Tools.Items[i] is TDCTextColorBandTool) then
              Continue;

            aTool := Chart.Tools.Items[i] as TDCTextColorBandTool;
            if aTool.Clicked(P.x, P.y) then
            begin
              if aTool.Text <> '' then
              begin
                CanShow := true;
                HintStr := aTool.Text;
                HintPos.X := Mouse.CursorPos.X + 16;
                HintPos.Y := Mouse.CursorPos.Y + 16;
                CursorRect := Rect(p.X, p.Y, p.X + 1, P.y + 1);
                Break;
              end;
            end;
          end;
        end;

      except
        on e: Exception do
          OPCLog.WriteToLogFmt('TChartFrame.ApplicationEvents1ShowHint: %s', [e.Message]);
      end;
    end
  end;
end;

procedure TChartFrame.aRuningExecute(Sender: TObject);
begin
  Chart.RealTime := not Chart.RealTime;
  //  if Chart.RealTime then
  //    Interval.Kind := ikShift;

  UpdateSeriesData;
  UpdateClientActions;
end;

procedure TChartFrame.aSerieScaleExecute(Sender: TObject);
var
  sNewScale: string;
  s: IaOPCSeries;
begin
  if Assigned(ClickedSerie) then
  begin
    if not Supports(ClickedSerie, IaOPCSeries, s) then
      Exit;

    sNewScale := FloatToStr(s.Scale);
    if InputQuery('Укажите масштаб', ClickedSerie.Title, sNewScale) then
    begin
      if FormatSettings.DecimalSeparator = '.' then
        sNewScale := ReplaceStr(sNewScale, ',', '.')
      else
        sNewScale := ReplaceStr(sNewScale, '.', ',');

      s.Scale := StrToFloatDef(sNewScale, s.Scale);
    end;
  end;
end;

procedure TChartFrame.aSerieShiftExecute(Sender: TObject);
var
  sNewShift: string;
  s: IaOPCSeries;
begin
  if Assigned(ClickedSerie) then
  begin
    if not Supports(ClickedSerie, IaOPCSeries, s) then
      Exit;

    sNewShift := FloatToStr(s.Shift);
    if InputQuery('Укажите величину сдвига', ClickedSerie.Title, sNewShift) then
    begin
      if FormatSettings.DecimalSeparator = '.' then
        sNewShift := ReplaceStr(sNewShift, ',', '.')
      else
        sNewShift := ReplaceStr(sNewShift, '.', ',');

      s.Shift := StrToFloatDef(sNewShift, s.Shift);
    end;
  end;
end;

procedure TChartFrame.aSeriesShowValueExecute(Sender: TObject);
begin
  if Assigned(ClickedSerie) then
    ClickedSerie.Marks.Visible := aSeriesShowValue.Checked;
end;

procedure TChartFrame.aSerieStatisticExecute(Sender: TObject);
var
  i: integer;
  aMessage: string;
  aAvg, aAvgTime: double;
  aIntegral: double;
  aSum: double;
  s: TaOPCLineSeries;

  v: double;
  t: TDateTime;
  aCount: integer;

  deltaTime: TDateTime;
  deltaValue: double;
begin
  if not Assigned(ClickedSerie) then
    exit;

  if ClickedSerie.YValues.Count = 0 then
    exit;

  aAvgTime := 0;
  aCount := 1;
  aIntegral := 0;
  v := ClickedSerie.YValues[0];
  t := ClickedSerie.XValues[0];
  aSum := v;

  for i := 1 to ClickedSerie.YValues.Count - 1 do
  begin
    if ClickedSerie.XValues[i] <> t then
    begin
      inc(aCount);
      aSum := aSum + ClickedSerie.YValues[i];
      deltaTime := ClickedSerie.XValues[i] - t;
      deltaValue := ClickedSerie.YValues[i] - v;
      aIntegral := aIntegral + (deltaTime * (v + deltaValue / 2));
      v := ClickedSerie.YValues[i];
      t := ClickedSerie.XValues[i];
    end;
    if (ClickedSerie is TaOPCLineSeries) and (TaOPCLineSeries(ClickedSerie).StairsOptions = []) then
      aAvgTime := aAvgTime + (ClickedSerie.YValue[i - 1] *
        (ClickedSerie.XValue[i] - ClickedSerie.XValue[i - 1]))
    else
      aAvgTime := aAvgTime + ((ClickedSerie.YValue[i] + ClickedSerie.YValue[i - 1]) / 2 *
        (ClickedSerie.XValue[i] - ClickedSerie.XValue[i - 1]))

  end;
  aAvg := aSum / aCount;
  aAvgTime := aAvgTime / (ClickedSerie.XValues.Last - ClickedSerie.XValues.First);
  aIntegral := aIntegral * 24;

  if ClickedSerie is TaOPCLineSeries then
  begin
    s := TaOPCLineSeries(ClickedSerie);
    aMessage := Format(
      '%s'#13#13 +
      'Интервал: %s ч.'#13#13 +
      'Минимум : %s %s'#13 +
      'Максимум: %s %s'#13 +
      'Среднее : %s %s'#13 +
      'Средневзвешенное : %s %s'#13 +
      'Интеграл         : %s %s*ч'#13,
      [
      ClickedSerie.Title,
        FormatFloat('# ##0.##', (ClickedSerie.XValues.Last - ClickedSerie.XValues.First) * 24),
        FormatFloat(s.DisplayFormat, ClickedSerie.MinYValue), s.SensorUnitName,
        FormatFloat(s.DisplayFormat, ClickedSerie.MaxYValue), s.SensorUnitName,
        FormatFloat('# ##0.00', aAvg), s.SensorUnitName,
        FormatFloat('# ##0.00', aAvgTime), s.SensorUnitName,
        FormatFloat('# ##0.00', aIntegral), s.SensorUnitName
        ]);
  end
  else
  begin
    aMessage := Format(
      '%s'#13#13 +
      'Интервал: %s ч.'#13#13 +
      'Минимум : %s '#13 +
      'Максимум: %s '#13 +
      'Среднее : %s '#13 +
      'Средневзвешенное : %s '#13 +
      'Интеграл         : %s *ч'#13,
      [
      ClickedSerie.Title,
        FormatFloat('# ##0.##', (ClickedSerie.XValues.Last - ClickedSerie.XValues.First) * 24),
        FloatToStr(ClickedSerie.MinYValue),
        FloatToStr(ClickedSerie.MaxYValue),
        FormatFloat('# ##0.00', aAvg),
        FormatFloat('# ##0.00', aAvgTime),
        FormatFloat('# ##0.00', aIntegral)
        ]);

  end;

  Application.MessageBox(PChar(aMessage), PChar(ClickedSerie.Title), MB_OK +
    MB_ICONINFORMATION + MB_TOPMOST);

  //MessageDlg(aMessage,mtInformation,[mbOK],0);
end;

procedure TChartFrame.aShowZeroExecute(Sender: TObject);
begin
  Chart.ShowZero := not Chart.ShowZero;
  aShowZero.Checked := Chart.ShowZero;
end;

procedure TChartFrame.aBuildExecute(Sender: TObject);
begin
  Interval.Lock;
  try
    Interval.Kind := ikInterval;
    Interval.ShiftKind := TShiftKind.skNone;
    Interval.SetInterval(Chart.BottomAxis.Minimum, Chart.BottomAxis.Maximum);
  finally
    Interval.Unlock;
  end;
  //IntervalChanged;
end;

procedure TChartFrame.aUpdateExecute(Sender: TObject);
begin
  UpdateSeriesData;

  //  Interval.Kind := ikInterval;
  //  Interval.Date1 := Chart.BottomAxis.Minimum;
  //  Interval.Date2 := Chart.BottomAxis.Maximum;
  //  IntervalChanged;
end;

procedure TChartFrame.aZoomOutExecute(Sender: TObject);
begin
  Chart.UndoZoom;
end;

function TChartFrame.BlinkSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;
var
  i: integer;
  OldColor: TColor;
begin
  Result := nil;
  if not (aDataLink is TaOPCDataLink) then
    Exit;

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if not (Chart.Series[i] is TaOPCLineSeries) then
      continue;

    Result := Chart.Series[i] as TaOPCLineSeries;
    if (Result.PhysID = aDataLink.PhysID) and
      (Result.OPCSource = TaOPCDataLink(aDataLink).OPCSource)
      and (Result.Scale = 1) and (Result.Shift = 0) and (Result.DifferentialOrder = 0)
      and not Result.IsState then
    begin
      OldColor := Result.SeriesColor;
      Result.SeriesColor := clWhite;
      Chart.Update;
      Application.ProcessMessages;
      Result.SeriesColor := OldColor;
      Break;
    end;
    Result := nil;
  end;
end;

//procedure TChartFrame.BlinkSeries(aSeries: TLineSeries);
procedure TChartFrame.BlinkSeries(aSeries: TCustomSeries);
var
  OldColor: TColor;
begin
  if not Assigned(aSeries) then
    Exit;

  OldColor := aSeries.SeriesColor;
  try
    aSeries.SeriesColor := clWhite;
    Chart.Update;
    Application.ProcessMessages;
  finally
    aSeries.SeriesColor := OldColor;
  end;
end;

procedure TChartFrame.CalcLabelsFormat;
var
  dif: extended;
  TimeDif: extended;
begin
  dif := Chart.LeftAxis.Maximum - Chart.LeftAxis.Minimum;
  if dif <= 1 then
    Chart.LeftAxis.AxisValuesFormat := '# ### ##0.00'
  else if dif <= 10 then
    Chart.LeftAxis.AxisValuesFormat := '# ### ##0.0'
  else
    Chart.LeftAxis.AxisValuesFormat := '# ### ##0';

  TimeDif := Chart.BottomAxis.Maximum - Chart.BottomAxis.Minimum;
  if TimeDif <= 5 / 24 / 60 then //1 минута
    Chart.BottomAxis.DateTimeFormat := 'hh:mm:ss'
  else if TimeDif <= 1 then //1 суток
    Chart.BottomAxis.DateTimeFormat := 'hh:mm'
  else
    Chart.BottomAxis.DateTimeFormat := 'dd.mm.yy';
end;

procedure TChartFrame.ChartBeforeDrawAxes(Sender: TObject);
begin
  CalcLabelsFormat;
end;

procedure TChartFrame.ChartClickLegend(Sender: TCustomChart;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tmp: integer;
  Series: TChartSeries;
begin
  tmp := Sender.Legend.Clicked(x, y);
  if tmp > -1 then
  begin
    Series := Sender.SeriesLegend(tmp, true);
    ClickSeries(Sender, Series, Button, Shift, X, Y, true);
  end;
end;

procedure TChartFrame.ChartClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ClickSeries(Sender, Series, Button, Shift, X, Y, false);

  if not (ssShift in Shift) then
    Chart.CancelMouse := false;
end;

procedure TChartFrame.ChartContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  i, v: integer;
  //Serie: TCustomSeries;
  s: IaOPCSeries;
  P: TPoint;
begin
  Handled := CheckMouseMove(MousePos.x, MousePos.y);

  if not Handled then
  begin
    P := Chart.ScreenToClient(Mouse.CursorPos);

    // проверяем необходимость вызвать контекстное меню для графика
    for i := Chart.SeriesCount - 1 downto 0 do
    begin
//      if not (Chart.SeriesList.Items[i] is TaOPCLineSeries) then
//        Continue;
      if not Supports(Chart.Series[i], IaOPCSeries, s) then
        Continue;

      //Serie := Chart.SeriesList.Items[i] as TaOPCLineSeries;
      v := Chart.SeriesList.Items[i].Clicked(P.X, P.Y);
      if v <> -1 then
      begin
        Handled := True;
        ClickedSerie := TCustomSeries(Chart.Series[i]);
        aSeriesShowValue.Checked := ClickedSerie.Marks.Visible;

        pmSeries.Popup(
          Mouse.CursorPos.X,
          Mouse.CursorPos.Y);
        Exit;
      end;
    end;

    // проверяем необходимость вызвать контекстное меню для Инструмента
    for i := Chart.Tools.Count - 1 downto 0 do
    begin
      if Chart.Tools.Items[i] is TaOPCMessureBandTool then
      begin
        if TaOPCMessureBandTool(Chart.Tools.Items[i]).Clicked(P.X, P.Y) then
        begin
          Handled := True;
          ClickedTool := Chart.Tools.Items[i];
          pmBandTools.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        end;
      end
      else if Chart.Tools.Items[i] is TaOPCMessureTool then
      begin
        if TaOPCMessureTool(Chart.Tools.Items[i]).Clicked(P.X, P.Y) then
        begin
          Handled := True;
          ClickedTool := Chart.Tools.Items[i];
          pmLineTools.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        end;
      end;

    end;


    Chart.CancelMouse := false; // can
  end;

end;

procedure TChartFrame.ChartDragDrop(Sender, Source: TObject; X, Y: Integer);
//var
//  i: integer;
begin
  if (Source is TaOPCLabel) and (TaOPCLabel(Source).PhysID <> '') then
     AddSerie(TaOPCLabel(Source).DataLink, True)
  else
    Exit;
end;

procedure TChartFrame.ChartDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TaOPCLabel) and (TaOPCLabel(Source).PhysID <> '');
end;

procedure TChartFrame.ChartFormActionsUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  UpdateClientActions;
end;

procedure TChartFrame.ChartKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) then
  begin
    case Key of
      VK_DELETE: aClearExecute(Sender);
      Ord('I'): aIntervalExecute(Sender);
      Ord('0'): aShowZeroExecute(Sender);
      Ord('3'): a3DExecute(Sender);
      Ord('L'): aLegendExecute(Sender);
      Ord('C'): aCopyExecute(Sender);
      //Ord('P'): aPrintExecute(Sender);
      Ord('E'): aEditorExecute(Sender);
      Ord('Z'): aZoomOutExecute(Sender);
    end;
  end
  else
  begin
    case Key of
      VK_F9: aRuningExecute(Sender);
      VK_F5: aUpdateExecute(Sender);
      VK_F6: aBuildExecute(Sender);
    end;
  end;
end;

procedure TChartFrame.ChartMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tmp: integer;
  s: IaOPCSeries;
begin
  FMouseDownX := X;
  FMouseDownY := Y;

  if Button = mbLeft then
  begin
    tmp := Chart.Legend.Clicked(x, y);
    if tmp < 0 then
      Exit;

    if Supports(Chart.SeriesLegend(tmp, true), IaOPCSeries, s) then
      ClickedSerie := TCustomSeries(Chart.SeriesLegend(tmp, true));
  end;

  if Parent is TForm then
    TForm(Parent).SetFocusedControl(Chart);

end;

procedure TChartFrame.ChartMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  aLeftAxis: TChartAxis;
  s: IaOPCSeries;
begin
  if Assigned(ClickedSerie) then
  begin
    if not Supports(ClickedSerie, IaOPCSeries, s) then
      Exit;

    if (ssLeft in Shift) and (ssShift in Shift) then
    begin
      if Assigned(ClickedSerie.CustomVertAxis) then
        aLeftAxis := ClickedSerie.CustomVertAxis
      else
        aLeftAxis := Chart.LeftAxis;

      s.Shift := FSerieShift + FVertDelta / aLeftAxis.IAxisSize * (FMouseDownY - Y)
    end
  end;
end;

procedure TChartFrame.ChartScroll(Sender: TObject);
begin
  //  if (Chart.BottomAxis.Minimum < Interval.Date1) or
  //    (Chart.BottomAxis.Maximum > Interval.Date2) then
  //  begin
  //    Interval.Kind := ikInterval;
  //    Interval.Date1 := Chart.BottomAxis.Minimum;
  //    Interval.Date2 := Chart.BottomAxis.Maximum;
  //    UpdateSeriesData;
  //  end;
end;

procedure TChartFrame.ChartUndoZoom(Sender: TObject);
begin
  UpdateClientActions;
  aZoomOut.Enabled := false;
end;

procedure TChartFrame.ChartZoom(Sender: TObject);
begin
  //aZoomOut.Enabled := true;
  UpdateClientActions;
end;

procedure TChartFrame.CheckAnimated;
var
  i: integer;
  AllVisibleCount: integer;
begin
  AllVisibleCount := 0;
  for i := 0 to Chart.SeriesCount - 1 do
  begin
    AllVisibleCount := AllVisibleCount + Chart.Series[i].Count; // .VisibleCount;
    if AllVisibleCount > 10000 then
    begin
      Chart.Zoom.Animated := false;
      exit;
    end;
  end;
  Chart.Zoom.Animated := True;

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if Assigned(Chart.Series[i].CustomVertAxis) then
      Chart.Series[i].CustomVertAxis.PositionPercent := (i + 1) * 50;
  end;
end;

function TChartFrame.CheckMouseMove(x, y: integer): Boolean;
begin
  Result := (Abs(FMouseDownX - x) > 5) or (Abs(FMouseDownY - y) > 5);
end;

procedure TChartFrame.ClearChart;
begin
  ClickedSerie := nil;
  while Chart.SeriesCount > 0 do
  begin
    if Assigned(Chart.Series[0].CustomVertAxis) then
      Chart.Series[0].CustomVertAxis.Free;
    Chart.Series[0].free;
  end;
  UpdateClientActions;
end;

procedure TChartFrame.ClearData;
begin
  ClearChart;
end;

procedure TChartFrame.ClickSeries(Sender: TCustomChart; Series: TChartSeries;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; LegendClicked: boolean);
var
  s: IaOPCSeries;
begin
  if (Button = mbLeft) then
  begin
    if Supports(Series, IaOPCSeries, s) then
      ClickedSerie := TCustomSeries(Series);

//    if Series is TaOPCLineSeries then
//      ClickedSerie := TaOPCLineSeries(Series);
    //    else
    //      ClickedSerie := nil;

    if not (LegendClicked and Chart.Legend.CheckBoxes) then
    begin
      if (Shift = [ssLeft]) then // просто шедчёк левой кнопкой
      begin // выдвинем на передний план
        while Sender.SeriesList[Sender.SeriesCount - 1] <> Series do
          Sender.SeriesDown(Series);
      end

      else if Supports(ClickedSerie, IaOPCSeries, s) then
      begin
        if (Shift = [ssLeft, ssCtrl]) and Assigned(ClickedSerie) then // + Ctrl
          s.Shift := 0 // сброс сдвига
        else if (Shift = [ssLeft, ssAlt]) and Assigned(ClickedSerie) then // + Alt
        begin
          if ClickedSerie.YValues.Count > 0 then
            s.Shift := -ClickedSerie.YValues[0]; // начинаем с нуля
        end;
      end;
    end;
  end
  else
  begin
    if (Button = mbRight) and LegendClicked then
    begin
      if Supports(Series, IaOPCSeries, s) then
      //if Series is TaOPCLineSeries then
      begin
        ClickedSerie := TCustomSeries(Series);
        aSeriesShowValue.Checked := ClickedSerie.Marks.Visible;
        pmSeries.Popup(Sender.ClientToScreen(Point(X, Y)).X, Sender.ClientToScreen(Point(X, Y)).Y);
      end
        //      else
        //        ClickedSerie := nil;
    end;
  end;

end;

constructor TChartFrame.Create(AOwner: TComponent);
begin
  inherited;
  FShowFullSeriesName := true;

  Interval := TOPCInterval.LastInterval;
  //Interval.OnChanged := DoIntervalChanged;
  Chart.OnIntervalChanged := DoIntervalChanged;

  OnKeyDown := ChartKeyDown;

  ClickedSerie := nil;
  UpdateClientActions;

  Chart.SetSubComponent(True);

  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

//  TeeUseMouseWheel := false;
  Chart.Panning.MouseWheel := pmwNone;

  UpdateCaption;

end;

procedure TChartFrame.CreateAxis(aSerie: TChartSeries; aIndex: integer);
var
  aAxis: TChartAxis;
begin
  aAxis := TChartAxis.Create(Chart);
  aAxis.Automatic := True;
  //  aAxis.

    //aAxis.Title.Caption := aSerie.Title;
  aAxis.Title.Angle := 90;
  aAxis.Title.Visible := True;
  //aAxis.Title.Font.Color := Result.SeriesColor;

  aAxis.PositionUnits := muPixels;
  aAxis.PositionPercent := (aIndex + 1) * 50;

  aAxis.Grid.Style := psDot;
  aAxis.Grid.Width := 0;
  aAxis.Grid.Color := clBlack;

  aAxis.Axis.Color := aSerie.SeriesColor;
  aAxis.Axis.Width := 0;

  aAxis.StartPosition := 1;
  aAXis.EndPosition := 99;

  //aAxis.Grid.Color := Result.SeriesColor;
  aAxis.Grid.Visible := (aSerie = ClickedSerie);

  aSerie.VertAxis := aCustomVertAxis;
  aSerie.CustomVertAxis := aAxis;
end;

function TChartFrame.CreateOPCGanttSerieByParam(aPhysID: string; aSource: TaCustomOPCSource; aTag: Integer; aControl: TObject;
  aColor: TColor): TaOPCGanttSeries;
var
  aLabel: TaOPCLabel;
begin
  if not Assigned(aSource) then
  begin
    ShowMessage('Нет подключения');
    Abort;
  end;

  Result := TaOPCGanttSeries.Create(Chart);

  Result.PhysID := aPhysID;

  if aColor <> clNone then
    Result.SeriesColor := aColor;

  Result.Tag := aTag;

  if Assigned(aControl) and (aControl is TaOPCLabel) then
  begin
    aLabel := TaOPCLabel(aControl);

    Result.ValueFormat := aLabel.DisplayFormat;
    Result.LookupList := aLabel.LookupList;

    Result.ShortName := aLabel.Name;
    Result.FullName := aLabel.Name;
  end
  else if Assigned(aControl) and (aControl is TDataLinkExtInfo) then
  begin
    if Assigned(TDataLinkExtInfo(aControl).DataPoint) then
      Result.FullName := TDataLinkExtInfo(aControl).DataPoint.Name + '.' + TDataLinkExtInfo(aControl).Name
    else
      Result.FullName := TDataLinkExtInfo(aControl).Name;

    Result.ShortName := Result.FullName;
  end;


  Result.XValues.DateTime := True;
  Result.Marks.Style := smsLabel;
  Result.Marks.Font.Name := Chart.Title.Font.Name;
  Result.ShowFullName := False;

  Result.OPCSource := aSource;
  Result.ConnectionName := aSource.Name;
  Result.StateLookupList := TaOPCLookupList(aSource.States);

  Chart.AddSeries(Result);

  if aAxisForEachSeries.Checked then
  begin
    Result.VertAxis := aCustomVertAxis;
    CreateAxis(Result, Chart.SeriesList.Count - 1);
  end
  else
    Result.VertAxis := aLeftAxis;

  Result.UpdateRealTime;

  Result.Pen.Width := 0; // FSeriesWidth;
end;

function TChartFrame.CreateOPCSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;
var
  //aConnection: TOPCConnectionCollectionItem;
  aLabel: TaCustomOPCLabel;
begin
  Result := nil;
  if not Assigned(aDataLink) then
    Exit;

  if not (aDataLink is TaOPCDataLink) then
    Exit;

  if not Assigned(TaOPCDataLink(aDataLink).RealSource) then
  begin
    ShowMessage('Нет подключения');
    Abort;
  end;

  Result := TaOPCLineSeries.Create(Chart);
  Result.PhysID := aDataLink.PhysID;
  Result.StairsOptions := aDataLink.StairsOptions;

  Result.Tag := integer(aDataLink);

  if Assigned(aDataLink.Control) and (aDataLink.Control is TaCustomOPCLabel) then
  begin
    aLabel := TaCustomOPCLabel(aDataLink.Control);

    //Result.ValueFormat := aLabel.DisplayFormat;

    Result.LookupList := aLabel.LookupList;
    Result.DisplayFormat := aLabel.DisplayFormat;

    if not Assigned(Result.LookupList) then
      Result.DisplayFormat := RemoveNonNumbers(aLabel.DisplayFormat);

    Result.ShortName := aLabel.Name;
    Result.FullName := aLabel.Name;
  end
  else if (aDataLink is TDataLinkExtInfo) then
  begin
    if Assigned(TDataLinkExtInfo(aDataLink).DataPoint) then
      Result.FullName := TDataLinkExtInfo(aDataLink).DataPoint.Name + '.' + TDataLinkExtInfo(aDataLink).Name
    else
      Result.FullName := TDataLinkExtInfo(aDataLink).Name;

    Result.ShortName := Result.FullName;
  end;


  Result.XValues.DateTime := True;
  Result.Marks.Style := smsLabel;
  Result.Marks.Font.Name := Chart.Title.Font.Name;

//  Result.ShortName := aDataLink.Name;
//  Result.FullName := aDataLink.DataPoint.Name + '.' + aDataLink.Name;
  Result.ShowFullName := False; //ShowFullSeriesName;
  Result.LinePen.Width := SeriesWidth;

  Result.OPCSource := TaOPCDataLink(aDataLink).RealSource;
  Result.ConnectionName := TaOPCDataLink(aDataLink).RealSource.Name;
  Result.StateLookupList := TaOPCLookupList(TaOPCDataLink(aDataLink).RealSource.States);

  Chart.AddSeries(Result);

  if aAxisForEachSeries.Checked then
  begin
    Result.VertAxis := aCustomVertAxis;
    CreateAxis(Result, Chart.SeriesList.Count - 1);
  end
  else
    Result.VertAxis := aLeftAxis;

  Result.UpdateRealTime;
end;

function TChartFrame.CreateOPCSerieByParam(aPhysID: string; aSource: TaCustomOPCSource; aStairsOptions: TDCStairsOptionsSet;
      aTag: Integer = 0; aControl: TObject = nil; aColor: TColor = clNone): TaOPCLineSeries;
var
  aLabel: TaOPCLabel;
begin
  if not Assigned(aSource) then
  begin
    ShowMessage('Нет подключения');
    Abort;
  end;

  Result := TaOPCLineSeries.Create(Chart);
  Result.PhysID := aPhysID;
  Result.StairsOptions := aStairsOptions;

  if aColor <> clNone then
    Result.SeriesColor := aColor
  else
    Result.SeriesColor := cDayColors[Chart.SeriesCount mod High(cDayColors)];

  Result.Tag := aTag;

  if Assigned(aControl) and (aControl is TaOPCLabel) then
  begin
    aLabel := TaOPCLabel(aControl);

    Result.ValueFormat := aLabel.DisplayFormat;
    Result.LookupList := aLabel.LookupList;

    Result.ShortName := aLabel.Name;
    Result.FullName := aLabel.Name;
  end
  else if Assigned(aControl) and (aControl is TDataLinkExtInfo) then
  begin
    if Assigned(TDataLinkExtInfo(aControl).DataPoint) then
      Result.FullName := TDataLinkExtInfo(aControl).DataPoint.Name + '.' + TDataLinkExtInfo(aControl).Name
    else
      Result.FullName := TDataLinkExtInfo(aControl).Name;

    Result.ShortName := Result.FullName;
  end;


  Result.XValues.DateTime := True;
  Result.Marks.Style := smsLabel;
  Result.Marks.Font.Name := Chart.Title.Font.Name;
  Result.ShowFullName := False;
  Result.LinePen.Width := SeriesWidth;

  Result.OPCSource := aSource;
  Result.ConnectionName := aSource.Name;
  Result.StateLookupList := TaOPCLookupList(aSource.States);

  Chart.AddSeries(Result);

  if aAxisForEachSeries.Checked then
  begin
    Result.VertAxis := aCustomVertAxis;
    CreateAxis(Result, Chart.SeriesList.Count - 1);
  end
  else
    Result.VertAxis := aLeftAxis;

  Result.UpdateRealTime;
end;

destructor TChartFrame.Destroy;
begin
  //FreeAndNil(FInterval);
  inherited;
end;

procedure TChartFrame.DoIntervalChanged(Sender: TObject);
begin
  Chart.UndoZoom;
  //Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);
  //Chart.VisibleInterval := Interval.TimeShift;
  UpdateSeriesData;
  smiInterval.Caption := Interval.AsText;
end;

procedure TChartFrame.DoLoadSettings;
//var
//  Section: string;
begin
  //inherited DoLoadSettings;

//  Section := TKeys.Main + '\' + Name;
//  Interval.Load(AppStorage, Section + '\Interval');
end;

procedure TChartFrame.DoSaveSettings;
//var
//  Section: string;
begin
  //inherited DoSaveSettings;

//  Section := TKeys.Main + '\' + Name;
//  Interval.Save(AppStorage, Section + '\Interval');
end;

function TChartFrame.FindSerie(aDataLink: TaCustomDataLink): TCustomSeries;
//var
//  i: Integer;
//  s: TaOPCLineSeries;
begin
  Result := nil;
  if not (aDataLink is TaOPCDataLink) then
    Exit;

  Result := FindSerieByParam(aDataLink.PhysID, TaOPCDataLink(aDataLink).OPCSource);
end;

function TChartFrame.FindSerieByParam(aPhysID: string; aSource: TaCustomOPCSource): TCustomSeries;
var
  i: Integer;
  s: IaOPCSeries;
begin
  Result := nil;

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if not Supports(Chart.Series[i], IaOPCSeries, s) then
      Continue;

//    if not (Chart.Series[i] is TaOPCLineSeries) then
//      Continue;

//    s := Chart.Series[i] as TaOPCLineSeries;

    if (s.PhysID = aPhysID) and (s.OPCSource = aSource)
      and (s.Scale = 1) and (s.Shift = 0)
      //and (s.DifferentialOrder = 0)
      //and not s.IsState
      then
    begin
      Result := TCustomSeries(Chart.Series[i]);
      Exit;
    end;
  end;
end;

function TChartFrame.GetInterval: TOPCInterval;
begin
  Result := Chart.Interval;
end;

function TChartFrame.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := nil;
end;

procedure TChartFrame.lIntervalClick(Sender: TObject);
begin
  aIntervalExecute(Sender);
end;

procedure TChartFrame.miThickClick(Sender: TObject);
begin
  SetSeriesWidth(1);
end;

procedure TChartFrame.miThinClick(Sender: TObject);
begin
  SetSeriesWidth(0);
end;

procedure TChartFrame.RestoreFrom(aStore: TCustomIniFile; aSectionName: string);
//var
//  aStream: TStream;
begin
  inherited;
//  aStream := TMemoryStream.Create;
//  try
//    try
//      aStore.ReadBinaryStream(aSectionName, 'Chart', aStream);
//      aStream.Position := 0;
//      if aStream.Size <> 0 then
//        LoadChartFromStream(TCustomChart(Chart), aStream);

      ShowFullSeriesName := aStore.ReadBool(aSectionName, 'ShowFullSeriesName', False);
      AxisForEachSeries := aStore.ReadBool(aSectionName, 'AxisForEachSeries', False);

      Chart.View3D := aStore.ReadBool(aSectionName, 'View3D', False);
      Chart.ShowZero := aStore.ReadBool(aSectionName, 'ShowZero', False);
      Chart.AutoScaleY := aStore.ReadBool(aSectionName, 'AutoScaleY', True);
      Chart.Legend.Visible := aStore.ReadBool(aSectionName, 'ShowLegend', True);
      Chart.RealTime := aStore.ReadBool(aSectionName, 'RealTime', True);

      Interval.Load(aStore, aSectionName + '\Interval');
      Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

//    except
//      on e: Exception do
//        OPCLog.WriteToLogFmt(
//          'TChartFrame.RestoreFrom: aSectionName = %s, Stream.Size = %d, Error: %s.',
//          [aSectionName, aStream.Size, e.Message]);
//    end;
//  finally
//    FreeAndNil(aStream);
//  end;
end;

procedure TChartFrame.RestorePosition;
begin
  FAllClient := False;
  Align := FSavePosition.Align;
  SetBounds(FSavePosition.Left, FSavePosition.Top, FSavePosition.Width, FSavePosition.Height);
end;

function TChartFrame.SerieExists(aDataLink: TaOPCDataLink): Boolean;
var
  i: integer;
  s: IaOPCSeries;
  //aSerie: TaOPCLineSeries;
begin
  Result := false;
  for i := 0 to Chart.SeriesCount - 1 do
  begin
//    if not (Chart.Series[i] is TaOPCLineSeries) then
//      continue;

    if not Supports(Chart.Series[i], IaOPCSeries, s) then
      Continue;

    //aSerie := Chart.Series[i] as TaOPCLineSeries;
    if (s.PhysID = aDataLink.PhysID) and
      (s.OPCSource = aDataLink.OPCSource)
      and (s.Scale = 1) and (s.Shift = 0)
      //and (aSerie.DifferentialOrder = 0)
      //and not aSerie.IsState
      then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TChartFrame.SetAxisForEachSeries(const Value: Boolean);
var
  i: integer;
begin
  if FAxisForEachSeries = Value then
    Exit;

  FAxisForEachSeries := Value;
  aAxisForEachSeries.Checked := Value;

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if Value then
    begin
      Chart.Series[i].VertAxis := aCustomVertAxis;
      if not Assigned(Chart.Series[i].CustomVertAxis) then
        CreateAxis(Chart.Series[i], i);
    end
    else
    begin
      if Assigned(Chart.Series[i].CustomVertAxis) then
        Chart.Series[i].CustomVertAxis.Free;
      Chart.Series[i].VertAxis := aLeftAxis;
    end;
  end;
end;

//procedure TChartFrame.SetClickedSerie(const Value: TaOPCLineSeries);
procedure TChartFrame.SetClickedSerie(const Value: TCustomSeries);
var
  aVertAxis: TChartAxis;
  s: IaOPCSeries;
begin
//  if FClickedSerie = Value then
//    exit;

  if Assigned(FClickedSerie)
    and (FClickedSerie.VertAxis = aCustomVertAxis)
    and Assigned(FClickedSerie.CustomVertAxis) then
    FClickedSerie.CustomVertAxis.Grid.Visible := false;

  FClickedSerie := Value;
  if Assigned(FClickedSerie) then
  begin
    if Value.VertAxis = aCustomVertAxis then
      aVertAxis := Value.CustomVertAxis
    else
      aVertAxis := Chart.LeftAxis;

    FVertDelta := aVertAxis.Maximum - aVertAxis.Minimum;

    if Supports(ClickedSerie, IaOPCSeries, s) then
      FSerieShift := s.Shift;

    tbItemClickedSerie.Caption := FClickedSerie.Title;

    if (FClickedSerie.VertAxis = aCustomVertAxis) and Assigned(FClickedSerie.CustomVertAxis) then
      FClickedSerie.CustomVertAxis.Grid.Visible := true;
  end
  else
    tbItemClickedSerie.Caption := '...';
end;

procedure TChartFrame.SetClickedTool(const Value: TTeeCustomTool);
begin
  FClickedTool := Value;
end;

procedure TChartFrame.SetInterval(const Value: TOPCInterval);
begin
  //FInterval.Assign(Value);
  //IntervalChanged;
  Chart.Interval := Value;
end;

procedure TChartFrame.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin

end;

procedure TChartFrame.SetSeriesWidth(aWidth: Integer);
begin
  if FSeriesWidth <> aWidth then
  begin
    FSeriesWidth := aWidth;
    for var i := 0 to Chart.SeriesCount - 1 do
      if Chart.Series[i] is TaOPCLineSeries then
        TaOPCLineSeries(Chart.Series[i]).Pen.Width := aWidth;  //Width := aWidth;
  end;
end;

procedure TChartFrame.SetShowFullSeriesName(const Value: boolean);
var
  i: integer;
  s: IaOPCSeries;
begin
  if FShowFullSeriesName <> Value then
  begin
    FShowFullSeriesName := Value;
    for i := 0 to Chart.SeriesCount - 1 do
    begin
      if Supports(Chart.Series[i], IaOPCSeries, s) then
        s.ShowFullName := FShowFullSeriesName;
//      if Chart.Series[i] is TaOPCLineSeries then
//        (Chart.Series[i] as TaOPCLineSeries).ShowFullName := FShowFullSeriesName;
    end;
  end;
end;

procedure TChartFrame.smiIntervalClick(Sender: TObject);
begin
  aIntervalExecute(Sender);
end;

procedure TChartFrame.smiIntervalPopup(Sender: TTBCustomItem; FromLink: Boolean);
var
  i: integer;
  aItem: TTBCustomItem;
begin
  for i := 0 to smiInterval.Count - 1 do
  begin
    aItem := smiInterval.Items[i];
    if aItem.Tag = Ord(Interval.ShiftKind) then
      aItem.Checked := True
    else
      aItem.Checked := False;

  end;

end;

procedure TChartFrame.SpTBXItem28Click(Sender: TObject);
begin
  Interval.Kind := ikInterval;
  Interval.ShiftKind := TShiftKind((Sender as TComponent).Tag);
  //smiInterval.Caption := Settings.DefaultInterval.AsText;
  //IntervalChanged;
end;

procedure TChartFrame.SpTBXItem34Click(Sender: TObject);
begin
  aIntervalExecute(Sender);
end;

procedure TChartFrame.StorePosition;
begin
  FSavePosition.Left := Left;
  FSavePosition.Top := Top;
  FSavePosition.Width := Width;
  FSavePosition.Height := Height;
  FSavePosition.Align := Align;
end;

procedure TChartFrame.StoreTo(aStore: TCustomIniFile; aSectionName: string);
//var
//  i: Integer;
//  aStream: TStream;
//  aChart: TChart;
begin
  inherited;

  Chart.UndoZoom;

  aStore.WriteBool(aSectionName, 'ShowFullSeriesName', ShowFullSeriesName);
  aStore.WriteBool(aSectionName, 'AxisForEachSeries', AxisForEachSeries);

  aStore.WriteBool(aSectionName, 'View3D', Chart.View3D);
  aStore.WriteBool(aSectionName, 'ShowZero', Chart.ShowZero);
  aStore.WriteBool(aSectionName, 'AutoScaleY', Chart.AutoScaleY);
  aStore.WriteBool(aSectionName, 'ShowLegend', Chart.Legend.Visible);
  aStore.WriteBool(aSectionName, 'RealTime', Chart.RealTime);

  Interval.Save(aStore, aSectionName + '\Interval');


{
  aStream := TMemoryStream.Create;
  try
    try
//      if not IncludeSeries then
      begin
        aChart := TChart.Create(nil);
        try
          aChart.Assign(Chart);
          while aChart.SeriesCount > 0 do
          begin
            if Assigned(Chart.Series[0].CustomVertAxis) then
              Chart.Series[0].CustomVertAxis.Free;
            aChart.Series[0].Free;
          end;
          //aChart.SeriesList.Clear;

          SaveChartToStream(aChart, aStream, false, false);
        finally
          aChart.Free;
        end;
      end;
//      else
//        SaveChartToStream(Chart, aStream, false, false);

      aStream.Position := 0;
      aStore.WriteBinaryStream(aSectionName, 'Chart', aStream);

    except
      on e: Exception do
        OPCLog.WriteToLogFmt(
          'TChartFrame.StoreTo: Stream.Size = %d, Error: %s',
          [aStream.Size, e.Message]);
    end;
  finally
    FreeAndNil(aStream);
  end;
  }
end;

procedure TChartFrame.tbDockTopRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = tbChartActions) or (Bar = tbSeriesPopup);
end;

procedure TChartFrame.UpdateCaption;
begin
  smiInterval.Caption := Interval.AsText;
end;

procedure TChartFrame.UpdateClientActions;
begin
  aRuning.Checked := Chart.RealTime;
  aRuning.Enabled := (Interval.Kind = ikShift) or
    ((Interval.Date2 > Now) and (Interval.Date1 < Now));

  aAutoScaleY.Checked := Chart.AutoScaleY;
  aShowZero.Checked := Chart.ShowZero;
  a3D.Checked := Chart.View3D;
  aLegend.Checked := Chart.Legend.Visible;
  //  aFullName.Checked := ChartForm.ShowFullSeriesName;

  aUpdate.Enabled := (not Chart.RealTime) and (Chart.SeriesCount > 0);
  //aBuild.Enabled := aUpdate.Enabled;

  aClear.Enabled := (Chart.SeriesCount > 0);

  aZoomOut.Enabled := Chart.Zoomed;
  aClearMessures.Enabled := Chart.Tools.Count > 0;

  tbItemClickedSerie.Enabled := Assigned(ClickedSerie);
  if Assigned(ClickedSerie) then
  begin
    //    pmIntegral.Enabled := (not ChartForm.Chart.RealTime) and (Serie.DifferentialOrder<>1);
    //    pmDif1.Enabled := (not ChartForm.Chart.RealTime) and (Serie.DifferentialOrder<>-1);
    //    pmDif2.Enabled := (not ChartForm.Chart.RealTime) and (Serie.DifferentialOrder<>-2);
    //
    //    aReset.Enabled := (not ChartForm.Chart.RealTime) and (Serie.DifferentialOrder <> 0);
    //
    //    aSerieState.Checked := Serie.IsState;
  end;

end;

procedure TChartFrame.UpdateSeriesData;
var
  i: integer;
  s: IaOPCSeries;
begin
  if Chart.RealTime then
    Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2)
  else
    Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if Supports(Chart.Series[i], IaOPCSeries, s) then
      s.FillSerie(Interval.Kind = ikShift);

//    if Chart.Series[i] is TaOPCLineSeries then
//      TaOPCLineSeries(Chart.Series[i]).FillOPCData((Interval.Kind = ikShift));// or (Chart.RealTime));
  end;

  CheckAnimated;
end;


procedure TChartFrame.UpdateSeriesTitle;
begin
  tbItemClickedSerie.Caption := FClickedSerie.Title;
end;

end.
