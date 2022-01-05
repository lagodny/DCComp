{$IFDEF DELPHI_2005_UP}{$REGION 'Класс TCWindowThread является потомком TComponent, содержит TThreadWindow и может использоваться в визуальной среде разработк...'}{$ENDIF}
///	<summary>Класс TCWindowThread является потомком TComponent, содержит TThreadWindow и может использоваться в визуальной
///	среде разработки. Этот модуль включает так же файл ресурсов Icons.res. По умолчанию используется пиктограмма
///	<b>MesIcon9</b></summary>
///	<seealso cref="WindowThread.TThreadWindow"></seealso>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
unit CWindowThread;

interface
{$I Directives.inc}
uses
  Windows, Messages, SysUtils, Classes, WindowThread, Controls, Graphics
  {$IFDEF DELPHI_6_UP}, GraphUtil{$ENDIF}
  , Forms;

type
  TPosWindowThread = (pwtDefault, pwtDesigned, pwtTopLeft, pwtBottomRight);

  {$IFDEF DELPHI_2005_UP}{$REGION 'Класс окна, работающего в своём собственном потоке. Используется в компонентных оболочках, напр.: TCWindowThread.'}{$ENDIF}
  ///	<summary>Класс окна, работающего в своём собственном потоке. Используется в компонентных оболочках, напр.:
  ///	TCWindowThread.</summary>
  ///	<seealso cref="CWindowThread.TCWindowThread.ClassWindow"></seealso>
  {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
  TClassThreadWindow = class of TCustomThreadWindow;

  TCWindowThread = class;


  {$IFDEF DELPHI_2005_UP}{$REGION 'Окно работающее в своём собственном потоке и имеющее компонентную оболочку.'}{$ENDIF}
  ///	<summary>Окно работающее в своём собственном потоке и имеющее компонентную оболочку.</summary>
  ///	<seealso cref="TThreadWindow"></seealso>
  {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
  TCustomThreadWindow = class (TThreadWindow)
  private
    fOwner: TCWindowThread;
  protected
    function DefaultBoundsRect: TRect; override;
  public
    {$IFDEF DELPHI_2005_UP}{$REGION 'Компонентная (визуальная) оболочка для окна ожидания, которая может использоваться для задания свойств в Object Inspector.'}{$ENDIF}
    ///	<summary>Компонентная (визуальная) оболочка для окна ожидания, которая может использоваться для задания свойств в
    ///	Object Inspector.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Owner: TCWindowThread read fOwner;
    constructor Show(AOwner: TCWindowThread; AMessage: string = '');
  end;


  {$IFDEF DELPHI_2005_UP}{$REGION 'Компонентная (визуальная) оболочка для окна ожидания. Используется для того, чтобы в IDE Object Inspector можно было задава...'}{$ENDIF}
  ///	<summary>Компонентная (визуальная) оболочка для окна ожидания. Используется для того, чтобы в IDE Object Inspector можно
  ///	было задавать свойства TThreadWindow</summary>
  ///	<seealso cref="WindowThread.TThreadWindow"></seealso>
  {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
  TCWindowThread = class(TComponent)
  private
    fSetProp: boolean;
    fChanged: boolean;
    fWindow: TCustomThreadWindow;
    fText: String;
    fCaption: TCaption;
    fClassWindow: TClassThreadWindow;
    fInterval: DWORD;
    fEnabled: boolean;
    fCanceled: boolean;
    fCtl3d: boolean;
    fPercent: Integer;
    fStartTime: TDateTime;
    fTotalTime: TDateTime;
    fColor: TColor;
    fCaptionColor: TColor;
    fFont: TFont;
    fCaptionFont: TFont;
    fTimerFont: TFont;
    fUseSysFont: boolean;
    fAlphaShow: boolean;
    fBoundsRect: TRect;
    fIcon: TIcon;
    fIconSize: integer;
    fPosition: TPosWindowThread;
    fIconResourceName: string;
    fIconIndex: integer;
    fIconUpdating: boolean;
    function GetVisible: boolean;
    procedure SetText(const Value: String);
    procedure SetCaption(const Value: TCaption);
    function GetInterval: DWORD;
    procedure SetInterval(const Value: DWORD);
    function GetEnabled: boolean;
    procedure SetEnabled(const Value: boolean);
    function GetCanceled: boolean;
    procedure SetCanceled(const Value: boolean);
    procedure SetCtl3d(const Value: boolean);
    function GetPercent: Integer;
    procedure SetPercent(const Value: Integer);
    function GetStartTime: TDateTime;
    procedure SetStartTime(const Value: TDateTime);
    function GetTotalTime: TDateTime;
    procedure SetTotalTime(const Value: TDateTime);
    function GetTotalTimeSec: integer;
    procedure SetTotalTimeSec(const Value: integer);
    procedure SetColor(const Value: TColor);
    procedure SetCaptionColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure ChangeFont(Sender: TObject);
    procedure ChangeCaptionFont(Sender: TObject);
    procedure SetUseSysFont(const Value: boolean);
    procedure SetCaptionFont(const Value: TFont);
    procedure SetAlphaShow(const Value: boolean);
    function GetBoundsRect: TRect;
    procedure SetBoundsRect(const Value: TRect);
    procedure SetIcon(const Value: TIcon);
    procedure ChangeIcon(Sender: TObject);
    procedure SetIconSize(const Value: integer);
    procedure ReaderBounds(Reader: TReader);
    procedure WriterBounds(Writer: TWriter);
    procedure SetPosition(const Value: TPosWindowThread);
    function GetHeight: integer;
    function GetWidth: integer;
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure SetTimerFont(const Value: TFont);
    procedure ChangeTimerFont(Sender: TObject);
    procedure SetIconResourceName(const Value: string);
    function IconByResourceName(Name: string): HIcon;
    procedure SetIconIndex(const Value: integer);
    procedure UpdateIconHande(Window: TCustomThreadWindow; IconResourceName: string);
  protected
    procedure UpdateProperties(Window: TCustomThreadWindow);
    function CreateWindow: TCustomThreadWindow; virtual;
    procedure FreeWindow; virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure SetVisible(const Value: boolean); virtual;
  public
    property Window: TCustomThreadWindow read fWindow;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Класс окна ожидания, по умолчанию используется TCustomThreadWindow'}{$ENDIF}
    ///	<summary>Класс окна ожидания, по умолчанию используется TCustomThreadWindow</summary>
    ///	<seealso cref="TClassThreadWindow"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property ClassWindow: TClassThreadWindow read fClassWindow write fClassWindow;
    property TotalTime: TDateTime read GetTotalTime write SetTotalTime stored false;
    property StartTime: TDateTime read GetStartTime write SetStartTime;
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
  published
    {$IFDEF DELPHI_2005_UP}{$REGION 'Это свойство указывает, в каком месте монитора будет отображаться окно после установки свойства Visible'}{$ENDIF}
    ///	<summary>Это свойство указывает, в каком месте монитора будет отображаться окно после установки свойства
    ///	Visible</summary>
    ///	<seealso cref="TCustomThreadWindow.DefaultBoundsRect"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Position: TPosWindowThread read fPosition write SetPosition default pwtDefault;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Если установлено это свойство, то используются системные шрифты, иначе шрифты Font, CaptionFont, TimerFont'}{$ENDIF}
    ///	<summary>Если установлено это свойство, то используются системные шрифты, иначе шрифты Font, CaptionFont,
    ///	TimerFont</summary>
    ///	<seealso cref="Font"></seealso>
    ///	<seealso cref="CaptionFont"></seealso>
    ///	<seealso cref="TimerFont"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property UseSysFont: boolean read fUseSysFont write SetUseSysFont default true;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Видимость окна. Свойство Visible в режиме Run-Time необходимо устанавливать вручную, значение из dfm не используется.'}{$ENDIF}
    ///	<summary>
    ///	  <para>Видимость окна.</para>
    ///	  <para>Свойство Visible в режиме Run-Time необходимо устанавливать вручную, значение из dfm не используется.</para>
    ///	</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Visible: boolean read GetVisible write SetVisible stored false;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Время в миллисекундах которое проходит от установки свойства Visible в True, до фактического отображения окна на экране'}{$ENDIF}
    ///	<summary>Время в миллисекундах которое проходит от установки свойства Visible в True, до фактического отображения окна
    ///	на экране</summary>
    ///	<seealso cref="Visible"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Interval: DWORD read GetInterval write SetInterval default 1000;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Предполагаемое общее время выполнения длительной операции (в cекундах) Если это свойство больше 0, то под пиктограммой от...'}{$ENDIF}
    ///	<summary>Предполагаемое общее время выполнения длительной операции (в cекундах) Если это свойство больше 0, то под
    ///	пиктограммой отображается оставшееся время.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property TotalTimeSec: integer read GetTotalTimeSec write SetTotalTimeSec default 0;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Это свойство устанавливается после клика на кнопке "Отмена" Используется для проверки необходимости прерывания операции.'}{$ENDIF}
    ///	<summary>Это свойство устанавливается после клика на кнопке "Отмена" Используется для проверки необходимости прерывания
    ///	операции.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Canceled: boolean read GetCanceled write SetCanceled stored false;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Если установлено свойство Enabled, то видна кнопка "Отмена", и возможно перетаскивание окна с помощью мыши.'}{$ENDIF}
    ///	<summary>Если установлено свойство Enabled, то видна кнопка "Отмена", и возможно перетаскивание окна с помощью
    ///	мыши.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Enabled: boolean read GetEnabled write SetEnabled default false;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Процент выполнения умноженный на 10. Если -1, то индикатор хода выполнения не отображается.'}{$ENDIF}
    ///	<summary>Процент выполнения умноженный на 10. Если -1, то индикатор хода выполнения не отображается.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Percent: Integer read GetPercent write SetPercent default -1;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Текст сообщения.'}{$ENDIF}
    ///	<summary>Текст сообщения.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Text: String read fText write SetText;

    {$IFDEF DELPHI_2005_UP}{$REGION 'Заголовок.'}{$ENDIF}
    ///	<summary>Заголовок.</summary>
    ///	<seealso cref="Text"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Caption: TCaption read fCaption write SetCaption;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Это свойство указывает является ли рамка объёмной, или плоской.'}{$ENDIF}
    ///	<summary>Это свойство указывает является ли рамка объёмной, или плоской.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Ctl3d: boolean read fCtl3d write SetCtl3d default false;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Цвет окна.'}{$ENDIF}
    ///	<summary>Цвет окна.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Color: TColor read fColor write SetColor default cl3DLight;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Цвет заголовка.'}{$ENDIF}
    ///	<summary>Цвет заголовка.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property CaptionColor: TColor read fCaptionColor write SetCaptionColor default clInActiveCaption;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Шрифт сообщения. Important Note: Это свойство используется если UseSysFont = False  '}{$ENDIF}
    ///	<summary>
    ///	  <para>Шрифт сообщения.</para>
    ///	  <note type="important">Это свойство используется если UseSysFont = False</note>
    ///	</summary>
    ///	<seealso cref="TCWindowThread.UseSysFont"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Font: TFont read fFont write SetFont;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Шрифт заголовка. Important Note: Это свойство используется если UseSysFont = False  '}{$ENDIF}
    ///	<summary>
    ///	  <para>Шрифт заголовка.</para>
    ///	  <note type="important">Это свойство используется если UseSysFont = False</note>
    ///	</summary>
    ///	<seealso cref="TCWindowThread.UseSysFont"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property CaptionFont: TFont read fCaptionFont write SetCaptionFont;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Шрифт отображаемого времени Important Note: Это свойство используется если UseSysFont = False  '}{$ENDIF}
    ///	<summary>
    ///	  <para>Шрифт отображаемого времени</para>
    ///	  <note type="important">Это свойство используется если UseSysFont = False</note>
    ///	</summary>
    ///	<seealso cref="TCWindowThread.UseSysFont"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property TimerFont: TFont read fTimerFont write SetTimerFont;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Если установлено это свойство, то при отображении будет происходить плавное изменение прозрачности. После того, как окно ...'}{$ENDIF}
    ///	<summary>Если установлено это свойство, то при отображении будет происходить плавное изменение прозрачности. После
    ///	того, как окно отобразилось.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property AlphaShow: boolean read fAlphaShow write SetAlphaShow default false;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Отображаемая пиктограмма. Important Note: Можно использовать либо Icon, либо IconResourceName'}{$ENDIF}
    ///	<summary>
    ///	  Отображаемая пиктограмма.
    ///	  <note type="important">Можно использовать либо Icon, либо IconResourceName</note>
    ///	</summary>
    ///	<seealso cref="IconResourceName"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Icon: TIcon read fIcon write SetIcon;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Название ресурса с пиктограммой. Important Note: Можно использовать либо Icon, либо IconResourceName  '}{$ENDIF}
    ///	<summary>
    ///	  <para>Название ресурса с пиктограммой.</para>
    ///	  <note type="important">Можно использовать либо Icon, либо IconResourceName</note>
    ///	</summary>
    ///	<seealso cref="Icon"></seealso>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property IconResourceName: string read fIconResourceName write SetIconResourceName;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Размер пиктограммы.'}{$ENDIF}
    ///	<summary>Размер пиктограммы.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property IconSize: integer read fIconSize write SetIconSize default 32;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Номер отображаемой пиктограммы.'}{$ENDIF}
    ///	<summary>Номер отображаемой пиктограммы.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property IconIndex: integer read fIconIndex write SetIconIndex default 0;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Высота окна.'}{$ENDIF}
    ///	<summary>Высота окна.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Height: integer read GetHeight write SetHeight stored false;
    {$IFDEF DELPHI_2005_UP}{$REGION 'Ширина окна.'}{$ENDIF}
    ///	<summary>Ширина окна.</summary>
    {$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    property Width: integer read GetWidth write SetWidth stored false;
  end;

procedure Register;

implementation
//uses
  //GraphUtilEx
   //  {$IFDEF DELPHI_2005_UP}, DesignIntf {$ENDIF}
  //   ;

{$R Icons.Res}

procedure Register;
begin
  //MessageBox(0, 'RegisterComponents(''Cep'', [TCWindowThread]);', 'Register', 0);
  //{$IFDEF DELPHI_2005_UP}  ForceDemandLoadState(dlDisable); {$ENDIF}
  RegisterComponents('Cep', [TCWindowThread]);
end;

{ TCWindowThread }

procedure TCWindowThread.ChangeCaptionFont(Sender: TObject);
begin
  if (not fSetProp) and (fWindow <> nil) and
    (not (csDestroying in ComponentState)) then
  begin
    if not fUseSysFont then
    begin
      fWindow.CaptionFont := fCaptionFont.Handle;
      fWindow.CaptionFontColor := Cardinal(ColorToRGB(fCaptionFont.Color));
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.ChangeFont(Sender: TObject);
begin
  if (not fSetProp) and (fWindow <> nil) and
    (not (csDestroying in ComponentState)) then
  begin
    if not fUseSysFont then
    begin
      fWindow.Font := fFont.Handle;
      fWindow.FontColor := Cardinal(ColorToRGB(fFont.Color));
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.ChangeTimerFont(Sender: TObject);
begin
  if (not fSetProp) and (fWindow <> nil) and
    (not (csDestroying in ComponentState)) then
  begin
    if not fUseSysFont then
    begin
      fWindow.TimerFont := fTimerFont.Handle;
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.ChangeIcon(Sender: TObject);
begin
  if fIconUpdating then Exit;
  if (not fSetProp) and (fWindow <> nil) and
    (not (csDestroying in ComponentState)) then
  begin
    if not fIcon.Empty then
      fIconResourceName := '';
    if fWindow <> nil then
      UpdateIconHande(fWindow, fIconResourceName);
  end;
end;

constructor TCWindowThread.Create(AOwner: TComponent);
begin
  inherited;
  fIcon := TIcon.Create;
  fIcon.OnChange := ChangeIcon;
  fIconSize := 32;
  fPercent := -1;
  fText := DefaultMessage;
  fInterval := 1000;
  fUseSysFont := true;
  fColor := cl3DLight;
  fCaptionColor := clInActiveCaption;
  fFont := TFont.Create;
  fCaptionFont := TFont.Create;
  fTimerFont := TFont.Create;
  Font := nil;
  CaptionFont := nil;
  TimerFont := nil;
  fFont.OnChange := ChangeFont;
  fCaptionFont.OnChange := ChangeCaptionFont;
  fTimerFont.OnChange := ChangeTimerFont;
end;

destructor TCWindowThread.Destroy;
begin
  FreeWindow;
  FreeAndNil(fIcon);
  FreeAndNil(fFont);
  FreeAndNil(fCaptionFont);
  FreeAndNil(fTimerFont);
  inherited;
end;

procedure TCWindowThread.UpdateIconHande(Window: TCustomThreadWindow; IconResourceName: string);
var
  Icon: HICON;
begin
  fIconUpdating := true;
  try
    Icon := IconByResourceName(IconResourceName);
    try
      Window.IconSize := fIconSize;
      if (Icon = 0) or (Integer(Icon) = -1) then
      begin
        if (fIcon.Empty) then fIcon.Handle := 0;
        Window.Icon := fIcon.Handle;
      end
      else
      begin
        fIcon.Handle := 0;
        Window.Icon := Icon;
      end;
    finally
      if (Icon <> 0) and (integer(Icon) <> -1) then
        if not DestroyIcon(Icon) then
          RaiseLastOSError;
    end;
  finally
    fIconUpdating := false;
  end;
end;

function TCWindowThread.IconByResourceName(Name: string): HIcon;
var
  F: Cardinal;
  W: integer;
begin
  result := HIcon(-1);
  if Name <> '' then
  begin
    F := LR_LOADMAP3DCOLORS;
    W := IconSize;
    if W <= 0 then
      F := F or LR_DEFAULTSIZE;
    result := Windows.LoadImage(hInstance, PChar(Name), IMAGE_ICON, W, W, F);
  end;
end;

function TCWindowThread.CreateWindow: TCustomThreadWindow;
var lpCriticalSection: TRTLCriticalSection;
    W, H: Integer;
    R: TRect;
begin
  if fClassWindow = nil then result := TCustomThreadWindow.Show(self, fText)
  else result := fClassWindow.Show(self, fText);
  try
    FillChar(lpCriticalSection, SizeOf(lpCriticalSection), 0);
    InitializeCriticalSection(lpCriticalSection);
    try
      with result do
      begin
        EnterCriticalSection(lpCriticalSection);

        Canceled := fCanceled;
        Interval := fInterval;
        AlphaShow := fAlphaShow;

        result.Color := TColor(ColorToRGB(fColor));
        CaptionColor := Cardinal(ColorToRGB(fCaptionColor));
        Text := fText;
        Caption := fCaption;
        Enabled := fEnabled;
        Ctl3d := fCtl3d;
        Percent := fPercent;
        StartTime := fStartTime;
        TotalTime := fTotalTime;
        IconSize := fIconSize;
        IconIndex := fIconIndex;
        if not fUseSysFont then
        begin
          Font := fFont.Handle;
          FontColor := Cardinal(ColorToRGB(fFont.Color));
          CaptionFontColor := Cardinal(ColorToRGB(fCaptionFont.Color));
          CaptionFont := fCaptionFont.Handle;
  //        TimerFontColor := clWindow;
        end;
        UpdateIconHande(Result, fIconResourceName);
        if Position = pwtDesigned then
          BoundsRect := fBoundsRect
        else
        begin
          FillChar(R, SizeOf(R), 0);
          W := Width;
          H := Height;
          if (W > 0) and (H > 0) then
          begin
            R := DefaultRect;
            BoundsRect := R;
          end;
        end;
      end;
    finally
      LeaveCriticalSection(lpCriticalSection);
      DeleteCriticalSection(lpCriticalSection);
    end;
  except
    result.Free;
    raise
  end;
end;

procedure TCWindowThread.UpdateProperties(Window: TCustomThreadWindow);
begin
  if (Window <> nil) and (not (csDestroying in ComponentState)) and (not fSetProp) then
  begin
    fSetProp := true;
    fChanged := false;
    Updating;
    try
      Text := Window.Message;
      Caption := Window.Caption;
      Interval := Window.Interval;
      Enabled := Window.Enabled;
      Canceled := Window.Canceled;
      Ctl3d := Window.Ctl3d;
      Percent := Window.Percent;
      StartTime := Window.StartTime;
      TotalTime := Window.TotalTime;
      Color := TColor(Window.Color);
      CaptionColor := TColor(Window.CaptionColor);
      BoundsRect := Window.BoundsRect;
      IconSize := Window.IconSize;
      IconIndex := Window.IconIndex;
      if not fUseSysFont then
      begin
        fFont.Color := TColor(Window.FontColor);
        fCaptionFont.Color := TColor(Window.CaptionFontColor);
        fTimerFont.Color := clWindow;
      end;
    finally
      fSetProp := false;
      Updated;
    end;
  end;
end;

procedure TCWindowThread.FreeWindow;
begin
  UpdateProperties(fWindow);
  fWindow.Free;
  fWindow := nil;
end;

function TCWindowThread.GetBoundsRect: TRect;
begin
  if fWindow <> nil then fBoundsRect := fWindow.BoundsRect;
  result := fBoundsRect;
end;

function TCWindowThread.GetCanceled: boolean;
begin
  if fWindow <> nil then fCanceled := fWindow.Canceled;
  result := fCanceled;
end;

function TCWindowThread.GetEnabled: boolean;
begin
  if fWindow <> nil then fEnabled := fWindow.Enabled;
  result := fEnabled;
end;

function TCWindowThread.GetHeight: integer;
var R: TRect;
begin
  R := BoundsRect;
  result := R.Bottom - R.Top;
end;

function TCWindowThread.GetInterval: Cardinal;
begin
  if fWindow <> nil then fInterval := fWindow.Interval;
  result := fInterval;
end;

function TCWindowThread.GetPercent: Integer;
begin
  if fWindow <> nil then fPercent := fWindow.Percent;
  result := fPercent;
end;

function TCWindowThread.GetStartTime: TDateTime;
begin
  if fWindow <> nil then fStartTime := fWindow.StartTime;
  result := fStartTime;
end;

function TCWindowThread.GetTotalTime: TDateTime;
begin
  if fWindow <> nil then fTotalTime := fWindow.TotalTime;
  result := fTotalTime;
end;

function TCWindowThread.GetTotalTimeSec: integer;
begin
  result := Round(TotalTime * (24 * 60 * 60));
end;

function TCWindowThread.GetVisible: boolean;
begin
  result := (fWindow <> nil) and (fWindow.Visible);
end;

function TCWindowThread.GetWidth: integer;
var R: TRect;
begin
  R := BoundsRect;
  result := R.Right - R.Left;
end;

procedure TCWindowThread.SetAlphaShow(const Value: boolean);
begin
  if Value <> fAlphaShow then
  begin
    fAlphaShow := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.AlphaShow := fAlphaShow;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetCanceled(const Value: boolean);
begin
  if Value <> fCanceled then
  begin
    fCanceled := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Canceled := fCanceled;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetCaption(const Value: TCaption);
begin
  if Value <> fCaption then
  begin
    fCaption := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Caption := fCaption;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetCaptionColor(const Value: TColor);
begin
  if Value <> fCaptionColor then
  begin
    fCaptionColor := Value;
    if (fWindow <> nil) and (not fSetProp) and
      (fWindow.CaptionColor <> Cardinal(ColorToRGB(fCaptionColor))) then
      fWindow.CaptionColor := Cardinal(ColorToRGB(fCaptionColor));
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetCaptionFont(const Value: TFont);
var Data: TLOGFont;
  F: HFont;
begin
  if Value <> nil then
  begin
    fCaptionFont.Assign(Value);
  end else
  begin
    Data := TCustomThreadWindow.GetFontIndirect(0, dSmCaptionFont);
    F := CreateFontIndirect(Data);
    try
      fCaptionFont.Handle := F;
      fCaptionFont.Color := clInactiveCaptionText;
    finally
      if not DeleteObject(F) then RaiseLastOSError;
    end;
  end;
end;

procedure TCWindowThread.SetTimerFont(const Value: TFont);
var Data: TLOGFont;
  F: HFont;
begin
  if Value <> nil then
  begin
    fTimerFont.Assign(Value);
  end else
  begin
    Data := TCustomThreadWindow.GetFontIndirect(0, dTimeFont);
    F := CreateFontIndirect(Data);
    try
      fTimerFont.Handle := F;
      fTimerFont.Color := clWindowText;
    finally
      if not DeleteObject(F) then RaiseLastOSError;
    end;
  end;
end;

procedure TCWindowThread.SetFont(const Value: TFont);
var Data: TLOGFont;
  F: HFont;
begin
  if Value <> nil then
  begin
    fFont.Assign(Value);
  end else
  begin
    Data := TCustomThreadWindow.GetFontIndirect(0, dMessageFont);
    F := CreateFontIndirect(Data);
    try
      fFont.Handle := F;
      fFont.Color := clWindowText;
    finally
      if not DeleteObject(F) then RaiseLastOSError;
    end;
  end;
end;

procedure TCWindowThread.SetHeight(const Value: integer);
var R: TRect;
begin
  R := BoundsRect;
  R.Bottom := R.Top + Abs(Value);
  fBoundsRect := R;
  if fWindow <> nil then
  begin
    R := fWindow.DefaultRect;
    fWindow.BoundsRect := R;
  end;
end;

procedure TCWindowThread.SetWidth(const Value: integer);
var R: TRect;
begin
  R := BoundsRect;
  R.Right := R.Left + Abs(Value);
  fBoundsRect := R;
  if fWindow <> nil then
  begin
    R := fWindow.DefaultRect;
    if (not fSetProp) then fWindow.BoundsRect := R;
  end;
end;

procedure TCWindowThread.SetBoundsRect(const Value: TRect);
var R: TRect;
begin
  R := Value;
  if not CompareMem(@R, @fBoundsRect, SizeOf(fBoundsRect)) then
  begin
    fBoundsRect := R;
    if (fWindow <> nil) then
    begin
      R := fWindow.DefaultRect;
      if (not fSetProp) then fWindow.BoundsRect := R;
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetColor(const Value: TColor);
begin
  if Value <> fColor then
  begin
    fColor := Value;
    if (fWindow <> nil) and (not fSetProp) and
      (fWindow.Color <> Cardinal(ColorToRGB(fColor))) then
      fWindow.Color := Cardinal(ColorToRGB(fColor));
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetCtl3d(const Value: boolean);
begin
  if Value <> fCtl3d then
  begin
    fCtl3d := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Ctl3d := fCtl3d;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetEnabled(const Value: boolean);
begin
  if Value <> fEnabled then
  begin
    fEnabled := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Enabled := fEnabled;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetIcon(const Value: TIcon);
begin
  if Value <> nil then
  begin
    fIcon.Assign(Value);
    fIconResourceName := '';
  end else
  begin
    fIcon.Handle := 0;
  end;
end;

procedure TCWindowThread.SetIconResourceName(const Value: string);
begin
  fIconResourceName := trim(UpperCase(Value));
  if (fWindow <> nil) and (not fSetProp) then
    UpdateIconHande(fWindow, fIconResourceName);
end;

procedure TCWindowThread.SetIconSize(const Value: integer);
begin
  if Value <> fIconSize then
  begin
    fIconSize := Value;
    if (fWindow <> nil) and (not fSetProp) then
    begin
      fWindow.IconSize := fIconSize;
      if IconResourceName <> '' then IconResourceName := fIconResourceName;
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetIconIndex(const Value: integer);
begin
  if Value <> fIconIndex then
  begin
    fIconIndex := Value;
    if (fWindow <> nil) and (not fSetProp) then
    begin
      fWindow.IconIndex := fIconIndex;
      if IconResourceName <> '' then IconResourceName := fIconResourceName;
    end;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetInterval(const Value: Cardinal);
begin
  if Value <> fInterval then
  begin
    fInterval := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Interval := fInterval;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetPercent(const Value: Integer);
begin
  if Value <> fPercent then
  begin
    fPercent := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Percent := fPercent;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetPosition(const Value: TPosWindowThread);
var R: TRect;
begin
  if Value <> fPosition then
  begin
    fPosition := Value;
    if fWindow <> nil then
    begin
      R := fWindow.DefaultRect;
      if (fWindow <> nil) and (not fSetProp) then
        fWindow.BoundsRect := R;
      fChanged := true;
    end;
  end;
end;

procedure TCWindowThread.SetStartTime(const Value: TDateTime);
begin
  if Value <> fStartTime then
  begin
    fStartTime := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.StartTime := fStartTime;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetText(const Value: String);
begin
  if Value <> fText then
  begin
    fText := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.Message := fText;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetTotalTime(const Value: TDateTime);
begin
  if Value <> fTotalTime then
  begin
    fTotalTime := Value;
    if (fWindow <> nil) and (not fSetProp) then fWindow.TotalTime := fTotalTime;
    fChanged := true;
  end;
end;

procedure TCWindowThread.SetTotalTimeSec(const Value: integer);
begin
  TotalTime := Value / (24 * 60 * 60);
end;

procedure TCWindowThread.SetUseSysFont(const Value: boolean);
var Data: TLOGFont;
  F: HFont;
begin
  if fUseSysFont <> Value then
  begin
    fUseSysFont := Value;
    if (fWindow <> nil) and (not fSetProp) then
    begin
      if fUseSysFont then
      begin
        Data := TCustomThreadWindow.GetFontIndirect(0, dMessageFont);
        F := CreateFontIndirect(Data);
        try
          fWindow.Font := F;
          fWindow.FontColor := Cardinal(ColorToRGB(clWindowText));
        finally
          if not DeleteObject(F) then RaiseLastOSError;
        end;
        Data := TCustomThreadWindow.GetFontIndirect(0, dSmCaptionFont);
        F := CreateFontIndirect(Data);
        try
          fWindow.CaptionFont := F;
          fWindow.CaptionFontColor := Cardinal(ColorToRGB(clInactiveCaptionText));
        finally
          if not DeleteObject(F) then RaiseLastOSError;
        end;
        Data := TCustomThreadWindow.GetFontIndirect(0, dTimeFont);
        F := CreateFontIndirect(Data);
        try
          fWindow.TimerFont := F;
        finally
          if not DeleteObject(F) then RaiseLastOSError;
        end;
      end else
      begin
        fWindow.Font := fFont.Handle;
        fWindow.CaptionFont := fCaptionFont.Handle;
        fWindow.FontColor := Cardinal(ColorToRGB(fFont.Color));
        fWindow.CaptionFontColor := Cardinal(ColorToRGB(fCaptionFont.Color));
        fWindow.TimerFont := fTimerFont.Handle;
      end;
    end;
  end;
end;

procedure TCWindowThread.SetVisible(const Value: boolean);
begin
  if (csLoading in ComponentState) and (not (csDesigning in ComponentState)) then Exit;
  if Value then
  begin
    if (fWindow <> nil) and (not fWindow.Visible) then FreeWindow;
    if fWindow = nil then fWindow := CreateWindow;
  end else
    FreeWindow;
end;

procedure TCWindowThread.DefineProperties(Filer: TFiler);
  function Need: boolean;
  var R: TRect;
  begin
    R := BoundsRect;
    result := (R.Right > R.Left) and (R.Bottom > R.Top);
  end;
begin
  inherited;
  Filer.DefineProperty('BoundsRect', ReaderBounds, WriterBounds, Need);
end;

procedure TCWindowThread.ReaderBounds(Reader: TReader);
var R: TRect;
begin
  Reader.ReadListBegin;
  R.Left := Reader.ReadInteger;
  R.Top := Reader.ReadInteger;
  R.Right := Reader.ReadInteger;
  R.Bottom := Reader.ReadInteger;
  Reader.ReadListEnd;
  BoundsRect := R;
end;

procedure TCWindowThread.WriterBounds(Writer: TWriter);
var R: TRect;
begin
  R := BoundsRect;
  Writer.WriteListBegin;
  Writer.WriteInteger(R.Left);
  Writer.WriteInteger(R.Top);
  Writer.WriteInteger(R.Right);
  Writer.WriteInteger(R.Bottom);
  Writer.WriteListEnd;
end;

{ TCustomThreadWindow }

function TCustomThreadWindow.DefaultBoundsRect: TRect;
var
  W: integer;
  H: integer;
  R: TRect;
  procedure SetDefaultR;
  begin
    R.Top := (Screen.Height - H) div (3);
    R.Left := (Screen.Width - W) div (2);
    R.Right := R.Left + W;
    R.Bottom := R.Top + H;
  end;
begin
  Result := inherited DefaultBoundsRect;
  if fOwner <> nil then
  begin
    W := fOwner.fBoundsRect.Right - fOwner.fBoundsRect.Left;
    if W <= 0 then
      W := Result.Right - Result.Left;

    H := fOwner.fBoundsRect.Bottom - fOwner.fBoundsRect.Top;
    if H <= 0 then
      H := Result.Bottom - Result.Top;

    case fOwner.Position of
      pwtDefault: SetDefaultR;
      pwtTopLeft:
        begin
          R.Top := GetSystemMetrics(SM_CYSMCAPTION);
          R.Left := GetSystemMetrics(SM_CYSMCAPTION);
          R.Right := R.Left + W;
          R.Bottom := R.Top + H;
        end;
      pwtBottomRight:
        begin
          R.Top := Screen.Height - 2 * GetSystemMetrics(SM_CYSMCAPTION);
          R.Left := Screen.Width - GetSystemMetrics(SM_CYSMCAPTION);
          R.Right := R.Left + W;
          R.Bottom := R.Top + H;
          OffsetRect(R, -W, -H);
          if R.Left < 0 then OffsetRect(R, -R.Left, 0);
        end;
      pwtDesigned:
        begin
          if ((fOwner.BoundsRect.Right - fOwner.BoundsRect.Left) <= 0) and
             ((fOwner.BoundsRect.Bottom - fOwner.BoundsRect.Top) <= 0) then
            SetDefaultR
          else
          begin
            R.Top := fOwner.BoundsRect.Top;
            R.Left := fOwner.BoundsRect.Left;
            R.Right := R.Left + W;
            R.Bottom := R.Top + H;
          end;
        end;
    end;
    fOwner.fBoundsRect := R;
    Result := R;
  end;
end;

constructor TCustomThreadWindow.Show(AOwner: TCWindowThread; AMessage: string);
begin
  if AOwner = nil then
    raise EThreadWindow.CreateFMT(ErrorParam, ['AOwner']);
  inherited Show(AMessage);
  fOwner := AOwner;
end;

end.

