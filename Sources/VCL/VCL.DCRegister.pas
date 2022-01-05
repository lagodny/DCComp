unit VCL.DCRegister;

interface

uses
  Classes;

procedure Register;

implementation

uses
  aOPCLabel,
  aOPCImage, aOPCImageList,
  aOPCStateLine, aOPCShape,
  aOPCChart,
  uChartFrame,
  uCinemaControl,
  aOPCVerUpdater;


procedure Register;
begin
  RegisterComponents('DC Controls', [TaOPCLabel]);
  RegisterComponents('DC Controls', [TaOPCImage]);
  RegisterComponents('DC Controls', [TaOPCImageList]);
  RegisterComponents('DC Controls', [TaOPCStateLine, TaOPCShape]);
  RegisterComponents('DC Controls', [TaOPCChart]);
  RegisterComponents('DC Controls', [TChartFrame]);
  RegisterComponents('DC Controls', [TaOPCCinemaControl]);
  RegisterComponents('DC Controls', [TaOPCVerUpdater]);

end;

end.
