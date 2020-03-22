unit uOPCSeriesTypes;

interface

uses
  Vcl.Graphics,
  aCustomOPCSource;

const
  cErrorSerieColor = clGray;

type
  TXY = record
    x: double;
    y: double;
  end;

  TXYS = record
    x: double;
    y: double;
    s: double;
    procedure Clear;
  end;

  TXYArray = array of TXY;

  TTransRec = record
    InValue, OutValue: extended;
  end;

  IaOPCSeries = interface
  ['{B6FF5AF6-0374-4BB2-9951-05851AB9D892}']
    function GetPhysID: TPhysID;
    function GetScale: Double;
    function GetShift: Double;
    function GetConnectionName: string;
    function GetOPCSource: TaCustomOPCSource;
    function GetFullName: string;
    function GetShortName: string;
    function GetShowFullName: boolean;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetScale(const Value: double);
    procedure SetShift(const Value: double);
    procedure SetConnectionName(const Value: string);
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    procedure SetFullName(const Value: string);
    procedure SetShortName(const Value: string);
    procedure SetShowFullName(const Value: boolean);

    procedure FillSerie(ToNow: boolean = false; aSourceValues: Boolean = False);
    procedure UpdateRealTime;

    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property Scale: double read GetScale write SetScale;
    property Shift: double read GetShift write SetShift;

    property OPCSource: TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property ConnectionName: string read GetConnectionName write SetConnectionName;

    property ShortName: string read GetShortName write SetShortName;
    property FullName: string read GetFullName write SetFullName;
    property ShowFullName: boolean read GetShowFullName write SetShowFullName;

  end;

  function GetXYSRec(x, y, s: double): TXYS;



implementation


function GetXYSRec(x, y, s: double): TXYS;
begin
  Result.x := x;
  Result.y := y;
  Result.s := s;
end;

{ TXYS }

procedure TXYS.Clear;
begin
  x := 0;
  y := 0;
  s := 0;
end;

end.
