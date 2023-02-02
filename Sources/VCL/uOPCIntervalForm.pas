unit uOPCIntervalForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  uOPCIntervalFrame, uOPCInterval;

type
  TOPCIntervalForm = class(TForm)
    OPCIntervalFrame: TOPCIntervalFrame;
    bOk: TButton;
    bCancel: TButton;
  private
  protected
    procedure Localize;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  function ShowIntervalForm(aInterval: TOPCInterval; aHelpContext: THelpContext; aPopupParent: TCustomForm): boolean;

implementation

function ShowIntervalForm(aInterval: TOPCInterval; aHelpContext: THelpContext; aPopupParent: TCustomForm): boolean;
begin
  //TOpenDialog.Create(nil).Execute()
  with TOPCIntervalForm.Create(nil) do
  begin
    try
      HelpContext := aHelpContext;
      PopupParent := aPopupParent;
      OPCIntervalFrame.SetInterval(aInterval);
      if ShowModal = mrOk then
      begin
        OPCIntervalFrame.GetInterval(aInterval);
        TOPCInterval.LastInterval := aInterval;
        Result := true;
      end
      else
        Result := false;
    finally
      Free;
    end;
  end;

end;


{$R *.dfm}

{ TOPCIntervalForm }

constructor TOPCIntervalForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Localize;
end;

procedure TOPCIntervalForm.Localize;
begin
//  Caption := TDCLocalizer.GetStringRes(idxIntervalForm_Caption);
//
//  bOk.Caption := TDCLocalizer.GetStringRes(idxButton_OK);
//  bCancel.Caption := TDCLocalizer.GetStringRes(idxButton_Cancel);

end;

end.
