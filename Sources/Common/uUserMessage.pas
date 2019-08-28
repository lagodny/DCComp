unit uUserMessage;

interface

uses
  System.Generics.Collections, System.SyncObjs,
  Classes, SysUtils;

type
  TUserMessage = class
  public
    SenderGUID: string;
    SenderAddr: string;
    SenderUserName: string;
    //Time: TDateTime;
    Text: string;

    constructor Create(aText: string); overload;

    function ToText: string;
    procedure InitFromText(aText: string);
  end;

  TUserMessageList = class(TList<TUserMessage>)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearMessages;

    function GetMessage(aIndex: Integer): TUserMessage;

    procedure AddMessage(aMessage: TUserMessage);
    procedure DeleteMessage(aIndex: Integer);

    procedure Lock;
    procedure UnLock;
  end;


implementation

uses
  StrUtils;

{ TUserMessage }

const
  cUserMsgDelim = ';';

constructor TUserMessage.Create(aText: string);
begin
  inherited Create;
  InitFromText(aText);
end;

procedure TUserMessage.InitFromText(aText: string);
var
  p: integer;

  function GetToken(aText: string; aDelim: string; var aPos: integer): string;
  var
    p: Integer;
  begin
    Result := '';
    p := PosEx(aDelim, aText, aPos);
    if p > 0 then
    begin
      Result := Copy(aText, aPos, p - aPos);
      aPos := p + Length(aDelim);
    end
    else
    begin
      Result := Copy(aText, aPos, Length(aText) - aPos + 1);
      aPos := Length(aText) + 1;
    end;
  end;


begin
  p := 1;
  SenderGUID := GetToken(aText, cUserMsgDelim, p);
  SenderAddr := GetToken(aText, cUserMsgDelim, p);
  SenderUserName := GetToken(aText, cUserMsgDelim, p);
  Text := GetToken(aText, cUserMsgDelim, p);
end;

function TUserMessage.ToText: string;
begin
  Result :=
    //FormatDateTime(Time) + cUserMsgDelim +
    SenderGUID + cUserMsgDelim +
    SenderAddr + cUserMsgDelim +
    SenderUserName + cUserMsgDelim +
    Text;
end;

{ TUserMessageList }

procedure TUserMessageList.AddMessage(aMessage: TUserMessage);
begin
  if not Assigned(aMessage) then
    Exit;
    
  Lock;
  try
    Add(aMessage);
  finally
    UnLock;
  end;
end;

procedure TUserMessageList.ClearMessages;
var
  i: integer;
begin
  Lock;
  try
    for i := Count - 1 downto 0 do
      Items[i].Free;
    Clear;
  finally
    UnLock;
  end;
end;

constructor TUserMessageList.Create;
begin
  inherited;

  FLock := TCriticalSection.Create;
end;

procedure TUserMessageList.DeleteMessage(aIndex: Integer);
begin
  Lock;
  try
    Items[aIndex].Free;
    Delete(aIndex);
  finally
    UnLock;
  end;
end;

destructor TUserMessageList.Destroy;
begin
  ClearMessages;
  FreeAndNil(FLock);
  inherited;
end;

function TUserMessageList.GetMessage(aIndex: Integer): TUserMessage;
begin
  Lock;
  try
    if (aIndex >= 0) and (aIndex < Count) then
      Result := Items[aIndex]
    else
      Result := nil;
  finally
    UnLock;
  end;

end;


procedure TUserMessageList.Lock;
begin
  FLock.Enter;
end;

procedure TUserMessageList.UnLock;
begin
  FLock.Leave;
end;

end.

