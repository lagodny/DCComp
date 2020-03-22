{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2013 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aOPCImage;

{$I VCL.DC.inc}

interface

uses
  SysUtils, Windows, Messages, Classes,
  Graphics, Controls, Forms, Dialogs
{$IFDEF GIF}
  //, GifImage
  ,Vcl.Imaging.GIFImg
{$ENDIF}
{$IFDEF TNG}
  , NGImages
{$ENDIF}
{$IFDEF JPEG}
  , Jpeg
{$ENDIF}
  , Vcl.Imaging.pngimage
  , aOPCDataObject, aOPCImageList;

type
  TaOPCPen = class(TPen)
    property Width default 0;
  end;

  TaOPCImage = class(TaCustomOPCDataObject)
  private
    FDrawing: Boolean;
    FImageChangeLink: TOPCImageListChangeLink;
    FOPCImageList: TaOPCImageList;
    FStretch: Boolean;
    FProportional: Boolean;
    FCenter: Boolean;
    FStates: Tstrings;
    FDiscrete: Boolean;
    FImageIndex: integer;

    // animated Gif
//    FGifImage  : TGifImage;   //for designe time
{$IFDEF TNG}
    FMNGImage: TNGImage;
{$ENDIF}
{$IFDEF GIF}
    //FGifPainter: TGIFPainter;
    FGifImage: TGIFImage;
{$ENDIF}
    FLoop: boolean;
    FSaveAnimate: boolean;
    FAnimate: boolean;
    FTile: boolean;
    FErrorImageIndex: integer;

    FBorder: TaOPCPen;

    procedure SetTile(const Value: boolean);
    procedure SetAnimate(const Value: boolean);
    procedure SetLoop(const Value: boolean);

    procedure ImageListChange(Sender: TObject);
    procedure ImageListPictureChange(Sender: TObject; aItem: TPictureCollectionItem);

    procedure DestroyPainter;

    function GetOPCImageList: TaOPCImageList;
    function CalcImageIndex: integer;
    procedure SetOPCImageList(const Value: TaOPCImageList);
    function GetPicture: TPicture;
    procedure SetStretch(const Value: Boolean);
    procedure SetProportional(const Value: Boolean);
    procedure SetCenter(const Value: Boolean);
    procedure SetStates(const Value: Tstrings);
    procedure SetDiscrete(const Value: Boolean);
    procedure SetErrorImageIndex(const Value: integer);
    procedure SetBorder(const Value: TaOPCPen);
    procedure StyleChanged(Sender: TObject);
  protected
    procedure CreateGif;

    function DestRect: TRect;
    function DoPaletteChange: Boolean;

    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure SetParent(AParent: TWinControl); override;

    procedure DoPictureChanged(Sender: TObject);
    procedure RepaintRequest(Sender: TObject); override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure Paint; override;

    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
  public
    procedure PictureChanged; virtual;

    property Picture: TPicture read GetPicture;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Interactive;

    property Height;
    property Width;
    property AutoSize;
    property ImageIndex: integer read FImageIndex stored false;
    property Discrete: Boolean read FDiscrete write SetDiscrete default true;
    property Proportional: Boolean read FProportional write SetProportional default false;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Center: Boolean read FCenter write SetCenter default False;
    property OPCImageList: TaOPCImageList read GetOPCImageList write SetOPCImageList;
    property States: TStrings read FStates write SetStates;
    property ErrorImageIndex: integer read FErrorImageIndex write SetErrorImageIndex default -1;
    property Animate: boolean read FAnimate write SetAnimate default true;
    property Loop: boolean read FLoop write SetLoop default true;
    property Tile: boolean read FTile write SetTile default false;

    property Border: TaOPCPen read FBorder write SetBorder;
  end;

var
  tstDesigne: boolean;

implementation

uses aCustomOPCSource;

{ TaOPCImage }

function TaOPCImage.CalcImageIndex: integer;
var
  i: integer;
  extV, Key, LastKey: extended;
begin
  Result := -1;
  if OPCImageList <> nil then
  begin
    try
      if ((ErrorCode <> 0) or (ErrorString <> '')) and (ErrorImageIndex > -1) then
      //if (ErrorString <> '') and (ErrorImageIndex > -1) then
        Result := ErrorImageIndex
      else if States.Count = 0 then
        Result := StrToInt(Value)
      else
      begin
        if Discrete then
          Result := StrToInt(States.Values[Value])
        else
        begin
          try
            extV := StrToFloat(Value);
            LastKey := StrToFloat(States.Names[0]);

            for i := 1 to States.Count - 1 do
            begin
              try
                Key := StrToFloat(States.Names[i]);
                if (LastKey <= extV) and (extV < Key) then
                begin
                  Result := StrToInt(States.ValueFromIndex[i - 1]);
                  break;
                end;
                LastKey := Key;
              except
                on e: exception do
                  ;
              end;
            end;
            if (Result < 0) and (extV >= LastKey) then
              Result := StrToInt(States.ValueFromIndex[States.Count - 1]);
          except
            on e: exception do
              ;
          end;
        end;
      end;

      if Result >= FOPCImageList.Items.Count then
        Result := -1;
    except
      on e: Exception do
        ;
    end;
  end;

end;

function TaOPCImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if (Picture <> nil) and
    (not (csDesigning in ComponentState) or
    (Picture.Width > 0) and
    (Picture.Height > 0)) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := Picture.Width;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := Picture.Height;
  end;

end;

constructor TaOPCImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDiscrete := true;

  FImageIndex := -1;
  FErrorImageIndex := -1;
  FStates := TStringList.Create;
  SetBounds(Left, Top, 100, 100);

{$IFDEF GIF}
  //FGifPainter := nil;
  FGifImage := nil;
{$ENDIF}
{$IFDEF TNG}
  FMNGImage := nil;
{$ENDIF}

  FAnimate := true;
  FLoop := true;
  FTile := false;

  FImageChangeLink := TOPCImageListChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FImageChangeLink.BeforChangePicture := ImageListPictureChange;

  FBorder := TaOPCPen.Create;
  FBorder.Width := 0;
  Fborder.OnChange := StyleChanged;

  //SetSubComponent(True);


end;

procedure TaOPCImage.CreateGif;
begin
  FreeAndNil(FGifImage);

  FGifImage := TGIFImage.Create;
  FGifImage.Assign(Picture.Graphic);

  FGifImage.OnChange := DoPictureChanged;

  FGifImage.Transparent := FOPCImageList.Items[FImageIndex].Transparent;
  FGifImage.BackgroundColor := FOPCImageList.Items[FImageIndex].TransparentColor;

  FGifImage.Animate := Animate;

  if Loop then
    FGifImage.AnimateLoop := glEnabled
  else
    FGifImage.AnimateLoop := glDisabled;

end;

function TaOPCImage.DestRect: TRect;
var
  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
  if Picture = nil then
  begin
    DestRect := ClientRect;
    exit;
  end;
  w := Picture.Width;
  h := Picture.Height;
  cw := ClientWidth;
  ch := ClientHeight;
  if Stretch or (Proportional and ((w > cw) or (h > ch))) then
  begin
    if Proportional and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
      begin
        w := cw;
        h := Trunc(cw / xyaspect);
        if h > ch then // woops, too big
        begin
          h := ch;
          w := Trunc(ch * xyaspect);
        end;
      end
      else
      begin
        h := ch;
        w := Trunc(ch * xyaspect);
        if w > cw then // woops, too big
        begin
          w := cw;
          h := Trunc(cw / xyaspect);
        end;
      end;
    end
    else
    begin
      w := cw;
      h := ch;
    end;
  end;

  with Result do
  begin
    Left := 0;
    Top := 0;
    Right := w;
    Bottom := h;
  end;

  if Center then
    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
end;

destructor TaOPCImage.Destroy;
begin
  OPCImageList := nil;

  DestroyPainter;

  FStates.Free;
  FreeAndNil(FImageChangeLink);

  FBorder.Free;

  inherited;
end;

procedure TaOPCImage.DestroyPainter;
begin
{$IFDEF TNG}
  FreeAndNil(FMNGImage);
{$ENDIF}
{$IFDEF GIF}
  FreeAndNil(FGifImage);
{$ENDIF}
end;

procedure TaOPCImage.DoMouseEnter;
begin
  if Interactive then
  begin
    FSaveAnimate := Animate;
    Animate := false;
    Invalidate;
  end;
end;

procedure TaOPCImage.DoMouseLeave;
begin
  if Interactive then
  begin
    Animate := FSaveAnimate;
    Invalidate;
  end;
end;

function TaOPCImage.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := Picture.Graphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil) and
    (Tmp.PaletteModified) then
  begin
    if (Tmp.Palette = 0) then
      Tmp.PaletteModified := False
    else
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and
        Parentform.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(wm_QueryNewPalette, 0, 0)
        else
          PostMessage(ParentForm.Handle, wm_QueryNewPalette, 0, 0);
        Result := True;
        Tmp.PaletteModified := False;
      end;
    end;
  end;
end;

procedure TaOPCImage.DoPictureChanged(Sender: TObject);
begin
  Invalidate;
end;

function TaOPCImage.GetOPCImageList: TaOPCImageList;
begin
  Result := FOPCImageList;
end;

function TaOPCImage.GetPicture: TPicture;
begin
  if (OPCImageList = nil) or (FImageIndex < 0) then
    Result := nil
  else
  begin
    if (FImageIndex > OPCImageList.Items.Count - 1) then
      FImageIndex := CalcImageIndex;
    if FImageIndex >= 0 then
      Result := OPCImageList.Items[ImageIndex].Picture
    else
      Result := nil;
  end;
end;

procedure TaOPCImage.ImageListChange(Sender: TObject);
begin
  FImageIndex := CalcImageIndex;
  PictureChanged;
  Repaint;
end;

procedure TaOPCImage.ImageListPictureChange(Sender: TObject;
  aItem: TPictureCollectionItem);
begin
  if aItem.Picture = Picture then
  begin
    DestroyPainter;
  end;
end;

procedure TaOPCImage.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and
    ((OPCImageList = AComponent)) then
  begin
    DestroyPainter;
    FImageIndex := -1;
    OPCImageList := nil;
    PictureChanged;
  end;
end;

procedure TaOPCImage.Paint;
var
  Save: Boolean;
  X, Y, W, H, S: Integer;

//{$IFDEF TNG}
  b: TBitmap;
//{$ENDIF}
begin
  if Assigned(Picture) then
  begin
    Save := FDrawing;
    FDrawing := True;
    try
{$IFDEF GIF}
      if (Picture.Graphic is TGIFImage) then
      begin
        if (not Assigned(FGIFImage)) then
          CreateGif;

        Canvas.StretchDraw(DestRect, FGIFImage);
      end
      else
{$ENDIF}
{$IFDEF TNG}if (Picture.Graphic is TNGImage) then
        begin
          if (not Assigned(FMNGImage)) then
          begin
            if Animate then
            begin
              FMNGImage := TMNGImage.Create;
              FMNGImage.Assign(Picture.Graphic);
              Canvas.StretchDraw(DestRect, FMNGImage);
            end
            else
            begin
              b := TMNGImage(Picture.Graphic).CopyBitmap;
              try
                Canvas.StretchDraw(DestRect, b);
              finally
                b.Free;
              end;
            end;
          end
          else
          begin

          end
        end
        else
{$ENDIF}
          Canvas.StretchDraw(DestRect, Picture.Graphic);

    finally
      FDrawing := Save;
    end;
  end
  else
  begin
    if (csDesigning in ComponentState) or tstDesigne then
      with Canvas do
      begin
        Pen.Style := psDash;
        Brush.Style := bsClear;
        Rectangle(0, 0, Width, Height);
      end;
  end;

  if Border.Width > 0 then
  begin
    with Canvas do
    begin
      Pen := FBorder;
      Brush.Style := bsClear;

      X := Pen.Width div 2;
      Y := X;
      W := Width - Pen.Width + 1;
      H := Height - Pen.Width + 1;

      if W < H then
        S := W
      else
        S := H;

      Rectangle(X, Y, X + W, Y + H);
    end;
  end;

  if Interactive and MouseInSide then
    with Canvas do
    begin
      Pen.Color := clWhite;
      Pen.Style := psDot;
      Pen.Mode := pmNot;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;

end;

procedure TaOPCImage.PictureChanged;
var
  G: TGraphic;
  D: TRect;
  FTransparent: boolean;
  //SaveImageIndex: integer;
begin
  DestroyPainter;

  if Picture <> nil then
  begin
    if AutoSize then
      SetBounds(Left, Top, Picture.Width, Picture.Height);

    FTransparent := FOPCImageList.Items[FImageIndex].Transparent;
    G := Picture.Graphic;
    if G <> nil then
    begin
      if not ((G is TMetaFile) or (G is TIcon)) then
      begin
        G.Transparent := FTransparent;
{$IFDEF GIF}
        if G is TGIFImage then
        begin
          CreateGif;
        end
        else
{$ENDIF}
{$IFDEF TNG}if G is TNGImage then
          begin
            if not Animate then
            begin
              exit;
            end
            else
            begin
              FMNGImage := TMNGImage.Create;

              FMNGImage.Assign(Picture.Graphic);
              //FMNGImage := Picture.Graphic;

              FMNGImage.Transparent := FOPCImageList.Items[FImageIndex].Transparent;
              FMNGImage.TransparentColor := FOPCImageList.Items[FImageIndex].TransparentColor;

              FMNGImage.Draw(Canvas, DestRect);

            end;
          end;
{$ENDIF}
        if G is TBitmap then
          (G as TBitmap).TransparentColor :=
            FOPCImageList.Items[FImageIndex].TransparentColor;
      end;

      D := DestRect;
      if (not G.Transparent) and (D.Left <= 0) and (D.Top <= 0) and
        (D.Right >= Width) and (D.Bottom >= Height) then
        ControlStyle := ControlStyle + [csOpaque]
      else // picture might not cover entire clientrect
        ControlStyle := ControlStyle - [csOpaque];
      //if DoPaletteChange and FDrawing then Update;
    end
    else
      ControlStyle := ControlStyle - [csOpaque];
  end;
  Invalidate;
end;

procedure TaOPCImage.RepaintRequest(Sender: TObject);
var
  tmpImageIndex: integer;
begin
  tmpImageIndex := CalcImageIndex;
  if tmpImageIndex <> ImageIndex then
  begin
    FImageIndex := tmpImageIndex;
    PictureChanged;
  end;
end;

procedure TaOPCImage.SetAnimate(const Value: boolean);
begin
  FAnimate := Value;
  PictureChanged;
end;

procedure TaOPCImage.SetBorder(const Value: TaOPCPen);
begin
  FBorder.Assign(Value);
end;

procedure TaOPCImage.SetCenter(const Value: Boolean);
begin
  if FCenter <> Value then
  begin
    FCenter := Value;
    PictureChanged;
  end;
end;

procedure TaOPCImage.SetDiscrete(const Value: Boolean);
begin
  if FDiscrete <> Value then
  begin
    FDiscrete := Value;
    ChangeData(self);
  end;
end;

procedure TaOPCImage.SetErrorImageIndex(const Value: integer);
begin
  FErrorImageIndex := Value;
end;

procedure TaOPCImage.SetLoop(const Value: boolean);
begin
  FLoop := Value;
  PictureChanged;
end;

procedure TaOPCImage.SetOPCImageList(const Value: TaOPCImageList);
begin
  if FOPCImageList <> Value then
  begin
    if Assigned(FOPCImageList) then
    begin
      FOPCImageList.RemoveFreeNotification(self);
      FOPCImageList.UnRegisterChanges(FImageChangeLink);
    end;
    if Assigned(Value) then
    begin
      Value.FreeNotification(Self);
      Value.RegisterChanges(FImageChangeLink);
    end;

    FOPCImageList := Value;
    FImageIndex := CalcImageIndex;
    PictureChanged;
    Repaint;
  end;
end;

procedure TaOPCImage.SetParent(AParent: TWinControl);
begin
  inherited;
  PictureChanged;
end;

procedure TaOPCImage.SetProportional(const Value: Boolean);
begin
  if FProportional <> Value then
  begin
    FProportional := Value;
    PictureChanged;
  end;
end;

procedure TaOPCImage.SetStates(const Value: Tstrings);
var
  i: Integer;
begin
  FStates.Assign(Value);
  while (FStates.Count > 0) and (FStates.Strings[FStates.Count - 1] = '') do
    FStates.Delete(FStates.Count - 1);
  for i := 0 to FStates.Count - 1 do
    FStates.Strings[i] :=
      Trim(FStates.Names[i]) + '=' + Trim(FStates.ValueFromIndex[i]);

end;

procedure TaOPCImage.SetStretch(const Value: Boolean);
begin
  if Value <> FStretch then
  begin
    FStretch := Value;
    PictureChanged;
  end;
end;

procedure TaOPCImage.SetTile(const Value: boolean);
begin
  FTile := Value;
  PictureChanged;
end;

procedure TaOPCImage.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

end.

