unit uCinemaFillHistoryProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, aOPCCinema;

const
  am_StartFill    = wm_User+10;

type
  TFillHistoryProgress = class(TForm)
    ProgressBar1: TProgressBar;
    bCancel: TButton;
    procedure FormActivate(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
  private
    PressCancel:boolean;
    procedure AMStartFill(var Message:TMessage);message am_StartFill;
    procedure StartFill;
  public
    OPCCinema : TaOPCCinema;
    procedure FillHistory(var StopFill:boolean;Progress:integer);
  end;

var
  FillHistoryProgress: TFillHistoryProgress;

implementation

{$R *.dfm}

procedure TFillHistoryProgress.FillHistory(var StopFill: boolean;
  Progress: integer);
begin
  ProgressBar1.Position := Progress;
  Application.ProcessMessages;
  //sleep(100);
  StopFill := PressCancel;
end;

procedure TFillHistoryProgress.bCancelClick(Sender: TObject);
begin
  PressCancel := true;
end;

procedure TFillHistoryProgress.AMStartFill(var Message: TMessage);
begin
  StartFill;
end;

procedure TFillHistoryProgress.FormActivate(Sender: TObject);
begin
  StartFill;
end;

procedure TFillHistoryProgress.StartFill;
var
  OldFHP:TFillHistoryEvent;
begin
  if not Assigned(OPCCinema) then
  begin
    ModalResult := mrNone;
    exit;
  end;

  OldFHP := OPCCinema.OnFillHistory;
  try
    OPCCinema.OnFillHistory := FillHistory;
    OPCCinema.Active := true;
  finally
    OPCCinema.OnFillHistory := OldFHP;
  end;
  ModalResult := mrOk;
  PostMessage(Handle,WM_CLOSE,0,0);
end;

end.
