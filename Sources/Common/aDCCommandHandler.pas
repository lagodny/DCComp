unit aDCCommandHandler;

interface

uses
  Classes,
  IdComponent, IdCommandHandlers, IdContext;

type
  TaDCCommandHandlers = class;

  TaDCNoCommandHandlerEvent = function(ASender: TaDCCommandHandlers; const AData: string;
    AContext: TIdContext): Boolean of object;

  TaDCCommandHandlers = class(TIdComponent)
  private
    FOnNoCommandHandler: TaDCNoCommandHandlerEvent;
    FCommandHandlers: TIdCommandHandlers;
    function GetOnAfterCommandHandler: TIdAfterCommandHandlerEvent;
    function GetOnBeforeCommandHandler: TIdBeforeCommandHandlerEvent;
    procedure SetOnAfterCommandHandler(const Value: TIdAfterCommandHandlerEvent);
    procedure SetOnBeforeCommandHandler(const Value: TIdBeforeCommandHandlerEvent);
    function GetOnCommandHandlersException: TIdCommandHandlersExceptionEvent;
    function GetPerformReplies: Boolean;
    procedure SetOnCommandHandlersException(const Value: TIdCommandHandlersExceptionEvent);
    procedure SetPerformReplies(const Value: Boolean);
  protected
    function DoOnNoCommandHandler(AContext: TIdContext; const AData: string): Boolean;
  public
    //constructor Create(aOwner: TComponent);
    procedure InitComponent; override;
    destructor Destroy; override;

    function HandleCommand(AContext: TIdContext; AData: string): Boolean; virtual;
  published
    property OnBeforeCommandHandler: TIdBeforeCommandHandlerEvent read GetOnBeforeCommandHandler
     write SetOnBeforeCommandHandler;
    property OnAfterCommandHandler: TIdAfterCommandHandlerEvent read GetOnAfterCommandHandler
     write SetOnAfterCommandHandler;
    property OnCommandHandlersException: TIdCommandHandlersExceptionEvent read GetOnCommandHandlersException
      write SetOnCommandHandlersException;
    property OnNoCommandHandler: TaDCNoCommandHandlerEvent read FOnNoCommandHandler
      write FOnNoCommandHandler;

    property CommandHandlers: TIdCommandHandlers read FCommandHandlers write FCommandHandlers;
    property PerformReplies: Boolean read GetPerformReplies write SetPerformReplies default False;

  end;



implementation

{ TaOPCCommandHandler }

//constructor TaDCCommandHandlers.Create(aOwner: TComponent);
//begin
//  inherited Create(aOwner);
//  FCommandHandlers := TIdCommandHandlers.Create(Self, nil, nil, nil, nil);
//end;

destructor TaDCCommandHandlers.Destroy;
begin
  FCommandHandlers.Free;
  inherited;
end;

function TaDCCommandHandlers.DoOnNoCommandHandler(AContext: TIdContext; const AData: string): Boolean;
begin
  if Assigned(OnNoCommandHandler) then
    Result := OnNoCommandHandler(Self, AData, AContext)
  else
    Result := False;
//  else
//    raise EIdTCPServerError.Create(RSNoCommandHandlerFound);
end;

function TaDCCommandHandlers.GetOnAfterCommandHandler: TIdAfterCommandHandlerEvent;
begin
  Result := CommandHandlers.OnAfterCommandHandler;
end;

function TaDCCommandHandlers.GetOnBeforeCommandHandler: TIdBeforeCommandHandlerEvent;
begin
  Result := CommandHandlers.OnBeforeCommandHandler;
end;

function TaDCCommandHandlers.GetOnCommandHandlersException: TIdCommandHandlersExceptionEvent;
begin
  Result := CommandHandlers.OnCommandHandlersException;
end;

function TaDCCommandHandlers.GetPerformReplies: Boolean;
begin
  Result := CommandHandlers.PerformReplies;
end;

function TaDCCommandHandlers.HandleCommand(AContext: TIdContext; AData: string): Boolean;
begin
  Result := CommandHandlers.HandleCommand(AContext, AData);
  if not Result then
    Result := DoOnNoCommandHandler(AContext, AData);
end;

procedure TaDCCommandHandlers.InitComponent;
begin
  inherited InitComponent;
  FCommandHandlers := TIdCommandHandlers.Create(Self, nil, nil, nil);
  FCommandHandlers.PerformReplies := False;
end;

procedure TaDCCommandHandlers.SetOnAfterCommandHandler(const Value: TIdAfterCommandHandlerEvent);
begin
  CommandHandlers.OnAfterCommandHandler := Value;
end;

procedure TaDCCommandHandlers.SetOnBeforeCommandHandler(const Value: TIdBeforeCommandHandlerEvent);
begin
  CommandHandlers.OnBeforeCommandHandler := Value;
end;

procedure TaDCCommandHandlers.SetOnCommandHandlersException(const Value: TIdCommandHandlersExceptionEvent);
begin
  CommandHandlers.OnCommandHandlersException := Value;
end;

procedure TaDCCommandHandlers.SetPerformReplies(const Value: Boolean);
begin
  CommandHandlers.PerformReplies := Value;
end;


end.
