unit aOPCLookupList;

interface

uses
  SysUtils, Classes,IniFiles,
  aCustomOPCSource, aOPCSource,
  uAppStorage;

type
  TaOPCLookupShowValue = (svExact, svLeft, svRight);

  TaOPCLookupList = class(TaCustomOPCLookupList)
  private
    FOPCSource: TaOPCSource;
    FTimeStamp: TDateTime;
    FTableName: string;
    FHint: string;
    FRegistrySection: string;
    FAutoUpdate: boolean;
    FShowValue: TaOPCLookupShowValue;
    procedure SetHint(const Value: string);
    procedure SetOPCSource(const Value: TaOPCSource);
    procedure SetRegistrySection(const Value: string);
    procedure SetAutoUpdate(const Value: boolean);
    procedure SetShowValue(const Value: TaOPCLookupShowValue);
  protected
    function GetLookupFileName:string;  
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    function GetLookup:boolean;
    procedure LoadLookup(aIniFile:TCustomIniFile = nil);
    procedure SaveLookup(aIniFile:TCustomIniFile = nil);
    procedure CheckForNewLookup(aIniFile:TCustomIniFile = nil;
      aLoad:boolean = true);

    function Lookup(aIndex:string; var aValue:string):integer;
    function GetValue(aName: string; aStrIfNotFound: string): string;
    function GetID(aValue: string):string;
  published
    property Hint: string read FHint write SetHint;
    property TableName : string read FTableName write FTableName;
    property Items;//:TStrings read FItems write SetItems;
    property OPCSource:TaOPCSource read FOPCSource write SetOPCSource;

    property ShowValue: TaOPCLookupShowValue read FShowValue write SetShowValue default svExact;

    // если не указывать RegistrySection, то работаем без кеширования
    property RegistrySection:string read FRegistrySection write SetRegistrySection;
    property AutoUpdate:boolean read FAutoUpdate write SetAutoUpdate default false;
  end;

implementation

uses
  //Windows,
  aOPCUtils,
  aOPCLog, uOPCCash;


{ TaOPCLookupList }


procedure TaOPCLookupList.LoadLookup(aIniFile: TCustomIniFile = nil);
var
  aSectionName: string;
//  tc:cardinal;
begin
//  tc := GetTickCount;
  try
    if not Assigned(aIniFile) then
      aIniFile := AppStorage;

    if RegistrySection = '' then
      aSectionName := TableName
    else
      aSectionName := RegistrySection + '\'+TableName;

    FTimeStamp := aIniFile.ReadDateTime(aSectionName,'TimeStamp',0);
    if FileExists(GetLookupFileName) then
      // загружаемся из файла (новый режим)
      Items.LoadFromFile(GetLookupFileName)
    else
      // попытаемся использовать старый режим загрузки из реестра
      aIniFile.ReadSectionValues(aSectionName+'Data',Items);

  except
    on e:Exception do
      OPCLog.WriteToLog('ошибка при загрузке '+TableName+':'+e.Message);
  end;         
//  OPCLog.WriteToLogFmt('TaOPCLookupList.LoadLookup: %s = %d',[TableName,GetTickCount-tc]);
end;

function TaOPCLookupList.Lookup(aIndex: string; var aValue: string): integer;
var
  aIndexNum, aNameNum: Double;
  i: Integer;
begin
  if Trim(aIndex) = '' then
    Exit;
    
  aValue := aIndex;

  if ShowValue = svExact then
  begin
    Result := Items.IndexOfName(aIndex);
    if Result < 0 then
    begin
      if AutoUpdate and Assigned(OPCSource) then
      begin
        CheckForNewLookup(nil,false);
        Result := Items.IndexOfName(aIndex);
        if Result < 0 then
        begin
          Items.Add(aIndex+'='+aIndex);
          aValue := aIndex;
          Exit;
        end;
      end
      else
        Exit;
    end;
    aValue := Items.ValueFromIndex[Result];
  end

  else
  begin
    Result := -1;
    aIndexNum := StrToFloat(aIndex);
    for i := 0 to Items.Count - 1 do
    begin
      aNameNum := StrToFloat(Items.Names[i]);
      // точное совпадение
      if aNameNum = aIndexNum then
      begin
        Result := i;
        aValue := Items.ValueFromIndex[Result];
        Exit;
      end
      // искомое значение меньше чем значение в текущей позииции
      else if aIndexNum < aNameNum then
      begin
        // нам нужно правое? - это оно и есть
        if ShowValue = svRight then
        begin
          Result := i;
          aValue := Items.ValueFromIndex[Result];
          Exit;
        end

        // нам нужно левое? - берем предыдущее
        else
        begin
          if i > 0 then
          begin
            Result := i - 1;
            aValue := Items.ValueFromIndex[Result];
            Exit;
          end
          else
          begin
            Result := 0;
            Items.Insert(Result, aIndex + '=' + aIndex);
            aValue := aIndex;
            Exit;
          end;
        end;
      end;
    end;

    // не нашли - добавим в конец и вернем
    if Result = -1 then
    begin
      Result := Items.Count;
      Items.Add(aIndex + '=' + aIndex);
      aValue := aIndex;
      Exit;
    end;
  end;
end;

function TaOPCLookupList.GetID(aValue: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Items.Count - 1 do
  begin
    if AnsiSameText(Items.ValueFromIndex[i], aValue)  then
    begin
      Result := Items.Names[i];
      Exit;
    end;
  end;
end;

function TaOPCLookupList.GetLookup:boolean;
var
  dt:TDateTime;
  str:string;
//  tc : cardinal;
begin
//  tc := GetTickCount;
  Result := false;
  if not Assigned(OPCSource) then
    raise Exception.Create('Не указан источник данных (OPCSource)');
  if TableName = '' then
    raise Exception.Create('Не указано имя таблицы (TableName)');

  if (not OPCSource.Connected) then
    exit;

//  if not FileExists(GetLookupFileName) then
//    FTimeStamp := -1;

  dt := FTimeStamp;
  str := OPCSource.LoadLookup(TableName,dt);
  if dt<>FTimeStamp then
  begin
    FTimeStamp := dt;
    Items.Text := str;
    Result := true;
  end;
//  OPCLog.WriteToLogFmt('TaOPCLookupList.GetLookup: %s = %d',[TableName,GetTickCount-tc]);
end;

function TaOPCLookupList.GetLookupFileName: string;
begin
  Result := OPCCash.Path + '\' + OPCSource.GetOPCName + '_ref_'+TableName+'.cash';
end;

function TaOPCLookupList.GetValue(aName, aStrIfNotFound: string): string;
var
  aIndex: integer;
begin
  aIndex := Items.IndexOfName(aName);
  if aIndex = -1 then
  begin
    if AutoUpdate and Assigned(OPCSource) then
    begin
      CheckForNewLookup(nil,false);
      aIndex := Items.IndexOfName(aName);
      if aIndex = -1 then
        Result := aStrIfNotFound
      else
        Result := Items.ValueFromIndex[aIndex];
    end
    else
      Result := aStrIfNotFound;
  end
  else
    Result := Items.ValueFromIndex[aIndex];
end;

procedure TaOPCLookupList.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FOPCSource) then
    FOPCSource := nil;

end;

procedure TaOPCLookupList.SaveLookup(aIniFile: TCustomIniFile = nil);
var
  aSectionName: string;
begin
  if not Assigned(aIniFile) then
    aIniFile := AppStorage;

  if RegistrySection = '' then
    aSectionName := TableName
  else
    aSectionName := RegistrySection + '\'+TableName;

  try
    Items.SaveToFile(GetLookupFileName);
    aIniFile.WriteDateTime(aSectionName,'TimeStamp',FTimeStamp);
  except
    on e: Exception do
      OPCLog.WriteToLogFmt('Не удалось сохранить таблицу %s в файл %s. Ошибка: %s',
        [TableName, GetLookupFileName, e.Message]);
  end;
end;

procedure TaOPCLookupList.SetAutoUpdate(const Value: boolean);
begin
  FAutoUpdate := Value;
end;

procedure TaOPCLookupList.SetHint(const Value: string);
begin
  FHint := Value;
end;

procedure TaOPCLookupList.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TaOPCLookupList.SetRegistrySection(const Value: string);
begin
  FRegistrySection := Value;
end;

procedure TaOPCLookupList.SetShowValue(const Value: TaOPCLookupShowValue);
begin
  FShowValue := Value;
end;

procedure TaOPCLookupList.CheckForNewLookup(
  aIniFile: TCustomIniFile = nil; aLoad:boolean = true);
begin
  if not Assigned(OPCSource) then
    exit;

  try
    FTimeStamp := 0;

    // если нет необходимости кешировать данные
//    if RegistrySection = '' then
//    begin
      GetLookup;
      exit;
//    end;

  { TODO : Разобраться с кеширование LookUp(ов) }
//    if not Assigned(aIniFile) then
//      aIniFile := AppStorage(RegistrySection);
//
//    if FileExists(GetLookupFileName) then
//      FTimeStamp := aIniFile.ReadDateTime(RegistrySection + '\'+TableName,'TimeStamp',0);
//
//    if GetLookup then // определили, что получили новые данные - сохраним их
//      SaveLookup(aIniFile)
//    else if aLoad then // если новых данных нет, и мы в режиме загрузки - загрузим данные из кеша
//      LoadLookup(aIniFile);
  except
    on e:Exception do
      OPCLog.WriteToLog('Error on Check for new lookup '+TableName+' : '+e.Message);
  end;
end;

end.
