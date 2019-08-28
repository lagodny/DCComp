unit uCinemaProperty;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TCinemaPropertyForm = class(TForm)
    GroupBox2: TGroupBox;
    Label3: TLabel;
    edStep: TEdit;
    Label4: TLabel;
    edSleepTime: TEdit;
    bOk: TButton;
    bCancel: TButton;
  private
  public
  end;

var
  CinemaPropertyForm: TCinemaPropertyForm;

implementation

{$R *.dfm}

{ TCinemaPropertyForm }

end.
