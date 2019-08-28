unit FMX.DCLabel;

interface

uses
  System.Classes, System.UITypes, System.Types, System.Rtti,
  FMX.Controls, FMX.StdCtrls, FMX.Types, FMX.Platform, FMX.Objects,
  uDCObjects,
  aOPCLookupList,
  FMX.DCText;

type

  //TaCustomOPCLabel = class(TTextControl)
  TaCustomOPCLabel = class(TaDCText)
  private
    FAutoSize: Boolean;
    FIsPressed: Boolean;
    FLookupList: TaOPCLookupList;
    FShowError: boolean;
    FDisplayFormat: string;
    FTrim: boolean;
    procedure SetAutoSize(const Value: Boolean);
    procedure FitSize;
    procedure SetDisplayFormat(const Value: string);
    procedure SetLookupList(const Value: TaOPCLookupList);
    procedure SetShowError(const Value: boolean);
    procedure SetTrim(const Value: boolean);
  protected
    procedure ApplyStyle; override;
    procedure SetText(const Value: string); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DefineProperties(Filer: TFiler); override;
    function GetDefaultSize: TSizeF; override;
    procedure Resize; override;

    function GetDefaultStyleLookupName: string; override;

    procedure ChangeData(Sender:TObject);override;

  public
    constructor Create(AOwner: TComponent); override;
    { triggers }
    property IsPressed: Boolean read FIsPressed;
  published
    property LookupList : TaOPCLookupList read FLookupList write SetLookupList;
    property DisplayFormat : string read FDisplayFormat write SetDisplayFormat;
    property StairsOptions default [soIncrease, soDecrease];
    property Trim:boolean read FTrim write SetTrim default False;
    property ShowError: boolean read FShowError write SetShowError default True;

    property Action;
    property Align;
    property Anchors;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property AutoTranslate default True;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    //property DesignVisible default True;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Font;
    property FontColor;
    property StyledSettings;
    property Locked default False;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HitTest default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property StyleLookup;
    property Text;
    property TextAlign;
    property TouchTargetExpansion;
    property VertTextAlign;
    property Visible default True;
    property Width;
    property WordWrap default True;
    property Trimming default TTextTrimming.None;
    {events}
    property OnApplyStyleLookup;
    {Drag and Drop events}
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    {Keyboard events}
    property OnKeyDown;
    property OnKeyUp;
    {Mouse events}
    property OnCanFocus;
    property OnClick;
    property OnDblClick;

    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnPainting;
    property OnPaint;
    property OnResize;
  end;

  TaOPCLabel = class(TaCustomOPCLabel)
  end;

//  TaOPCLabelTest = class(TLabel)
//  end;


implementation

uses
  aOPCUtils,
  System.SysUtils;

{ TLabel }

procedure TaCustomOPCLabel.ChangeData(Sender: TObject);
var
  aValue: Extended;
  Precision: Integer;
  i: Integer;
  aValueStr: string;
begin

  if (ErrorCode <> 0) and FShowError then
    Text := ErrorString
  else
  begin
    if LookupList = nil then
    begin
      try
        if Value = '' then
          Exit;
        aValue := StrToFloat(Value); //TryStrToFloat(Value); //StrToFloat(Value, OpcFS);
        // нужно ли отсекать, а не округлять
        if Trim then
        begin
          Precision := 1;
          i := pos('.',DisplayFormat);
          if i>0 then
          begin
            inc(i);
            while i<=Length(DisplayFormat) do
            begin
              if CharInSet(DisplayFormat[i], ['0','#']) then
                Precision := Precision * 10;
              inc(i);
            end;
          end;
          aValue := Trunc(aValue*Precision) / Precision;
        end;
        Text := FormatValue(aValue, DisplayFormat);
      except
        Text := Value
      end;
    end
    else
    begin
      // пытаемся найти соответствие нашему значению и форматируем его
      // если не находим, то возвращаем числовое значение
      LookupList.Lookup(Value,aValueStr);
      if DisplayFormat <> '' then
        Text := Format(DisplayFormat,[aValueStr])
      else
        Text := aValueStr
    end;
  end;

  inherited;
end;

constructor TaCustomOPCLabel.Create(AOwner: TComponent);
var
  DefaultValueService: IInterface;
  TrimmingDefault: TValue;
begin
  inherited;
  AutoTranslate := True;

  if (csDesigning in ComponentState)
    and SupportsPlatformService(IFMXDefaultPropertyValueService, DefaultValueService) then
  begin
    TrimmingDefault := IFMXDefaultPropertyValueService(DefaultValueService).GetDefaultPropertyValue(Self.ClassName, 'trimming');
    if not TrimmingDefault.IsEmpty then
      Trimming := TrimmingDefault.AsType<TTextTrimming>;
  end;

  WordWrap := True;
  HitTest := False;
  SetAcceptsControls(False);
end;

procedure TaCustomOPCLabel.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('TabOrder', IgnoreIntegerValue, nil, False);
end;

function TaCustomOPCLabel.GetDefaultSize: TSizeF;
var
  DefMetricsSrv: IFMXDefaultMetricsService;
begin
//  if SupportsPlatformService(IFMXDefaultMetricsService, IInterface(DefMetricsSrv)) and DefMetricsSrv.SupportsDefaultSize(ckLabel) then
//    Result := TSizeF.Create(DefMetricsSrv.GetDefaultSize(ckLabel).Width, DefMetricsSrv.GetDefaultSize(ckLabel).Height)
//  else
    Result := TSizeF.Create(120, 17);
end;

function TaCustomOPCLabel.GetDefaultStyleLookupName: string;
begin
  Result := 'Labelstyle';
end;

procedure TaCustomOPCLabel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if Button = TMouseButton.mbLeft then
  begin
    FIsPressed := True;
    StartTriggerAnimation(Self, 'IsPressed');
    ApplyTriggerEffect(Self, 'IsPressed');
  end;
end;

procedure TaCustomOPCLabel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if (Button = TMouseButton.mbLeft) and (FIsPressed) then
  begin
    FIsPressed := False;
    StartTriggerAnimation(Self, 'IsPressed');
    ApplyTriggerEffect(Self, 'IsPressed');
  end;
end;

procedure TaCustomOPCLabel.Resize;
begin
  inherited;
  if FAutoSize then
    FitSize;
end;

procedure TaCustomOPCLabel.FitSize;
begin
  if not (csLoading in ComponentState) then
    WordWrap := False;
  ApplyStyle;
end;

procedure TaCustomOPCLabel.ApplyStyle;
var
  TextObj: TText;
  S: TAlignLayout;
begin
  inherited;
  if AutoSize and (Text <> '') then
  begin
    if Assigned(TextObject) and (TextObject is TText) then
    begin
      TextObj := TText(TextObject);
      S := TextObj.Align;
      TextObj.Align := TAlignLayout.None;
      TextObj.AutoSize := True;
      Width := TextObj.Width;
      Height := TextObj.Height;
      TextObj.AutoSize := False;
      TextObj.Align := S;
    end;
  end;
end;

procedure TaCustomOPCLabel.SetAutoSize(const Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    if FAutoSize then
      FitSize;
  end;
end;

procedure TaCustomOPCLabel.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
  ChangeData(self);
end;

procedure TaCustomOPCLabel.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
  if Value <> nil then
    Value.FreeNotification(Self);

  ChangeData(self);
end;

procedure TaCustomOPCLabel.SetShowError(const Value: boolean);
begin
  FShowError := Value;
  ChangeData(self);
end;

procedure TaCustomOPCLabel.SetText(const Value: string);
begin
  if Value <> Text then
  begin
    inherited;
    if FAutoSize then
      ApplyStyle;
  end
  else
    inherited;
end;

procedure TaCustomOPCLabel.SetTrim(const Value: boolean);
begin
  FTrim := Value;
  ChangeData(self);
end;

initialization
  RegisterFmxClasses([TaCustomOPCLabel]);



end.
