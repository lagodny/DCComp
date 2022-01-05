unit aOPCShape;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TOPCShapeType = (ostNone, ostCross, ostDiagCross);

  TaOPCShape = class(TShape)
  private
    OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight: integer;
    FOPCShape: TOPCShapeType;
    procedure SetOPCShape(const Value: TOPCShapeType);
  protected
    Scale : extended;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer); override;

    procedure Paint; override;

  public
    procedure UpdateOriginalPosition;
  published
    property OPCShape: TOPCShapeType read FOPCShape write SetOPCShape default ostNone;
  end;

implementation

uses
  Math;

{ TaOPCShape }

procedure TaOPCShape.ChangeScale(M, D: Integer);
begin
  if M <> D then
  begin
    if SameValue(D/M,Scale,0.001) then
    begin
      Scale := 1;
      SetBounds(OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight);
    end
    else
    begin
      Scale := Scale * M/D;
      SetBounds(Round(OriginalLeft*Scale),Round(OriginalTop*Scale),
        Round(OriginalWidth*Scale),Round(OriginalHeight*Scale));
    end;
  end;
end;

procedure TaOPCShape.Loaded;
begin
  inherited;
  UpdateOriginalPosition;
end;

procedure TaOPCShape.Paint;
var
  X, Y, W, H: Integer;
begin
  if OPCShape = ostNone then
  begin
    inherited Paint;
    Exit;
  end;

  with Canvas do
  begin
    Pen := Self.Pen;
    Brush := Self.Brush;
    X := Pen.Width div 2;
    Y := X;
    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;

    case OPCShape of
      ostCross:
      begin
        MoveTo(X, Y + H div 2);
        LineTo(X + W, Y + H div 2);
        MoveTo(X + W div 2, Y);
        LineTo(X + W div 2, Y + H);
      end;
      ostDiagCross:
      begin
        MoveTo(X, Y);
        LineTo(X + W, Y + H);
        MoveTo(X + W, Y);
        LineTo(X, Y + H);
      end;
    end;
  end;
end;

procedure TaOPCShape.SetOPCShape(const Value: TOPCShapeType);
begin
  FOPCShape := Value;
  Invalidate;
end;

procedure TaOPCShape.UpdateOriginalPosition;
begin
  OriginalLeft := Left;
  OriginalTop  := Top;
  OriginalWidth := Width;
  OriginalHeight := Height;
  Scale := 1;
end;

end.
