unit uOPCSetValueForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  aOPCLookupList,
  uOPCSetValueFrame;

type
  TSetValueForm = class(TForm)
    SetValueFrame: TFrame1;
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function ShowSetValueForm(var aValue: string; var aMoment: TDateTime;
    aLookupList: TaOPCLookupList; aRefAutoFill: Boolean; aHelpContext: THelpContext): boolean;



implementation

{$R *.dfm}


function ShowSetValueForm(var aValue: string; var aMoment: TDateTime;
  aLookupList: TaOPCLookupList; aRefAutoFill: Boolean; aHelpContext: THelpContext): boolean;
var
  aSetValueForm: TSetValueForm;
begin
  aSetValueForm := TSetValueForm.Create(nil);
  try
    aSetValueForm.PopupParent := Application.MainForm;

    aSetValueForm.SetValueFrame.Value := aValue;
    aSetValueForm.SetValueFrame.Date := aMoment;
    aSetValueForm.SetValueFrame.RefAutoFill := aRefAutoFill;
    if Assigned(aLookupList) then
      aSetValueForm.SetValueFrame.Lookup := aLookupList.Items;


    aSetValueForm.SetValueFrame.UpdateClientAction;

    Result := aSetValueForm.ShowModal = mrOk;

    if Result then
    begin
      aValue := aSetValueForm.SetValueFrame.Value;
      aMoment := aSetValueForm.SetValueFrame.Date;
    end;

  finally
    aSetValueForm.Free;
  end;
end;


end.
