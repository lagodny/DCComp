unit uAppStorage;

interface

uses
  Classes,
  {$IFDEF MSWINDOWS}
  System.Win.Registry, Winapi.Windows,
  {$ENDIF}
  IniFiles;
type

{$IFDEF MSWINDOWS}
  TAppRegistry = class(TRegistryIniFile)
  public
    FKey: string;
    constructor Create(const FileName: string); overload;

    function ReadBinaryStream(const Section, Name: string; Value: TStream): Integer; override;
    procedure WriteBinaryStream(const Section, Name: string; Value: TStream); override;
  end;
{$ENDIF}

  TAppIniFile = class(TIniFile)
  public
    FIniFileName: string;
    constructor Create(const FileName: string); overload;

{$IFDEF MSWINDOWS}
    procedure WriteString(const Section, Ident, Value: String); override;
    function ReadString(const Section, Ident, Default: string): string; override;
{$ENDIF}
  end;

  TAppStorageKind = (skRegistry, skIniFile);

var
  AppKey : string;
  AppStorageKind: TAppStorageKind;

function AppStorage: TCustomIniFile;overload;
function AppStorage(aKey:string): TCustomIniFile; overload;

implementation

uses
  Math, SysUtils;

const
  cMaxStrSize = 2047;
  cMaxStreamSize = 16*1024; // пусть будет 16КБ

var
{$IFDEF MSWINDOWS}
  FAppRegistry : TAppRegistry;
{$ENDIF}
  FAppIniFile  : TAppIniFile;

function AppStorage: TCustomIniFile;overload;
begin
  Result := nil;
  case AppStorageKind of
{$IFDEF MSWINDOWS}
    skRegistry:
      Result := FAppRegistry;
{$ENDIF}
    skIniFile:
      Result := FAppIniFile;
  end;
  if not Assigned(Result) then
    raise Exception.Create('Вызов функции возможен только после вызова AppStorage(aKey)');
end;

function AppStorage(aKey:string): TCustomIniFile; overload;
begin
  Result := nil;
  case AppStorageKind of
{$IFDEF MSWINDOWS}
    skRegistry:
      begin
        if not Assigned(FAppRegistry) then
          FAppRegistry := TAppRegistry.Create(aKey)
        else if FAppRegistry.FKey <> aKey then
        begin
          FreeAndNil(FAppRegistry);
          FAppRegistry := TAppRegistry.Create(aKey);
        end;
        Result := FAppRegistry;
      end;
{$ENDIF}
    skIniFile:
      begin
        if not Assigned(FAppIniFile) then
          FAppIniFile := TAppIniFile.Create(aKey)
        else if FAppIniFile.FIniFileName <> aKey then
        begin
          FreeAndNil(FAppIniFile);
          FAppIniFile := TAppIniFile.Create(aKey);
        end;
        Result := FAppIniFile;
      end;
  end;
end;


{$IFDEF MSWINDOWS}

{ TAppRegistry }

constructor TAppRegistry.Create(const FileName: string);
begin
  inherited Create(FileName);
  FKey := FileName;
end;

function TAppRegistry.ReadBinaryStream(const Section, Name: string;
  Value: TStream): Integer;
var
  i: integer;
  aResult: integer;
begin
  Result := inherited ReadBinaryStream(Section,Name,Value);

  if Value.Size >= cMaxStreamSize then //нужен проход по вспомагательным Name
  begin
    i := 1;
    repeat
      Value.Position := Value.Size;
      aResult := inherited ReadBinaryStream(Section,Format('%s_part%d',[Name,i]),Value);
      Inc(i);
      Result := Result + aResult;
    until aResult < cMaxStreamSize;
  end;
  Value.Position := Value.Size;
end;

procedure TAppRegistry.WriteBinaryStream(const Section, Name: string;
  Value: TStream);
var
  i:integer;
  aCount  : integer;
  aBufSize: integer;
  aStream : TMemoryStream;
begin
  aCount := Value.Size div cMaxStreamSize;
  if aCount = 0 then
  begin
    inherited WriteBinaryStream(Section,Name,Value);
    exit;
  end;

  aStream := TMemoryStream.Create;
  try
    Value.Position := 0;
    aBufSize := Min(Value.Size - Value.Position, cMaxStreamSize);
    aStream.CopyFrom(Value, aBufSize);
    aStream.Position := 0;
    inherited WriteBinaryStream(Section,Name,aStream);

    for i := 1 to aCount do
    begin
      aStream.Clear;
      aBufSize := Min(Value.Size - Value.Position, cMaxStreamSize);
      aStream.CopyFrom(Value, aBufSize);
      aStream.Position := 0;
      inherited WriteBinaryStream(Section,Format('%s_part%d',[Name,i]),aStream);
    end;
  finally
    aStream.Free;
  end;
end;
{$ENDIF}

{ TAppIniFile }

constructor TAppIniFile.Create(const FileName: string);
begin
  inherited Create(FileName);
  FIniFileName := FileName;
end;

{$IFDEF MSWINDOWS}
function TAppIniFile.ReadString(const Section, Ident, Default: string): string;
var
  Buffer: array[0..cMaxStrSize] of Char;
  i: integer;
  aResult: string;
begin
  SetString(Result, Buffer, GetPrivateProfileString(PChar(Section),
    PChar(Ident), PChar(Default), Buffer, SizeOf(Buffer), PChar(FileName)));

  if Length(Result)>=cMaxStrSize then //нужен проход по вспомагательным Ident
  begin
    i := 1;
    repeat
      SetString(aResult, Buffer, GetPrivateProfileString(PChar(Section),
        PChar(Format('%s_%d',[Ident,i])), PChar(Default), Buffer, SizeOf(Buffer), PChar(FileName)));
      Inc(i);
      Result := Result + aResult;
    until Length(aResult)<cMaxStrSize;
  end;
end;

procedure TAppIniFile.WriteString(const Section, Ident, Value: String);
var
  i:integer;
  aCount  : integer;
begin
  aCount := (Length(Value)-1) div cMaxStrSize;
  inherited WriteString(Section,Ident,Copy(Value,1,cMaxStrSize));
  for i := 1 to aCount do
    inherited WriteString(Section,Format('%s_%d',[Ident,i]),Copy(Value,i*cMaxStrSize+1,cMaxStrSize));
end;
{$ENDIF}



{$IFDEF MSWINDOWS}
initialization
  AppStorageKind := skRegistry;
  FAppRegistry := nil;
  FAppIniFile  := nil;

finalization
  FreeAndNil(FAppRegistry);
  FreeAndNil(FAppIniFile);
{$ENDIF}

{$IFDEF ANDROID}
initialization
  AppStorageKind := skIniFile;
  FAppIniFile  := nil;

finalization
  FreeAndNil(FAppIniFile);
{$ENDIF}




end.
