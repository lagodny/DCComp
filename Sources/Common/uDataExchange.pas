unit uDataExchange;

interface

uses
  Classes, Windows, Messages;

const
  sDataExchangeWindow = 'DataExchangeWindow';
  iID = 123456;

type
  TOnNewData=procedure(Sender:TObject;const Data:string) of object;
  TDataExchange=class
  private
    FWindowHandle:HWND;
    FOnNewData:TOnNewData;
    procedure WndProc(var Msg:TMessage);
  public
    constructor Create(const ID:string);
    destructor Destroy; override;
    property OnNewData:TOnNewData read FOnNewData write FOnNewData;
  end;


implementation

{ TDataExchange }

constructor TDataExchange.Create(const ID: string);
begin
  FWindowHandle := AllocateHWnd(WndProc);
  SetProp(FWindowHandle, PChar(ID), iID);
end;

destructor TDataExchange.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited;
end;

procedure TDataExchange.WndProc(var Msg: TMessage);
var
  Data:string;
begin
  with Msg do
  begin
    if (Msg = WM_COPYDATA)and Assigned(FOnNewData) then
    begin
      with PCopyDataStruct(lParam)^ do
      begin
        SetString(Data,PChar(lpData),cbData);
        OnNewData(Self,Data);
      end
    end
    else
      Result:=DefWindowProc(FWindowHandle,Msg,wParam,lParam);
  end;
end;

end.
