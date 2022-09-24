{$IFDEF DELPHI_2005_UP}{$REGION 'Класс TThreadWindow является потомком TThread, и содержит окно с иконкой, текстом и индикатором хода работы. Можно использова...'}{$ENDIF}
///	<summary>Класс TThreadWindow является потомком TThread, и содержит окно с иконкой, текстом и индикатором хода работы. Можно
///	использовать при длительных операциях, чтобы пользователь не скучал.</summary>
///	<example>
///	  <para>F := TThreadWindow.Show;</para>
///	  <para><b>try</b></para>
///	  <para>&#8230;</para>
///	  <para><b>finally</b></para>
///	  <para>  F.Free;</para>
///	  <para><b>end</b>;</para>
///	</example>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
unit WindowThread;

(*
  * Module:     Класс TThreadWindow является потомком TThread
  *             и содержит окно с иконкой, текстом и индикатором
  *             хода работы.
  *             Можно использовать при длительных операциях,
  *             чтобы пользователь не скучал.
  * Version:    03.02 (10.11.2010)
  * Author:     Cepгей Poщин
  * Comments:   Сайт автора: http://www.roschinspb.narod.ru
  *
  * Copyright:  © 2005 - 2010 г.
  *
  * Version:    03.02 (10.11.2010)
  * Realized:   Добавлены комментарии для поддержки Help Insight
  *
  * Version:    03.01 (01.11.2010)
  * Realized:   Исправлена ошибка которая могла возникнуть при одновременном отображении нескольких
  *             окон. Добавлена потокозащищенность MakeObjectInstance и AllocateHWnd
  *
  * Version:    03.00 (16.04.2009)
  * Realized:   Переделал первоначальную версию задействовав Message методы (стандарный для Delphi механизм
  *             обработки сообщений).
  *             См. http://www.delphikingdom.com/asp/viewitem.asp?catalogid=1390
  *             Спасибо Сергею Галездинову
*)
interface

uses Windows,
  Messages,
  Classes,
  SysUtils,
  Math
{$IFDEF VER130},
  OldVersions{$ELSE}, GraphUtil{$ENDIF}
    //, GraphUtilEx
    ;
{$I Directives.inc}

const
{$IFDEF DELPHI_2005_UP} {$REGION 'Название ресурса, который содержит иконку этого окна'} {$ENDIF}
  /// <summary>Название ресурса, который содержит иконку этого окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  NameIconWait = 'MESICON9';
{$IFDEF DELPHI_2005_UP} {$REGION 'Название класса окна'} {$ENDIF}
  /// <summary>Название класса окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  NameClass: string = 'Class Window of TThreadWindow (new)';
{$IFDEF DELPHI_2005_UP} {$REGION 'Эта константа определяет, сколько времени надо ждать, пока будет обработано сообщение посланое потоку (0 - соответствует бе...'} {$ENDIF}
  /// <summary>Эта константа определяет, сколько времени надо ждать, пока будет обработано сообщение посланое потоку (0 -
  /// соответствует бесконечности).</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  // Alex **
  //InterValTimeOut = 20000;
  InterValTimeOut = 20000000;  // for debug

resourcestring
{$IFDEF DELPHI_2005_UP}{$REGION 'Текст отображаемый в TThreadWindow по умолчанию'}{$ENDIF}
  /// <summary>Текст отображаемый в TThreadWindow по умолчанию</summary>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
  DefaultMessage = 'Дождитесь окончания текущей операции!';
{$IFDEF DELPHI_2005_UP}{$REGION 'Текст отображаемый на кнопке "Отмена"'}{$ENDIF}
  /// <summary>Текст отображаемый на кнопке "Отмена"</summary>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
  TextCancel = 'Отмена';
  ErrorWait = 'Время ожидания истекло';
  ErrorThread = 'Во время работы потока возникла ошибка %1:s' + #13#10 + '%0:s';
  ErrorParam = 'Неверное значение параметра %s (%s)';

const
  BorderWidth = 8;
  UM_GetPropertyData = WM_USER + 2;
  UM_SetPropertyValue = WM_USER + 3;

  IntBool: array [boolean] of NativeInt = (0, 1);
  IDVisible = 1;
  IdColor = 2;
  IdFontColor = 3;
  IdIcon = 4;
  IdIconIndex = 5;
  IdIconSize = 6;
  IdBoundsRect = 7;
  IdText = 8;
  IdAlphaBlendValue = 9;
  IdFont = 10;
  IdCanceled = 11;
  IdDefaultRect = 12;

type
//  TPropertyData = packed record
  TPropertyData = record
    RecordSize: integer;
    DataSize: integer;
    Data: Pointer;
  end;

  PRopertyData = ^TPropertyData;

  //TUMPropertyData = packed record
  TUMPropertyData = record
    Msg: Cardinal;

    case Integer of
      0: (
        IndexProp: Word;
        Part: Word;
        WParamFiller1: TDWordFiller;
        //WParam: WPARAM;

        Value: PRopertyData;
        //LParam: LPARAM;

        Result: LRESULT);
      1: (
        WParamLo: Word;
        WParamHi: Word;
        WParamFiller: TDWordFiller;
        LParamLo: Word;
        LParamHi: Word;
        LParamFiller: TDWordFiller;
        ResultLo: Word;
        ResultHi: Word;
        ResultFiller: TDWordFiller);

//    //LParamFiller: TDWordFiller;
//    Value: PRopertyData;
//
//    //ResultFiller: TDWordFiller;
//    Result: LRESULT; //LongInt;
//
//    procedure FromMsg(aMsg: TMessage);
//    procedure ToMsg(var aMsg: TMessage);
  end;

  //TUMPropertyValue = packed record
  TUMPropertyValue = record
    Msg: Cardinal;

    case Integer of
      0: (
        IndexProp: Word;
        Part: Word;
        WParamFiller1: TDWordFiller;
        //WParam: WPARAM;

        Value: LPARAM; //LongInt;
        //LParam: LPARAM;

        Result: LRESULT);
      1: (
        WParamLo: Word;
        WParamHi: Word;
        WParamFiller: TDWordFiller;
        LParamLo: Word;
        LParamHi: Word;
        LParamFiller: TDWordFiller;
        ResultLo: Word;
        ResultHi: Word;
        ResultFiller: TDWordFiller);

//    WParamFiller: TDWordFiller;
//    IndexProp: Word;
//    Part: Word;
//
//    //LParamFiller: TDWordFiller;
//    Value: LPARAM; //LongInt;
//
//    //ResultFiller: TDWordFiller;
//    Result: LRESULT;//LongInt;
//
////    procedure FromMsg(aMsg: TMessage);

  end;

{$IFDEF DELPHI_2005_UP} {$REGION 'Координаты всех элементов окна относительно физических границ окна.'} {$ENDIF}
  /// <summary>Координаты всех элементов окна относительно физических границ окна.</summary>
  /// <remarks>
  /// <para>TextRect - координаты основного текста</para>
  /// <para>IconRect - координаты&#160;пиктограммы</para>
  /// <para>ProgressRect - координаты индикатора хода выполнения</para>
  /// <para>CaptionRect - координаты заголовка</para>
  /// <para>ButtonRect - координаты кнопки "отмена"</para>
  /// <para>Reserv - координаты текста отображающего время до окончания операции</para>
  /// </remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}

  TElementPos = packed record
    TextRect: TRect;
    IconRect: TRect;
    ProgressRect: TRect;
    CaptionRect: TRect;
    ButtonRect: TRect;
    Reserv: TRect;
  end;

  TWndMethod = procedure(var Message: TMessage) of object;

{$IFDEF DELPHI_2005_UP} {$REGION 'В каком месте вызывается обработчик события'} {$ENDIF}
  /// <summary>В каком месте вызывается обработчик события</summary>
  /// <remarks>
  /// <para>cdNone - неизвестно</para>
  /// <para>cdOutThread - не в потоке окна</para>
  /// <para>cdInThread - в потоке окна</para>
  /// <para>cdInWindow - в оконной процедуре</para>
  /// </remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  TCallDispath = (cdNone, cdOutThread, cdInThread, cdInWindow);

{$IFDEF DELPHI_2005_UP} {$REGION 'Что требуется перерисовать в окне'} {$ENDIF}
  /// <summary>Что требуется перерисовать в окне</summary>
  /// <remarks>
  /// <para>uaAll -&#160;Требуется перерасчет координат элементов окна и перерисовка всего окна</para>
  /// <para>uaWindow -&#160;Требуется перерисовка всего окна</para>
  /// <para>uaIcon -&#160;Требуется перерисовка только пиктограммы</para>
  /// <para>uaProgress -&#160;Требуется перерисовка только индикатора хода выполнения</para>
  /// <para>uaButton - требуется&#160;перерисовка только кнопки</para>
  /// <para>uaCaption -&#160;требуется перерисовка только заголовка</para>
  /// <para>uaTimer - требуется перерисовка только таймера</para>
  /// </remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  TUpdateArea = (uaAll, uaWindow, uaIcon, uaProgress, uaButton,
    uaCaption, uaTimer);

{$IFDEF DELPHI_2005_UP} {$REGION 'Несколько участков, которые требуется перерисовать'} {$ENDIF}
  /// <summary>Несколько участков, которые требуется перерисовать</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  TUpdateAreas = set of TUpdateArea;

{$IFDEF DELPHI_2005_UP} {$REGION 'Тип системного шрифта'} {$ENDIF}
  /// <summary>Тип системного шрифта</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
  TDefaultFont = (dCaptionFont, dSmCaptionFont, dMenuFont, dStatusFont,
    dMessageFont, dTimeFont);

{$IFDEF DELPHI_2005_UP} {$REGION 'Исключение которое может возникнуть в TThreadWindow'} {$ENDIF}
  /// <summary>Исключение которое может возникнуть в TThreadWindow</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}

  EThreadWindow = class(Exception)
  public
  end;

{$IFDEF DELPHI_2005_UP} {$REGION 'Окно отображающее ход выполнения длительной операции и работающее в своём собственном потоке.'} {$ENDIF}
  /// <summary>Окно отображающее ход выполнения длительной операции и работающее в своём собственном потоке.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}

  TThreadWindow = class(TThread)
  private
    fBusy: THandle;
    fHandleCreated: THandle;
    fTextError: string;
    fErrorClass: ExceptClass;
    fVisible: boolean;
    fShowTick: DWORD;
    fHandleCreatedTick: DWORD;
    fTimer: UINT;
    fInterval: DWORD;
    fWND: HWND;
    fColor: Cardinal;
    fBrush: HBrush;
    fCaptionBrush: HBrush;
    fBoundsRect: TRect;
    fWindowRect: TRect;
    fClientRect: TRect;
    fHObj: Pointer;
    fCallDispath: TCallDispath;
    fLastMessage: TMessage;
    fFont: hFont;
    fFontColor: Cardinal;
    fIcon: HIcon;
    fIconSize: NativeInt;
    fIconIndex: NativeInt;
    fText: string;
    fCaption: string;
    fPercent: integer;
    fOldPercent: SmallInt;
    fElementPos: TElementPos;
    fAlphaShow: boolean;
    fAlphaBlendValue: byte;
    fIntervalAlphaShow: integer;
    fEnabled: boolean;
    FEnabledCancel: Boolean;
    fOldEnabled: boolean;
    fUpdateAreas: TUpdateAreas;
    fHotPoint: TPoint;
    fCountInStack: integer;
    fLayoutUpdated: boolean;
    fStateButton: UINT;
    fCtl3D: boolean;
    fOldCtl3d: boolean;
    fCanceled: boolean;
    fCaptionFont: hFont;
    fCaptionFontColor: Cardinal;
    fCaptionColor: Cardinal;
    fTimerFont: hFont;
    fTotalTime: TDateTime;
    fStartTime: TDateTime;
    fOldStartTime: TDateTime;
    fOldTimeText: string;
    fLowBlink: boolean;
    procedure AllocateHWnd(Method: TWndMethod);
    procedure DeallocateHWnd;
    procedure SetVisible(const Value: boolean);
{$IFDEF DELPHI_2005_UP} {$REGION 'Выполняется при получении потоком любого сообщения.'} {$ENDIF}
    /// <summary>Выполняется при получении потоком любого сообщения.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure ProcessMessage(Msg: TMSG);
{$IFDEF DELPHI_2005_UP} {$REGION 'Выполняется при получении окном любого сообщения'} {$ENDIF}
    /// <summary>Выполняется при получении окном любого сообщения</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure WNDProc(var Message: TMessage);
{$IFDEF DELPHI_2005_UP} {$REGION 'Выполняется таймером через короткие промежутки времени'} {$ENDIF}
    /// <summary>Выполняется таймером через короткие промежутки времени</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure TimerProc(var M: TMessage);
{$IFDEF DELPHI_2005_UP} {$REGION 'Создание дескриптора окна'} {$ENDIF}
    /// <summary>Создание дескриптора окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure ShowWND;
{$IFDEF DELPHI_2005_UP} {$REGION 'Освобождение дескриптора окна'} {$ENDIF}
    /// <summary>Освобождение дескриптора&#160;окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure CloseWND;
    procedure SetColor(const Value: Cardinal);
    procedure UpdateBrush(const Color: Cardinal; var Brush: HBrush);
    procedure SetBoundsRect(const Value: TRect);

{$IFDEF DELPHI_2005_UP} {$REGION 'Для получения данных посылается сообщение содержащие адрес и размер данных.'} {$ENDIF}
    /// <summary>Для получения данных посылается сообщение содержащие адрес и размер данных.</summary>
    /// <remarks>Обработчик сообщение помещает данные по указанному адресу Если адрес и указатель нулевые, то выделяется память
    /// нужного размера, которую потом необходимо освободить</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure UMGetPropertyData(var Message: TUMPropertyData); message UM_GetPropertyData;
{$IFDEF DELPHI_2005_UP} {$REGION 'Отправка данных потоку окна.'} {$ENDIF}
    /// <summary>Отправка данных потоку окна.</summary>
    /// <remarks>После отправки сообщения потоку, необходимо обязательно дождаться его обработки, для этого можно использовать
    /// процедуру perform</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure UMSetPropertyValue(var Message: TUMPropertyValue);  message UM_SetPropertyValue;

    procedure WMSHOWWINDOW(var Message: TWMSHOWWINDOW); message WM_SHOWWINDOW;
    procedure WMWINDOWPOSCHANGED(var Message: TWMWINDOWPOSCHANGED);
      message WM_WINDOWPOSCHANGED;
    procedure WMERASEBKGND(var Message: TWMERASEBKGND); message WM_ERASEBKGND;
    procedure WMTIMER(var Message: TWMTIMER); message WM_TIMER;
    procedure WMLBUTTONDOWN(var Message: TWMLBUTTONDOWN);
      message WM_LBUTTONDOWN;
    procedure WMLBUTTONUP(var Message: TWMLBUTTONUP); message WM_LBUTTONUP;
    procedure SetFont(const Value: hFont);
    procedure SetFontColor(const Value: Cardinal);
    procedure SetIcon(const Value: HIcon);
    procedure FreeIcon(var DestIcon: HIcon);
    procedure UpdateIcon(SourceIcon: HIcon; var DestIcon: HIcon);
    procedure SetIconSize(const Value: NativeInt);
    procedure SetText(const Value: string);
    procedure SetIconIndex(const Value: NativeInt);
    procedure SetAlphaBlendValue(const Value: byte);
    procedure UpdateBlend(const WND: HWND; Value: byte);
    function GetText: string;
    function GetVisible: boolean;
    function GetBoundsRect: TRect;
    function CalcTextRect(S: string; Font: hFont): TRect;
    procedure SetCanceled(const Value: boolean);
    procedure SetCaptionFont(const Value: hFont);
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    procedure SetCaptionColor(const Value: Cardinal);
    procedure SetCaptionFontColor(const Value: Cardinal);
    procedure SetTimerFont(const Value: hFont);
    function GetTimeText: string;
    function GetDefaultRect: TRect;
  protected
    procedure Stop;
    procedure Execute; override;
    function MakeWParam(IndexProp, Part: Word): NativeUInt; // inline;
{$IFDEF DELPHI_2005_UP} {$REGION 'Получение данных из потока, в котором работает окно'} {$ENDIF}
    /// <summary>Получение данных из потока, в котором работает окно</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure GetPropertyData(IndexProp, Part: Word; var Buffer; Size: NativeInt); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var S: string); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var I: NativeInt); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var B: boolean); overload;
{$IFDEF DELPHI_2005_UP} {$REGION 'Если при выполнении потока произошла какая-то ошибка, то по окончании генерируем соответствующую ошибку'} {$ENDIF}
    /// <summary>Если при выполнении потока произошла какая-то ошибка, то по окончании генерируем соответствующую
    /// ошибку</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DoTerminate; override;
{$IFDEF DELPHI_2005_UP} {$REGION 'Метод DoBeforeResume выполняется в основной нити приложения перед запуском этой нити.'} {$ENDIF}
    /// <summary>Метод DoBeforeResume выполняется в основной нити приложения перед запуском этой нити.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DoBeforeResume; virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Метод DoAfterStop выполняется в основном нити приложения после остановки нити окна'} {$ENDIF}
    /// <summary>Метод DoAfterStop выполняется в основном нити приложения после остановки нити окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DoAfterStop; virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Этот метод выполняется после создания окна'} {$ENDIF}
    /// <summary>Этот метод выполняется после создания окна</summary>
    /// <param name="WND">Хэндл созданного окна</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure WNDCreated(WND: HWND); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Этот метод выполняется перед разрушением окна'} {$ENDIF}
    /// <summary>Этот метод выполняется перед разрушением окна</summary>
    /// <param name="WND">Хэндл разрушаемого окна. Если внутри метода вы самостоятельно разрушили его, то надо обнулить этот
    /// параметр.</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure WNDDestroy(var WND: HWND); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Этот метод выполняется перед обработкой сообщения'} {$ENDIF}
    /// <summary>Этот метод выполняется перед обработкой сообщения</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DoBeforeDispath(var Message: TMessage); virtual;

{$IFDEF DELPHI_2005_UP}{$REGION 'Выполняет перерисовку всего окна.'}{$ENDIF}
    /// <summary>Выполняет перерисовку всего окна.</summary>
    /// <param name="DC">Контекст в котором необходимо осуществлять вывод</param>
    /// <param name="ARect">Физические координаты окна, относительно рабочего стола</param>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    procedure DrawWND(DC: HDC; ARect: TRect); virtual;

{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка индикатора хода выполнения'} {$ENDIF}
    /// <summary>Перерисовка индикатора хода выполнения</summary>
    /// <param name="DC">Контекст устройства</param>
    /// <param name="ARect">Координаты относительно левого верхнего угла физических координат окна</param>
    /// <param name="Percent">Процент выполнения*10.</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawProgress(DC: HDC; ARect: TRect; Percent: integer); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка кнопки'} {$ENDIF}
    /// <summary>Перерисовка кнопки</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawButton(DC: HDC; ARect: TRect; State: UINT); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка таймера'} {$ENDIF}
    /// <summary>Перерисовка&#160;таймера</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawTime(DC: HDC; ARect: TRect;
      StartTime, TotalTime: TDateTime); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Устанавливает физические границы окна'} {$ENDIF}
    /// <summary>Устанавливает физические границы окна и границы клиентской области.</summary>
    /// <param name="NewBoundsRect">Новые видимые границы окна (входной параметр)</param>
    /// <param name="NewWindowRect">Новые физические границы окна</param>
    /// <param name="NewClientRect">Новые границы клиентской области,&#160; относительно физических границ окна.</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DoAfterSetBounds(NewBoundsRect: TRect;
      var NewWindowRect, NewClientRect: TRect); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Возвращает координаты всех элементов окна'} {$ENDIF}
    /// <summary>Возвращает координаты всех элементов окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure UpdateLayout(ClientRect: TRect;
      var ElementPos: TElementPos); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка текста сообщения'} {$ENDIF}
    /// <summary>Перерисовка текста сообщения</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawText(DC: HDC; ARect: TRect; Text: PChar;
      Len: integer); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка заголовка'} {$ENDIF}
    /// <summary>Перерисовка заголовка</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawCaption(DC: HDC; ARect: TRect; Text: PChar;
      Len: integer); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка пиктограммы'} {$ENDIF}
    /// <summary>Перерисовка пиктограммы</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawIcon(DC: HDC; ARect: TRect; Icon: HIcon;
      Brush: HBrush); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка рамки.'} {$ENDIF}
    /// <summary>Перерисовка рамки.</summary>
    /// <param name="DC">Графический контекст на который должен осуществляться вывод.</param>
    /// <param name="ARect">Координаты изображаемой рамки, относительно физических границ окна.</param>
    /// <param name="Ctl3D">Выпуклая, или плоская рамка</param>
    /// <param name="Width">Толщина</param>
    /// <param name="BorderColor">Цвет изображаемой рамки</param>
    /// <param name="IsDown">Если это свойство True, то необходимо изображать рамку в нажатом состоянии.</param>
    /// <remarks>Этот метод может быть использован для перерисовки границ как всего окна так и для границ кнопки.</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawBorder(DC: HDC; ARect: TRect; Ctl3D: boolean; Width: integer;
      BorderColor: Cardinal; IsDown: boolean = false); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Перерисовка фона'} {$ENDIF}
    /// <summary>Перерисовка фона</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure DrawBackground(DC: HDC; ARect: TRect; Ctl3D: boolean); virtual;

{$IFDEF DELPHI_2005_UP}{$REGION 'Ждем, пока не произойдет событие fBusy.'}{$ENDIF}
    /// <summary>Ждем, пока не произойдет событие fBusy.</summary>
    /// <param name="SetAfterWaiting">
    /// <para>После того, как дождались, событие автоматически сбрасывается.</para>
    /// <para>Если SetAfterWaiting = true, то после завершения ожидания оно устанавливается</para>
    /// </param>
    /// <returns>Если объект разрушен, или не создан, то возвращается false, иначе true</returns>
    /// <exception cref="EOSError">Если не смогли дождаться события, или не могли установить событие</exception>
    /// <remarks>Если не дождались (время ожидания истекло), то возникает ошибка.</remarks>
    /// <seealso cref="InterValTimeOut"></seealso>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    function WaitBusy(SetAfterWaiting: boolean = false): boolean;
{$IFDEF DELPHI_2005_UP} {$REGION 'Посылка сообщения нити и ожидание его выполнения (можно посылать только пользовательские сообщения > WM_USER)'} {$ENDIF}
    /// <summary>Посылка сообщения нити и ожидание его выполнения (можно посылать только пользовательские сообщения &gt;
    /// WM_USER)</summary>
    /// <param name="Msg">Номер пользовательского сообщения</param>
    /// <param name="WParam">Первый параметр сообщения</param>
    /// <param name="LParam">Второй параметр сообщения</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    // Alex ** (for 64 bit compatibility)
    //function Perform(Msg: Cardinal; WParam, LParam: LongInt): LongInt;
    function Perform(Msg: UINT; WParam: WPARAM; LParam: LPARAM): LRESULT;

{$IFDEF DELPHI_2005_UP} {$REGION 'Виртуальный метод Change указывает, на то, что некоторая часть окна изменилась и неплохо бы окошко перерисовать.'} {$ENDIF}
    /// <summary>Виртуальный метод Change указывает, на то, что некоторая часть окна изменилась и неплохо бы окошко
    /// перерисовать.</summary>
    /// <param name="UpdateAreas">Какие именно части окна изменились.</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure Change(var UpdateAreas: TUpdateAreas); virtual;
{$IFDEF DELPHI_2005_UP} {$REGION 'Посылка сообщения о том, что необходимо перерисовать какуюто часть окна'} {$ENDIF}
    /// <summary>Посылка сообщения о том, что необходимо перерисовать какуюто часть окна</summary>
    /// <param name="Area">Определяет, что именно надо перерисовать</param>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure Invalidate(Area: TUpdateArea = uaWindow);
{$IFDEF DELPHI_2005_UP} {$REGION 'Определяет находится ли выполняемый код в потоке окна.'} {$ENDIF}
    /// <summary>Определяет находится ли выполняемый код в потоке окна.</summary>
    /// <returns>Возвращается&#160;True, если вызов осуществился внутри потока, в котором работает окно.</returns>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    function InThread: boolean;
    property LowBlink: boolean read fLowBlink write fLowBlink;
    function DefaultBoundsRect: TRect; virtual;
  public
{$IFDEF DELPHI_2005_UP}{$REGION 'Создание и отображение окна с параметрами по умолчанию и текстом сообщения AMessage, если текст не задан, то с текстом De...'} {$ENDIF}
    /// <summary>Создание и отображение окна с параметрами по умолчанию и текстом сообщения AMessage, если текст не задан, то с
    /// текстом DefaultMessage</summary>
    /// <seealso cref="DefaultMessage"></seealso>
{$IFDEF DELPHI_2005_UP} {$ENDREGION}{$ENDIF}
    constructor Show(AMessage: string = '');
{$IFDEF DELPHI_2005_UP} {$REGION 'Разрушение созданного экземпляра окна'} {$ENDIF}
    /// <summary>Разрушение созданного экземпляра окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    destructor Destroy; override;
{$IFDEF DELPHI_2005_UP} {$REGION 'Этот метод выполняется после создания экземпляра класса'} {$ENDIF}
    /// <summary>Этот метод&#160;выполняется после создания экземпляра класса</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    procedure AfterConstruction; override;

{$IFDEF DELPHI_2005_UP}{$REGION 'Возвращает информацию о шрифте.'}{$ENDIF}
    /// <summary>Возвращает информацию о шрифте.</summary>
    /// <param name="Font">Дескриптором шрифта.</param>
    /// <param name="DefaultFont">Если Font равен 0, то возвращается информация об указанном стандартном шрифте.</param>
    /// <returns>Параметры шрифта</returns>
    /// <seealso cref="TDefaultFont"></seealso>
{$IFDEF DELPHI_2005_UP}{$ENDREGION}{$ENDIF}
    class function GetFontIndirect(Font: hFont; DefaultFont: TDefaultFont)
      : TLogFont;

    // Основные свойства окна
    // В большинстве случаев для получения значения поля не требуется ни каких дополнительных
    // действий и потокозащищенность. Но для примера методы
    // GetVisible и GetText сделаны потокозащищенными

{$IFDEF DELPHI_2005_UP} {$REGION 'Это свойство указывает, должно ли окно быть видимым. Установка свойства равным True не приводит к немедленному открытию о...'} {$ENDIF}
    /// <summary>Это свойство указывает, должно ли окно быть видимым. Установка свойства равным True не приводит к немедленному
    /// открытию окна (см. Interval)</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Visible: boolean read GetVisible write SetVisible;
{$IFDEF DELPHI_2005_UP} {$REGION 'Цвет окна'} {$ENDIF}
    /// <summary>Цвет окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Color: Cardinal read fColor write SetColor;
{$IFDEF DELPHI_2005_UP} {$REGION 'Цвет заголовка'} {$ENDIF}
    /// <summary>Цвет заголовка</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property CaptionColor: Cardinal read fCaptionColor write SetCaptionColor;
{$IFDEF DELPHI_2005_UP} {$REGION 'Это свойство указывает является ли рамка выпуклой, или плоской'} {$ENDIF}
    /// <summary>Это свойство указывает является ли рамка выпуклой, или плоской</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Ctl3D: boolean read fCtl3D write fCtl3D;
{$IFDEF DELPHI_2005_UP} {$REGION 'Это принимает значение True после нажатия на кнопку "Отмена". Используется для проверки необходимости остановки работы.'} {$ENDIF}
    /// <summary>Это принимает значение True после нажатия на кнопку "Отмена". Используется для проверки необходимости
    /// остановки работы.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Canceled: boolean read fCanceled write SetCanceled;
{$IFDEF DELPHI_2005_UP} {$REGION 'Видимые координаты окна, относительно рабочего стола. В случае окон сложной формы, могут не совпадать c физическими коорд...'} {$ENDIF}
    /// <summary>Видимые координаты окна, относительно рабочего стола. В случае окон сложной формы, могут не совпадать c
    /// физическими координатами окна. См. WindowRect</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
{$IFDEF DELPHI_2005_UP} {$REGION 'Дескриптор шрифта основного текста'} {$ENDIF}
    /// <summary>Дескриптор шрифта основного текста</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Font: hFont read fFont write SetFont;
{$IFDEF DELPHI_2005_UP} {$REGION 'Дескриптор шрифта заголовка'} {$ENDIF}
    /// <summary>Дескриптор шрифта заголовка</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property CaptionFont: hFont read fCaptionFont write SetCaptionFont;
{$IFDEF DELPHI_2005_UP} {$REGION 'Дескриптор шрифта отображающего оставшееся время'} {$ENDIF}
    /// <summary>Дескриптор шрифта отображающего оставшееся время</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property TimerFont: hFont read fTimerFont write SetTimerFont;

    property FontColor: Cardinal read fFontColor write SetFontColor;
    property CaptionFontColor: Cardinal read fCaptionFontColor
      write SetCaptionFontColor;
    property Icon: HIcon read fIcon write SetIcon;
    property IconIndex: NativeInt read fIconIndex write SetIconIndex;
    property IconSize: NativeInt read fIconSize write SetIconSize;

{$IFDEF DELPHI_2005_UP} {$REGION 'Степень прозрачности окна. Если 0, то свойство Visible становится False'} {$ENDIF}
    /// <summary>Степень прозрачности окна. Если 0, то свойство Visible становится False</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property AlphaBlendValue: byte read fAlphaBlendValue
      write SetAlphaBlendValue;
{$IFDEF DELPHI_2005_UP} {$REGION 'Основной текст, изображаемый в окне. Тоже самое что и Message.'} {$ENDIF}
    /// <summary>Основной текст, изображаемый в окне. Тоже самое что и Message.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Text: string read GetText write SetText;
    property Message: string read GetText write SetText;
{$IFDEF DELPHI_2005_UP} {$REGION 'Заголовок.'} {$ENDIF}
    /// <summary>Заголовок.</summary>
    /// <remarks>Если '', то заголовок не отображается.</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Caption: string read GetCaption write SetCaption;
{$IFDEF DELPHI_2005_UP} {$REGION 'Системное время начала выполнения длительной операции. Для установки можно использовать функцию Now.'} {$ENDIF}
    /// <summary>Системное время начала выполнения длительной операции. Для установки можно использовать функцию Now.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property StartTime: TDateTime read fStartTime write fStartTime;
{$IFDEF DELPHI_2005_UP} {$REGION 'Предполагаемое общее время выполнения длительной операции (в сутках). Если это свойство больше 0, то под пиктограммой ото...'} {$ENDIF}
    /// <summary>Предполагаемое общее время выполнения длительной операции (в сутках). Если это свойство больше 0, то под
    /// пиктограммой отображается время, оставшееся до завершения процесса.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property TotalTime: TDateTime read fTotalTime write fTotalTime;

    // Простейшие свойства.
    // Изменение этих свойств не требует моментальной реакции окна. В методе Change
    // периодически сравниваются старые и новые значения, и в случае изменения
    // возвращается признак того, что изменилась некоторая часть окна

{$IFDEF DELPHI_2005_UP} {$REGION 'Дескриптор окна'} {$ENDIF}
    /// <summary>Дескриптор окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property WND: HWND read fWND;
{$IFDEF DELPHI_2005_UP} {$REGION 'Дескриптор кисти для заливки фона окна'} {$ENDIF}
    /// <summary>Дескриптор кисти для заливки фона окна</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Brush: HBrush read fBrush;
{$IFDEF DELPHI_2005_UP} {$REGION 'Время задержки появления окна (мс), после установки свойства Visible.'} {$ENDIF}
    /// <summary>Время задержки появления окна (мс), после установки свойства Visible.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Interval: DWORD read fInterval write fInterval;
{$IFDEF DELPHI_2005_UP} {$REGION 'Результат функции GetTickCount в момент установки свойства Visible'} {$ENDIF}
    /// <summary>Результат функции GetTickCount в момент установки свойства Visible</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property ShowTick: DWORD read fShowTick;
{$IFDEF DELPHI_2005_UP} {$REGION 'Процент выполнения умноженный на 10 (0..1000). Если меньше 0, то не отображается'} {$ENDIF}
    /// <summary>Процент выполнения умноженный на 10 (0..1000). Если меньше 0, то не отображается</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Percent: integer read fPercent write fPercent;
{$IFDEF DELPHI_2005_UP} {$REGION 'Физические координаты окна, относительно рабочего стола. См. также BoundsRect'} {$ENDIF}
    /// <summary>Физические координаты окна, относительно рабочего стола. См. также BoundsRect</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property WindowRect: TRect read fWindowRect;
{$IFDEF DELPHI_2005_UP} {$REGION 'Координаты клиентской области окна относительно левого верхнего угла физических координат окна.'} {$ENDIF}
    /// <summary>Координаты клиентской области окна относительно левого верхнего угла физических координат окна.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property ClientRect: TRect read fClientRect;
{$IFDEF DELPHI_2005_UP} {$REGION 'Указывает на то, в каком месте вызывается обработчик события'} {$ENDIF}
    /// <summary>Указывает на то, в каком месте вызывается обработчик события</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property CallDispath: TCallDispath read fCallDispath;
{$IFDEF DELPHI_2005_UP} {$REGION 'Если установлено это свойство, то при отображении окна будет происходить плавное изменение прозрачности. После того, как ...'} {$ENDIF}
    /// <summary>Если установлено это свойство, то при отображении окна будет происходить плавное изменение прозрачности. После
    /// того, как окно отобразилось, это свойство принимает значение False.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property AlphaShow: boolean read fAlphaShow write fAlphaShow;
{$IFDEF DELPHI_2005_UP} {$REGION 'Время (в миллисекундах) в течении которого будет происходить изменение прозрачности.'} {$ENDIF}
    /// <summary>Время (в миллисекундах) в течении которого будет происходить изменение прозрачности.</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property IntervalAlphaShow: integer read fIntervalAlphaShow
      write fIntervalAlphaShow;
{$IFDEF DELPHI_2005_UP} {$REGION 'Доступность окна.'} {$ENDIF}
    /// <summary>Доступность окна.</summary>
    /// <remarks>Если это свойство имеет значение True, то окно можно перетаскивать мышью и у него видна кнопка
    /// отмена.</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property Enabled: boolean read fEnabled write fEnabled;

    property EnabledCancel: Boolean read FEnabledCancel write FEnabledCancel;
{$IFDEF DELPHI_2005_UP} {$REGION 'Координаты окна по умолчанию относительно рабочего стола.'} {$ENDIF}
    /// <summary>Координаты окна по умолчанию относительно рабочего стола.</summary>
    /// <remarks>Рассчитываются исходя из того, какие элементы окна видны, текста и размера шрифта.</remarks>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
    property DefaultRect: TRect read GetDefaultRect;
  end;

function Test(AllMembers, Member: Cardinal): boolean;
function Blend(Color1, Color2: Cardinal; BlendColor1: byte): Cardinal;
{$IFDEF DELPHI_2005_UP} {$REGION 'Потокозащищенный аналог стандартной процедуры MakeObjectInstance'} {$ENDIF}
/// <summary>Потокозащищенный аналог стандартной процедуры MakeObjectInstance</summary>
{$IFDEF DELPHI_2005_UP} {$ENDREGION} {$ENDIF}
function MakeObjectInstance(AMethod: TWndMethod): Pointer;

implementation

uses
  Vcl.Graphics;

var
  EventMake, EventAllocate: THandle;

function MakeObjectInstance(AMethod: TWndMethod): Pointer;
var
  R: DWORD;
begin
  Result := nil;
  R := WaitForSingleObject(EventMake, InterValTimeOut);
  case R of
    WAIT_TIMEOUT:
      raise EThreadWindow.Create(ErrorWait);
    WAIT_ABANDONED:
      exit;
    WAIT_OBJECT_0:
      begin
        try
          Result := {$IFDEF VER130}OldVersions{$ELSE}Classes{$ENDIF}.
            MakeObjectInstance(AMethod);
        finally
          Windows.SetEvent(EventMake);
        end;
      end;
  else
    RaiseLastOSError;
  end;
end;

function Test(AllMembers, Member: Cardinal): boolean;
begin
  Result := ((Member) and (AllMembers)) = Member;
end;


{$IFDEF  WIN64}
function Blend(Color1, Color2: Cardinal; BlendColor1: Byte): Cardinal;
var
  c1, c2: Integer;
  r, g, b, v1, v2: byte;
begin
//  Result := Color1;
//  Exit;

  BlendColor1:= Byte(Round(2.55 * BlendColor1));
  c1 := ColorToRGB(Color1);
  c2 := ColorToRGB(Color2);
  v1:= Byte(c1);
  v2:= Byte(c2);
  r:= Byte(BlendColor1 * (v1 - v2) shr 8 + v2);
  v1:= Byte(c1 shr 8);
  v2:= Byte(c2 shr 8);
  g:= Byte(BlendColor1 * (v1 - v2) shr 8 + v2);
  v1:= Byte(c1 shr 16);
  v2:= Byte(c2 shr 16);
  b:= Byte(BlendColor1 * (v1 - v2) shr 8 + v2);
  Result := (b shl 16) + (g shl 8) + r;
end;
{$ELSE}
function Blend(Color1, Color2: Cardinal; BlendColor1: byte): Cardinal; assembler;
asm
  push  eBx
  push  eCx
  push  eDx
  push  eAx

  and   eCx, $000000FF

  xor   eAx, eAx
  mov   Al, byte ptr SS:[ESP]
  mul   Cx
  xor   eBx, eBx
  shr   eAx, 8
  mov   Bl, byte ptr SS:[eSp + 4]
  add   Ax, Bx
  xchg  Ax, Bx
  mul   Cx
  shr   Ax, 8
  xchg  eAx, eBx
  sbb   Ax, Bx
  mov   byte ptr SS:[eSp], Al


  xor   eAx, eAx
  mov   Al, byte ptr SS:[ESP + 1]
  mul   Cx
  xor   eBx, eBx
  shr   eAx, 8
  mov   Bl, byte ptr SS:[eSp + 5]
  add   Ax, Bx
  xchg  Ax, Bx
  mul   Cx
  shr   Ax, 8
  xchg  eAx, eBx
  sbb   Ax, Bx
  mov   byte ptr SS:[eSp + 1], Al

  xor   eAx, eAx
  mov   Al, byte ptr SS:[ESP + 2]
  mul   Cx
  xor   eBx, eBx
  shr   eAx, 8
  mov   Bl, byte ptr SS:[eSp + 6]
  add   Ax, Bx
  xchg  Ax, Bx
  mul   Cx
  shr   Ax, 8
  xchg  eAx, eBx
  sbb   Ax, Bx
  mov   byte ptr SS:[eSp + 2], Al

  pop   eAx
  pop   eDx
  pop   eCx
  pop   eBx
end;
{$ENDIF}

function InternalSetFont(var Font: hFont; Value: hFont;
  DefaultFont: TDefaultFont): Bool;
var
  NewLogFont, OldLogFont: TLogFont;
begin
  NewLogFont := TThreadWindow.GetFontIndirect(Value, DefaultFont);
  Result := Font = 0;
  if not Result then
  begin
    OldLogFont := TThreadWindow.GetFontIndirect(Font, DefaultFont);
    Result := not CompareMem(@OldLogFont, @NewLogFont, SizeOf(NewLogFont));
  end;
  if Result then
  begin
    if (Font <> 0) and (not DeleteObject(Font)) then
      RaiseLastOSError
    else
      Font := 0;
    Font := CreateFontIndirect(NewLogFont);
  end;
end;

{ TThreadWindow }

function TThreadWindow.WaitBusy(SetAfterWaiting: boolean): boolean;
var
  R: DWORD;
  H: array [0 .. 1] of THandle;
begin
  Result := false;
  if fBusy <> 0 then
  begin
    H[0] := fBusy;
    H[1] := fHandleCreated;
    R := WaitForMultipleObjects(Length(H), PWOHandleArray(@H), True,
      InterValTimeOut);
    case R of
      WAIT_OBJECT_0:
        begin
          Result := True;
          if SetAfterWaiting then
          begin
            if not SetEvent(fBusy) then
              RaiseLastOSError;
          end;
        end;
      WAIT_TIMEOUT:
        raise EThreadWindow.Create(ErrorWait);
      WAIT_ABANDONED:
        exit;
    else
      RaiseLastOSError;
    end;
  end;
end;

procedure TThreadWindow.Stop;
begin
  if ThreadID <> 0 then
  begin

    if GetCurrentThreadId <> ThreadID then
    begin
      Terminate;
      PostThreadMessage(ThreadID, WM_NULL, 0, 0);
      // WaitBusy(false);
      if ThreadID <> 0 then
      begin
        // WaitForSingleObject(ThreadID, 10000);
        // SetEvent
        // SyncEvent := 0;
        // WaitForSingleObject(SyncEvent, 1000);
        WaitFor;
      end;
    end
    else
      Terminate;
  end
  else
    Terminate;
end;

destructor TThreadWindow.Destroy;
begin
  // Terminate;
  Stop;
  // WaitFor;
  DeallocateHWnd;
  if fBusy <> 0 then
  begin
    CloseHandle(fBusy);
    fBusy := 0;
  end;
  if fHandleCreated <> 0 then
  begin
    CloseHandle(fHandleCreated);
    fHandleCreated := 0;
  end;
  FreeIcon(fIcon);
  try
    if fFont <> 0 then
      DeleteObject(fFont);
    if fCaptionFont <> 0 then
      DeleteObject(fCaptionFont);
    if fTimerFont <> 0 then
      DeleteObject(fTimerFont);
    fFont := 0;
    fCaptionFont := 0;
    fTimerFont := 0;
    DoAfterStop;
  finally
    inherited;
  end;
end;

procedure TThreadWindow.Execute;
var
  First: boolean;
  // Получаем текущее сообщение и обрабатываем его
  function ProcessCurrentMessage: boolean;
  var
    Msg: TMSG;
  begin
    if not Windows.GetMessage(Msg, 0, 0, 0) then
      Terminate;
    if First then
    begin
      First := false;
      SetEvent(fBusy);
    end;
    if not Terminated then
    begin
      // Если пришло сообщение от таймера
      if (Msg.message = WM_TIMER) and (UINT(Msg.WParam) = fTimer) then
      begin
        // Немного ждём окончания передачи данных от основного потока
        if WaitForSingleObject(fBusy, 10) = WAIT_OBJECT_0 then
        begin
          // Если дождались, то выполняем обработчик события таймера
          try
            ProcessMessage(Msg);
          finally
            SetEvent(fBusy);
          end
        end
        // Если недождались, то пропускаем этот тост
        // else
        // PostMessage(MSG.hwnd, MSG.message, MSG.wParam, MSG.lParam);
      end
      else
        ProcessMessage(Msg);
    end;
    Result := Msg.message = WM_NULL;
  end;
// Ждем, пока окно невидимо
  procedure WaitNoVisible;
  begin
    while (not fVisible) and (not Terminated) do
      ProcessCurrentMessage;
    PostThreadMessage(ThreadID, WM_NULL, 0, 0);
    while not ProcessCurrentMessage do
      if Terminated then
        break;
  end;
// Выжидаем, некоторое время, до того, как окно должно стать фактически видимым
  procedure WaitInterval;
  var
    P: Pointer;
    T: Int64;
  begin
    P := nil;
    fTimer := 0;
    try
      fShowTick := GetTickCount;
      if (fVisible) and (not Terminated) then
      begin
        if fInterval > 0 then
        begin
          P := MakeObjectInstance(TimerProc);
          fTimer := SetTimer(0, 1, 10, P);
        end;
      end;
      if fInterval > 0 then
      begin
        while (fVisible) and (not Terminated) do
        begin
          T := GetTickCount;
          T := Abs(T - fShowTick);
          if T > fInterval then
            break;
          ProcessCurrentMessage;
        end;
      end;
      // Запрещаем добавление сообщений в очередь
      ResetEvent(fHandleCreated);
      // Обрабатываем все оставшиеся сообщения в очереди
      PostThreadMessage(ThreadID, WM_NULL, 0, 0);
      while (not Terminated) and (not ProcessCurrentMessage) do;
    finally
      if fTimer <> 0 then
        if not KillTimer(0, fTimer) then
          RaiseLastOSError;
      if P <> nil then
        FreeObjectInstance(P);
      fTimer := 0;
    end;
  end;
// В цикле обрабатываем сообщения посланые окну
// Также создаём таймер, который шлёт сообщения WM_TIMER
  procedure MainCikl;
  begin
    fTimer := SetTimer(fWND, 2, 10, nil);
    try
      while (fVisible) and (not Terminated) do
      begin
        ProcessCurrentMessage;
      end;
    finally
      if fTimer <> 0 then
        if not KillTimer(fWND, fTimer) then
          RaiseLastOSError;
    end;
  end;

// Собственно тело метода Execute
begin
  First := True;
  try
    try
      repeat
        WaitNoVisible;
        WaitInterval;
        if (fVisible) and (not Terminated) then
        begin
          ShowWND;
          // Разрешаем добавление сообщений в очередь
          SetEvent(fHandleCreated);
          try
            MainCikl;
          finally
            CloseWND;
          end;
        end
        else
          SetEvent(fHandleCreated);
      until Terminated;
    finally
      ResetEvent(fHandleCreated);
      try
        Windows.UnregisterClass(PChar(NameClass), hInstance);
      finally
        SetEvent(fHandleCreated);
      end;
    end;
  except
    on E: Exception do
    begin
      fTextError := E.message;
      fErrorClass := ExceptClass(E.ClassType);
      SetEvent(fBusy);
    end;
  end;
end;

// Эта функция возвращает параметры шрифта
// Если Font=0, то возвращаются соответствующие параметы по умолчанию

class function TThreadWindow.GetFontIndirect(Font: hFont;
  DefaultFont: TDefaultFont): TLogFont;
var
  NonClientMetrics: TNonClientMetrics;
  Siz: integer;
  procedure DoIndirect;
  begin
{$IFDEF DELPHI_2010_UP}
    Siz := NonClientMetrics.SizeOf;
{$ELSE}
    Siz := SizeOf(NonClientMetrics);
{$ENDIF}
    FillChar(NonClientMetrics, Siz, 0);
    NonClientMetrics.cbSize := Siz;
    if DefaultFont <> dTimeFont then
    begin
      if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0,
        @NonClientMetrics, 0) then
        with NonClientMetrics do
          case DefaultFont of
            dCaptionFont:
              Result := lfCaptionFont;
            dSmCaptionFont:
              Result := lfSmCaptionFont;
            dMenuFont:
              Result := lfMenuFont;
            dStatusFont:
              Result := lfStatusFont;
            dMessageFont:
              Result := lfMessageFont;
          end
      else
        RaiseLastOSError;
    end
    else
    begin
      Result.lfHeight := -8;
      Result.lfWidth := 0;
      Result.lfEscapement := 0;
      Result.lfOrientation := 0;
      Result.lfWeight := FW_NORMAL;
      Result.lfItalic := 0;
      Result.lfUnderline := 0;
      Result.lfStrikeOut := 0;
      Result.lfCharSet := DEFAULT_CHARSET;
      Result.lfOutPrecision := OUT_DEFAULT_PRECIS;
      Result.lfClipPrecision := CLIP_DEFAULT_PRECIS;
      Result.lfQuality := PROOF_QUALITY;
      Result.lfPitchAndFamily := FF_MODERN;
      Result.lfFaceName := 'Small Fonts';
    end;
  end;

begin
  FillChar(Result, SizeOf(Result), 0);
  if Font = 0 then
    DoIndirect
  else
  begin
    Siz := SizeOf(Result);
    if GetObject(Font, Siz, @Result) = 0 then
    begin
      DoIndirect
    end;
  end;
end;

function TThreadWindow.GetTimeText: string;
var
  T: TDateTime;
  S: string;
begin
  T := StartTime + TotalTime - Now + 1 / 24 / 60 / 60;
  if T > 1 / (24 * 60 * 60 * 2) then
  begin
    if T > 1 / (24) then
      DateTimeToString(S, 'hh:NN:SS', T)
    else if T > 1 / (24 * 60) then
      DateTimeToString(S, 'NN:SS', T)
    else
      DateTimeToString(S, 'SS', T);
  end
  else
    S := '';
  Result := S;
end;

procedure TThreadWindow.ProcessMessage(Msg: TMSG);
var
  Message: TMessage;
  OldCallDispath: TCallDispath;
begin
  Message.Msg := Msg.message;
  Message.WParam := Msg.WParam;
  Message.LParam := Msg.LParam;
  Message.Result := 0;
  try
    OldCallDispath := fCallDispath;
    // Если нить еще не создана, то сразу вызываем обработчики событий
    if ThreadID = 0 then
    begin
      fCallDispath := cdOutThread;
      try
        DoBeforeDispath(Message);
        if Message.Result = 0 then
          Dispatch(Message);
      finally
        fCallDispath := OldCallDispath;
        fLastMessage := Message;
      end;
    end
    else
    begin
      // Если сообщение передавалось окну, то пересылаем сообщение окну
      // иначе вызываем обработчики событий
      if fCallDispath <> cdInWindow then
        fCallDispath := cdInThread;
      try
        inc(fCountInStack);
        DoBeforeDispath(Message);
        if (fCallDispath <> cdInWindow) and // Вызов производится не в окне
          (Message.Result = 0) and // Сообщение не обработано
          (Msg.HWND = fWND) and // Сообщение предназаначалось окну
          (fWND <> 0) then { // Окно создано }
        begin
          Msg.message := Message.Msg;
          Msg.WParam := Message.WParam;
          Msg.LParam := Message.LParam;
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end
        else
        begin
          try
            if Message.Result = 0 then
              Dispatch(Message);
          finally
            if (Message.Msg > WM_USER) and (fCountInStack = 1) then
            begin
              fLastMessage := Message;
              SetEvent(fBusy);
            end;
          end;
        end;
      finally
        Dec(fCountInStack);
        if fCallDispath <> cdInWindow then
          fCallDispath := OldCallDispath;
      end;
    end;
  except
    on E: EAbort do
      exit
    else
      raise;
  end;
end;

procedure TThreadWindow.WNDProc(var Message: TMessage);
var
  OldCallDispath: TCallDispath;
begin
  OldCallDispath := fCallDispath;
  try
    fCallDispath := cdInWindow;
    DoBeforeDispath(Message);
    if Message.Result = 0 then
      Dispatch(Message);
    if Message.Result = 0 then
      Message.Result := DefWindowProc(fWND, Message.Msg, Message.WParam, Message.LParam);
    fLastMessage := Message;
  finally
    fCallDispath := OldCallDispath;
  end;
end;

function TThreadWindow.InThread: boolean;
var
  Id: Cardinal;
begin
  Result := (ThreadID = 0) or (fBusy = 0);
  if not Result then
  begin
    Id := GetCurrentThreadId;
    Result := Id = ThreadID;
  end;
end;

//function TThreadWindow.Perform(Msg: Cardinal; WParam, LParam: LongInt): LongInt;
function TThreadWindow.Perform(Msg: UINT; WParam: WPARAM; LParam: LPARAM): LRESULT;
var
  M: TMSG;
  procedure CallinThread;
  begin
    FillChar(M, SizeOf(M), 0);
    M.message := Msg;
    M.WParam := WParam;
    M.LParam := LParam;
    ProcessMessage(M);
    Result := fLastMessage.Result;
  end;

begin
  Result := -1;
  if InThread then
    CallinThread
  else
  begin
    if Msg <= WM_USER then
      raise EThreadWindow.CreateFmt(ErrorParam, ['MSG', inttostr(Msg)]);
    if Terminated then
    begin
      WaitFor;
      CallinThread;
      exit;
    end;
    if (ThreadID <> 0) and (WaitBusy) then
    begin
      PostThreadMessage(ThreadID, Msg, WParam, LParam);
      if WaitBusy then
      begin
        Result := fLastMessage.Result;
        SetEvent(fBusy);
      end;
    end;
  end;
end;

// По таймеру посылаем потоку пустое сообщение
// для того, чтобы поток вышел из режима ожидания

procedure TThreadWindow.TimerProc(var M: TMessage);
begin
  if ThreadID <> 0 then
    PostThreadMessage(ThreadID, WM_NULL, 0, 0);
end;

procedure TThreadWindow.DoTerminate;
var
  EClass: string;
begin
  inherited;
  if fTextError <> '' then
  begin
    if fErrorClass = nil then
      EClass := 'nil'
    else
      EClass := fErrorClass.ClassName;
    if not fErrorClass.InheritsFrom(EAbort) then
      raise EThreadWindow.CreateFmt(ErrorThread, [fTextError, EClass]);
  end;
end;

procedure TThreadWindow.ShowWND;
begin
  try
    AllocateHWnd(WNDProc);
    WNDCreated(fWND);
    Invalidate(uaAll);
    ShowWindow(fWND, SW_SHOWNA);
  except
    on E: Exception do
    begin
      raise Exception(E.ClassType).Create('ShowWND:' + #13#10 + E.message);
    end;
  end;
end;

procedure TThreadWindow.Change(var UpdateAreas: TUpdateAreas);
var
  Style: NativeInt;
  S: string;
begin
  if fPercent <> fOldPercent then
  begin
    if (fOldPercent = -1) or (fPercent = -1) then
      UpdateAreas := UpdateAreas + [uaAll]
    else
      UpdateAreas := UpdateAreas + [uaProgress];
    fOldPercent := fPercent;
  end;
  if fOldStartTime <> fStartTime then
  begin
    if (fOldStartTime = 0) or (fStartTime = 0) then
      UpdateAreas := UpdateAreas + [uaAll];
    fOldStartTime := fStartTime;
  end;
  if fStartTime > 0 then
  begin
    S := GetTimeText;
    if S <> fOldTimeText then
    begin
      fOldTimeText := S;
      UpdateAreas := UpdateAreas + [uaTimer];
    end;
  end;

  if fEnabled <> fOldEnabled then
  begin
    UpdateAreas := UpdateAreas + [uaAll];
    fOldEnabled := fEnabled;
    if fWND <> 0 then
    begin
      Style := GetWindowLong(fWND, GWL_STYLE);
      if fEnabled then
        Style := Style and (not WS_DISABLED)
      else
      begin
        Style := Style or WS_DISABLED;
        fHotPoint.X := -1;
        fHotPoint.Y := -1;
      end;
      SetWindowLong(fWND, GWL_STYLE, Style);
    end;
  end;
  if (fCtl3D <> fOldCtl3d) then
  begin
    UpdateAreas := UpdateAreas + [uaWindow];
    fOldCtl3d := fCtl3D;
  end;

end;

procedure TThreadWindow.CloseWND;
begin
  try
    try
      WNDDestroy(fWND);
    finally
      DeallocateHWnd;
    end;
  finally
    fVisible := false;
    fShowTick := 0;
  end;
end;

function TThreadWindow.DefaultBoundsRect: TRect;
var
  W, H, Cx, CY: integer;
  DC: HDC;
  R: TRect;
  OldFont: hFont;
begin
  Cx := Windows.GetSystemMetrics(SM_CXFULLSCREEN);
  CY := (2 * Windows.GetSystemMetrics(SM_CYFULLSCREEN)) div (3);
  DC := GetWindowDC(0);
  OldFont := SelectObject(DC, fFont);
  try
    R := Rect(0, 0, Cx div 2, CY * 2);
    Windows.DrawText(DC, PChar(fText), Length(fText), R, DT_CALCRECT);
    W := R.Right + 2 * BorderWidth;
    H := Max(R.Bottom, IconSize) + 2 * BorderWidth;
    if IconSize > 0 then
      inc(W, IconSize + BorderWidth);
    if Percent >= 0 then
      inc(H, 2 * BorderWidth);
    R := Rect((Cx - W) div (2), (CY - H) div (2), (Cx + W) div (2),
      (CY + H) div (2));
    Result := R;
    if Enabled then
    begin
      R := Rect(0, 0, 2000, 2000);
      Windows.DrawText(DC, PChar(TextCancel), Length(TextCancel), R,
        DT_CALCRECT);
      inc(Result.Bottom, R.Bottom + 4 + BorderWidth);
    end;
    if fCaption <> '' then
      inc(Result.Bottom, GetSystemMetrics(SM_CYSMCAPTION) +
        (BorderWidth div 2));
  finally
    SelectObject(DC, OldFont);
    ReleaseDC(0, DC);
  end;
end;

// Создание дескриптора окна

procedure TThreadWindow.AllocateHWnd(Method: TWndMethod);
var
  TempClassInfo: TWndClass;
  WndClass: TWndClass;
  ClassRegistered: LongBool;
  HInst: THandle;
  HA: THandle;
  A: array [0 .. 255] of char;
  Style: Cardinal;
  R: DWORD;
  procedure UpdateBoundsRect;
  begin
    if (fBoundsRect.Right - fBoundsRect.Left) = 0 then
      fBoundsRect := DefaultBoundsRect;
  end;
  procedure Init;
  begin
    // Задание исходных данных
    if fWND <> 0 then
      DeallocateHWnd;
    fLayoutUpdated := false;
    HInst := hInstance;
    if HInst = 0 then
      Exception.Create('Hinst ' + SysErrorMessage(GetLastError));
    FillChar(TempClassInfo, SizeOf(TempClassInfo), 0);
    FillChar(WndClass, SizeOf(WndClass), 0);
    FillChar(A, SizeOf(A), 0);
    move(NameClass[1], A, Length(NameClass) * SizeOf(NameClass[1]));
  end;
  procedure CreateWndClass;
  begin
    // Регистрация класса, если еще не зарегистрирован
    ClassRegistered := GetClassInfo(HInst, PChar(NameClass), TempClassInfo);
    if not ClassRegistered then
    begin
      WndClass.Style := CS_GLOBALCLASS or CS_NOCLOSE or
        CS_SAVEBITS { or CS_DROPSHADOW };
      WndClass.lpfnWndProc := @DefWindowProc;
      WndClass.hInstance := HInst;
      WndClass.hbrBackground := 0;
      WndClass.lpszMenuName := '';
      WndClass.lpszClassName := PChar(@A);
      WndClass.hCursor := LoadCursor(0, IDC_ARROW);
      HA := Windows.RegisterClass(WndClass);
      if HA = 0 then
        RaiseLastOSError;
    end;
  end;
  procedure CreateObjects;
  begin
    try
      if fFont = 0 then
        InternalSetFont(fFont, 0, dMessageFont);
      if fCaptionFont = 0 then
        InternalSetFont(fCaptionFont, 0, dSmCaptionFont);
      if fTimerFont = 0 then
        InternalSetFont(fTimerFont, 0, dTimeFont);
      if NativeInt(fIcon) = -1 then
        UpdateIcon(fIcon, fIcon);
      UpdateBoundsRect;
      UpdateBrush(fColor, fBrush);
      UpdateBrush(fCaptionColor, fCaptionBrush);
      DoAfterSetBounds(fBoundsRect, fWindowRect, fClientRect);

      Style := WS_POPUP;
      if not fEnabled then
        Style := Style or WS_DISABLED;

      fWND := CreateWindowEx(WS_EX_TOOLWINDOW or WS_EX_TOPMOST or
        WS_EX_NOACTIVATE { or WS_EX_LAYOUTRTL } , PChar(@A), 'WaitNew', Style,
        fWindowRect.Left, fWindowRect.Top,
        Abs(fWindowRect.Right - fWindowRect.Left),
        Abs(fWindowRect.Bottom - fWindowRect.Top), 0, 0, HInst, nil);
      if fWND = 0 then
        RaiseLastOSError;
      fHandleCreatedTick := GetTickCount;
      if fAlphaShow then
        UpdateBlend(fWND, 1)
      else
        UpdateBlend(fWND, fAlphaBlendValue);
      if Assigned(Method) then
      begin
        fHObj := MakeObjectInstance(Method);
        Windows.SetWindowLong(fWND, GWL_WNDPROC, integer(fHObj));
      end;
    except
      DeallocateHWnd;
      raise;
    end;
  end;

begin
  R := WaitForSingleObject(EventAllocate, InterValTimeOut);
  case R of
    WAIT_TIMEOUT:
      raise EThreadWindow.Create(ErrorWait);
    WAIT_ABANDONED:
      begin
        DeallocateHWnd;
        exit;
      end;
    WAIT_OBJECT_0:
      begin
        try
          Init;
          CreateWndClass;
          CreateObjects;
        finally
          Windows.SetEvent(EventAllocate);
        end;
      end;
  else
    RaiseLastOSError;
  end;
end;

// Удаление дескриптора окна

procedure TThreadWindow.DeallocateHWnd;
begin
  try
    try
      if fWND <> 0 then
      begin
        if DestroyWindow(fWND) then
          fWND := 0
        else
          RaiseLastOSError;
      end;
    finally
      if fHObj <> nil then
      begin
        FreeObjectInstance(fHObj);
        fHObj := nil;
      end;
    end;
  finally
    fVisible := false;
    UpdateBrush($1FFFFFFF, fBrush);
    UpdateBrush($1FFFFFFF, fCaptionBrush);
  end;
end;

procedure TThreadWindow.Invalidate(Area: TUpdateArea = uaWindow);
var
  R: PRect;
begin
  if Area = uaAll then
    fLayoutUpdated := false;
  if fWND <> 0 then
  begin
    case Area of
      uaIcon:
        R := @fElementPos.IconRect;
      uaProgress:
        R := @fElementPos.ProgressRect;
      uaButton:
        R := @fElementPos.ButtonRect;
      uaCaption:
        R := @fElementPos.CaptionRect;
      uaTimer:
        R := @fElementPos.Reserv;
    else
      R := nil;
    end;
    InvalidateRect(fWND, R, True);
  end;
end;

function TThreadWindow.MakeWParam(IndexProp, Part: Word): NativeUInt;
begin
  Result := ((Part) shl (16)) or IndexProp;
end;

procedure TThreadWindow.UMGetPropertyData(var Message: TUMPropertyData);
//procedure TThreadWindow.UMGetPropertyData(var m: TMessage);
  procedure CopyBuffer(var Buffer; Size: integer);
  begin
    if Message.Value^.DataSize <= 0 then
    begin
      Message.Value^.DataSize := Size;
      ReallocMem(Message.Value^.Data, Message.Value^.DataSize);
    end;
    FillChar(Message.Value^.Data^, Message.Value^.DataSize, 0);
    if @Buffer <> nil then
      move(Buffer, Message.Value^.Data^, Min(Message.Value^.DataSize, Size));
  end;

var
  R: TRect;
  m: TMessage absolute Message;
begin
  //Message.FromMsg(m);
  if (Message.Value = nil) or
    (Message.Value^.RecordSize <> SizeOf(TPropertyData)) or
    ((Message.Value^.DataSize <= 0) and (Message.Value^.Data <> nil)) or
    ((Message.Value^.DataSize > 0) and (Message.Value^.Data = nil)) then
  begin
    Message.Result := 0;
    exit;
  end;

  Message.Result := 1;
  case Message.IndexProp of
    IDVisible:
      CopyBuffer(fVisible, SizeOf(fVisible));
    IdColor:
      case Message.Part of
        0:
          CopyBuffer(fColor, SizeOf(fColor));
        1:
          CopyBuffer(fCaptionColor, SizeOf(fCaptionColor));
      end;
    IdFontColor:
      case Message.Part of
        0:
          CopyBuffer(fFontColor, SizeOf(fFontColor));
        1:
          CopyBuffer(fCaptionFontColor, SizeOf(fCaptionFontColor));
      end;
    IdIcon:
      CopyBuffer(fIcon, SizeOf(fIcon));
    IdIconIndex:
      CopyBuffer(fIconIndex, SizeOf(fIconIndex));
    IdIconSize:
      CopyBuffer(fIconSize, SizeOf(fIconSize));
    IdBoundsRect:
      CopyBuffer(fBoundsRect, SizeOf(fBoundsRect));
    IdText:
      case Message.Part of
        0:
          if fText <> '' then
            CopyBuffer(fText[1], SizeOf(fText[1]) * (Length(fText) + 1));
        1:
          if fCaption <> '' then
            CopyBuffer(fCaption[1], SizeOf(fCaption[1]) *
              (Length(fCaption) + 1));
      end;
    IdAlphaBlendValue:
      CopyBuffer(fAlphaBlendValue, SizeOf(fAlphaBlendValue));
    IdFont:
      case Message.Part of
        0:
          CopyBuffer(fFont, SizeOf(fFont));
        1:
          CopyBuffer(fCaptionFont, SizeOf(fCaptionFont));
        2:
          CopyBuffer(fTimerFont, SizeOf(fTimerFont));
      end;
    IdDefaultRect:
      begin
        R := DefaultBoundsRect;
        CopyBuffer(R, SizeOf(R));
      end;
  else
    Message.Result := 0;
  end;

//  Message.ToMsg(m);
end;

// Alex ** 64 bit
procedure TThreadWindow.UMSetPropertyValue(var Message: TUMPropertyValue);
//procedure TThreadWindow.UMSetPropertyValue(var m: TMessage);
var
  S: string;
  I: NativeInt;
//  Message: TUMPropertyValue;
  m: TMessage absolute Message;
begin
//  m.Result := 1;
//  Message.FromMsg(m);
  Message.Result := 1;
  I := Message.Value;
  case Message.IndexProp of
    IDVisible:
      begin
        if fVisible <> (I <> 0) then
        begin
          fVisible := I <> 0;
          if not fAlphaShow then
          begin
            if AlphaBlendValue = 0 then
              AlphaBlendValue := 255;
          end;
        end;
      end;
    IdColor:
      begin
        case Message.Part of
          0:
            begin
              if fColor <> Cardinal(I) then
              begin
                fColor := Cardinal(I);
                if fWND <> 0 then
                begin
                  UpdateBrush(fColor, fBrush);
                  fUpdateAreas := fUpdateAreas + [uaWindow];
                end;
              end;
            end;
          1:
            begin
              if fCaptionColor <> Cardinal(I) then
              begin
                fCaptionColor := Cardinal(I);
                if fWND <> 0 then
                begin
                  UpdateBrush(fCaptionColor, fCaptionBrush);
                  fUpdateAreas := fUpdateAreas + [uaCaption];
                end;
              end;
            end;
        end;
      end;
    IdFontColor:
      begin
        case Message.Part of
          0:
            if fFontColor <> Cardinal(I) then
            begin
              fFontColor := Cardinal(I);
              fUpdateAreas := fUpdateAreas + [uaWindow];
            end;
          1:
            if fCaptionFontColor <> Cardinal(I) then
            begin
              fCaptionFontColor := Cardinal(I);
              fUpdateAreas := fUpdateAreas + [uaCaption];
            end;
        end;
      end;
    IdIcon:
      begin
        UpdateIcon(HIcon(I), fIcon);
        Invalidate(uaIcon);
      end;
    IdIconIndex:
      if fIconIndex <> I then
      begin
        fIconIndex := I;
        Invalidate(uaIcon);
      end;
    IdIconSize:
      if fIconSize <> I then
      begin
        fIconSize := I;
        fUpdateAreas := fUpdateAreas + [uaAll];
      end;
    IdBoundsRect:
      begin
        move(Pointer(I)^, fBoundsRect, SizeOf(fBoundsRect));
        DoAfterSetBounds(fBoundsRect, fWindowRect, fClientRect);
        if (fWND <> 0) and (Visible) then
        begin
          Invalidate(uaAll);
          SetWindowPos(fWND, 0, fWindowRect.Left, fWindowRect.Top,
            fWindowRect.Right - fWindowRect.Left, fWindowRect.Bottom -
            fWindowRect.Top, SWP_NOACTIVATE or SWP_NOOWNERZORDER);
        end;
      end;
    IdText:
      begin
        S := PChar(Message.Value);
        case Message.Part of
          0:
            begin
              if S <> fText then
              begin
                fText := S;
                Invalidate(uaWindow);
              end;
            end;
          1:
            begin
              if S <> fCaption then
              begin
                if (S = '') or (fCaption = '') then
                  Invalidate(uaAll)
                else
                  Invalidate(uaCaption);
                fCaption := S;
              end;
            end;
        end;
      end;
    IdAlphaBlendValue:
      if fAlphaBlendValue <> I then
      begin
        fAlphaBlendValue := I;
        if not fAlphaShow then
        begin
          if fAlphaBlendValue = 0 then
            fVisible := false
          else
            UpdateBlend(fWND, fAlphaBlendValue);
        end;
      end
      else
        Message.Result := 0;
    IdFont:
      begin
        case Message.Part of
          0:
            if InternalSetFont(fFont, hFont(I), dMessageFont) then
              Invalidate(uaAll);
          1:
            if InternalSetFont(fCaptionFont, hFont(I), dSmCaptionFont) then
              Invalidate(uaAll);
          2:
            if InternalSetFont(fTimerFont, hFont(I), dTimeFont) then
              Invalidate(uaAll);
        end;
      end;
    IdCanceled:
      begin
        if fCanceled <> (I <> 0) then
        begin
          fCanceled := I <> 0;
          if fCanceled then
            fStateButton := fStateButton or DFCS_PUSHED
          else
            fStateButton := fStateButton and (not DFCS_PUSHED);
          Invalidate(uaButton);
        end;
      end
  else
    Message.Result := 0;
  end;
end;

procedure TThreadWindow.WMERASEBKGND(var Message: TWMERASEBKGND);
var
  NeedDC: boolean;
  OldBrush: HBrush;
  OldPen: HPen;
  OldFont: hFont;
  OldBk: integer;
begin
  if (CallDispath = cdInWindow) and (fWND <> 0) and (not Terminated) then
    with Message do
    begin
      NeedDC := DC = 0;
      if NeedDC then
        DC := GetWindowDC(fWND);
      try
        if not fLayoutUpdated then
        begin
          UpdateLayout(fClientRect, fElementPos);
          fLayoutUpdated := True;
        end;
        if fBrush <> 0 then
          OldBrush := SelectObject(DC, fBrush)
        else
          OldBrush := SelectObject(DC, GetStockObject(NULL_BRUSH));
        OldPen := SelectObject(DC, GetStockObject(BLACK_PEN));
        OldBk := GetBkMode(DC);
        OldFont := SelectObject(DC, fFont);
        SetTextColor(DC, fFontColor);
        try
          SetBkMode(DC, TRANSPARENT);
          DrawWND(DC, fWindowRect);
        finally
          SetBkMode(DC, OldBk);
          SelectObject(DC, OldFont);
          SelectObject(DC, OldPen);
          SelectObject(DC, OldBrush);
        end;
      finally
        if NeedDC then
        begin
          ReleaseDC(fWND, DC);
          DC := 0;
        end;
      end;
      Message.Result := 1;
    end;
end;

procedure TThreadWindow.WMLBUTTONDOWN(var Message: TWMLBUTTONDOWN);
var
  P: TPoint;
  R: TRect;
begin
  P.X := Message.XPos;
  P.Y := Message.YPos;
  if PtInRect(fClientRect, P) then
  begin
    GetWindowRect(fWND, R);
    if Enabled and PtInRect(fElementPos.ButtonRect, P) then
    begin
      fHotPoint.X := -1;
      fHotPoint.Y := -1;
      fStateButton := fStateButton or DFCS_PUSHED;
      Invalidate(uaButton);
    end
    else
    begin
      fHotPoint.X := P.X + R.Left;
      fHotPoint.Y := P.Y + R.Top;
    end;
  end;
end;

procedure TThreadWindow.WMLBUTTONUP(var Message: TWMLBUTTONUP);
var
  P: TPoint;
begin
  fHotPoint.X := -1;
  fHotPoint.Y := -1;
  P.X := Message.XPos;
  P.Y := Message.YPos;
  if Enabled and PtInRect(fElementPos.ButtonRect, P) and
    Test(fStateButton, DFCS_PUSHED) then
    Canceled := True
  else
  begin
    if Not Canceled then
      fStateButton := fStateButton and (not DFCS_PUSHED);
    Invalidate(uaButton);
  end;
end;

procedure TThreadWindow.WMSHOWWINDOW(var Message: TWMSHOWWINDOW);
begin
  Visible := Message.Show;
  Message.Result := 1;
end;

procedure TThreadWindow.WMTIMER(var Message: TWMTIMER);
var
  CurrBlend: Double;
  P: TPoint;
  R: TRect;
  UpdateAreas: TUpdateAreas;
  A: TUpdateArea;
  OldStateButton: UINT;
begin
  if (fVisible) and (not Terminated) then
  begin
    UpdateAreas := fUpdateAreas;
    Change(UpdateAreas);
    fUpdateAreas := [];
    if uaAll in UpdateAreas then
      Invalidate(uaAll)
    else if uaWindow in UpdateAreas then
      Invalidate(uaWindow)
    else
    begin
      A := uaWindow;
      repeat
        if A < High(TUpdateArea) then
          A := Succ(A);
        if A in UpdateAreas then
          Invalidate(A);
      until A = High(TUpdateArea);
    end;
  end;
  if fAlphaShow and (UINT(Message.TimerID) = fTimer) and
    (fIntervalAlphaShow > 0) and (CallDispath = cdInWindow) then
  begin
    CurrBlend := GetTickCount;
    CurrBlend := Abs(CurrBlend - fHandleCreatedTick) / fIntervalAlphaShow;
    if CurrBlend >= 1 then
    begin
      fAlphaShow := false;
      UpdateBlend(fWND, fAlphaBlendValue);
    end
    else
    begin
      UpdateBlend(fWND, Round(CurrBlend * fAlphaBlendValue));
    end;
  end;
  if Enabled then
  begin
    Windows.GetCursorPos(P);
    Windows.ScreenToClient(fWND, P);
    OldStateButton := fStateButton;
    if not PtInRect(fElementPos.ButtonRect, P) then
    begin
      if (not Canceled) then
        fStateButton := fStateButton and (not DFCS_PUSHED);
      fStateButton := fStateButton and (not DFCS_FLAT);
    end
    else
      fStateButton := fStateButton or DFCS_FLAT;
    if OldStateButton <> fStateButton then
      Invalidate(uaButton);

    if ((fHotPoint.X <> -1) or (fHotPoint.Y <> -1)) then
    begin
      Windows.GetCursorPos(P);
      if (P.X <> fHotPoint.X) or (P.Y <> fHotPoint.Y) then
      begin
        ResetEvent(fHandleCreated);
        try
          R := BoundsRect;
          OffsetRect(R, P.X - fHotPoint.X, P.Y - fHotPoint.Y);
          BoundsRect := R;
          inc(fHotPoint.X, P.X - fHotPoint.X);
          inc(fHotPoint.Y, P.Y - fHotPoint.Y);
        finally
          SetEvent(fHandleCreated);
        end;
      end;
    end;
  end;
end;

procedure TThreadWindow.WMWINDOWPOSCHANGED(var Message: TWMWINDOWPOSCHANGED);
begin
  with Message.WindowPos^ do
  begin
    if Test(flags, SWP_HIDEWINDOW) then
      Visible := false;
    if Test(flags, SWP_SHOWWINDOW) then
      Visible := True;
  end;
end;

// Освобождение дескриптора иконки

procedure TThreadWindow.FreeIcon(var DestIcon: HIcon);
begin
  if (DestIcon <> 0) and (DestIcon <> THandle(-1)) and
    (DestIcon <> LoadIcon(0, IDI_APPLICATION)) then
  begin
    if DestroyIcon(DestIcon) then
      DestIcon := 0
    else
      RaiseLastOSError;
  end
  else
    DestIcon := 0;
end;

procedure TThreadWindow.UpdateIcon(SourceIcon: HIcon; var DestIcon: HIcon);
var
  IconInfo: TIconInfo;
  function LoadDefIcon: HIcon;
  begin
    Result := LoadIcon(hInstance, NameIconWait);
    if Result = 0 then
      Result := LoadIcon(hInstance, 'MAINICON');
    if Result = 0 then
      Result := LoadIcon(0, IDI_APPLICATION);
  end;

begin
  FreeIcon(DestIcon);
  if (SourceIcon = HIcon(-1)) or (fIconSize = -1) then
  begin
    DestIcon := LoadDefIcon;
    fIconSize := GetSystemMetrics(SM_CXICON);
  end
  else
  begin
    FillChar(IconInfo, SizeOf(IconInfo), 0);
    IconInfo.fIcon := True;
    if GetIconInfo(SourceIcon, IconInfo) then
    begin
      DestIcon := CreateIconIndirect(IconInfo);
      if IconInfo.hbmColor <> 0 then
        if not DeleteObject(IconInfo.hbmColor) then
          RaiseLastOSError;
      if IconInfo.hbmMask <> 0 then
        if not DeleteObject(IconInfo.hbmMask) then
          RaiseLastOSError;
    end
    else
      DestIcon := LoadDefIcon;
  end;
end;

function TThreadWindow.CalcTextRect(S: string; Font: hFont): TRect;
var
  DC: HDC;
  OldFont: hFont;
begin
  Result := Rect(0, 0, 2000, 2000);
  OldFont := 0;
  DC := GetDC(fWND);
  try
    OldFont := SelectObject(DC, Font);
    Windows.DrawText(DC, PChar(S), Length(S), Result, DT_CALCRECT);
  finally
    SelectObject(DC, OldFont);
    ReleaseDC(fWND, DC);
  end;
end;

procedure TThreadWindow.UpdateLayout(ClientRect: TRect;
  var ElementPos: TElementPos);
var
  H, W, Tmp, RealIconSize: integer;
  R: TRect;
begin
  H := (ClientRect.Bottom - ClientRect.Top) - 2 * BorderWidth;
  with ElementPos do
  begin
    // Координаты заголовка
    CaptionRect := ClientRect;
    if fCaption <> '' then
    begin
      CaptionRect.Bottom := CaptionRect.Top + GetSystemMetrics(SM_CYSMCAPTION);
      InflateRect(CaptionRect, -(BorderWidth div 2), 0);
      OffsetRect(CaptionRect, 0, BorderWidth div 2);
    end
    else
      CaptionRect.Bottom := CaptionRect.Top;
    // Координаты иконки
    RealIconSize := Max(IconSize, 0);
    if RealIconSize < H then
    begin
      Tmp := Min(((H - RealIconSize) div (2)), 0) + BorderWidth;
      IconRect := Rect(ClientRect.Left + BorderWidth, CaptionRect.Bottom + Tmp,
        ClientRect.Left + BorderWidth + RealIconSize, CaptionRect.Bottom + Tmp +
        RealIconSize)
    end
    else
      IconRect := Rect(ClientRect.Left + BorderWidth,
        CaptionRect.Bottom + BorderWidth, ClientRect.Left + BorderWidth +
        RealIconSize, CaptionRect.Bottom + BorderWidth + RealIconSize);
    // Время до окончания
    R := CalcTextRect('00:00:00', fTimerFont);
    R.Left := (IconRect.Right + IconRect.Left - R.Right) div (2);
    R.Top := IconRect.Bottom;
    R.Right := R.Left + R.Right;
    R.Bottom := R.Top + R.Bottom;
    Reserv := R;
    // Кнопка отмена
    if Enabled then
    begin
      R := CalcTextRect(TextCancel, fFont);
      H := R.Bottom;
      W := R.Right;
      ButtonRect := Rect(ClientRect.Right - BorderWidth - W - 10,
        ClientRect.Bottom - BorderWidth - H - 6, ClientRect.Right - BorderWidth,
        ClientRect.Bottom - BorderWidth);
    end
    else
      FillChar(ButtonRect, SizeOf(ButtonRect), 0);
    // Координаты процента выполнения
    ProgressRect := Rect(ClientRect.Left + BorderWidth, ClientRect.Bottom - 2 *
      BorderWidth, ClientRect.Right - BorderWidth,
      ClientRect.Bottom - BorderWidth);
    if fPercent < 0 then
      ProgressRect.Top := ProgressRect.Bottom;
    if Enabled then
      OffsetRect(ProgressRect, 0, -(ButtonRect.Bottom - ButtonRect.Top +
        BorderWidth));
    if (fStartTime > 0) and (ProgressRect.Top < Reserv.Bottom) then
      ProgressRect.Left := Reserv.Right + BorderWidth;
    if (ProgressRect.Top < IconRect.Bottom + BorderWidth) and
      (IconSize > 0) then
      ProgressRect.Left := IconRect.Right + BorderWidth;
    // Координаты текста
    TextRect := ClientRect;
    TextRect.Top := CaptionRect.Bottom;
    InflateRect(TextRect, -BorderWidth, -BorderWidth);
    if IconSize > 0 then
      TextRect.Left := IconRect.Right + BorderWidth;
    if fPercent >= 0 then
      TextRect.Bottom := ProgressRect.Top - 1
    else if Enabled then
      TextRect.Bottom := ButtonRect.Top - 1;
  end;
end;

// Создание кисти

procedure TThreadWindow.UpdateBrush(const Color: Cardinal; var Brush: HBrush);
begin
  if Brush <> 0 then
    if not DeleteObject(Brush) then
      RaiseLastOSError
    else
      Brush := 0;
  if (Color <> $1FFFFFFF) and (Brush = 0) then
    Brush := CreateSolidBrush(Color);
end;

// Изменение прозрачности окна

procedure TThreadWindow.UpdateBlend(const WND: HWND; Value: byte);
var
  AStyle: DWORD;
begin
  if (WND <> 0) and (@SetLayeredWindowAttributes <> nil) then
  begin
    AStyle := GetWindowLong(WND, GWL_EXSTYLE);
    if AStyle and WS_EX_LAYERED = 0 then
      if SetWindowLong(WND, GWL_EXSTYLE, AStyle or WS_EX_LAYERED) = 0 then
        raise EOSError.Create(SysErrorMessage(GetLastError));
    if not SetLayeredWindowAttributes(WND, 0, Value, LWA_ALPHA) then
      raise EOSError.Create(SysErrorMessage(GetLastError));
  end;
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var Buffer; Size: NativeInt);
var
  WParam: NativeUInt;
  Value: TPropertyData;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := Size;
  if Size <= 0 then
    raise EThreadWindow.CreateFmt(ErrorParam, ['Size', inttostr(Size)]);
  Value.Data := @Buffer;
  if Value.Data = nil then
    raise EThreadWindow.CreateFmt(ErrorParam, ['Buffer', 'nil']);
  Perform(UM_GetPropertyData, WParam, NativeInt(@Value));
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var S: string);
var
  WParam: NativeUInt;
  Value: TPropertyData;
  Len: integer;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := 0;
  Value.Data := nil;
  Perform(UM_GetPropertyData, WParam, NativeInt(@Value));
  S := '';
  if (Value.Data <> nil) then
  begin
    try
      Len := Value.DataSize div SizeOf(S[1]);
      if PChar(Value.Data)[Len - 1] = #0 then
        Dec(Len);
      if Len > 0 then
      begin
        SetLength(S, Len);
        move(Value.Data^, S[1], Len * SizeOf(S[1]));
      end;
    finally
      ReallocMem(Value.Data, 0);
    end;
  end;
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var I: NativeInt);
var
  WParam: NativeUInt;
  Value: TPropertyData;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := SizeOf(I);
  Value.Data := @I;
  Perform(UM_GetPropertyData, WParam, NativeInt(@Value));
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var B: boolean);
var
  I: NativeInt;
begin
  GetPropertyData(IndexProp, Part, I);
  B := (I <> 0);
end;

procedure TThreadWindow.SetText(const Value: string);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdText, 0), NativeInt(PChar(Value)));
end;

function TThreadWindow.GetText: string;
begin
  if InThread then
    Result := fText
  else
    GetPropertyData(IdText, 0, Result);
end;

procedure TThreadWindow.SetCaption(const Value: string);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdText, 1), NativeInt(PChar(Value)));
end;

procedure TThreadWindow.SetCaptionColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdColor, 1), NativeInt(Value));
end;

function TThreadWindow.GetCaption: string;
begin
  if InThread then
    Result := fCaption
  else
    GetPropertyData(IdText, 1, Result);
end;

function TThreadWindow.GetVisible: boolean;
begin
  if InThread then
    Result := fVisible
  else
    GetPropertyData(IDVisible, 0, Result);
end;

function TThreadWindow.GetBoundsRect: TRect;
begin
  GetPropertyData(IdBoundsRect, 0, Result, SizeOf(Result));
end;

function TThreadWindow.GetDefaultRect: TRect;
begin
  GetPropertyData(IdDefaultRect, 0, Result, SizeOf(Result));
end;

procedure TThreadWindow.SetAlphaBlendValue(const Value: byte);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdAlphaBlendValue, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetBoundsRect(const Value: TRect);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdBoundsRect, 0), NativeInt(@Value));
end;

procedure TThreadWindow.SetIcon(const Value: HIcon);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdIcon, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetIconIndex(const Value: NativeInt);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdIconIndex, 0), Value);
end;

procedure TThreadWindow.SetIconSize(const Value: NativeInt);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdIconSize, 0), Value);
end;

procedure TThreadWindow.SetCanceled(const Value: boolean);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdCanceled, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdColor, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetFont(const Value: hFont);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdFont, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetCaptionFont(const Value: hFont);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdFont, 1), NativeInt(Value));
end;

procedure TThreadWindow.SetTimerFont(const Value: hFont);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdFont, 2), NativeInt(PChar(Value)));
end;

procedure TThreadWindow.SetCaptionFontColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdFontColor, 1), NativeInt(Value));
end;

procedure TThreadWindow.SetFontColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdFontColor, 0), NativeInt(Value));
end;

procedure TThreadWindow.SetVisible(const Value: boolean);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDVisible, 0), IntBool[Value]);
end;

// Перед выполнением потока устанавливаем параметры по умолчанию

procedure TThreadWindow.AfterConstruction;
begin
  // Приоритет потока в котором работает окно ожидания
  Priority := { tpLowest tpTimeCritical } tpHighest;
  fLowBlink := True;
  fCtl3D := True;
  fOldPercent := fPercent;
  try
    DoBeforeResume;
  finally
    if not Terminated then
    begin
      fBusy := Windows.CreateEvent(nil, false, false, nil);
      fHandleCreated := Windows.CreateEvent(nil, True, True, nil);
    end;
    inherited;
    if not Terminated then
    begin
      //Resume;
      Start;
      WaitBusy(True);
    end;
  end;
end;

constructor TThreadWindow.Show(AMessage: string);
begin
  inherited Create(True);
  fEnabled := True;
  fHotPoint.X := -1;
  fHotPoint.Y := -1;
  fAlphaBlendValue := 255;
  AlphaShow := True;
  IntervalAlphaShow := 1000;
  Interval := 500;
  FontColor := GetSysColor(COLOR_WINDOWTEXT);
  Color := GetSysColor(COLOR_BTNFACE);
  CaptionFontColor := GetSysColor(COLOR_CAPTIONTEXT);
  CaptionColor := GetSysColor(COLOR_ACTIVECAPTION);
  Percent := -1;
  IconSize := -1;
  Icon := HIcon(-1);
  if AMessage = '' then
    AMessage := DefaultMessage;
  Text := AMessage;
  Visible := True;
end;

procedure TThreadWindow.DoBeforeResume;
begin

end;

procedure TThreadWindow.DoAfterSetBounds(NewBoundsRect: TRect;
  var NewWindowRect, NewClientRect: TRect);
begin
  NewWindowRect := NewBoundsRect;
  NewClientRect := NewWindowRect;
  OffsetRect(NewClientRect, -NewClientRect.Left, -NewClientRect.Top);
end;

procedure TThreadWindow.DoAfterStop;
begin

end;

procedure TThreadWindow.DoBeforeDispath(var Message: TMessage);
begin

end;

procedure TThreadWindow.DrawBackground(DC: HDC; ARect: TRect; Ctl3D: boolean);
begin
  DrawBorder(DC, ARect, Ctl3D, BorderWidth div 2, 0, false);
end;

procedure TThreadWindow.DrawBorder(DC: HDC; ARect: TRect; Ctl3D: boolean;
  Width: integer; BorderColor: Cardinal; IsDown: boolean);
var
  OldPen, Pen: HPen;
  OldBrush: HBrush;
  I: integer;
  B: byte;
  C, C1, C2: Cardinal;
  R: TRect;
  P: TPoint;
begin
  OldBrush := SelectObject(DC, GetStockObject(NULL_BRUSH));
  try
    if Ctl3D then
    begin
      for I := 0 to Width - 1 do
      begin
        R := ARect;
        InflateRect(R, -I, -I);
        if IsDown then
          if Width = 1 then
            B := 128
          else
            B := Round(128 * sqr(Sin(I * Pi / Width)))
        else
          B := Round(255 * sqr((Width - I) * (255 / Width) / 255));
        OldPen := 0;
        Pen := 0;
        try
          if IsDown then
            C := $00FFFFFF
          else
          begin
            C := BorderColor;
            if BorderColor = 0 then
              B := (B * 2) div 3;
          end;
          C1 := Blend(C, fColor, B);
          Pen := CreatePen(PS_SOLID, 1, C1);
          OldPen := SelectObject(DC, Pen);
          Windows.MoveToEx(DC, R.Left, R.Bottom - 1, @P);
          Windows.LineTo(DC, R.Right - 1, R.Bottom - 1);
          Windows.LineTo(DC, R.Right - 1, R.Top);
        finally
          SelectObject(DC, OldPen);
          DeleteObject(Pen);
        end;
        if IsDown then
          B := Round(255 * SQRt(I * (255 / Width) / 255))
        else if Width = 1 then
          B := 128
        else
          B := Round(128 * sqr(Sin(I * Pi / Width)));
        OldPen := 0;
        Pen := 0;
        try
          if IsDown then
          begin
            C := BorderColor;
            if BorderColor = 0 then
              B := (B * 2) div 3;
          end
          else
            C := $00FFFFFF;
          C2 := Blend(C, fColor, B);
          Pen := CreatePen(PS_SOLID, 1, C2);
          OldPen := SelectObject(DC, Pen);
          Windows.LineTo(DC, R.Left, R.Top);
          Windows.LineTo(DC, R.Left, R.Bottom);
          C := Blend(C1, C2, 128);
          Windows.SetPixel(DC, R.Left, R.Bottom - 1, C);
          Windows.SetPixel(DC, R.Right - 1, R.Top, C);
          if I = (Width - 1) then
          begin
            InflateRect(R, -1, -1);
            Windows.FillRect(DC, R, OldBrush);
          end;
        finally
          SelectObject(DC, OldPen);
          DeleteObject(Pen);
        end;
      end;
    end
    else
    begin
      for I := 0 to Width - 1 do
      begin
        R := ARect;
        InflateRect(R, -I, -I);
        if IsDown then
          B := (I * 255) div Width
        else
          B := ((Width - I) * 255) div Width;
        OldPen := 0;
        Pen := 0;
        try
          if BorderColor = 0 then
            B := (B * 2) div 3;
          C := Blend(BorderColor, fColor, B);
          Pen := CreatePen(PS_SOLID, 1, C);
          OldPen := SelectObject(DC, Pen);
          if I = (Width - 1) then
            SelectObject(DC, OldBrush);
          Windows.Rectangle(DC, R.Left, R.Top, R.Right, R.Bottom);
        finally
          SelectObject(DC, OldPen);
          DeleteObject(Pen);
        end;
      end;
    end;
  finally
    SelectObject(DC, OldBrush);
  end;
end;

procedure TThreadWindow.DrawIcon(DC: HDC; ARect: TRect; Icon: HIcon;
  Brush: HBrush);
begin
  if Icon <> 0 then
  begin
    Windows.DrawIconEx(DC, ARect.Left, ARect.Top, Icon,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, fIconIndex, Brush,
      DI_NORMAL);
  end;
end;

procedure TThreadWindow.DrawProgress(DC: HDC; ARect: TRect; Percent: integer);
var
  TmpR: TRect;
  Br: HBrush;
  C: Cardinal;
begin
  if (Percent >= 0) then
  begin
    Percent := Min(Percent, 1000);
    TmpR := ARect;
    InflateRect(TmpR, -1, -1);
    TmpR.Right := TmpR.Left + ((TmpR.Right - TmpR.Left) * Percent + 500)
      div (1000);
    if TmpR.Right <> TmpR.Left then
    begin
      C := GetHighLightColor(Color, 50);
      if C = Color then
        C := GetShadowColor(Color, -80);
      Br := CreateSolidBrush(C);
      try
        FillRect(DC, TmpR, Br);
      finally
        DeleteObject(Br);
        ExcludeClipRect(DC, TmpR.Left, TmpR.Top, TmpR.Right, TmpR.Bottom);
      end;
    end;
    Rectangle(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  end;
end;

procedure TThreadWindow.DrawButton(DC: HDC; ARect: TRect; State: UINT);
var
  R: TRect;
  Br, OldBrush: HBrush;
  IsDown: LongBool;
  W, H, C: integer;
  S: string;

begin
  R := ARect;
  OldBrush := 0;
  Br := 0;
  IsDown := ((State and DFCS_PUSHED) = DFCS_PUSHED);
  try
    // Получаем прямоугольник в котором изображается текст
    S := TextCancel;
    Windows.DrawText(DC, PChar(S), Length(S), R, DT_CALCRECT or DT_SINGLELINE);
    W := Min(R.Right - R.Left, ARect.Right - ARect.Left - 8);
    H := Min(R.Bottom - R.Top, ARect.Bottom - ARect.Top - 6);
    R.Left := (ARect.Left + ARect.Right - W + 1) div (2);
    R.Top := (ARect.Bottom + ARect.Top - H + 1) div (2);
    R.Right := R.Left + W;
    R.Bottom := R.Top + H;
    OffsetRect(R, 0, -1);
    if IsDown then
      OffsetRect(R, 1, 1);

    // Изображаем внутреннюю часть кнопки
    C := Color;
    if (State and DFCS_INACTIVE) = DFCS_INACTIVE then
    begin
      SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
    end
    else
    begin
      if (State and DFCS_FLAT) = DFCS_FLAT then
        SetTextColor(DC, GetSysColor(COLOR_HOTLIGHT))
      else
      begin
        if FontColor = $1FFFFFFF then
          SetTextColor(DC, GetSysColor(COLOR_BTNTEXT))
        else
          SetTextColor(DC, FontColor);
      end;
      if IsDown then
        C := GetHighLightColor(Color, 12);
    end;
    SetBkMode(DC, OPAQUE);
    SetBkColor(DC, C);
    Windows.DrawText(DC, PChar(S), Length(S), R, DT_SINGLELINE);
    Windows.ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
    // Изображаем границу кнопки
    if ((State and DFCS_FLAT) = DFCS_FLAT) or (Ctl3D) or (IsDown) then
    begin
      Br := CreateSolidBrush(C);
      OldBrush := SelectObject(DC, Br);
      DrawBorder(DC, ARect, Ctl3D, 2, $00000000, IsDown);
    end
    else
      FillRect(DC, ARect, fBrush);
  finally
    if OldBrush <> 0 then
      SelectObject(DC, OldBrush);
    DeleteObject(Br);
  end;
end;

procedure TThreadWindow.DrawCaption(DC: HDC; ARect: TRect; Text: PChar;
  Len: integer);
var
  R: TRect;
  D: integer;
begin
  R := Rect(0, 0, 2000, 2000);
  Windows.DrawText(DC, Text, Len, R, DT_CALCRECT);
  D := BorderWidth div 2;
  R.Right := Min(R.Right, ARect.Right - ARect.Left - D);
  R.Bottom := Min(R.Bottom, ARect.Bottom - ARect.Top);

  R.Left := (ARect.Right + ARect.Left - R.Right) div (2);
  R.Top := (ARect.Bottom + ARect.Top - R.Bottom - 1) div (2);
  R.Right := R.Left + R.Right;
  R.Bottom := R.Top + R.Bottom;
  Windows.DrawText(DC, PChar(Text), Len, R, DT_SINGLELINE or DT_END_ELLIPSIS);
  Dec(R.Right);
  ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
  if fCaptionBrush <> 0 then
    Windows.FillRect(DC, ARect, fCaptionBrush)
end;

procedure TThreadWindow.DrawText(DC: HDC; ARect: TRect; Text: PChar;
  Len: integer);
begin
  if Text <> nil then
    Windows.DrawText(DC, Text, Len, ARect, DT_WORDBREAK or DT_LEFT);
end;

procedure TThreadWindow.DrawTime(DC: HDC; ARect: TRect;
  StartTime, TotalTime: TDateTime);
var
  S: string;
  R: TRect;
begin
  S := GetTimeText;
  if S <> '' then
  begin
    R := ARect;
    Windows.DrawText(DC, PChar(S), Length(S), R, DT_CALCRECT or DT_LEFT);
    OffsetRect(R, ((ARect.Right - ARect.Left) - (R.Right - R.Left)) div (2), 0);
    Windows.DrawText(DC, PChar(S), Length(S), R, DT_LEFT);
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
  end;
  // FillRect(DC, ARect, fBrush);
end;

procedure TThreadWindow.DrawWND(DC: HDC; ARect: TRect);
var
  R: TRect;
  Pen, OldPen: HPen;
  function NotNullRect(R: TRect): boolean;
  begin
    Result := (R.Right > R.Left) and (R.Bottom > R.Top);
  end;
// Рисуем иконку
  procedure PaintIcon;
  begin
    if (fIcon <> 0) and (NativeInt(fIcon) <> -1) and
      (NotNullRect(fElementPos.IconRect)) then
      with fElementPos do
      begin
        DrawIcon(DC, IconRect, fIcon, fBrush);
        if LowBlink then
          ExcludeClipRect(DC, IconRect.Left, IconRect.Top, IconRect.Right,
            IconRect.Bottom);
      end;
  end;
// Рисуем текст сообщения
  procedure PaintText;
  begin
    if (fText <> '') and NotNullRect(fElementPos.TextRect) then
      with fElementPos do
      begin
        SelectObject(DC, fFont);
        SetTextColor(DC, fFontColor);
        SetBkColor(DC, Color);
        SetBkMode(DC, TRANSPARENT);
        SelectObject(DC, fBrush);
        DrawText(DC, TextRect, PChar(fText), Length(fText));
      end;
  end;
  procedure PaintCaption;
  var
    C: Cardinal;
  begin
    if (fCaption <> '') and NotNullRect(fElementPos.CaptionRect) then
      with fElementPos do
      begin
        SelectObject(DC, fCaptionFont);
        SetTextColor(DC, fCaptionFontColor);
        if fCaptionColor <> $1FFFFFFF then
          C := fCaptionColor
        else
          C := fColor;
        if C <> $1FFFFFFF then
          Windows.SetBkMode(DC, OPAQUE)
        else
          Windows.SetBkMode(DC, TRANSPARENT);

        Windows.SetBkColor(DC, C);
        DrawCaption(DC, CaptionRect, PChar(fCaption), Length(fCaption));
        if LowBlink then
          ExcludeClipRect(DC, CaptionRect.Left, CaptionRect.Top,
            CaptionRect.Right, CaptionRect.Bottom);
      end;
  end;
  procedure PaintTimer;
  begin
    if fStartTime > 0 then
    begin
      SelectObject(DC, fTimerFont);
      SetTextColor(DC, fFontColor);
      if fColor <> $1FFFFFFF then
        Windows.SetBkMode(DC, OPAQUE)
      else
        Windows.SetBkMode(DC, TRANSPARENT);
      Windows.SetBkColor(DC, fColor);
      DrawTime(DC, fElementPos.Reserv, fStartTime, fTotalTime);
    end;
  end;
// Рисуем кнопку
  procedure PaintButton;
  begin
    if Enabled and EnabledCancel then
    begin
      SelectObject(DC, fFont);
      SetTextColor(DC, fFontColor);
      SetBkColor(DC, fColor);
      SetBkMode(DC, OPAQUE);
      SelectObject(DC, GetStockObject(NULL_PEN));
      SelectObject(DC, fBrush);
      with fElementPos do
      begin
        DrawButton(DC, fElementPos.ButtonRect, fStateButton);
        if LowBlink then
          ExcludeClipRect(DC, ButtonRect.Left, ButtonRect.Top, ButtonRect.Right,
            ButtonRect.Bottom);
      end;
    end;
  end;

begin
  R := ARect;
  OffsetRect(R, -R.Left, -R.Top);
  try
    Pen := CreatePen(PS_SOLID, 1,
      { GetSysColor(COLOR_BTNSHADOW) } GetShadowColor(Color, -50));
    OldPen := SelectObject(DC, Pen);
    SelectObject(DC, fBrush);
    try
      if fLowBlink then
      begin
        if (fPercent >= 0) and (NotNullRect(fElementPos.ProgressRect)) then
          with fElementPos do
          begin
            DrawProgress(DC, ProgressRect, fPercent);
            ExcludeClipRect(DC, ProgressRect.Left, ProgressRect.Top,
              ProgressRect.Right, ProgressRect.Bottom);
          end;
        PaintIcon;
        PaintButton;
        PaintCaption;
        PaintTimer;
        DrawBackground(DC, fClientRect, fCtl3D);
        PaintText;
      end
      else
      begin
        DrawBackground(DC, fClientRect, fCtl3D);
        PaintTimer;
        PaintIcon;
        PaintButton;
        PaintText;
        PaintCaption;
        if (fPercent >= 0) and (NotNullRect(fElementPos.ProgressRect)) then
          DrawProgress(DC, fElementPos.ProgressRect, fPercent);
      end;
    finally
      SelectObject(DC, OldPen);
      if not DeleteObject(Pen) then
        RaiseLastOSError;
    end;
  finally
  end;
end;

procedure TThreadWindow.WNDCreated(WND: HWND);
begin

end;

procedure TThreadWindow.WNDDestroy(var WND: HWND);
begin

end;

//{ TUMPropertyData }
//
//procedure TUMPropertyData.FromMsg(aMsg: TMessage);
//begin
//  Msg := aMsg.Msg;
//  IndexProp := aMsg.WParam and $FFFF;
//  Part := (aMsg.WParam shr 16) and $FFFF;
//  Value := PRopertyData(aMsg.LParam);
//  Result := aMsg.Result;
//end;
//
//procedure TUMPropertyData.ToMsg(var aMsg: TMessage);
//begin
//  aMsg.Msg := Msg;
//  aMsg.WParam := MakeWParam(IndexProp, Part);
//  aMsg.LParam := NativeInt(Value);
//  aMsg.Result := Result;
//end;
//
//{ TUMPropertyValue }
//
//procedure TUMPropertyValue.FromMsg(aMsg: TMessage);
//begin
//  Msg := aMsg.Msg;
//  IndexProp := aMsg.WParam and $FFFF;
//  Part := (aMsg.WParam shr 16) and $FFFF;
//  Value := aMsg.LParam;
//  Result := aMsg.Result;
//end;

initialization

EventMake := Windows.CreateEvent(nil, false, True, 'EventMakeTThreadWindow');
EventAllocate := Windows.CreateEvent(nil, false, True,
  'EventAllocateTThreadWindow');

finalization

if EventMake <> 0 then
  Windows.CloseHandle(EventMake);
if EventAllocate <> 0 then
  Windows.CloseHandle(EventAllocate);

end.
