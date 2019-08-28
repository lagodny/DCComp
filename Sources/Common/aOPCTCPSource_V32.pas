unit aOPCTCPSource_V32;

interface

uses
  Classes, SysUtils,
  IdComponent,
  DC.StrUtils,
  aOPCSource, aOPCTCPSource_V30,
  uDCObjects, uUserMessage, aCustomOPCSource, aCustomOPCTCPSource;

const
  cPV32_BlockSize = 64*1024;


type
  TaOPCTCPSource_V32 = class(TaOPCTCPSource_V30)
  public
    constructor Create(aOwner: TComponent); override;

    procedure WriteFileStream(aStream: TStream);

    function GetProjects(aMask: string = ''): string;
    function GetProjectGroups(aParentID: Integer = 0): string;

    function GetProjectVersions(aProjectID: integer; aLastVerCount: Integer; aDate1, aDate2: TDateTime): string;
    function GetProjectVersionInfo(aProjectID, aVersionID: integer): string;


    function GetProjectVersionFileName(aProjectID, aVersionID: Integer): string;
    procedure GetProjectVersionFile(
      aProjectID, aVersionID: Integer; aStream: TStream; aComment: string;
      aProgressNotify: TOPCProgressNotify = nil);

    function AddProject(aLabel, aOwner, aDescription, DevEnviroment,
      Plant, Process, Equipment: string; GroupID: Integer): Integer;
    function UpdateProject(aID: Integer; aLabel, aOwner, aDescription, DevEnviroment,
      Plant, Process, Equipment: string; GroupID: Integer): Integer;
    function DelProject(aID: Integer): Integer;

    function AddProjectGroup(aLabel, aDescription: string; aParentID: Integer): Integer;
    function UpdateProjectGroup(aID: Integer; aLabel, aDescription: string; aParentID: Integer): Integer;
    function DelProjectGroup(aID: Integer): Integer;



    function AddProjectVersionInfo(aProjectID: Integer;
      aLabel, aComment, aDescription, aAuthor: string): Integer;
    procedure AddProjectVersionFile(
      aProjectID, aVersionID: Integer; aStream: TStream;
      aProgressNotify: TOPCProgressNotify = nil);

    function AddProjectVersion(aProjectID: Integer;
      aLabel, aComment, aDescription, aAuthor: string;
      aStream: TStream; aProgressNotify: TOPCProgressNotify = nil): Integer;

    procedure LockProject(aProjectID, aHours: Integer; aReason: string);
    procedure UnlockProject(aProjectID: Integer);

    procedure DownloadPMCSetup(aStream: TStream; aProgressNotify: TOPCProgressNotify = nil);

    //function GetUserProjectPermission(aProjectID: Integer): string;

    //function GetProjectPermission(aProjectID: Integer): string;
    //procedure SetProjectPermission(aProjectID: Integer; aUserPermitions: string);

    function GetOperationLog(aLastCount: Integer; aDate1, aDate2: TDateTime): string;

  end;

implementation

uses
  Math,
  uDCStrResource;


{ TaOPCTCPSource_V32 }

function TaOPCTCPSource_V32.AddProject(aLabel, aOwner, aDescription, DevEnviroment,
  Plant, Process, Equipment: string; GroupID: Integer): Integer;
begin
  LockConnection;
  try
    DoConnect;
    DoCommandFmt('AddProject ' +
      'Encoded=1;' +
      'Label=%s;' +
      'Owner=%s;' +
      'Description=%s;' +
      'DevEnviroment=%s;' +
      'Plant=%s;' +
      'Process=%s;' +
      'Equipment=%s;' +
      'GroupID=%s',
      [EncodeStr(aLabel), EncodeStr(aOwner), EncodeStr(aDescription),
       EncodeStr(DevEnviroment), EncodeStr(Plant), EncodeStr(Process), EncodeStr(Equipment),
       EncodeStr(IntToStr(GroupID))]);

    Result := StrToInt(ReadLn);
  finally
    UnLockConnection;
  end;
end;

function TaOPCTCPSource_V32.AddProjectGroup(aLabel, aDescription: string; aParentID: Integer): Integer;
begin
  LockConnection;
  try
    DoConnect;
    DoCommandFmt('AddProjectGroup ' +
      'Encoded=1;' +
      'Label=%s;' +
      'Description=%s;' +
      'ParentID=%s',
      [EncodeStr(aLabel), EncodeStr(aDescription), EncodeStr(IntToStr(aParentID))]);

    Result := StrToInt(ReadLn);
  finally
    UnLockConnection;
  end;
end;

function TaOPCTCPSource_V32.AddProjectVersion(aProjectID: Integer; aLabel,
  aComment, aDescription, aAuthor: string; aStream: TStream;
  aProgressNotify: TOPCProgressNotify): Integer;
var
  aSize: Integer;
  aBlockSize: Integer;
  aCanceled: Boolean;
  oldOnWork: TWorkEvent;
begin
  Assert(Assigned(aStream), uDCStrResource.dcResS_StreamNotCreated);

  LockConnection;
  try
    aSize := aStream.Size;

    DoConnect;
    DoCommandFmt('AddProjectVersion ' +
      'ProjectID=%d;' +
      'StreamSize=%d;' +
      'Encoded=1;' +
      'Label=%s;' +
      'Description=%s;' +
      'Comment=%s;' +
      'Author=%s',
      [aProjectID, aSize,
       EncodeStr(aLabel),
       EncodeStr(aDescription),
       EncodeStr(aComment),
       EncodeStr(aAuthor)]);

    aCanceled := False;
    aStream.Position := 0;

// попытка 1
//    WriteFileStream(aStream);


// попытка 2
{
    OpenWriteBuffer;
    try
      WriteStream(aStream, False, False, aStream.Size);
    finally
      CloseWriteBuffer;
    end;
}



    aBlockSize := Min(cPV32_BlockSize, aStream.Size);
    //aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);

    OpenWriteBuffer;

    try
      while aStream.Position < aSize do
      begin
        WriteStream(aStream, False, False, aBlockSize);
        if Assigned(aProgressNotify) then
        begin
          aProgressNotify(aStream.Position, aSize, aCanceled);
          if aCanceled then
            Break;
        end;
        aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
      end;
    finally
      CloseWriteBuffer;
    end;



    if not aCanceled then
    begin
      CheckCommandResult;
      Result := StrToInt(ReadLn);
    end;

  finally
    UnLockConnection;
  end;

  if aCanceled then
  begin
    DoDisconnect;
    raise EOPCTCPOperationCanceledException.Create(uDCStrResource.dcResS_OperationCanceledByUser);
  end;


end;

procedure TaOPCTCPSource_V32.AddProjectVersionFile(aProjectID,
  aVersionID: Integer; aStream: TStream; aProgressNotify: TOPCProgressNotify);
var
  aSize: Integer;
  aBlockSize: Integer;
  aCanceled: Boolean;
begin
  Assert(Assigned(aStream), dcResS_StreamNotCreated);

  LockConnection;
  try
    aSize := aStream.Size;

    DoConnect;
    DoCommandFmt('AddProjectVersionFile %d;%d;%d', [aProjectID, aVersionID, aSize]);

    aCanceled := False;
    aStream.Position := 0;
    aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    while aStream.Position < aSize do
    begin
      WriteStream(aStream, False, False, aBlockSize);
      if Assigned(aProgressNotify) then
      begin
        aProgressNotify(aStream.Position, aSize, aCanceled);
        if aCanceled then
          Break;
      end;
      aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    end;
  finally
    UnLockConnection;
  end;

  if aCanceled then
  begin
    Disconnect;
    raise EOPCTCPOperationCanceledException.Create(dcResS_OperationCanceledByUser);
  end;

end;

function TaOPCTCPSource_V32.AddProjectVersionInfo(aProjectID: Integer; aLabel,
  aComment, aDescription, aAuthor: string): Integer;
begin
  LockConnection;
  try
    DoConnect;
    DoCommandFmt('AddProjectVersionInfo ' +
      'ProjectID=%d;' +
      'Label=%s;' +
      'Description=%s;' +
      'Comment=%s;' +
      'Author=%s',
      [aProjectID, aLabel, aDescription, aComment, aAuthor]);

    Result := StrToInt(ReadLn);
  finally
    UnLockConnection;
  end;
end;

constructor TaOPCTCPSource_V32.Create(aOwner: TComponent);
begin
  inherited;

  ProtocolVersion := 32;

  { TODO -oAlex -cCompression : Проблемы со сжатием при передаче файлов }
  CompressionLevel := 0;
end;

function TaOPCTCPSource_V32.DelProject(aID: Integer): Integer;
begin
  LockAndDoCommandFmt('DelProject %d', [aID]);
end;

function TaOPCTCPSource_V32.DelProjectGroup(aID: Integer): Integer;
begin
  LockAndDoCommandFmt('DelProjectGroup %d', [aID]);
end;

procedure TaOPCTCPSource_V32.DownloadPMCSetup(aStream: TStream; aProgressNotify: TOPCProgressNotify);
var
  aSize: Integer;
  aBlockSize: Integer;
  aCanceled: Boolean;
begin
  Assert(Assigned(aStream), dcResS_StreamNotCreated);

  LockConnection;
  try
    DoConnect;
    DoCommand('DownloadPMC');
    aSize := StrToInt(ReadLn);

    aCanceled := False;
    aStream.Position := 0;
    aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    while aStream.Position < aSize do
    begin
      ReadStream(aStream, aBlockSize);
      if Assigned(aProgressNotify) then
      begin
        aProgressNotify(aStream.Position, aSize, aCanceled);
        if aCanceled then
          Break;
      end;
      aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    end;
  finally
    UnLockConnection;
  end;

  if aCanceled then
  begin
    Disconnect;
    Reconnect;
    raise EOPCTCPOperationCanceledException.Create(dcResS_OperationCanceledByUser);
  end;

end;

function TaOPCTCPSource_V32.GetOperationLog(aLastCount: Integer; aDate1, aDate2: TDateTime): string;
begin
  Result := LockAndGetStringsCommand(
    Format('GetOperationLog LastCount=%d;Encoded=1;Date1=%s;Date2=%s',
      [aLastCount, FloatToStr(aDate1, OpcFS), FloatToStr(aDate2, OpcFS)]));
end;

function TaOPCTCPSource_V32.GetProjectGroups(aParentID: Integer): string;
begin
  Result := LockAndGetStringsCommand(Format('GetProjectGroups %d', [aParentID]));
end;

//function TaOPCTCPSource_V32.GetProjectPermission(aProjectID: Integer): string;
//begin
//  Result := LockAndGetStringsCommand(Format('GetProjectPermission %d;1', [aProjectID]));
//end;

function TaOPCTCPSource_V32.GetProjects(aMask: string): string;
begin
  Result := LockAndGetStringsCommand(Format('GetProjects %s;1', [EncodeStr(aMask)]));
end;

procedure TaOPCTCPSource_V32.GetProjectVersionFile(aProjectID,
  aVersionID: Integer; aStream: TStream; aComment: string;
  aProgressNotify: TOPCProgressNotify);
var
  aSize: Integer;
  aBlockSize: Integer;
  aCanceled: Boolean;
begin
  Assert(Assigned(aStream), dcResS_StreamNotCreated);

  LockConnection;
  try
    DoConnect;
    DoCommandFmt('GetProjectVersionFile %d;%d;%s', [aProjectID, aVersionID, EncodeStr(aComment)]);
    aSize := StrToInt(ReadLn);

    aCanceled := False;
    aStream.Position := 0;
    aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    while aStream.Position < aSize do
    begin
      ReadStream(aStream, aBlockSize);
      if Assigned(aProgressNotify) then
      begin
        aProgressNotify(aStream.Position, aSize, aCanceled);
        if aCanceled then
          Break;
      end;
      aBlockSize := Min(cPV32_BlockSize, aSize - aStream.Position);
    end;
  finally
    UnLockConnection;
  end;

  if aCanceled then
  begin
    Disconnect;
    raise EOPCTCPOperationCanceledException.Create(dcResS_OperationCanceledByUser);
  end;

end;

function TaOPCTCPSource_V32.GetProjectVersionFileName(aProjectID, aVersionID: Integer): string;
begin
  Result := LockDoCommandReadLnFmt('GetProjectVersionFileName %d;%d', [aProjectID, aVersionID]);
end;

function TaOPCTCPSource_V32.GetProjectVersionInfo(aProjectID,
  aVersionID: integer): string;
begin
  Result := LockAndGetStringsCommand(
    Format('GetProjectVersionInfo %d;%d', [aProjectID, aVersionID]))
end;

function TaOPCTCPSource_V32.GetProjectVersions(aProjectID,
  aLastVerCount: Integer; aDate1, aDate2: TDateTime): string;
begin
  // получить список версий проекта по ID
//  if aLastVerCount <> 0 then
    Result := LockAndGetStringsCommand(
      Format('GetProjectVersions %d;%d;1;%s;%s',
        [aProjectID, aLastVerCount, FloatToStr(aDate1, OpcFS), FloatToStr(aDate2, OpcFS)]))
//  else
//    Result := LockAndGetStringsCommand(
//      Format('GetProjectVersions %d;0;1', [aProjectID]))
end;

//function TaOPCTCPSource_V32.GetUserProjectPermission(aProjectID: Integer): string;
//begin
//  LockConnection;
//  try
//    DoConnect;
//    DoCommandFmt('GetUserProjectPermission %d', [aProjectID]);
//
//    Result := ReadLn;
//  finally
//    UnLockConnection;
//  end;
//
//end;

procedure TaOPCTCPSource_V32.LockProject(aProjectID, aHours: Integer; aReason: string);
begin
  LockAndDoCommandFmt('LockProject %d;%d;%s;1', [aProjectID, aHours, StrToHex(aReason)]);
end;

//procedure TaOPCTCPSource_V32.SetProjectPermission(aProjectID: Integer; aUserPermitions: string);
//begin
//  LockAndDoCommandFmt('SetProjectPermission %d;%s;1', [aProjectID, EncodeStr(aUserPermitions)]);
//end;

procedure TaOPCTCPSource_V32.UnlockProject(aProjectID: Integer);
begin
  LockAndDoCommandFmt('UnlockProject %d', [aProjectID]);
end;

function TaOPCTCPSource_V32.UpdateProject(aID: Integer; aLabel, aOwner, aDescription, DevEnviroment, Plant, Process,
  Equipment: string; GroupID: Integer): Integer;
begin
  LockConnection;
  try
    DoConnect;
    DoCommandFmt('UpdateProject ' +
      'Encoded=1;' +
      'ID=%d;' +
      'Label=%s;' +
      'Owner=%s;' +
      'Description=%s;' +
      'DevEnviroment=%s;' +
      'Plant=%s;' +
      'Process=%s;' +
      'Equipment=%s;' +
      'GroupID=%s',
      [aID, EncodeStr(aLabel), EncodeStr(aOwner), EncodeStr(aDescription),
       EncodeStr(DevEnviroment), EncodeStr(Plant), EncodeStr(Process), EncodeStr(Equipment),
       EncodeStr(IntToStr(GroupID))]);

    Result := StrToInt(ReadLn);
  finally
    UnLockConnection;
  end;

end;

function TaOPCTCPSource_V32.UpdateProjectGroup(aID: Integer; aLabel, aDescription: string; aParentID: Integer): Integer;
begin
  LockConnection;
  try
    DoConnect;
    DoCommandFmt('UpdateProjectGroup ' +
      'Encoded=1;' +
      'ID=%s;' +
      'Label=%s;' +
      'Description=%s;' +
      'ParentID=%s',
      [EncodeStr(IntToStr(aID)), EncodeStr(aLabel), EncodeStr(aDescription), EncodeStr(IntToStr(aParentID))]);

    Result := StrToInt(ReadLn);
  finally
    UnLockConnection;
  end;
end;

procedure TaOPCTCPSource_V32.WriteFileStream(aStream: TStream);
const
  cBufSize = 1024 * 1024;
var
  aSize: Int64;
  aSendSize: Int64;
begin
  aSize := aStream.Size;
  aStream.Position := 0;

  Connection.IOHandler.Write(aSize);
  repeat
    aSendSize := Min(aSize, cBufSize);
    Connection.IOHandler.Write(aStream, aSendSize, True);
    aSize := aSize - aSendSize;
    CheckCommandResult;
  until aSize <= 0;

end;

end.
