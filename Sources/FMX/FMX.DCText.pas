unit FMX.DCText;

interface

uses
  System.UITypes, System.UIConsts,
  System.Classes, System.Rtti,
  System.Types, System.TypInfo,
  System.RTLConsts,
  System.Actions,
  FMX.Controls, FMX.Graphics, FMX.Types, FMX.ActnList, FMX.BehaviorManager, FMX.Objects, FMX.Consts,
  FMX.TextLayout,
  FMX.DCDataObject;

type
  TTextSettingsInfo = class (TPersistent)
  public type
    TBaseTextSettings = class (TTextSettings)
    private
      [Weak] FInfo: TTextSettingsInfo;
      [Weak] FControl: TControl;
    public
      constructor Create(const AOwner: TPersistent); override;
      property Info: TTextSettingsInfo read FInfo;
      property Control: TControl read FControl;
    end;
    TCustomTextSettings = class (TBaseTextSettings)
    public
      constructor Create(const AOwner: TPersistent); override;
      property WordWrap default True;
      property Trimming default TTextTrimming.None;
    end;
    TCustomTextSettingsClass = class of TCustomTextSettings;
    TTextPropLoader = class
    private
      FInstance: TPersistent;
      FFiler: TFiler;
      FITextSettings: ITextSettings;
      FTextSettings: TTextSettings;
    protected
      procedure ReadSet(const Instance: TPersistent; const Reader: TReader; const PropertyName: string);
      procedure ReadEnumeration(const Instance: TPersistent; const Reader: TReader; const PropertyName: string);
      procedure ReadFontFillColor(Reader: TReader);
      procedure ReadFontFamily(Reader: TReader);
      procedure ReadFontFillKind(Reader: TReader);
      procedure ReadFontStyle(Reader: TReader);
      procedure ReadFontSize(Reader: TReader);
      procedure ReadTextAlign(Reader: TReader);
      procedure ReadTrimming(Reader: TReader);
      procedure ReadVertTextAlign(Reader: TReader);
      procedure ReadWordWrap(Reader: TReader);
    public
      constructor Create(const AInstance: TComponent; const AFiler: TFiler);
      procedure ReadProperties; virtual;
      property Instance: TPersistent read FInstance;
      property Filer: TFiler read FFiler;
      property TextSettings: TTextSettings read FTextSettings;
    end;
  private
    FDefaultTextSettings: TTextSettings;
    FTextSettings: TTextSettings;
    FResultingTextSettings: TTextSettings;
    FOldTextSettings: TTextSettings;
    [Weak] FOwner: TPersistent;
    FDesign: Boolean;
    FStyledSettings: TStyledSettings;
    procedure SetDefaultTextSettings(const Value: TTextSettings);
    procedure SetStyledSettings(const Value: TStyledSettings);
    procedure SetTextSettings(const Value: TTextSettings);
    procedure OnDefaultChanged(Sender: TObject);
    procedure OnTextChanged(Sender: TObject);
    procedure OnCalculatedTextSettings(Sender: TObject);
  protected
    procedure RecalculateTextSettings; virtual;
    procedure DoDefaultChanged; virtual;
    procedure DoTextChanged; virtual;
    procedure DoCalculatedTextSettings; virtual;
    procedure DoStyledSettingsChanged; virtual;
  public
    constructor Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass); virtual;
    destructor Destroy; override;
    property Design: Boolean read FDesign write FDesign;
    property StyledSettings: TStyledSettings read FStyledSettings write SetStyledSettings;
    property DefaultTextSettings: TTextSettings read FDefaultTextSettings write SetDefaultTextSettings;
    property TextSettings: TTextSettings read FTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read FResultingTextSettings;
    property Owner: TPersistent read FOwner;
  end;

{ TaDCText }

  TaDCText = class(TaOPCDataObject, ITextSettings)
  private
    FTextSettingsInfo: TTextSettingsInfo;
    FTextObject: TControl;
    FITextSettings: ITextSettings;
    FObjectState: IObjectState;
    FText: string;
    FIsChanging: Boolean;
    function IsTextStored: Boolean;
    function GetFont: TFont;
    function GetText: string;
    procedure SetFont(const Value: TFont);
    function GetTextAlign: TTextAlign;
    procedure SetTextAlign(const Value: TTextAlign);
    function GetVertTextAlign: TTextAlign;
    procedure SetVertTextAlign(const Value: TTextAlign);
    function GetWordWrap: Boolean;
    procedure SetWordWrap(const Value: Boolean);
    function GetFontColor: TAlphaColor;
    procedure SetFontColor(const Value: TAlphaColor);
    function GetTrimming: TTextTrimming;
    procedure SetTrimming(const Value: TTextTrimming);
    { ITextSettings }
    function GetDefaultTextSettings: TTextSettings;
    function GetTextSettings: TTextSettings;
    function GetStyledSettings: TStyledSettings;
    function GetResultingTextSettings: TTextSettings;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    procedure DoStyleChanged; override;
    procedure SetText(const Value: string); virtual;
    procedure SetTextInternal(const Value: string); virtual;
    procedure SetName(const Value: TComponentName); override;
    function GetData: TValue; override;
    procedure SetData(const Value: TValue); override;
    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); override;
    procedure Loaded; override;
    function FindTextObject: TFmxObject; virtual;
    procedure UpdateTextObject(const TextControl: TControl; const Str: string);
    property TextObject: TControl read FTextObject;
    procedure DoTextChanged; virtual;
    function CalcTextObjectSize(const MaxWidth: Single; var Size: TSizeF): Boolean;
    { ITextSettings }
    procedure SetTextSettings(const Value: TTextSettings); virtual;
    procedure SetStyledSettings(const Value: TStyledSettings); virtual;
    procedure DoChanged; virtual;
    function StyledSettingsStored: Boolean; virtual;
    function GetTextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    function ToString: string; override;

    property Text: string read GetText write SetText stored IsTextStored;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings stored StyledSettingsStored nodefault;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;

    procedure Change;
    procedure EndUpdate; //override;
    property Font: TFont read GetFont write SetFont;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor default TAlphaColorRec.Black;
    property VertTextAlign: TTextAlign read GetVertTextAlign write SetVertTextAlign default TTextAlign.Center;
    property TextAlign: TTextAlign read GetTextAlign write SetTextAlign default TTextAlign.Leading;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default False;
    property Trimming: TTextTrimming read GetTrimming write SetTrimming default TTextTrimming.None;
  end;


//  TaDCText = class(TaOPCDataObject)
//  private
//    FTextSettingsInfo: TTextSettingsInfo;
//    FTextObject: TControl;
//    FTextShadow: TControl;
//    FITextSettings: ITextSettings;
//    FIShadowSettings: ITextSettings;
//    FText: string;
//    FIsChanging: Boolean;
//    function IsTextStored: Boolean;
//    function GetFont: TFont;
//    function GetText: string;
//    procedure SetFont(const Value: TFont);
//    function GetTextAlign: TTextAlign;
//    procedure SetTextAlign(const Value: TTextAlign);
//    function GetVertTextAlign: TTextAlign;
//    procedure SetVertTextAlign(const Value: TTextAlign);
//    function GetWordWrap: Boolean;
//    procedure SetWordWrap(const Value: Boolean);
//    function GetFontColor: TAlphaColor;
//    procedure SetFontColor(const Value: TAlphaColor);
//    function GetTrimming: TTextTrimming;
//    procedure SetTrimming(const Value: TTextTrimming);
//    procedure ReadFontFillColor(Reader: TReader);
//    procedure ReadFontFillKind(Reader: TReader);
//    { ITextSettings }
//    function GetDefaultTextSettings: TTextSettings;
//    function GetTextSettings: TTextSettings;
//    function GetStyledSettings: TStyledSettings;
//    function GetLastTextSettings: TTextSettings;
//    function CreateTextSettingsInfo: TTextSettingsInfo;
//  protected
//    procedure DefineProperties(Filer: TFiler); override;
//    procedure ApplyStyle; override;
//    procedure FreeStyle; override;
//    procedure DoStyleChanged; override;
//    procedure SetText(const Value: string); virtual;
//    procedure SetName(const Value: TComponentName); override;
//    function GetData: TValue; override;
//    procedure SetData(const Value: TValue); override;
//    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); override;
//    procedure Loaded; override;
//    function FindTextObject: TFmxObject; virtual;
//    property TextObject: TControl read FTextObject;
//    { ITextSettings }
//    procedure SetTextSettings(const Value: TTextSettings); virtual;
//    procedure SetStyledSettings(const Value: TStyledSettings); virtual;
//    procedure DoChanged; virtual;
//    function StyledSettingsStored: Boolean; virtual;
//  public
//    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;
//    procedure AfterConstruction; override;
//    function ToString: string; override;
//
//    property Text: string read GetText write SetText stored IsTextStored;
//
//    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
//    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
//    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings stored StyledSettingsStored nodefault;
//    property LastTextSettings: TTextSettings read GetLastTextSettings;
//
//    procedure Change;
//    property Font: TFont read GetFont write SetFont;
//    property FontColor: TAlphaColor read GetFontColor write SetFontColor default TAlphaColorRec.Black;
//    property VertTextAlign: TTextAlign read GetVertTextAlign write SetVertTextAlign default TTextAlign.taCenter;
//    property TextAlign: TTextAlign read GetTextAlign write SetTextAlign default TTextAlign.taLeading;
//    property WordWrap: Boolean read GetWordWrap write SetWordWrap default False;
//    property Trimming: TTextTrimming read GetTrimming write SetTrimming default TTextTrimming.ttNone;
//  end;


implementation

uses
  System.SysUtils,
  System.Math, System.Math.Vectors;

type
  TOpenFMXActionLink = class (TActionLink);


{$REGION 'TTextSettingsInfo'}

{$REGION 'Helper classes'}

{ TTextSettingsInfo.TBaseTextSettings }

constructor TTextSettingsInfo.TBaseTextSettings.Create(const AOwner: TPersistent);
begin
  inherited;
  if AOwner is TTextSettingsInfo then
  begin
    FInfo := TTextSettingsInfo(AOwner);
    if FInfo.Owner is TControl then
      FControl := TControl(FInfo.Owner);
  end
  else
    raise EArgumentException.CreateFMT(SEUseHeirs, [TTextSettingsInfo.ClassName]);
end;

{ TTextSettingsInfo.TCustomTextSettings }

constructor TTextSettingsInfo.TCustomTextSettings.Create(const AOwner: TPersistent);
begin
  inherited;
  Trimming := TTextTrimming.None;
  WordWrap := True;
end;

{$ENDREGION}

type
  TOpenReader = class (TReader)

  end;

{ TTextSettingsInfo.TTextPropLoader }

constructor TTextSettingsInfo.TTextPropLoader.Create(const AInstance: TComponent; const AFiler: TFiler);
begin
  if (AInstance = nil) or (AFiler = nil) then
    raise EArgumentNilException.Create(SArgumentNil);
  inherited Create;
  FInstance := AInstance;
  FFiler := AFiler;
  if not FInstance.GetInterface(ITextSettings, FITextSettings) then
    raise EArgumentException.CreateFMT(SUnsupportedInterface, [FInstance.ClassName, 'ITextSettings']);
  FTextSettings := FITextSettings.TextSettings;
  if (FTextSettings = nil) then
    raise EArgumentNilException.Create(SArgumentNil);
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadSet(const Instance: TPersistent; const Reader: TReader; const PropertyName: string);
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Instance.ClassInfo, PropertyName);
  if (PropInfo <> nil) and (PropInfo.PropType <> nil) and (PropInfo.PropType^.Kind = tkSet) then
    SetOrdProp(Instance, PropInfo, TOpenReader(Reader).ReadSet(PropInfo.PropType^))
  else
    Reader.SkipValue;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadEnumeration(const Instance: TPersistent; const Reader: TReader; const PropertyName: string);
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Instance.ClassInfo, PropertyName);
  if (PropInfo <> nil) and (PropInfo.PropType <> nil) and (PropInfo.PropType^.Kind = tkEnumeration) then
    SetEnumProp(Instance, PropertyName, Reader.ReadIdent)
  else
    Reader.SkipValue;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadFontFillColor(Reader: TReader);
var
  LFontColor: TAlphaColor;
begin
  IdentToAlphaColor(Reader.ReadIdent, Integer(LFontColor));
  TextSettings.FontColor := LFontColor;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadFontFamily(Reader: TReader);
begin
  TextSettings.Font.Family := Reader.ReadString;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadFontFillKind(Reader: TReader);
begin
  Reader.ReadIdent;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadFontStyle(Reader: TReader);
begin
  ReadSet(TextSettings.Font, Reader, 'Style');
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadFontSize(Reader: TReader);
begin
  TextSettings.Font.Size := Reader.ReadFloat;
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadTextAlign(Reader: TReader);
begin
  ReadEnumeration(TextSettings, Reader, 'HorzAlign');
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadVertTextAlign(Reader: TReader);
begin
  ReadEnumeration(TextSettings, Reader, 'VertAlign');
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadWordWrap(Reader: TReader);
begin
  ReadEnumeration(TextSettings, Reader, 'WordWrap');
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadTrimming(Reader: TReader);
begin
  ReadEnumeration(TextSettings, Reader, 'Trimming');
end;

procedure TTextSettingsInfo.TTextPropLoader.ReadProperties;
begin
  TextSettings.BeginUpdate;
  try
    Filer.DefineProperty('FontFill.Color', ReadFontFillColor, nil, False);
    Filer.DefineProperty('FontFill.Kind', ReadFontFillKind, nil, False);
    Filer.DefineProperty('Font.Family', ReadFontFamily, nil, False);
    Filer.DefineProperty('Font.Style', ReadFontStyle, nil, False);
    Filer.DefineProperty('Font.Size', ReadFontSize, nil, False);
    Filer.DefineProperty('FontColor', ReadFontFillColor, nil, False);
    Filer.DefineProperty('TextAlign', ReadTextAlign, nil, False);
    Filer.DefineProperty('HorzTextAlign', ReadTextAlign, nil, False);
    Filer.DefineProperty('VertTextAlign', ReadVertTextAlign, nil, False);
    Filer.DefineProperty('WordWrap', ReadWordWrap, nil, False);
    Filer.DefineProperty('Trimming', ReadTrimming, nil, False);
  finally
    TextSettings.EndUpdate;
  end;
end;

{ TTextSettingsInfo }

constructor TTextSettingsInfo.Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass);
var
  LClass: TTextSettingsInfo.TCustomTextSettingsClass;
begin
  if not Assigned(AOwner) then
    raise EArgumentNilException.Create(SArgumentNil);
  inherited Create;
  FOwner := AOwner;
  FStyledSettings := DefaultStyledSettings;
  if ATextSettingsClass = nil then
    LClass := TCustomTextSettings
  else
    LClass := ATextSettingsClass;

  FDefaultTextSettings := LClass.Create(Self);
  FDefaultTextSettings.OnChanged := OnDefaultChanged;
  FTextSettings := LClass.Create(Self);
  FTextSettings.OnChanged := OnTextChanged;
  FResultingTextSettings := LClass.Create(Self);
  FResultingTextSettings.OnChanged := OnCalculatedTextSettings;
  FOldTextSettings := LClass.Create(Self);
  FOldTextSettings.Assign(FTextSettings);
end;

destructor TTextSettingsInfo.Destroy;
begin
  FreeAndNil(FDefaultTextSettings);
  FreeAndNil(FTextSettings);
  FreeAndNil(FResultingTextSettings);
  FreeAndNil(FOldTextSettings);
  inherited;
end;

procedure TTextSettingsInfo.OnCalculatedTextSettings(Sender: TObject);
begin
  DoCalculatedTextSettings;
end;

procedure TTextSettingsInfo.OnDefaultChanged(Sender: TObject);
begin
  DoDefaultChanged;
end;

procedure TTextSettingsInfo.OnTextChanged(Sender: TObject);
begin
  DoTextChanged;
end;

procedure TTextSettingsInfo.SetDefaultTextSettings(const Value: TTextSettings);
begin
  FDefaultTextSettings.Assign(Value);
end;

procedure TTextSettingsInfo.SetTextSettings(const Value: TTextSettings);
begin
  FTextSettings.Assign(Value);
end;

procedure TTextSettingsInfo.SetStyledSettings(const Value: TStyledSettings);
begin
  if FStyledSettings <> Value then
  begin
    FStyledSettings := Value;
    DoStyledSettingsChanged;
  end;
end;

procedure TTextSettingsInfo.DoStyledSettingsChanged;
begin
  RecalculateTextSettings;
end;

procedure TTextSettingsInfo.RecalculateTextSettings;
var
  TmpResultingTextSettings: TTextSettings;
begin
  if ResultingTextSettings <> nil then
  begin
    TmpResultingTextSettings := TTextSettingsClass(TextSettings.ClassType).Create(Self);
    try
      TmpResultingTextSettings.Assign(DefaultTextSettings);
      TmpResultingTextSettings.AssignNotStyled(TextSettings, StyledSettings);
      ResultingTextSettings.Assign(TmpResultingTextSettings);
    finally
      TmpResultingTextSettings.Free;
    end;
  end;
end;

procedure TTextSettingsInfo.DoDefaultChanged;
begin
  RecalculateTextSettings;
end;

procedure TTextSettingsInfo.DoTextChanged;
begin
  try
    if Design then
      TextSettings.UpdateStyledSettings(FOldTextSettings, DefaultTextSettings, FStyledSettings);
    RecalculateTextSettings;
  finally
    if FOldTextSettings <> nil then
      FOldTextSettings.Assign(FTextSettings);
  end;
end;

procedure TTextSettingsInfo.DoCalculatedTextSettings;
begin
end;

{$ENDREGION}

type
  TaDCTextSettingsInfo = class (TTextSettingsInfo)
  private
    [Weak] FTextControl: TaDCText;
  protected
    procedure DoCalculatedTextSettings; override;
  public
    constructor Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass); override;
    property TextControl: TaDCText read FTextControl;
  end;

{ TaDCTextSettingsInfo }

constructor TaDCTextSettingsInfo.Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass);
begin
  inherited;
  if AOwner is TaDCText then
    FTextControl := TaDCText(AOwner)
  else
    raise EArgumentException.CreateFMT(SEUseHeirs, [TaDCText.ClassName]);
end;

procedure TaDCTextSettingsInfo.DoCalculatedTextSettings;
begin
  inherited;
  FTextControl.DoChanged;
end;

{ TaDCText }
type
  TaDCTextTextSettings = class (TTextSettingsInfo.TCustomTextSettings)
  published
    property Font;
    property FontColor;
  end;

constructor TaDCText.Create(AOwner: TComponent);
begin
  inherited;
  FIsChanging := True;
  FTextSettingsInfo := TaDCTextSettingsInfo.Create(Self, GetTextSettingsClass);
  EnableExecuteAction := True;
end;

destructor TaDCText.Destroy;
begin
  FreeAndNil(FTextSettingsInfo);
  inherited;
end;

procedure TaDCText.AfterConstruction;
begin
  inherited;
  FIsChanging := False;
end;

procedure TaDCText.DefineProperties(Filer: TFiler);
var
  LTextPropLoader: TTextSettingsInfo.TTextPropLoader;
begin
  inherited;
  // Only for backward compatibility with old versions
  LTextPropLoader := TTextSettingsInfo.TTextPropLoader.Create(Self, Filer);
  try
    LTextPropLoader.ReadProperties;
  finally
    LTextPropLoader.Free;
  end;
end;

procedure TaDCText.SetName(const Value: TComponentName);
var
  ChangeText: Boolean;
begin
  ChangeText := not(csLoading in ComponentState) and (Name = Text) and
    ((Not Assigned(Owner)) or not(Owner is TComponent) or not(csLoading in TComponent(Owner).ComponentState));
  inherited SetName(Value);
  if ChangeText then
    Text := Value;
end;

procedure TaDCText.ActionChange(Sender: TBasicAction; CheckDefaults: Boolean);
begin
  if Sender is TCustomAction then
  begin
    if (not CheckDefaults) or (Text = '') or (Text = Name) then
     Text := TCustomAction(Sender).Text;
  end;
  inherited;
end;

function TaDCText.FindTextObject: TFmxObject;
begin
  Result := FindStyleResource('text');
end;

procedure TaDCText.ApplyStyle;
var
  S: TFmxObject;
  NewT : string;
  FontBehavior: IFontBehavior;

  procedure SetupDefaultTextSetting(const AObject: TFmxObject;
                                      var AITextSettings: ITextSettings;
                                      var ATextObject: TControl;
                                    const ADefaultTextSettings: TTextSettings);
  var
    NewFamily: string;
    NewSize: Single;
  begin
    if (AObject <> nil) and AObject.GetInterface(IObjectState, FObjectState) then
      FObjectState.SaveState
    else
      FObjectState := nil;
    AITextSettings := nil;
    ATextObject := nil;
    if Assigned(ADefaultTextSettings) then
    begin
      if Assigned(AObject) and Supports(AObject, ITextSettings, AITextSettings) then
        ADefaultTextSettings.Assign(AITextSettings.TextSettings)
      else
        ADefaultTextSettings.Assign(nil);

      if Assigned(FontBehavior) then
      begin
        NewFamily := '';
        FontBehavior.GetDefaultFontFamily(Scene.GetObject, NewFamily);
        if NewFamily <> '' then
          ADefaultTextSettings.Font.Family := NewFamily;

        NewSize := 0;
        FontBehavior.GetDefaultFontSize(Scene.GetObject, NewSize);
        if not SameValue(NewSize, 0, TEpsilon.FontSize) then
          ADefaultTextSettings.Font.Size := NewSize;
      end;
    end;
    if (AObject is TControl) then
      ATextObject := TControl(AObject)
  end;

begin
  ResultingTextSettings.BeginUpdate;
  try
    FTextSettingsInfo.Design := False;
    { behavior }
    if Assigned(Scene) then
      TBehaviorServices.Current.SupportsBehaviorService(IFontBehavior, IInterface(FontBehavior), Scene.GetObject);
    { from text }
    SetupDefaultTextSetting(FindTextObject,
                            FITextSettings,
                            FTextObject,
                            FTextSettingsInfo.DefaultTextSettings);
    inherited;
    { from foreground }
    S := FindStyleResource('foreground');
    if Assigned(S) and (S is TBrushObject) then
    begin
      // use instead of the black, foreground color
      if (FTextSettingsInfo.DefaultTextSettings.FontColor = claBlack) or
         (FTextSettingsInfo.DefaultTextSettings.FontColor = claNull) then
        FTextSettingsInfo.DefaultTextSettings.FontColor := TBrushObject(S).Brush.Color;
    end;
    ResultingTextSettings.Change;
  finally
    ResultingTextSettings.EndUpdate;
    FTextSettingsInfo.Design := csDesigning in ComponentState;
  end;
  if AutoTranslate and (FText <> '') then
  begin
    NewT := Translate(Text); // need for collection texts
    if not(csDesigning in ComponentState) then
      Text := NewT;
  end;
end;

procedure TaDCText.FreeStyle;
begin
  if FObjectState <> nil then
  begin
    FObjectState.RestoreState;
    FObjectState := nil;
  end
  else
    if FITextSettings <> nil then
      FITextSettings.TextSettings := FITextSettings.DefaultTextSettings;
  FITextSettings := nil;
  FTextObject := nil;
  inherited;
end;

procedure TaDCText.DoChanged;
var
  TextStr: string;
begin
  if Assigned(FITextSettings) then
    FITextSettings.TextSettings.BeginUpdate;
  try
    if Assigned(FITextSettings) then
      FITextSettings.TextSettings.Assign(ResultingTextSettings);
    TextStr := DelAmp(Text);

    if Assigned(FTextObject) then
    begin
      UpdateTextObject(FTextObject, TextStr);
    end
    else
    begin
      if Assigned(ResourceControl) and (ResourceControl is TText) then
        UpdateTextObject(ResourceControl, TextStr)
      else
      begin
        Repaint;
        UpdateEffects;
      end;
    end;
  finally
    if Assigned(FITextSettings) then
      FITextSettings.TextSettings.EndUpdate;
  end;
end;

procedure TaDCText.DoTextChanged;
begin

end;

procedure TaDCText.EndUpdate;
var
  NeedChange: Boolean;
begin
  NeedChange := IsUpdating and ([csLoading, csDestroying] * ComponentState = []) and (not Released);
  inherited;
  if NeedChange and not IsUpdating and (ResultingTextSettings.IsAdjustChanged or ResultingTextSettings.IsChanged) then
    Change;
end;

function TaDCText.CalcTextObjectSize(const MaxWidth: Single; var Size: TSizeF): Boolean;
const
  FakeText = 'P|y';

  function RoundToScale(const Value, Scale: Single): Single;
  begin
    if Scale > 0 then
      Result := Ceil(Value * Scale) / Scale
    else
      Result := Ceil(Value);
  end;

var
  Layout: TTextLayout;
  LScale: Single;
  LText: string;
  LMaxWidth: Single;

begin
  Result := False;
  if (Scene <> nil) and (TextObject <> nil) then
  begin
    LMaxWidth := MaxWidth - TextObject.Margins.Left - TextObject.Margins.Right;

    LScale := Scene.GetSceneScale;
    Layout := TTextLayoutManager.DefaultTextLayout.Create;
    try
      if TextObject is TText then
        LText := TText(TextObject).Text
      else
        LText := Text;
      Layout.BeginUpdate;
      if LText.IsEmpty then
        Layout.Text := FakeText
      else
        Layout.Text := LText;
      Layout.Font := ResultingTextSettings.Font;
      if WordWrap and (LMaxWidth > 1) then
        Layout.MaxSize := TPointF.Create(LMaxWidth, Layout.MaxSize.Y);
      Layout.WordWrap := WordWrap;
      Layout.Trimming := Trimming;
      Layout.VerticalAlign := TTextAlign.Leading;
      Layout.HorizontalAlign := TTextAlign.Leading;
      Layout.EndUpdate;
      if LText.IsEmpty then
        Size.Width := 0
      else
        Size.Width := RoundToScale(Layout.Width, LScale);
      Size.Width := Size.Width + TextObject.Margins.Left + TextObject.Margins.Right;
      Size.Height := RoundToScale(Layout.Height, LScale) + TextObject.Margins.Top + TextObject.Margins.Bottom;
      Result := True;
    finally
      Layout.Free;
    end;
  end;
end;

procedure TaDCText.Change;
begin
  if not FIsChanging and ([csLoading, csDestroying] * ComponentState = []) and (not Released) then
  begin
    FIsChanging := True;
    try
      DoChanged;
      ResultingTextSettings.IsAdjustChanged := False;
      ResultingTextSettings.IsChanged := False;
    finally
      FIsChanging := False;
    end;
  end;
end;

procedure TaDCText.DoStyleChanged;
var
  NewT: string;
begin
  inherited;
  if AutoTranslate and (Text <> '') then
  begin
    NewT := Translate(Text); // need for collection texts
    if not(csDesigning in ComponentState) then
      Text := NewT;
  end;
end;

function TaDCText.IsTextStored: Boolean;
begin
  Result := ((Text <> '') and (not ActionClient))
            or
            (not (ActionClient and
                  (ActionLink is TActionLink) and
                  (TOpenFMXActionLink(ActionLink).IsCaptionLinked) and
                  (Action is TContainedAction)));
end;

procedure TaDCText.Loaded;
begin
  inherited;
  Change;
  FTextSettingsInfo.Design := csDesigning in ComponentState;
end;

function TaDCText.GetText: string;
begin
  Result := FText;
end;

procedure TaDCText.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    ResultingTextSettings.IsAdjustChanged := True;
    if (FUpdating = 0) and ([csUpdating, csLoading, csDestroying] * ComponentState = []) then
    begin
      Change;
      DoTextChanged;
    end;
  end;
end;

procedure TaDCText.SetTextInternal(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    Change;
  end;
end;

procedure TaDCText.SetStyledSettings(const Value: TStyledSettings);
begin
  FTextSettingsInfo.StyledSettings := Value;
end;

function TaDCText.GetData: TValue;
begin
  Result := Text;
end;

procedure TaDCText.SetData(const Value: TValue);
begin
  if Value.IsEmpty then
    Text := ''
  else
    Text := Value.ToString;
end;

function TaDCText.GetFont: TFont;
begin
  Result := FTextSettingsInfo.TextSettings.Font;
end;

procedure TaDCText.SetFont(const Value: TFont);
begin
  FTextSettingsInfo.TextSettings.Font := Value;
end;

function TaDCText.GetFontColor: TAlphaColor;
begin
  Result := FTextSettingsInfo.TextSettings.FontColor;
end;

function TaDCText.GetResultingTextSettings: TTextSettings;
begin
  Result := FTextSettingsInfo.ResultingTextSettings;
end;

procedure TaDCText.SetFontColor(const Value: TAlphaColor);
begin
  FTextSettingsInfo.TextSettings.FontColor := Value;
end;

function TaDCText.GetTextAlign: TTextAlign;
begin
  Result := FTextSettingsInfo.TextSettings.HorzAlign;
end;

procedure TaDCText.SetTextAlign(const Value: TTextAlign);
begin
  FTextSettingsInfo.TextSettings.HorzAlign := Value;
end;

function TaDCText.GetVertTextAlign: TTextAlign;
begin
  Result := FTextSettingsInfo.TextSettings.VertAlign;
end;

procedure TaDCText.SetVertTextAlign(const Value: TTextAlign);
begin
  FTextSettingsInfo.TextSettings.VertAlign := Value;
end;

function TaDCText.GetWordWrap: Boolean;
begin
  Result := FTextSettingsInfo.TextSettings.WordWrap;
end;

procedure TaDCText.SetWordWrap(const Value: Boolean);
begin
  FTextSettingsInfo.TextSettings.WordWrap := Value;
end;

function TaDCText.StyledSettingsStored: Boolean;
begin
  Result := StyledSettings <> DefaultStyledSettings;
end;

function TaDCText.ToString: string;
begin
  Result := Format('%s ''%s''', [inherited ToString, FText]);
end;

procedure TaDCText.UpdateTextObject(const TextControl: TControl; const Str: string);
begin
  if Assigned(TextControl) then
  begin
    if TextControl is TText then
    begin
      TText(TextControl).Text := Str;
      TText(TextControl).Width := Min(TText(TextControl).Width, Width - TText(TextControl).Position.X - 5);
    end;
    if TextControl is TaDCText then
      TaDCText(TextControl).Text := Str;
    TextControl.UpdateEffects;
    UpdateEffects;
    TextControl.Repaint;
  end;
end;

function TaDCText.GetDefaultTextSettings: TTextSettings;
begin
  Result := FTextSettingsInfo.DefaultTextSettings;
end;

function TaDCText.GetTextSettings: TTextSettings;
begin
  Result := FTextSettingsInfo.TextSettings;
end;

function TaDCText.GetTextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass;
begin
  Result := TaDCTextTextSettings;
end;

procedure TaDCText.SetTextSettings(const Value: TTextSettings);
begin
  FTextSettingsInfo.TextSettings.Assign(Value);
end;

function TaDCText.GetStyledSettings: TStyledSettings;
begin
  Result := FTextSettingsInfo.StyledSettings;
end;

function TaDCText.GetTrimming: TTextTrimming;
begin
  Result := FTextSettingsInfo.TextSettings.Trimming;
end;

procedure TaDCText.SetTrimming(const Value: TTextTrimming);
begin
  FTextSettingsInfo.TextSettings.Trimming := Value;
end;


end.

