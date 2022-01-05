unit uDCStatus;

interface

uses
  Graphics,
  CWindowThread;

type
  TDCStatus = class
  private
    FProgressWin: TCWindowThread;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ShowStatus(aStatus: string; aCanceled: Boolean = False; aPercent: Integer = -1);
    procedure HideStatus;

    property ProgressWin: TCWindowThread read FProgressWin;
  end;

function DCStatus: TDCStatus;

implementation

uses
  SysUtils;

var
  FDCStatus: TDCStatus;

function DCStatus: TDCStatus;
begin
  if not Assigned(FDCStatus) then
    FDCStatus := TDCStatus.Create;
    
  Result := FDCStatus;
end;



{ TDCStatus }

constructor TDCStatus.Create;
begin
  FProgressWin := TCWindowThread.Create(nil);

  ProgressWin.Visible := False;

  ProgressWin.Width := 400;
  ProgressWin.Height := 70;
  ProgressWin.Percent := -1;
  ProgressWin.Enabled := False;
  ProgressWin.Interval := 500;

  ProgressWin.Color := 14935011;
  ProgressWin.CaptionColor := 14405055;
  ProgressWin.Font.Color := clWindowText;

end;

destructor TDCStatus.Destroy;
begin
  ProgressWin.Free;
  inherited;
end;

procedure TDCStatus.HideStatus;
begin
  ProgressWin.Visible := False;
  ProgressWin.Percent := -1;
  ProgressWin.Canceled := False;
end;

procedure TDCStatus.ShowStatus(aStatus: string; aCanceled: Boolean; aPercent: Integer);
begin
  ProgressWin.Text := aStatus;
  ProgressWin.Enabled := aCanceled;
  ProgressWin.Percent := aPercent;
  
  if not ProgressWin.Visible then
    ProgressWin.Visible := True;
end;

initialization
  FDCStatus := nil;

finalization
  FreeAndNil(FDCStatus);

end.
