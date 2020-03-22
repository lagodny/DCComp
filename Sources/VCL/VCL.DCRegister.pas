unit VCL.DCRegister;

interface

uses
  Classes;

procedure Register;

implementation

uses
  aOPCLabel,
  aOPCStateLine,
  aOPCChart,
  uChartFrame;


procedure Register;
begin
  RegisterComponents('DC Controls', [TaOPCLabel]);
  RegisterComponents('DC Controls', [TaOPCStateLine]);
  RegisterComponents('DC Controls', [TaOPCChart]);
  RegisterComponents('DC Controls', [TChartFrame]);

end;

end.
