unit FMX.DCRegister;

interface

uses
  Classes;

procedure Register;

implementation

uses
  FMX.DCLabel,
  FMX.DCChart;


procedure Register;
begin
  RegisterComponents('DC Controls', [TaOPCLabel]);
  RegisterComponents('DC Controls', [TaDCChart]);
end;

end.
