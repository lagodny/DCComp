unit DC.FastSeries;

interface

uses
  System.Classes,
  VCLTee.Chart, VCLTee.Series,
  DC.SeriesAdapter, DC.SeriesAdapterIntf;

type
  TDCFastLineSeries = class(TFastLineSeries, IDCSeriesAdapter)
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
  TeeMsg_GalleryDCFastLine: string;

implementation

{ TDCFastLineSeries }

constructor TDCFastLineSeries.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  // максимальна эфективність
  DrawAllPoints := False;
  DrawAllPointsStyle := daMinMax;
  // створюємо Адаптер, через який будемо виконувати всі команди та налаштування
  FDCAdapter := TDCSeriesAdapter.Create(Self);
end;

destructor TDCFastLineSeries.Destroy;
begin
  FDCAdapter.Free;
  inherited;
end;

function TDCFastLineSeries.GetDCAdapter: TDCSeriesAdapter;
begin
  Result := FDCAdapter;
end;

procedure TDCFastLineSeries.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  DCAdapter.Notification(AComponent, Operation);
end;

procedure TDCFastLineSeries.SetDCAdapter(const Value: TDCSeriesAdapter);
begin
  FDCAdapter.Assign(Value);
end;

initialization
  TeeMsg_GalleryDCFastLine := 'DC fast line';
  RegisterTeeSeries(TDCFastLineSeries, @TeeMsg_GalleryDCFastLine);


end.
