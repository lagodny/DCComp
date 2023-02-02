unit VCL.DCRegister;

interface

uses
  Classes;

procedure Register;

implementation

uses
  aOPCLabel,
  aOPCImage, aOPCImage2In,
  aOPCGauge,
  aOPCPanel,
  aOPCImageList,
  aOPCStateLine, aOPCShape,
  aOPCListBox,
  aOPCChart,
  uChartFrame,
  uCinemaControl,
  aOPCVerUpdater,
  aOPCAuthorization,

  uOPCFrame,
  ukzTempFrame;


procedure Register;
begin
  RegisterComponents('DC Controls', [TaOPCLabel, TaOPCColorLabel, TaOPCBlinkLabel]);
  RegisterComponents('DC Controls', [TaOPCImage, TaOPCImage2In]);
  RegisterComponents('DC Controls', [TaOPCImageList]);
  RegisterComponents('DC Controls', [TaOPCStateLine, TaOPCShape]);
  RegisterComponents('DC Controls', [TaOPCPanel]);
  RegisterComponents('DC Controls', [TaOPCGauge]);
  RegisterComponents('DC Controls', [TaOPCListBox]);

  RegisterComponents('DC Controls', [TaOPCChart]);
  RegisterComponents('DC Controls', [TChartFrame]);

  RegisterComponents('DC Controls', [TaOPCCinemaControl]);
  RegisterComponents('DC Controls', [TaOPCVerUpdater]);

  RegisterComponents('DC Controls', [TaOPCAuthorization]);

  RegisterComponents('DC Frames', [TkzTemp]);


end;

end.
