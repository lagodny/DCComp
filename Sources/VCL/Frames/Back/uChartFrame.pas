unit uChartFrame;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Menus, ActnList, ExtCtrls, AppEvnts,
  VCLTee.TeeProcs,
  SpTBXItem, TB2Dock, TB2Toolbar, TB2Item, SpTBXCustomizer,
  System.IniFiles,
  VCLTee.TeEngine,
  VCLTee.Chart, aOPCChart,
  uDCObjects, uDCSensors,
  uOPCFrame,
  aCustomOPCSource,
  uOPCIntervalForm,
  uOPCInterval,
  aOPCDataObject, aOPCLabel,
  aOPCLineSeries,
  aOPCConnectionList, aOPCLog, aOPCUtils, ImgList, Vcl.Touch.GestureMgr, VclTee.TeeGDIPlus, System.ImageList, System.Actions
  ;

type
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
    SpTBXToolbar1: TSpTBXToolbar;
    SpTBXItem10: TSpTBXItem;
    SpTBXSeparatorItem13: TSpTBXSeparatorItem;
    SpTBXItem26: TSpTBXItem;
    SpTBXItem11: TSpTBXItem;
    SpTBXSeparatorItem15: TSpTBXSeparatorItem;
    SpTBXItem12: TSpTBXItem;
    SpTBXSeparatorItem14: TSpTBXSeparatorItem;
    SpTBXItem17: TSpTBXItem;
    SpTBXItem38: TSpTBXItem;
    SpTBXItem16: TSpTBXItem;
    SpTBXItem18: TSpTBXItem;
    SpTBXItem19: TSpTBXItem;
    SpTBXSeparatorItem5: TSpTBXSeparatorItem;
    SpTBXItem25: TSpTBXItem;
    SpTBXItem35: TSpTBXItem;
    SpTBXSeparatorItem6: TSpTBXSeparatorItem;
    SpTBXItem14: TSpTBXItem;
    SpTBXSeparatorItem4: TSpTBXSeparatorItem;
    SpTBXItem13: TSpTBXItem;
    smiInterval: TSpTBXSubmenuItem;
    SpTBXItem28: TSpTBXItem;
    SpTBXItem29: TSpTBXItem;
    SpTBXItem30: TSpTBXItem;
    SpTBXItem31: TSpTBXItem;
    SpTBXItem32: TSpTBXItem;
    SpTBXItem33: TSpTBXItem;
    SpTBXSeparatorItem17: TSpTBXSeparatorItem;
    SpTBXItem34: TSpTBXItem;
    SpTBXToolbar2: TSpTBXToolbar;
    tbItemClickedSerie: TSpTBXSubmenuItem;
    SpTBXItem5: TSpTBXItem;
    SpTBXSeparatorItem8: TSpTBXSeparatorItem;
    SpTBXItem6: TSpTBXItem;
    SpTBXItem7: TSpTBXItem;
    SpTBXSeparatorItem9: TSpTBXSeparatorItem;
    SpTBXItem8: TSpTBXItem;
    SpTBXItem9: TSpTBXItem;
    CommonImages: TImageList;
    GestureManager1: TGestureManager;
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
  private
    FMouseDownX: Integer;
    FMouseDownY: Integer;

    FClickedSerie: TaOPCLineSeries;
    FVertDelta: extended;
    FSerieShift: extended;

    FShowFullSeriesName: boolean;
    //FInterval: TOPCInterval;

    procedure SetShowFullSeriesName(const Value: boolean);
    procedure ClickSeries(Sender: TCustomChart;
      Series: TChartSeries; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer;
      LegendClicked: boolean = false);

    procedure CalcLabelsFormat;
    function CheckMouseMove(x, y: integer): Boolean;

    procedure CreateAxis(aSerie: TChartSeries; aIndex: integer);
    //procedure UpdateChartAfterLoad;

    function BlinkSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries; overload;
    function BlinkSerie(aSensor: TSensor): TaOPCLineSeries; overload;

    function CreateOPCSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries; overload;
    function CreateOPCSerie(aSensor: TSensor): TaOPCLineSeries; overload;

    procedure SetClickedSerie(const Value: TaOPCLineSeries);

    function GetInterval: TOPCInterval;
    procedure SetInterval(const Value: TOPCInterval);

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

    procedure LoadSettings(aStorage: TCustomIniFile; aSectionName: string);
    procedure SaveSettings(aStorage: TCustomIniFile; aSectionName: string; aIncludeSeries: Boolean = True);

    procedure UpdateChartAfterLoad(aConnections: TaOPCConnectionList);


    function SerieExists(aDataLink: TaOPCDataLink): Boolean; overload;
    function SerieExists(aSensor: TSensor): Boolean; overload;
    function SerieExists(aPhysID: string; aSource: TaCustomOPCSource): Boolean; overload;
    procedure UpdateClientActions;

    procedure ClearData;
    procedure ClearChart;

    procedure CheckAnimated;
    procedure UpdateSeriesData;

    function AddSerie(aDataLink: TaCustomDataLink; aDelIfExist: Boolean): TaOPCLineSeries; overload;
    function AddSerie(aSensor: TSensor; aDelIfExist: Boolean): TaOPCLineSeries; overload;

    property Interval: TOPCInterval read GetInterval write SetInterval;
    //procedure IntervalChanged;

    property ShowFullSeriesName: boolean read FShowFullSeriesName write SetShowFullSeriesName;

    property ClickedSerie: TaOPCLineSeries read FClickedSerie write SetClickedSerie;
  end;

implementation

{$DEFINE TEECHARTEDITOR}

uses
  StrUtils
{$IFDEF TEECHARTEDITOR}
  , VCLTee.TeeEdit, VCLTee.TeeEditCha, VCLTee.TeeRussian, VCLTee.TeeStore
{$ENDIF}
  , aOPCLookupList;

//  uAppStorage,
//  uKeys;


{$R *.dfm}

const
  cIntervalHelpContext = 0;

procedure TChartFrame.a3DExecute(Sender: TObject);
begin
  Chart.View3D := not Chart.View3D;
  a3D.Checked := Chart.View3D;
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
var
  i: integer;
begin
  aAxisForEachSeries.Checked := not aAxisForEachSeries.Checked;
  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if aAxisForEachSeries.Checked then
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

procedure TChartFrame.aClearExecute(Sender: TObject);
begin
  //  if DockingControl.Focused then
  //  if ActiveControl = Chart then
  ClearData;
end;

procedure TChartFrame.aCopyExecute(Sender: TObject);
begin
  Chart.CopyToClipboardBitmap;
end;

function TChartFrame.AddSerie(aSensor: TSensor; aDelIfExist: Boolean): TaOPCLineSeries;
var
  aSerie: TaOPCLineSeries;
begin
  Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  aSerie := BlinkSerie(aSensor);
  if not Assigned(aSerie) then
    aSerie := CreateOPCSerie(aSensor)
  else if aDelIfExist then
  begin
    ClickedSerie := aSerie;
    aDeleteSeriesExecute(Self);
    Exit;
  end;

  aSerie.FillOPCData(Interval.Kind = ikShift);
  ClickedSerie := aSerie;
  Result := aSerie;

  CheckAnimated;
  UpdateClientActions;
end;

function TChartFrame.AddSerie(aDataLink: TaCustomDataLink; aDelIfExist: Boolean): TaOPCLineSeries;
var
  aSerie: TaOPCLineSeries;
begin
  Result := nil;

  Chart.UndoZoom;
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  aSerie := BlinkSerie(aDataLink);
  if not Assigned(aSerie) then
    aSerie := CreateOPCSerie(aDataLink)
  else if aDelIfExist then
  begin
    ClickedSerie := aSerie;
    aDeleteSeriesExecute(Self);
    Exit;
  end;

  aSerie.FillOPCData(Interval.Kind = ikShift);
  ClickedSerie := aSerie;
  Result := aSerie;

  CheckAnimated;
  UpdateClientActions;
end;

procedure TChartFrame.aDeleteSeriesExecute(Sender: TObject);
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
    if Chart.SeriesList.Items[0] is TaOPCLineSeries then
      ClickedSerie := TaOPCLineSeries(Chart.SeriesList.Items[0]);
  end;

  CheckAnimated;
  UpdateClientActions;
end;

procedure TChartFrame.aEditorExecute(Sender: TObject);
begin
{$IFDEF TEECHARTEDITOR}
  with TChartEditor.Create(Self) do
  begin
    try
      TeeSetRussian;
      Options := [
        ceAdd,
      ceDelete,
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
  ShowIntervalForm(Interval, cIntervalHelpContext);
end;

procedure TChartFrame.aLegendExecute(Sender: TObject);
begin
  Chart.Legend.Visible := not Chart.Legend.Visible;
  aLegend.Checked := Chart.Legend.Visible;
  ;
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
  end
//    else if Msg.message = WM_KEYDOWN then
//    begin
//      if Chart.Focused then
//        Chart.Perform(Msg.message, Msg.WParam, Msg.LParam);
//      Key := Msg.wParam;
//      case Key of
//        vk_Delete: aClearExecute(Self);
//      end;
//    end;

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
  Serie: TaOPCLineSeries;
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
          if not (Chart.SeriesList.Items[i] is TaOPCLineSeries) then
            Continue;

          Serie := Chart.SeriesList.Items[i] as TaOPCLineSeries;
          v := Serie.Clicked(P.x, P.y);
          if v <> -1 then
          begin
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
                    vertAxis := Chart.RightAxis;

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
begin
  if Assigned(ClickedSerie) then
  begin
    sNewScale := FloatToStr(ClickedSerie.Scale);
    if InputQuery('Укажите масштаб', ClickedSerie.Title, sNewScale) then
    begin
//      if DecimalSeparator = '.' then
//        sNewScale := ReplaceStr(sNewScale, ',', '.')
//      else
//        sNewScale := ReplaceStr(sNewScale, '.', ',');

      sNewScale := ReplaceStr(sNewScale, ',', '');
      ClickedSerie.Scale := StrToFloatDef(sNewScale, ClickedSerie.Scale, dotFS);
    end;
  end;
end;

procedure TChartFrame.aSerieShiftExecute(Sender: TObject);
var
  sNewShift: string;
begin
  if Assigned(ClickedSerie) then
  begin
    sNewShift := FloatToStr(ClickedSerie.Shift);
    if InputQuery('Укажите величину сдвига', ClickedSerie.Title, sNewShift) then
    begin
//      if DecimalSeparator = '.' then
//        sNewShift := ReplaceStr(sNewShift, ',', '.')
//      else
//        sNewShift := ReplaceStr(sNewShift, '.', ',');

      sNewShift := ReplaceStr(sNewShift, ',', '');
      ClickedSerie.Shift := StrToFloatDef(sNewShift, ClickedSerie.Shift, dotFS);
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
    if ClickedSerie.StairsOptions = [] then
      aAvgTime := aAvgTime + (ClickedSerie.YValue[i - 1] *
        (ClickedSerie.XValue[i] - ClickedSerie.XValue[i - 1]))
    else
      aAvgTime := aAvgTime + ((ClickedSerie.YValue[i] + ClickedSerie.YValue[i - 1]) / 2 *
        (ClickedSerie.XValue[i] - ClickedSerie.XValue[i - 1]))

  end;
  aAvg := aSum / aCount;
  aAvgTime := aAvgTime / (ClickedSerie.XValues.Last - ClickedSerie.XValues.First);
  aIntegral := aIntegral * 24;

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
      FormatFloat(ClickedSerie.DisplayFormat, ClickedSerie.MinYValue), ClickedSerie.SensorUnitName,
      FormatFloat(ClickedSerie.DisplayFormat, ClickedSerie.MaxYValue), ClickedSerie.SensorUnitName,
      FormatFloat('# ##0.00', aAvg), ClickedSerie.SensorUnitName,
      FormatFloat('# ##0.00', aAvgTime), ClickedSerie.SensorUnitName,
      FormatFloat('# ##0.00', aIntegral), ClickedSerie.SensorUnitName
      ]);
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
    Interval.ShiftKind := skNone;
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

function TChartFrame.BlinkSerie(aSensor: TSensor): TaOPCLineSeries;
var
  i: integer;
  OldColor: TColor;
begin
  Assert(Assigned(aSensor));

  Result := nil;
  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if not (Chart.Series[i] is TaOPCLineSeries) then
      Continue;

    Result := Chart.Series[i] as TaOPCLineSeries;
    if (Result.PhysID = aSensor.IdStr) and (Result.OPCSource = aSensor.Connection.OPCSource)
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

function TChartFrame.BlinkSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;
var
  i: integer;
  OldColor: TColor;
begin
  if not (aDataLink is TaOPCDataLink) then
    Exit;

  Result := nil;
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
  Serie: TaOPCLineSeries;
  P: TPoint;
begin
  Handled := CheckMouseMove(MousePos.x, MousePos.y);

  if not Handled then
  begin
    P := Chart.ScreenToClient(Mouse.CursorPos);
    for i := Chart.SeriesList.Count - 1 downto 0 do
    begin
      if not (Chart.SeriesList.Items[i] is TaOPCLineSeries) then
        Continue;

      Serie := Chart.SeriesList.Items[i] as TaOPCLineSeries;
      v := Serie.Clicked(P.X, P.Y);
      if v <> -1 then
      begin
        Handled := True;
        ClickedSerie := TaOPCLineSeries(Serie);
        aSeriesShowValue.Checked := ClickedSerie.Marks.Visible;

        pmSeries.Popup(
          Mouse.CursorPos.X,
          Mouse.CursorPos.Y);
        Exit;
      end;

    end;
    Chart.CancelMouse := false; // can
  end;

end;

procedure TChartFrame.ChartDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: integer;
begin
  if (Source is TaOPCLabel) and (TaOPCLabel(Source).PhysID <> '') then
  begin
     AddSerie(TaOPCLabel(Source).DataLink, True);
  end
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
begin
  if Button = mbLeft then
  begin
    tmp := Chart.Legend.Clicked(x, y);
    if (tmp > -1) and (Chart.SeriesLegend(tmp, true) is TaOPCLineSeries) then
      ClickedSerie := TaOPCLineSeries(Chart.SeriesLegend(tmp, true))
        //    else
      //      ClickedSerie := nil;
  end;

  FMouseDownX := X;
  FMouseDownY := Y;

//  if Parent is TForm then
//  begin
//    TForm(Parent).SetFocusedControl(Chart);
//  end;

  SetFocus;

  //Chart.SetFocus;


end;

procedure TChartFrame.ChartMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  aLeftAxis: TChartAxis;
begin
  if Assigned(ClickedSerie) then
  begin
    if (ssLeft in Shift) and (ssShift in Shift) then
    begin
      if Assigned(ClickedSerie.CustomVertAxis) then
        aLeftAxis := ClickedSerie.CustomVertAxis
      else
        aLeftAxis := Chart.LeftAxis;

      ClickedSerie.Shift := FSerieShift + FVertDelta / aLeftAxis.IAxisSize * (FMouseDownY - Y)
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
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  LegendClicked: boolean);
begin
  if (Button = mbLeft) then
  begin
    if Series is TaOPCLineSeries then
      ClickedSerie := TaOPCLineSeries(Series);
    //    else
    //      ClickedSerie := nil;

    if not (LegendClicked and Chart.Legend.CheckBoxes) then
    begin
      if (Shift = [ssLeft]) then // просто шедчёк левой кнопкой
      begin // выдвинем на передний план
        while Sender.SeriesList[Sender.SeriesCount - 1] <> Series do
          Sender.SeriesDown(Series);
      end
      else if (Shift = [ssLeft, ssCtrl]) and Assigned(ClickedSerie) then // + Ctrl
        ClickedSerie.Shift := 0 // сброс сдвига
      else if (Shift = [ssLeft, ssAlt]) and Assigned(ClickedSerie) then // + Alt
      begin
        if ClickedSerie.YValues.Count > 0 then
          ClickedSerie.Shift := -ClickedSerie.YValues[0]; // начинаем с нуля
      end;
    end;
  end
  else
  begin
    if (Button = mbRight) and LegendClicked then
    begin
      if Series is TaOPCLineSeries then
      begin
        ClickedSerie := TaOPCLineSeries(Series);
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
  Chart.Panning.MouseWheel := pmwNone;
  //TeeUseMouseWheel := false;

  UpdateCaption;

end;

procedure TChartFrame.CreateAxis(aSerie: TChartSeries; aIndex: integer);
var
  aAxis: TChartAxis;
begin
  aAxis := TChartAxis.Create(Chart);
  aAxis.Automatic := true;
  //  aAxis.

    //aAxis.Title.Caption := aSerie.Title;
  aAxis.Title.Angle := 90;
  aAxis.Title.Visible := true;
  //aAxis.Title.Font.Color := Result.SeriesColor;

  aAxis.PositionUnits := muPixels;
  aAxis.PositionPercent := (aIndex + 1) * 50;
  aAxis.Axis.Color := aSerie.SeriesColor;
  aAxis.Axis.Width := 1;
  aAxis.StartPosition := 1;
  aAXis.EndPosition := 99;

  //aAxis.Grid.Color := Result.SeriesColor;
  aAxis.Grid.Visible := (aSerie = ClickedSerie);

  aSerie.VertAxis := aCustomVertAxis;
  aSerie.CustomVertAxis := aAxis;
end;

function TChartFrame.CreateOPCSerie(aSensor: TSensor): TaOPCLineSeries;
var
  //aConnection: TOPCConnectionCollectionItem;
  aLabel: TaOPCLabel;
begin
  Assert(Assigned(aSensor));

  Result := TaOPCLineSeries.Create(Chart);
  Result.PhysID := aSensor.IdStr;
  Result.StairsOptions := aSensor.StairsOptions;

  Result.Tag := 0; // integer(aDataLink);

  Result.ValueFormat := aSensor.DisplayFormat;
  Result.LookupList := aSensor.LookupList;
  Result.ShortName := aSensor.Name;
  Result.FullName := aSensor.FullName;
  Result.SensorUnitName := aSensor.SensorUnitName;

  Result.XValues.DateTime := True;
  Result.Marks.Style := smsLabel;
  Result.Marks.Font.Name := Chart.Title.Font.Name;

  Result.ShowFullName := ShowFullSeriesName;

  if Assigned(aSensor.Connection) then
  begin
    Result.OPCSource := aSensor.Connection.OPCSource;
    Result.ConnectionName := aSensor.Connection.Name;
    Result.StateLookupList := TaOPCLookupList(aSensor.Connection.OPCSource.States);
  end;

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

function TChartFrame.CreateOPCSerie(aDataLink: TaCustomDataLink): TaOPCLineSeries;
var
  //aConnection: TOPCConnectionCollectionItem;
  aLabel: TaOPCLabel;
begin
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

  if Assigned(aDataLink.Control) and (aDataLink.Control is TaOPCLabel) then
  begin
    aLabel := TaOPCLabel(aDataLink.Control);

    Result.ValueFormat := aLabel.DisplayFormat;
    Result.LookupList := aLabel.LookupList;

    Result.ShortName := aLabel.Name;
    Result.FullName := aLabel.Name;
  end;

  Result.XValues.DateTime := True;
  Result.Marks.Style := smsLabel;
  Result.Marks.Font.Name := Chart.Title.Font.Name;

//  Result.ShortName := aDataLink.Name;
//  Result.FullName := aDataLink.DataPoint.Name + '.' + aDataLink.Name;
  Result.ShowFullName := False; //ShowFullSeriesName;

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
var
  Section: string;
begin
  //inherited DoLoadSettings;

//  Section := TKeys.Main + '\' + Name;
//  Interval.Load(AppStorage, Section + '\Interval');
end;

procedure TChartFrame.DoSaveSettings;
var
  Section: string;
begin
  //inherited DoSaveSettings;

//  Section := TKeys.Main + '\' + Name;
//  Interval.Save(AppStorage, Section + '\Interval');
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

procedure TChartFrame.LoadSettings(aStorage: TCustomIniFile; aSectionName: string);
var
  aStream: TMemoryStream;
begin
  aStream := TMemoryStream.Create;
  try
    aStorage.ReadBinaryStream(aSectionName, 'Chart', aStream);
    aStream.Position := 0;
    LoadChartFromStream(TCustomChart(Chart), aStream);
  finally
    aStream.Free;
  end;

  ShowFullSeriesName := aStorage.ReadBool(aSectionName, 'ShowFullSeriesName', False);
  aAxisForEachSeries.Checked := aStorage.ReadBool(aSectionName, 'AxisForEachSeries', False);

//  Set3D(aStorage.ReadBool(aSectionName, 'View3D', False));
//  FDecompOrder := aStorage.ReadInteger(aSectionName, 'DecompOrder', 3);
//  FDecompLevel := aStorage.ReadInteger(aSectionName, 'DecompLevel', 3);

  Interval.Load(aStorage, aSectionName + '\Interval');
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  //UpdateChartAfterLoad;
end;

function TChartFrame.SerieExists(aDataLink: TaOPCDataLink): Boolean;
begin
  Result := false;
  if not Assigned(aDataLink) then
    Exit;

  Result := SerieExists(aDataLink.PhysID, aDataLink.OPCSource);
end;

procedure TChartFrame.SaveSettings(aStorage: TCustomIniFile; aSectionName: string; aIncludeSeries: Boolean);
var
  aStream: TStream;
  aChart: TChart;
  i: Integer;
begin
  aStorage.WriteBool(aSectionName, 'ShowFullSeriesName', ShowFullSeriesName);
  aStorage.WriteBool(aSectionName, 'AxisForEachSeries', aAxisForEachSeries.Checked);

  Interval.Save(aStorage, aSectionName + '\Interval');

  Chart.UndoZoom;
  aStream := TMemoryStream.Create;
  try
    try
      if not aIncludeSeries then
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
          SaveChartToStream(aChart, aStream, false, false);
        finally
          aChart.Free;
        end;
      end
      else
        SaveChartToStream(Chart, aStream, false, false);

      aStream.Position := 0;

      aStorage.WriteBinaryStream(aSectionName, 'Chart', aStream);

    except
      on e: Exception do
        OPCLog.WriteToLogFmt('TChartFrame.SaveSettings: Stream.Size = %d, Error: %s', [aStream.Size, e.Message]);
    end;
  finally
    FreeAndNil(aStream);
  end;
end;

function TChartFrame.SerieExists(aPhysID: string; aSource: TaCustomOPCSource): Boolean;
var
  i: integer;
  aSerie: TaOPCLineSeries;
begin
  Result := false;
  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if not (Chart.Series[i] is TaOPCLineSeries) then
      continue;

    aSerie := Chart.Series[i] as TaOPCLineSeries;
    if (aSerie.PhysID = aPhysID) and
      (aSerie.OPCSource = aSource)
      and (aSerie.Scale = 1) and (aSerie.Shift = 0) and (aSerie.DifferentialOrder = 0)
      and not aSerie.IsState then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TChartFrame.SerieExists(aSensor: TSensor): Boolean;
begin
  Result := false;
  if not Assigned(aSensor) then
    Exit;

  Result := SerieExists(aSensor.IDStr, aSensor.Connection.OPCSource);
end;

procedure TChartFrame.SetClickedSerie(const Value: TaOPCLineSeries);
var
  aVertAxis: TChartAxis;
begin
  if FClickedSerie = Value then
    exit;

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
    FSerieShift := FClickedSerie.Shift;
    tbItemClickedSerie.Caption := FClickedSerie.Title;

    if (FClickedSerie.VertAxis = aCustomVertAxis) and Assigned(FClickedSerie.CustomVertAxis) then
      FClickedSerie.CustomVertAxis.Grid.Visible := true;
  end
  else
    tbItemClickedSerie.Caption := '...';
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

procedure TChartFrame.SetShowFullSeriesName(const Value: boolean);
var
  i: integer;
begin
  if FShowFullSeriesName <> Value then
  begin
    FShowFullSeriesName := Value;
    for i := 0 to Chart.SeriesCount - 1 do
    begin
      if Chart.Series[i] is TaOPCLineSeries then
        (Chart.Series[i] as TaOPCLineSeries).ShowFullName := FShowFullSeriesName;
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

procedure TChartFrame.UpdateCaption;
begin
  smiInterval.Caption := Interval.AsText;
end;

procedure TChartFrame.UpdateChartAfterLoad(aConnections: TaOPCConnectionList);
var
  i: integer;
  ls: TaOPCLineSeries;
  aConnection: TOPCConnectionCollectionItem;
  aOPCObject: TDCObject;
begin
  Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);
  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if not (Chart.Series[i] is TaOPCLineSeries) then
      continue;

    ls := TaOPCLineSeries(Chart.Series[i]);

    aConnection := nil;
    aConnection := aConnections.Connections[ls.ConnectionName];

    if not Assigned(aConnection) then
      Continue;

    ls.OPCSource := (aConnection.OPCSource);
    ls.ConnectionName := aConnection.Name;

    aOPCObject :=
      aConnection.OPCObjectList.FindObjectByID(StrToIntDef(ls.PhysID, 0));
    if not Assigned(aOPCObject) or not (aOPCObject is TSensor) then
      Continue;

    ls.LookupList := TSensor(aOPCObject).LookupList;
    ls.StateLookupList := aConnection.GetLookupByTableName('States');
    ls.FillOPCData(Interval.Kind = ikShift);

    if i = 0 then
      ClickedSerie := ls;

  end;



  //Chart.Name            := 'Chart';
  Chart.Parent := Self;
  Chart.Align := alClient;

  Chart.PopupMenu := pmChart; //PopupMenu;
  Chart.OnContextPopup := ChartContextPopup;
  Chart.OnDragDrop := ChartDragDrop;
  Chart.OnDragOver := ChartDragOver;
  Chart.OnMouseDown := ChartMouseDown;
  Chart.OnClickLegend := ChartClickLegend;

  Chart.OnClickLegend := ChartClickLegend;
  Chart.OnClickSeries := ChartClickSeries;
  Chart.OnBeforeDrawAxes := ChartBeforeDrawAxes;

  //Chart.BottomAxis.Automatic := true;
  //Chart.LeftAxis.Automatic := true;
  Chart.UndoZoom;
  UpdateCaption;
  CheckAnimated;
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
  aBuild.Enabled := aUpdate.Enabled;

  aClear.Enabled := (Chart.SeriesCount > 0);

  aZoomOut.Enabled := Chart.Zoomed;

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
begin
  if Chart.RealTime then
    Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2)
  else
    Chart.BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  for i := 0 to Chart.SeriesCount - 1 do
  begin
    if Chart.Series[i] is TaOPCLineSeries then
      TaOPCLineSeries(Chart.Series[i]).FillOPCData((Interval.Kind = ikShift) or (Chart.RealTime));
  end;

  CheckAnimated;
end;


end.
