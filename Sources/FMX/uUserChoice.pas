unit uUserChoice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.ListBox, FMX.Layouts,
  aOPCSource, FMX.Controls.Presentation;

type
  TUserChoice = class(TForm)
    cbUser: TComboBox;
    lUser: TLabel;
    lPassword: TLabel;
    ePassword: TEdit;
    bOk: TButton;
    bCalcel: TButton;
    Layout1: TLayout;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FOPCSource: TaOPCSource;
    procedure SetOPCSource(const Value: TaOPCSource);
    { Private declarations }
  public
    destructor Destroy; override;
    procedure Localize;

    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;
  end;

var
  UserChoice: TUserChoice;

implementation

{$R *.fmx}

{ TUserChoice }

destructor TUserChoice.Destroy;
begin
  inherited;

end;

procedure TUserChoice.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TUserChoice.Localize;
begin

end;

procedure TUserChoice.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
end;

end.
