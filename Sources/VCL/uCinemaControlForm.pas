unit uCinemaControlForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uCinemaControl;

type
  TCinemaControlForm = class(TForm)
    aOPCCinemaControl1: TaOPCCinemaControl;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CinemaControlForm: TCinemaControlForm;

implementation

uses
  Math;

{$R *.dfm}

procedure TCinemaControlForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    if Assigned(aOPCCinemaControl1) and Assigned(aOPCCinemaControl1.OPCCinema) then
    begin
//      aOPCCinemaControl1.OPCCinema.OPCSource.Active := false;
      aOPCCinemaControl1.OPCCinema.DisconnectOPCSourceDataLinks;
//      aOPCCinemaControl1.OPCCinema.OPCSource.Active := true;
    end;
  except
  end;
  CinemaControlForm := nil;
  Action := caFree;
end;

procedure TCinemaControlForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  //AlphaBlendValue := Max(AlphaBlendValue - 5, 20);
end;

procedure TCinemaControlForm.FormMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  //AlphaBlendValue := Min(AlphaBlendValue + 5, 255);
end;

procedure TCinemaControlForm.FormShow(Sender: TObject);
begin
  if aOPCCinemaControl1.SelectInterval then
    aOPCCinemaControl1.FillHistory
  else
    Close;

end;

end.
