unit DC.LineSeries;

interface

uses
  System.Classes,
  VCLTee.Chart, VCLTee.Series,
  DC.SeriesAdapter, DC.SeriesAdapterIntf;

type
  TDCLineSeries = class(TLineSeries, IDCSeriesAdapter)
  private
    FDCAdapter: TDCSeriesAdapter;
    function GetDCAdapter: TDCSeriesAdapter;
    procedure SetDCAdapter(const Value: TDCSeriesAdapter);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DCAdapter: TDCSeriesAdapter read GetDCAdapter write SetDCAdapter;
  end;

var
  TeeMsg_GalleryDCLine: string;

implementation

{ TDCFastLineSeries }

constructor TDCLineSeries.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
//  // максимальна эфективність
//  DrawAllPoints := False;
//  DrawAllPointsStyle := daMinMax;
  // створюємо Адаптер, через який будемо виконувати всі команди та налаштування
  FDCAdapter := TDCSeriesAdapter.Create(Self);
end;

destructor TDCLineSeries.Destroy;
begin
  FDCAdapter.Free;
  inherited;
end;

function TDCLineSeries.GetDCAdapter: TDCSeriesAdapter;
begin
  Result := FDCAdapter;
end;

procedure TDCLineSeries.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  DCAdapter.Notification(AComponent, Operation);
end;

procedure TDCLineSeries.SetDCAdapter(const Value: TDCSeriesAdapter);
begin
  FDCAdapter.Assign(Value);
end;

initialization
  TeeMsg_GalleryDCLine := 'DC line';
  RegisterTeeSeries(TDCLineSeries, @TeeMsg_GalleryDCLine);


end.
