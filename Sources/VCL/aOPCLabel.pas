{ *******************************************************
  Copyright (c) 2001-2015 by Alex A. Lagodny
 ******************************************************* }

unit aOPCLabel;

interface

uses
  Forms, Windows, SysUtils, Classes, Controls, StdCtrls,
  Messages, Types, Themes, Graphics,
  aOPCUtils, aCustomOPCSource, aOPCLookupList,
  aOPCDataObject, uDCObjects;

type

  TaOPCOnDrawLabelEvent = procedure(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean) of object;

  TaCustomOPCLabel = class(TaCustomOPCDataObject)
  private
    OriginalInteractiveFontSize: Integer;

    FFocusControl: TWinControl;
    FAlignment: TAlignment;
    FAutoSize: Boolean;
    FLayout: TTextLayout;
    FWordWrap: Boolean;
    FShowAccelChar: Boolean;
    FTransparentSet: Boolean;
    FLookupList: TaOPCLookupList;
    FDisplayFormat: string;
    FTrim: Boolean;
    FInteractiveFont: TFont;
    FBorderWidth: TBorderWidth;
    FShowError: Boolean;
    FOnDrawLabel: TaOPCOnDrawLabelEvent;
    FBorderColor: TColor;
    FRotationAngle: Integer;
    procedure SetInteractiveFont(const Value: TFont);
    procedure SetTrim(const Value: Boolean);
    function GetTransparent: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetFocusControl(Value: TWinControl);
    procedure SetShowAccelChar(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
    procedure SetLayout(Value: TTextLayout);
    procedure SetWordWrap(Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure SetLookupList(const Value: TaOPCLookupList);
    procedure SetDisplayFormat(const Value: string);
    procedure SetBorderWidth(const Value: TBorderWidth);
    procedure SetShowError(const Value: Boolean);
    procedure SetBorderColor(const Value: TColor);

    procedure CalcTextPos(var aRect: TRect; aAngle: Integer; aTxt: String);
    procedure DrawAngleText(aCanvas: TCanvas; aRect: TRect; aAngle: Integer; aTxt: String);
    procedure SetRotationAngle(const Value: Integer);
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure AdjustBounds; dynamic;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); dynamic;

    function GetLabelText: string; virtual;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure SetAutoSize(Value: Boolean); override;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property FocusControl: TWinControl read FFocusControl write SetFocusControl;
    property ShowAccelChar: Boolean read FShowAccelChar write SetShowAccelChar default True;
    property Transparent: Boolean read GetTransparent write SetTransparent stored FTransparentSet;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;

    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth default 0;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBlack;

    procedure UpdateOriginalPosition; override;

    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;

    procedure ChangeData(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Caption;
    property Canvas;
  published
    property Interactive;
    property InteractiveFont: TFont read FInteractiveFont write SetInteractiveFont;
    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property StairsOptions default [soIncrease, soDecrease];
    property Trim: Boolean read FTrim write SetTrim default False;
    property ShowError: Boolean read FShowError write SetShowError default True;

    property RotationAngle: Integer read FRotationAngle write SetRotationAngle;

    property OnDrawLabel: TaOPCOnDrawLabelEvent read FOnDrawLabel write FOnDrawLabel;
  end;

  TaOPCLabel = class(TaCustomOPCLabel)
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderWidth;
    property BorderColor;
    property Caption;
    property Color nodefault;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent;
    property Layout;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnStartDock;
    property OnStartDrag;
  end;

  TaOPCBlinkLabel = class;

  TaOPCBlinkThread = class(TThread)
  private
    FOwner: TaOPCBlinkLabel;
    procedure SetOwner(const Value: TaOPCBlinkLabel);
  public
    procedure Execute; override;
    property Owner: TaOPCBlinkLabel read FOwner write SetOwner;
  end;

  TBlinkOptions = set of (boText, boFont, boColor);

  TaOPCBlinkLabel = class(TaOPCLabel)
  private
    FInBlink: Boolean;
    FBlinkThread: TaOPCBlinkThread;
    FBlinkInterval: Integer;
    FBlink: Boolean;
    FBlinkFont: TFont;
    FBlinkOptions: TBlinkOptions;
    FBlinkCount: Integer;
    FBlinkColor: TColor;
    FBlinkText: TCaption;
    procedure SetBlinkText(const Value: TCaption);
    procedure SetBlinkColor(const Value: TColor);
    procedure SetBlinkCount(const Value: Integer);
    procedure SetBlinkFont(const Value: TFont);
    procedure SetBlinkOptions(const Value: TBlinkOptions);
    procedure SetBlink(const Value: Boolean);
    procedure SetBlinkInterval(const Value: Integer);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Blink: Boolean read FBlink write SetBlink default False;
    property BlinkInterval: Integer read FBlinkInterval write SetBlinkInterval default 1000;
    property BlinkCount: Integer read FBlinkCount write SetBlinkCount default 0;
    property BlinkOptions: TBlinkOptions read FBlinkOptions write SetBlinkOptions default [boText];
    property BlinkText: TCaption read FBlinkText write SetBlinkText;
    property BlinkFont: TFont read FBlinkFont write SetBlinkFont;
    property BlinkColor: TColor read FBlinkColor write SetBlinkColor default clRed;
  end;

  TaOPCColorLabel = class(TaOPCLabel)
  private
    FColors: TStrings;
    FErrorColor: TColor;
    FShowValue: Boolean;
    procedure SetColors(const Value: TStrings);
    procedure SetErrorColor(const Value: TColor);
    procedure SetShowValue(const Value: Boolean);
  protected
    function CalcColor: TColor;
    procedure Paint; override;
    procedure ChangeData(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ErrorColor: TColor read FErrorColor write SetErrorColor default clRed;
    property Colors: TStrings read FColors write SetColors;
    property ShowValue: Boolean read FShowValue write SetShowValue default False;
    property Transparent default False;
    property ParentColor default False;
  end;

implementation

uses Math,
  Hyphen;

{ TCustomOPCLabel }

procedure TaCustomOPCLabel.AdjustBounds;
const
  WordWraps: array [Boolean] of Word = (0, DT_WORDBREAK);
var
  DC: HDC;
  X: Integer;
  Rect: TRect;
  AAlignment: TAlignment;
begin
  if not(csReading in ComponentState) and FAutoSize then
  begin
    Rect := ClientRect;
    if BorderWidth > 0 then
      InflateRect(Rect, -BorderWidth, -BorderWidth);

    DC := GetDC(0);
    Canvas.Handle := DC;
    DoDrawText(Rect, (DT_EXPANDTABS or DT_CALCRECT) or WordWraps[FWordWrap]);
    Canvas.Handle := 0;
    ReleaseDC(0, DC);
    X := Left;
    AAlignment := FAlignment;
    if UseRightToLeftAlignment then
      ChangeBiDiModeAlignment(AAlignment);
    if AAlignment = taRightJustify then
      Inc(X, Width - Rect.Right);
    SetBounds(X - BorderWidth, Top, Rect.Right + BorderWidth, Rect.Bottom + BorderWidth);
  end;
end;

procedure TaCustomOPCLabel.AssignTo(Dest: TPersistent);
var
  D: TaCustomOPCLabel;
begin
  if Dest is TaCustomOPCLabel then
  begin
    D := TaCustomOPCLabel(Dest);
    D.Align := Align;
    D.Alignment := Alignment;
    D.AutoSize := AutoSize;
    D.BorderColor := BorderColor;
    D.BorderWidth := BorderWidth;
    D.Caption := Caption;
    D.Color := Color;
    D.Cursor := Cursor;
    D.DisplayFormat := DisplayFormat;
    D.DragCursor := DragCursor;
    D.DragKind := DragKind;
    D.DragMode := DragMode;
    D.Enabled := Enabled;
    D.ErrorCode := ErrorCode;
    D.ErrorString := ErrorString;
    D.Font.Assign(Font);
    D.Height := Height;
    D.HelpContext := HelpContext;
    D.HelpKeyword := HelpKeyword;
    D.HelpType := HelpType;
    D.Hint := Hint;
    D.Hints := Hints;
    D.Interactive := Interactive;
    D.Layout := Layout;
    D.Left := Left;
    D.LookupList := LookupList;
    D.OPCSource := OPCSource;
    D.PhysID := PhysID;
    D.ShowAccelChar := ShowAccelChar;
    D.ShowError := ShowError;
    D.ShowHint := ShowHint;
    D.StairsOptions := StairsOptions;
    D.Transparent := Transparent;
    D.Trim := Trim;
    D.UpdateOnChangeMoment := UpdateOnChangeMoment;
    D.Value := Value;
    D.Visible := Visible;
    D.Width := Width;
    D.WordWrap := WordWrap;
    // inherited;
  end;

end;

procedure TaCustomOPCLabel.CalcTextPos(var aRect: TRect; aAngle: Integer; aTxt: String);
{ ========================================================================== }
{ Calculate text pos. depend. on: Font, Escapement, Alignment and length }
{ if AutoSize true : set properties Height and Width }
{ -------------------------------------------------------------------------- }
var
  DC: HDC;
  hSavFont: HFont;
  Size: TSize;
  X, y: Integer;
  //cStr: array [0 .. 255] of Char;
begin
  //StrPCopy(cStr, aTxt);
  DC := GetDC(0);
  hSavFont := SelectObject(DC, Font.Handle);
  GetTextExtentPoint32(DC, PChar(aTxt), Length(aTxt), Size);
//{$IFDEF WIN32}
//  GetTextExtentPoint32(DC, cStr, Length(aTxt), Size);
//{$ELSE}
//  GetTextExtentPoint(DC, cStr, Length(aTxt), Size);
//{$ENDIF}
  SelectObject(DC, hSavFont);
  ReleaseDC(0, DC);

  if aAngle <= 90 then
  begin { 1.Quadrant }
    X := 0;
    y := Trunc(Size.cx * sin(aAngle * Pi / 180));
  end
  else if aAngle <= 180 then
  begin { 2.Quadrant }
    X := Trunc(Size.cx * -cos(aAngle * Pi / 180));
    y := Trunc(Size.cx * sin(aAngle * Pi / 180) + Size.cy * cos((180 - aAngle) * Pi / 180));
  end
  else if aAngle <= 270 then
  begin { 3.Quadrant }
    X := Trunc(Size.cx * -cos(aAngle * Pi / 180) + Size.cy * sin((aAngle - 180) * Pi / 180));
    y := Trunc(Size.cy * sin((270 - aAngle) * Pi / 180));
  end
  else if aAngle <= 360 then
  begin { 4.Quadrant }
    X := Trunc(Size.cy * sin((360 - aAngle) * Pi / 180));
    y := 0;
  end;
  aRect.Top := aRect.Top + y;
  aRect.Left := aRect.Left + X;

  X := Abs(Trunc(Size.cx * cos(aAngle * Pi / 180))) + Abs(Trunc(Size.cy * sin(aAngle * Pi / 180)));
  y := Abs(Trunc(Size.cx * sin(aAngle * Pi / 180))) + Abs(Trunc(Size.cy * cos(aAngle * Pi / 180)));

  if AutoSize then
  begin
    Width := X;
    Height := y;
  end
  else
  begin
    case Alignment of
      taCenter:
        aRect.Left := aRect.Left + ((Width - X) div 2);
      taRightJustify:
        aRect.Left := aRect.Left + Width - X - BorderWidth;
      taLeftJustify:
        aRect.Left := aRect.Left + BorderWidth;
    end;

    case Layout of
      tlCenter:
        aRect.Top := aRect.Top + ((Height - y) div 2);
      tlBottom:
        aRect.Top := aRect.Top + Height - y - 2 * BorderWidth;
      tlTop:
        aRect.Top := aRect.Top + BorderWidth;
    end;
  end;
end;

procedure TaCustomOPCLabel.ChangeData(Sender: TObject);
var
  aValue: Extended;
  Precision: Integer;
  i: Integer;
  aValueStr: string;
begin
  // if (ErrorString <> '') and (FShowError) then
  if (ErrorCode <> 0) and FShowError then
    Caption := ErrorString
  else
  begin
    if LookupList = nil then
    begin
      try
        if Value = '' then
          Caption := Value

        else
        begin
          aValue := StrToFloat(Value); // TryStrToFloat(Value); //StrToFloat(Value, OpcFS);
          // нужно ли отсекать, а не округлять
          if Trim then
          begin
            Precision := 1;
            i := pos('.', DisplayFormat);
            if i > 0 then
            begin
              Inc(i);
              while i <= Length(DisplayFormat) do
              begin
                if CharInSet(DisplayFormat[i], ['0', '#']) then
                  Precision := Precision * 10;
                Inc(i);
              end;
            end;
            aValue := Trunc(aValue * Precision) / Precision;
          end;
          Caption := FormatValue(aValue, DisplayFormat);
        end;
      except
        Caption := Value
      end;
    end
    else
    begin
      // пытаемся найти соответствие нашему значению и форматируем его
      // если не находим, то возвращаем числовое значение
      LookupList.Lookup(Value, aValueStr);
      if DisplayFormat <> '' then
        Caption := Format(DisplayFormat, [aValueStr])
      else
        Caption := aValueStr
    end;
  end;

  inherited;
end;

procedure TaCustomOPCLabel.ChangeScale(M, D: Integer);
begin
  if M <> 0 then
  begin
    if M <> D then
    begin
      if SameValue(D / M, Scale, 0.001) then
        InteractiveFont.Size := OriginalInteractiveFontSize
      else
        InteractiveFont.Size := Round(OriginalInteractiveFontSize * Scale * M / D);
    end;

    inherited ChangeScale(M, D);
  end
  else
  begin
    InteractiveFont.Size := OriginalInteractiveFontSize;
    inherited ChangeScale(1, 1);
  end;

end;

procedure TaCustomOPCLabel.CMDialogChar(var Message: TCMDialogChar);
begin
  if (FFocusControl <> nil) and Enabled and ShowAccelChar and IsAccel(Message.CharCode, Caption) then
    with FFocusControl do
      if CanFocus then
      begin
        SetFocus;
        Message.Result := 1;
      end;
end;

procedure TaCustomOPCLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustBounds;
end;

procedure TaCustomOPCLabel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
  AdjustBounds;
end;

constructor TaCustomOPCLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 65;
  Height := 17;
  FAutoSize := True;
  FShowAccelChar := True;
  { The "default" value for the Transparent property depends on
    if you have Themes available and enabled or not. If you have
    ever explicitly set it, that will override the default value. }
  // if ThemeServices.ThemesEnabled then
  ControlStyle := ControlStyle - [csOpaque];
  // else
  // ControlStyle := ControlStyle + [csOpaque];
  StairsOptions := [soIncrease, soDecrease];

  FInteractiveFont := TFont.Create;
  FInteractiveFont.Color := clHighlight;
  FInteractiveFont.Style := [fsUnderline];
  FShowError := True;

  FBorderWidth := 0;
  FBorderColor := clBlack;
end;

destructor TaCustomOPCLabel.Destroy;
begin
  FreeAndNil(FInteractiveFont);
  inherited;
end;

procedure TaCustomOPCLabel.DoDrawText(var Rect: TRect; Flags: Integer);
var
  Text: string;
  aHandled: Boolean;

//  lf: TLogFont;
//  tf: TFont;
//  w, h: Integer;
//
//  hOldFont, hNewFont: HFont;

begin

  if Interactive and MouseInSide then
    Canvas.Font := InteractiveFont
  else
    Canvas.Font := Font;

  if (Flags and DT_CALCRECT <> 0) and ((Text = '') or FShowAccelChar and (Text[1] = '&') and (Text[2] = #0)) then
    Text := Text + ' ';

  Text := GetLabelText;

  if not FShowAccelChar then
    Flags := Flags or DT_NOPREFIX;
  Flags := DrawTextBiDiModeFlags(Flags);

  if Assigned(OnDrawLabel) then
  begin
    aHandled := False;
    OnDrawLabel(Self, Canvas, Text, aHandled);
    if aHandled then
      Exit;
  end;

  if RotationAngle <> 0 then
    DrawAngleText(Canvas, Rect, RotationAngle mod 360, Text)

    // if Font.Orientation <> 0 then
    // begin
    // with Canvas do
    // begin
    /// /      w := TextWidth(Text);
    /// /      h := TextHeight(Text);
    //
    /// /  GetObject(aCanvas.Font.Handle,SizeOf(LFont),Addr(LFont));
    /// /  LFont.lfEscapement := aAngle*10;
    /// /  hNewFont := CreateFontIndirect(LFont);
    /// /  hOldFont := SelectObject(aCanvas.Handle,hNewFont);
    /// /
    /// /  aCanvas.TextOut(aRect.Left,aRect.Top,aTxt);
    /// /
    /// /  hNewFont := SelectObject(aCanvas.Handle,hOldFont);
    /// /  DeleteObject(hNewFont);
    //
    //
    // GetObject(Font.Handle, SizeOf(lf),Addr(lf));
    // lf.lfEscapement := Font.Orientation;
    // hNewFont := CreateFontIndirect(lf);
    // hOldFont := SelectObject(Handle,hNewFont);
    //
    // TextOut(BorderWidth, Height-BorderWidth, Text);
    /// /      aCanvas.TextOut(aRect.Left,aRect.Top,aTxt);
    //
    // hNewFont := SelectObject(Handle, hOldFont);
    // DeleteObject(hNewFont);
    //
    //
    /// /      tf := TFont.Create;
    /// /      try
    /// /        tf.Assign(Font);
    /// /        GetObject(tf.Handle, sizeof(lf), @lf);
    /// /        lf.lfEscapement := Font.Orientation;
    /// /        lf.lfOrientation := Font.Orientation;
    /// /        tf.Handle := CreateFontIndirect(lf);
    /// /        Font.Assign(tf);
    /// ///        TextOut(BorderWidth, Height-BorderWidth, Text);
    /// /
    /// /        case Font.Orientation of
    /// /          0:   TextOut((Width-w)div 2,(Height-h)div 2, Text);
    /// /          450: TextOut(h div 3,Height-h, Text);
    /// /          900: TextOut((Width-h) div 2,Height-(Height-w)div 2, Text);
    /// /          1350:TextOut(Width-h,Height-h div 3, Text);
    /// /          1800:TextOut(Width-((Width-w)div 2),((Height-h)div 2)+h, Text);
    /// /          2250:TextOut(Width-h div 3,h, Text);
    /// /          2700:TextOut(((Width-h)div 2)+h,(Height-w)div 2, Text);
    /// /          3150:TextOut(h,h div 3, Text);
    /// /          else
    /// /            TextOut(BorderWidth, Height-BorderWidth, Text);
    /// /        end;
    /// /
    /// /      finally
    /// /        tf.Free;
    /// /      end;
    // end;
    // end
  else
  begin
    if not Enabled then
    begin
      OffsetRect(Rect, 1, 1);
      Canvas.Font.Color := clBtnHighlight;
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
      OffsetRect(Rect, -1, -1);
      Canvas.Font.Color := clBtnShadow;
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
    end
    else
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
  end;
end;

procedure TaCustomOPCLabel.DoMouseEnter;
begin
  if Interactive then
  begin
    Invalidate;
    AdjustBounds
  end;
end;

procedure TaCustomOPCLabel.DoMouseLeave;
begin
  if Interactive then
  begin
    Invalidate;
    AdjustBounds
  end;
end;

procedure TaCustomOPCLabel.DrawAngleText(aCanvas: TCanvas; aRect: TRect; aAngle: Integer; aTxt: String);
{ ========================================================================== }
{ Draw text with FontIndirect (angle -> escapement) }
{ -------------------------------------------------------------------------- }
var
  LFont: TLogFont;
  hOldFont, hNewFont: HFont;
begin
  CalcTextPos(aRect, aAngle, aTxt);

  GetObject(aCanvas.Font.Handle, SizeOf(LFont), Addr(LFont));
  LFont.lfEscapement := aAngle * 10;
  hNewFont := CreateFontIndirect(LFont);
  hOldFont := SelectObject(aCanvas.Handle, hNewFont);

  aCanvas.TextOut(aRect.Left, aRect.Top, aTxt);

  hNewFont := SelectObject(aCanvas.Handle, hOldFont);
  DeleteObject(hNewFont);
end;

function TaCustomOPCLabel.GetLabelText: string;
var
  Strs: TStrings;
  t: string;
begin
  if WordWrap then
  begin
    Strs := TStringList.Create;
    try
      HyphenParagraph(Caption, Strs, Width, Canvas);
      t := Strs.Text;
      Result := Copy(t, 1, Length(t) - 2);
    finally
      Strs.Free;
    end;
  end
  else
    Result := Caption;
end;

function TaCustomOPCLabel.GetTransparent: Boolean;
begin
  Result := not(csOpaque in ControlStyle);
end;

procedure TaCustomOPCLabel.Loaded;
begin
  inherited Loaded;
  AdjustBounds;
end;

procedure TaCustomOPCLabel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FFocusControl) then
      FFocusControl := nil
    else if (AComponent = FLookupList) then
      FLookupList := nil;
  end;
end;

procedure TaCustomOPCLabel.Paint;
const
  Alignments: array [TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  WordWraps: array [Boolean] of Word = (0, DT_WORDBREAK);
var
  Rect, CalcRect: TRect;
  DrawStyle: Longint;
begin
  with Canvas do
  begin
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;

    Rect := ClientRect;
    if BorderWidth > 0 then
    begin
      CalcRect := Rect;
      InflateRect(CalcRect, -(BorderWidth div 2), -(BorderWidth div 2));
      Pen.Width := BorderWidth;
      Pen.Color := BorderColor;
      Rectangle(CalcRect);
      InflateRect(Rect, -BorderWidth, -BorderWidth);
    end;

    Brush.Style := bsClear;
    { DoDrawText takes care of BiDi alignments }
    DrawStyle := DT_EXPANDTABS or WordWraps[FWordWrap] or Alignments[FAlignment];
    { Calculate vertical layout }
    if FLayout <> tlTop then
    begin
      CalcRect := Rect;
      DoDrawText(CalcRect, DrawStyle or DT_CALCRECT);
      if FLayout = tlBottom then
        OffsetRect(Rect, 0, Rect.Bottom - (CalcRect.Bottom))
      else
        OffsetRect(Rect, 0, (Rect.Bottom - CalcRect.Bottom) div 2);
    end;
    DoDrawText(Rect, DrawStyle);
  end;
end;

procedure TaCustomOPCLabel.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    AdjustBounds;
  end;
end;

procedure TaCustomOPCLabel.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
end;

procedure TaCustomOPCLabel.SetBorderWidth(const Value: TBorderWidth);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
  ChangeData(Self);
end;

procedure TaCustomOPCLabel.SetFocusControl(Value: TWinControl);
begin
  FFocusControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TaCustomOPCLabel.SetInteractiveFont(const Value: TFont);
begin
  FInteractiveFont.Assign(Value);
end;

procedure TaCustomOPCLabel.SetLayout(Value: TTextLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
  ChangeData(Self);
end;

procedure TaCustomOPCLabel.SetRotationAngle(const Value: Integer);
begin
  if FRotationAngle <> Value then
  begin
    FRotationAngle := Value;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.SetShowAccelChar(Value: Boolean);
begin
  if FShowAccelChar <> Value then
  begin
    FShowAccelChar := Value;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.SetShowError(const Value: Boolean);
begin
  FShowError := Value;
  ChangeData(Self);
end;

procedure TaCustomOPCLabel.SetTransparent(Value: Boolean);
begin
  if Transparent <> Value then
  begin
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
  FTransparentSet := True;
end;

procedure TaCustomOPCLabel.SetTrim(const Value: Boolean);
begin
  FTrim := Value;
  ChangeData(Self);
end;

procedure TaCustomOPCLabel.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TaCustomOPCLabel.UpdateOriginalPosition;
begin
  inherited;
  OriginalInteractiveFontSize := InteractiveFont.Size;
end;

{ TaOPCBlinkThread }

procedure TaOPCBlinkThread.Execute;
const
  MinSleepInterval = 10;
var
  i: Integer;
  BlinkCount: Integer;
begin
  BlinkCount := 0;
  Owner.FBlink := True;
  while not Terminated do
  begin
    if Owner.BlinkOptions <> [] then
      Owner.FInBlink := not Owner.FInBlink;

    Owner.Invalidate;
    Owner.AdjustBounds;

    Inc(BlinkCount);
    if (Owner.BlinkCount > 0) and ((BlinkCount div 2) >= Owner.BlinkCount) then
      Break;

    for i := 1 to Owner.BlinkInterval div MinSleepInterval do
      if Terminated then
        Break
      else
        Sleep(MinSleepInterval);
  end;
  Owner.FInBlink := False;
  Owner.Invalidate;
  Owner.AdjustBounds;
  Owner.FBlink := False;
end;

procedure TaOPCBlinkThread.SetOwner(const Value: TaOPCBlinkLabel);
begin
  FOwner := Value;
end;

{ TaOPCBlinkLabel }

procedure TaOPCBlinkLabel.AssignTo(Dest: TPersistent);
var
  D: TaOPCBlinkLabel;
begin
  inherited AssignTo(Dest);

  if Dest is TaOPCBlinkLabel then
  begin
    D := TaOPCBlinkLabel(Dest);
    D.Blink := Blink;
    D.BlinkInterval := BlinkInterval;
    D.BlinkCount := BlinkCount;
    D.BlinkOptions := BlinkOptions;
    D.BlinkText := BlinkText;
    D.BlinkFont.Assign(BlinkFont);
    D.BlinkColor := BlinkColor;
  end;
end;

constructor TaOPCBlinkLabel.Create(AOwner: TComponent);
begin
  inherited;
  FBlinkInterval := 1000;
  FBlinkOptions := [boText];
  FBlinkFont := TFont.Create;
  // FBlinkFont.Assign(Font);
  FBlinkColor := clRed;
  FBlinkText := '';
end;

destructor TaOPCBlinkLabel.Destroy;
begin
  if Assigned(FBlinkThread) then
    FBlinkThread.Terminate;
  FreeAndNil(FBlinkFont);

  inherited;
end;

procedure TaOPCBlinkLabel.DoDrawText(var Rect: TRect; Flags: Integer);
var
  Text: string;
  aHandled: Boolean;
begin
  if FInBlink and (boFont in BlinkOptions) then
    Canvas.Font := BlinkFont
  else
    Canvas.Font := Font;

  if (Flags and DT_CALCRECT <> 0) and ((Text = '') or FShowAccelChar and (Text[1] = '&') and (Text[2] = #0)) then
    Text := Text + ' ';

  if FInBlink and (boText in BlinkOptions) then
    Text := BlinkText
  else
    Text := GetLabelText;

  if not FShowAccelChar then
    Flags := Flags or DT_NOPREFIX;
  Flags := DrawTextBiDiModeFlags(Flags);

  if Assigned(OnDrawLabel) then
  begin
    aHandled := False;
    OnDrawLabel(Self, Canvas, Text, aHandled);
    if aHandled then
      Exit;
  end;

  if not Enabled then
  begin
    OffsetRect(Rect, 1, 1);
    Canvas.Font.Color := clBtnHighlight;
    DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
    OffsetRect(Rect, -1, -1);
    Canvas.Font.Color := clBtnShadow;
    DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
  end
  else
    DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
end;

procedure TaOPCBlinkLabel.Paint;
const
  Alignments: array [TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  WordWraps: array [Boolean] of Word = (0, DT_WORDBREAK);
var
  Rect, CalcRect: TRect;
  DrawStyle: Longint;
begin
  with Canvas do
  begin
    if not Transparent then
    begin
      if FInBlink and (boColor in BlinkOptions) then
        Brush.Color := BlinkColor
      else
        Brush.Color := Self.Color;

      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;

    Rect := ClientRect;
    if BorderWidth > 0 then
    begin
      CalcRect := Rect;
      InflateRect(CalcRect, -(BorderWidth div 2), -(BorderWidth div 2));
      Pen.Width := BorderWidth;
      Rectangle(CalcRect);
      InflateRect(Rect, -BorderWidth, -BorderWidth);
    end;

    Brush.Style := bsClear;
    { DoDrawText takes care of BiDi alignments }
    DrawStyle := DT_EXPANDTABS or WordWraps[FWordWrap] or Alignments[FAlignment];
    { Calculate vertical layout }
    if FLayout <> tlTop then
    begin
      CalcRect := Rect;
      DoDrawText(CalcRect, DrawStyle or DT_CALCRECT);
      if FLayout = tlBottom then
        OffsetRect(Rect, 0, Rect.Bottom - (CalcRect.Bottom))
      else
        OffsetRect(Rect, 0, (Rect.Bottom - CalcRect.Bottom) div 2);
    end;
    DoDrawText(Rect, DrawStyle);
  end;
end;

procedure TaOPCBlinkLabel.SetBlink(const Value: Boolean);
begin
  if Value = FBlink then
    Exit;

  if Value then
  begin
    FBlinkThread := TaOPCBlinkThread.Create(True);
    FBlinkThread.FreeOnTerminate := True;
    FBlinkThread.Owner := Self;
    // FBlinkThread.Resume;
    FBlinkThread.Start;
  end
  else
  begin
    if Assigned(FBlinkThread) then
    begin
      FBlinkThread.Terminate;
      FBlinkThread := nil;
    end;
  end;

  FBlink := Value;

end;

procedure TaOPCBlinkLabel.SetBlinkColor(const Value: TColor);
begin
  FBlinkColor := Value;
end;

procedure TaOPCBlinkLabel.SetBlinkCount(const Value: Integer);
begin
  FBlinkCount := Value;
end;

procedure TaOPCBlinkLabel.SetBlinkFont(const Value: TFont);
begin
  FBlinkFont.Assign(Value);
end;

procedure TaOPCBlinkLabel.SetBlinkInterval(const Value: Integer);
begin
  FBlinkInterval := Value;
end;

procedure TaOPCBlinkLabel.SetBlinkOptions(const Value: TBlinkOptions);
begin
  FBlinkOptions := Value;
end;

procedure TaOPCBlinkLabel.SetBlinkText(const Value: TCaption);
begin
  FBlinkText := Value;
end;

{ TaOPCColorLabel }

function TaOPCColorLabel.CalcColor: TColor;
var
  i: Integer;
  extV, Key, LastKey: Extended;
begin
  Result := -1;

  try
    if ((ErrorCode <> 0) or (ErrorString <> '')) and (ErrorColor > -1) then
      Result := ErrorColor

    else if Colors.Count = 0 then
      Result := StrToInt(Value)
    else
    begin
      try
        extV := StrToFloat(Value);
        LastKey := StrToFloat(Colors.Names[0]);

        for i := 1 to Colors.Count - 1 do
        begin
          try
            Key := StrToFloat(Colors.Names[i]);
            if (LastKey <= extV) and (extV < Key) then
            begin
              Result := StringToColor(Colors.ValueFromIndex[i - 1]);
              Break;
            end;
            LastKey := Key;
          except
            on e: exception do;
          end;
        end;
        if (Result < 0) and (extV >= LastKey) then
          Result := StringToColor(Colors.ValueFromIndex[Colors.Count - 1]);
      except
        on e: exception do;
      end;
    end;
  except
    on e: exception do;
  end;
end;

procedure TaOPCColorLabel.ChangeData(Sender: TObject);
begin
  if ShowValue then
  begin
    inherited
  end

  else
  begin
    UpdateDataLinks;
    Hint := CalcHint;

    if Assigned(OnChange) and (not(csLoading in ComponentState)) and (not(csDestroying in ComponentState)) then
      OnChange(Self);

    RepaintRequest(Self);
  end;
end;

constructor TaOPCColorLabel.Create(AOwner: TComponent);
begin
  inherited;
  Transparent := False;
  ParentColor := False;
  FColors := TStringList.Create;
end;

destructor TaOPCColorLabel.Destroy;
begin
  FColors.Free;
  inherited;
end;

procedure TaOPCColorLabel.Paint;
var
  aColor: TColor;
begin
  aColor := CalcColor;
  if aColor <> -1 then
    Color := aColor;
  // Canvas.Brush.Color := aColor;

  inherited;
end;

procedure TaOPCColorLabel.SetErrorColor(const Value: TColor);
begin
  FErrorColor := Value;
end;

procedure TaOPCColorLabel.SetShowValue(const Value: Boolean);
begin
  FShowValue := Value;
end;

procedure TaOPCColorLabel.SetColors(const Value: TStrings);
var
  i: Integer;
begin
  FColors.Assign(Value);

  while (FColors.Count > 0) and (FColors.Strings[FColors.Count - 1] = '') do
    FColors.Delete(FColors.Count - 1);

  for i := 0 to FColors.Count - 1 do
    FColors.Strings[i] := SysUtils.Trim(FColors.Names[i]) + '=' + SysUtils.Trim(FColors.ValueFromIndex[i]);

end;

end.
