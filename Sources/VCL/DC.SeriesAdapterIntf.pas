unit DC.SeriesAdapterIntf;

interface

uses
  DC.SeriesAdapter;

type
  IDCSeriesAdapter = interface
  ['{77D53E2E-06F7-4B73-A041-3A93CCAA78FE}']
    function GetDCAdapter: TDCSeriesAdapter;
    property DCAdapter: TDCSeriesAdapter read GetDCAdapter;
  end;


implementation

end.
