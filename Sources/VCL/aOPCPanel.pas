unit aOPCPanel;

interface
uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TaOPCPanel = class(TPanel)
  private
    OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight: integer;
  protected
    Scale : extended;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer); override;
  public
    procedure UpdateOriginalPosition;
  published
    { Published declarations }
  end;

implementation

uses
  Math;

{ TaOPCPanel }

procedure TaOPCPanel.ChangeScale(M, D: Integer);
var
  i: Integer;
begin
  inherited ChangeScale(M, D);

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
//  for i := 0 to ControlCount - 1 do
//    Controls[i].
end;

procedure TaOPCPanel.Loaded;
begin
  inherited;
  UpdateOriginalPosition;
end;

procedure TaOPCPanel.UpdateOriginalPosition;
begin
  OriginalLeft := Left;
  OriginalTop  := Top;
  OriginalWidth := Width;
  OriginalHeight := Height;
  Scale := 1;
end;

end.
