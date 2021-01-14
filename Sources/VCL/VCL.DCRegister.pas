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
  uChartFrame,
  uCinemaControl;


procedure Register;
begin
  RegisterComponents('DC Controls', [TaOPCLabel]);
  RegisterComponents('DC Controls', [TaOPCStateLine]);
  RegisterComponents('DC Controls', [TaOPCChart]);
  RegisterComponents('DC Controls', [TChartFrame]);
  RegisterComponents('DC Controls', [TaOPCCinemaControl]);

end;

end.
