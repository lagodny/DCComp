unit uOPCSeriesAdapterIntf;

interface

uses
  uOPCSeriesAdapter;

type
  IOPCSeriesAdapter = interface
  ['{77D53E2E-06F7-4B73-A041-3A93CCAA78FE}']
    function GetOPCAdapter: TOPCSeriesAdapter;
    property OPCAdapter: TOPCSeriesAdapter read GetOPCAdapter;
  end;


implementation

end.
