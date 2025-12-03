unit DC.SeriesTypes;

interface

type
  TXY = record
    x, y: Double;
  end;
  TXYArray = array of TXY;

  TXYS = record
    x, y, s: Double;
    procedure Clear;
  end;

  TTransRec = record
    InValue, OutValue: extended;
  end;

function GetXYSRec(x, y, s: double): TXYS;

implementation

{ TXYS }

procedure TXYS.Clear;
begin
  x := 0;
  y := 0;
  s := 0;
end;

function GetXYSRec(x, y, s: double): TXYS;
begin
  Result.x := x;
  Result.y := y;
  Result.s := s;
end;


end.
