unit aOPCFastSeries;

interface

uses
  Windows, Forms, SysUtils, Classes, Controls, StdCtrls, Graphics,
  VCLTee.Chart, VCLTee.Series, VCLTee.TeEngine,
  aOPCUtils, aCustomOPCSource, aOPCSource, aOPCLookupList, uDCObjects,
  aOPCSeries,
  uChoiceIntervalExt, uOPCInterval,
  uOPCSeriesTypes,
  uOPCFilter,
  uOPCSeriesAdapter, uOPCSeriesAdapterIntf;

type
  TaOPCFastLineSeries = class(TFastLineSeries, IOPCSeriesAdapter)
  private
    FOPCAdapter: TOPCSeriesAdapter;
    function GetOPCAdapter: TOPCSeriesAdapter;
    procedure SetOPCAdapter(const Value: TOPCSeriesAdapter);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OPCAdapter: TOPCSeriesAdapter read GetOPCAdapter write SetOPCAdapter;
  end;

var
  TeeMsg_GalleryOPCFastLine: string;

implementation

{ TaOPCFastLineSeries }

constructor TaOPCFastLineSeries.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  // максимальна эфективність
  DrawAllPoints := False;
  DrawAllPointsStyle := daMinMax;
  // створюємо Адаптер, через який будемо виконувати всі команди та налаштування
  FOPCAdapter := TOPCSeriesAdapter.Create(Self);
end;

destructor TaOPCFastLineSeries.Destroy;
begin
  FOPCAdapter.Free;
  inherited;
end;

function TaOPCFastLineSeries.GetOPCAdapter: TOPCSeriesAdapter;
begin
  Result := FOPCAdapter;
end;

procedure TaOPCFastLineSeries.SetOPCAdapter(const Value: TOPCSeriesAdapter);
begin
  FOPCAdapter.Assign(Value);
end;

initialization
  TeeMsg_GalleryOPCFastLine := 'OPC fast line';
  RegisterTeeSeries(TaOPCFastLineSeries, @TeeMsg_GalleryOPCFastLine);


end.
