
unit aOPCConnectionList;

interface

uses
  Classes, SysUtils, IniFiles,
  aOPCClass, uDCObjects, uAppStorage,
  aOPCLookupList,
  aCustomOPCSource, aOPCSource, aCustomOPCTCPSource,
  aOPCTCPSource, aOPCTCPSource_V30, aOPCTCPSource_V31, aOPCTCPSource_V32, aOPCTCPSource_V33;

type
  EOPCConnectionCollectionError = class(Exception);

  TOPCConnectionCollection = class;
  TaOPCConnectionList = class;

  TOPCProtocolVersion = (
    opv0 = 0,
    opv30 = 1,
    opv31 = 2,
    opv32 = 3,
    opv33 = 4);

  TOPCConnectionCollectionItem = class(TCollectionItem)
  private
    FID: Integer;
    FName: string;
    FOPCSource: TaCustomOPCTCPSource;
    FOPCObjectList: TDCObjectList;
    FLookupsList: TStringList;
    FEnable: boolean;
    FProtocolVersion: TOPCProtocolVersion;
    function GetName: string;
    function GetOPCConnectionCollection: TOPCConnectionCollection;
    procedure SetEnable(const Value: boolean);
    procedure SetProtocolVersion(const Value: TOPCProtocolVersion);
  public
    constructor Create(Collection: TCollection); override;
    constructor CreateProtocol(Collection: TCollection; aProtocol: TOPCProtocolVersion);

    destructor Destroy; override;

    function CreateOPCSource: TaCustomOPCTCPSource;

    function GetDisplayName: string; override;
    procedure Assign(Source: TPersistent); override;

    procedure LoadChildsFromServer(aParent: TDCObject; aLevelCount: Integer);

    //список объектов (иерархия, пространство имён...)
    property OPCObjectList: TDCObjectList read FOPCObjectList;

    //список Lookup-ов:
    // строка - имя справочника в базе данных
    // объект - LookupList для этого справочника
    property LookupsList: TStringList read FLookupsList;

    //ссылка на владельца (коллекцию подключений)
    property OPCConnectionCollection: TOPCConnectionCollection read GetOPCConnectionCollection;

    procedure Clear;
    function GetLookupByTableName(aRefTableName: string): TaOPCLookupList;
    procedure LoadLookups(aAppStorage: TCustomIniFile; aKey: string); overload;
    //    procedure LoadLookups(aRegistrySection:string);overload;
    function GetStatesLookup: TaOPCLookupList;

    procedure InitObjectList(aNameSpace: TStrings; aStartObject: TDCObject = nil);
    function InitOPCObjectList(aObjectSID: string = ''; aLevelCount: Integer = 0): boolean;

    procedure StringsToHierarchy(aNameSpace: TStrings; aHierarchy: TDCObjectList);

    // заполнить список объектов из списка строк иерархии
    procedure FillHierarchy(aHierarchy: TDCObjectList; aRootID: string = ''; aLevelCount: Integer = 0;
      aKinds: TDCObjectKindSet = []);


  published
    // идентификатор подключения (для поиска)
    property ID: Integer read FID write FID;

    //имя подключения (состоит из имени сервера+порт)
    property Name: string read GetName write FName;

    property Enable: boolean read FEnable write SetEnable default True;
    property ProtocolVersion: TOPCProtocolVersion read FProtocolVersion write SetProtocolVersion default opv0;

    //источник данных для этого подключения
    property OPCSource: TaCustomOPCTCPSource read FOPCSource;

  end;

  TOPCConnectionCollection = class(TCollection)
  private
    FConnectionList: TaOPCConnectionList;
    function GetItem(Index: Integer): TOPCConnectionCollectionItem;
  protected
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    function Find(aOPCSource: TaCustomOPCSource): TOPCConnectionCollectionItem;

    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);

    property Items[Index: Integer]: TOPCConnectionCollectionItem read GetItem; default;
    property ConnectionList: TaOPCConnectionList read FConnectionList;
  end;

  TaOPCCustomConnectionList = class(TComponent)
  private
    FItems: TOPCConnectionCollection;
    procedure SetItems(Value: TOPCConnectionCollection);
    function GetConnection(const Name: string): TOPCConnectionCollectionItem;
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;

    property Items: TOPCConnectionCollection read FItems write SetItems;
    property Connections[const Name: string]: TOPCConnectionCollectionItem read GetConnection;
  end;

  {
    TConnectionNotifyEvent = procedure(Sender: TObject; OPCSource:TaOPCTCPSource) of object;
    TConnectionMsgEvent = procedure(Sender: TObject; OPCSource:TaOPCTCPSource; Msg:string) of object;
  }
    {  TaOPCConnectionList  }

  TaOPCConnectionList = class(TaOPCCustomConnectionList)
  private
    FOnDeactivate: TNotifyEvent;
    FOnRequest: TNotifyEvent;
    FOnActivate: TNotifyEvent;
    FOnError: TMessageStrEvent;
    FDescription: string;
    FOnConnect: TNotifyEvent;
    FOnDisconnect: TNotifyEvent;
    procedure SetActive(const Value: boolean);
    procedure SetOnActivate(const Value: TNotifyEvent);
    procedure SetOnDeactivate(const Value: TNotifyEvent);
    procedure SetOnError(const Value: TMessageStrEvent);
    procedure SetOnRequest(const Value: TNotifyEvent);
    procedure SetDescription(const Value: string);
    procedure SetOnConnect(const Value: TNotifyEvent);
    procedure SetOnDisconnect(const Value: TNotifyEvent);
  public
    function IndexOf(aObject: TObject): integer;
    function IndexOfOPCSource(aOPCSource: TaCustomOPCSource): Integer;

    function IndexOfConnectionID(aID: Integer): Integer;
    function IndexOfConnectionName(aName: string): Integer;

    function FindObjectByID(aConnectionID: integer; ID: integer): TDCObject;
    function FindObjectBySourceAndID(aOPCSource: TaCustomOPCSource; ID: integer): TDCObject;

    function GetOPCSourceByConnectionName(aConnectionName: string): TaCustomOPCSource;
    procedure LoadSettings(aCustomIniFile: TCustomIniFile; aSectionName: string; aNotClearItems: Boolean = False);
    procedure SaveSettings(aCustomIniFile: TCustomIniFile; aSectionName: string);

//    procedure Connect(aUser: string; aLoadNameSpace, aLoadLookups, aActivate: Boolean;
//      aStatusNotify: TOPCStatusNotify = nil; aPassword: string = '');
  published
    property Items;

    property Active: boolean write SetActive;
    property Description: string read FDescription write SetDescription;

    // случается, когда прошел цикл опроса датчиков
    property OnRequest: TNotifyEvent read FOnRequest write SetOnRequest; 
    property OnError: TMessageStrEvent read FOnError write SetOnError;
    property OnActivate: TNotifyEvent read FOnActivate write SetOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write SetOnDeactivate;

    property OnConnect: TNotifyEvent read FOnConnect write SetOnConnect;
    property OnDisconnect: TNotifyEvent read FOnDisconnect write SetOnDisconnect;
  end;

implementation

uses
  uCommonClass, DC.StrUtils;

{ TOPCConnectionCollectionItem }

procedure TOPCConnectionCollectionItem.Assign(Source: TPersistent);
begin
  if Source is TOPCConnectionCollectionItem then
  begin
    FOPCSource.Assign(TOPCConnectionCollectionItem(Source).FOPCSource);
    FOPCObjectList.Assign(TOPCConnectionCollectionItem(Source).FOPCObjectList);

  end
  else
    inherited Assign(Source);
end;

procedure TOPCConnectionCollectionItem.Clear;
var
  i: integer;
begin
  FOPCObjectList.Clear;
  //FOPCObjectList.SortedKind := skNone;

  for i := 0 to FLookupsList.Count - 1 do
    FLookupsList.Objects[i].Free;
  FLookupsList.Clear;
end;

constructor TOPCConnectionCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FEnable := true;
  FProtocolVersion := opv30;

  FOPCSource := CreateOPCSource;

  FOPCObjectList := TDCObjectList.Create;//(False);
  FLookupsList := TStringList.Create;
end;

function TOPCConnectionCollectionItem.CreateOPCSource: TaCustomOPCTCPSource;
var
  aOwner: TComponent;
  aConnectionList: TaOPCConnectionList;
begin
  Result := nil;
  if (Collection is TOPCConnectionCollection) then
    aOwner := TOPCConnectionCollection(Collection).ConnectionList
  else
    aOwner := nil;

  case ProtocolVersion of
    opv0: Result := TaOPCTCPSource.Create(aOwner);
    opv30: Result := TaOPCTCPSource_V30.Create(aOwner);
    opv31: Result := TaOPCTCPSource_V31.Create(aOwner);
    opv32: Result := TaOPCTCPSource_V32.Create(aOwner);
    opv33: Result := TaOPCTCPSource_V33.Create(aOwner);
  end;
  Result.SetSubComponent(true);

  if Assigned(Collection) then
  begin
    aConnectionList := (Collection as TOPCConnectionCollection).ConnectionList;

    Result.Description := aConnectionList.Description;
    Result.OnRequest := aConnectionList.OnRequest;
    Result.OnError := aConnectionList.OnError;
    Result.OnActivate := aConnectionList.OnActivate;
    Result.OnDeactivate := aConnectionList.OnDeactivate;

    Result.OnConnect := aConnectionList.OnConnect;
    Result.OnDisconnect := aConnectionList.OnDisconnect;
  end;
end;

constructor TOPCConnectionCollectionItem.CreateProtocol(Collection: TCollection; aProtocol: TOPCProtocolVersion);
begin
  inherited Create(Collection);

  FEnable := true;
  FProtocolVersion := aProtocol;

  FOPCSource := CreateOPCSource;

  FOPCObjectList := TDCObjectList.Create;//(False);
  FLookupsList := TStringList.Create;
end;

destructor TOPCConnectionCollectionItem.Destroy;
var
  i: integer;
begin
  // удаляем датчики и группы
  if Assigned(FOPCObjectList) then
  begin
    for i := FOPCObjectList.Count - 1 downto 0 do
      FOPCObjectList.Items[i].Free;
  end;
  FreeAndNil(FOPCObjectList);

  // удаляем справочники
  if Assigned(FLookupsList) then
  begin
    for i := FLookupsList.Count - 1 downto 0 do
      FLookupsList.Objects[i].Free;
  end;
  FreeAndNil(FLookupsList);

  // удаляем источник данных
  FreeAndNil(FOPCSource);

  inherited Destroy;
end;


procedure TOPCConnectionCollectionItem.FillHierarchy(aHierarchy: TDCObjectList; aRootID: string; aLevelCount: Integer;
  aKinds: TDCObjectKindSet);
var
  aNameSpace: TStrings;
begin
  aNameSpace := TStringList.Create;
  try
    OPCSource.FillNameSpaceStrings(aNameSpace, aRootID, aLevelCount, aKinds);
    StringsToHierarchy(aNameSpace, aHierarchy);
  finally
    aNameSpace.Free;
  end;
end;

{
function TOPCConnectionCollectionItem.GetCorrectName: string;
begin
  Result := OPCSource.RemoteMachine;
end;
}

function TOPCConnectionCollectionItem.GetDisplayName: string;
begin
  Result := Format('%s(%d)', [OPCSource.RemoteMachine, OPCSource.Port]);
end;

function TOPCConnectionCollectionItem.GetLookupByTableName(
  aRefTableName: string): TaOPCLookupList;
var
  i: integer;
begin
  if aRefTableName = '' then
    Exit(nil);

  for i := 0 to FLookupsList.Count - 1 do
  begin
    if aRefTableName = FLookupsList.Strings[i] then
    begin
      Result := TaOPCLookupList(FLookupsList.Objects[i]);
      exit;
    end;
  end;
  // не нашли нужный - создадим новый
  Result := TaOPCLookupList.Create(nil);
  FLookupsList.AddObject(aRefTableName, Result);
  Result.TableName := aRefTableName;
  Result.OPCSource := FOPCSource;
  Result.AutoUpdate := true;
end;

function TOPCConnectionCollectionItem.GetName: string;
begin
  if FName <> '' then
    Result := FName
  else
    Result := Format('%s(%d)', [OPCSource.RemoteMachine, OPCSource.Port]);
end;

function TOPCConnectionCollectionItem.GetOPCConnectionCollection:
  TOPCConnectionCollection;
begin
  Result := Collection as TOPCConnectionCollection;
end;

function TOPCConnectionCollectionItem.GetStatesLookup: TaOPCLookupList;
begin
  Result := GetLookupByTableName('States');
end;

// aNameSpace - иерархия полученная с сервера (строки)
// aStartObject - объект, стоящий на верхушке этой иерархии
procedure TOPCConnectionCollectionItem.InitObjectList(aNameSpace: TStrings; aStartObject: TDCObject);
var
  i: Integer;
  ALevel: Integer;
  aCaption: string;
  Data: TStrings;
  CurrStr: string;
  aObject, aNewObject, aNextObject: TDCObject;
  CaseStairs: integer;
  aRefTableName: string;
  aIndexStart: Integer;
  aLevelStart: Integer;
begin

  if not Assigned(aNameSpace) then
    Exit;

  aObject := aStartObject;

  // если уже есть добавленный в список объект, то пропускаем первую строку
  if Assigned(aStartObject) then
  begin
    aIndexStart := 1;
    aLevelStart := aStartObject.Level;
  end
  else
  begin
    aIndexStart := 0;
    aLevelStart := 0;
  end;


  // проходим по предварительно загруженной иерархии
  for i := aIndexStart to aNameSpace.Count - 1 do
  begin
    // вычитываем информационную строку и определяем грубину вложенности
    CurrStr  := GetBufStart(PChar(aNameSpace[i]), ALevel);
    ALevel := aLevelStart + ALevel;

    // вычитываем наименование объекта
    aCaption := ExtractData(CurrStr);

    // вычитываем данные по объекту, создаем и наполняем объект
    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if Data.Strings[1] = '1' then
      begin
        aNewObject := TDCObject.Create;
        aNewObject.Kind  := StrToIntDef(Data.Strings[2],1000);
        aNewObject.ServerChildCount := StrToIntDef(Data.Strings[5], 0);
      end
      else
      begin
        aNewObject := TSensor.Create;
        aNewObject.Kind := 0;

        with TSensor(aNewObject) do
        begin
          DisplayFormat := Data.Strings[2];
          SensorUnitName := Data.Strings[3];
//            SensorKind    := StrToIntDef(Data.Strings[1],0);
//
          aRefTableName := Data.Strings[6];
          if aRefTableName <> '' then
          begin
            LookupList := GetLookupByTableName(aRefTableName);
            if Data.Count >= 10 then
            begin
              if Data.Strings[9] = '1' then
                LookupList.ShowValue := svLeft
              else if Data.Strings[9] = '2' then
                LookupList.ShowValue := svRight;
            end;
          end;

          CaseStairs := StrToIntDef(Data.Strings[5],0);
          case CaseStairs of
            0: StairsOptions := [soIncrease,soDecrease];
            1: StairsOptions := [];
            2: StairsOptions := [soIncrease];
            3: StairsOptions := [soDecrease];
          end;
        end;
      end;

      // добавляем объект в список
      OPCObjectList.Add(aNewObject);
      aNewObject.Owner := Self;

      aNewObject.Name  := aCaption;
      aNewObject.IDStr := Data.Strings[0];

      // определяем родителя объекта и добавляемся в список детей родителя
      if aObject = nil then
        aNewObject.Parent := nil
      else if aObject.Level = ALevel then
        aNewObject.Parent := aObject.Parent
      else if aObject.Level = (ALevel - 1) then
        aNewObject.Parent := aObject
      else if aObject.Level > ALevel then
      begin
        aNextObject := aObject.Parent;
        while Assigned(aNextObject) and (aNextObject.Level >= ALevel) do
          aNextObject := aNextObject.Parent;
        aNewObject.Parent := aNextObject;
      end
      else
        raise Exception.CreateFmt('ALevel=%d - aObject.Level=%d',[ALevel, aObject.Level]);

      aObject := aNewObject;
    finally
      FreeAndNil(Data);
    end;
  end;

  // добавляем табличу состояний для отображения ошибок
  if OPCObjectList.Count > 0 then
    OPCSource.States := GetLookupByTableName('States');

  // сортируем дерево так, чтобы папки были сверху
  // 1 вариант - проверяем все объекты
  if not Assigned(aStartObject) then
  begin
    for i := 0 to OPCObjectList.Count - 1 do
      if OPCObjectList.Items[i].Childs.Count > 0 then
        OPCObjectList.Items[i].Childs.SortedKind := skFolderAndName;
  end
  // 2 вариант - проверяем только объекты подгруженные для указанного родителя
  else
  begin
    aStartObject.SortChilds(skFolderAndName);
  end;

end;

function TOPCConnectionCollectionItem.InitOPCObjectList(aObjectSID: string; aLevelCount: Integer): boolean;
var
  ALevel, i: Integer;
  lastLevel: Integer;
  CurrStr: string;
  Data: TStringList;
  newObject, lastObject, aParent: TDCObject;
  CaseStairs: integer;
  aRefTableName: string;

  aCaption : string;
begin
  //newObject := nil;
  lastObject := nil;
  lastLevel := 0;
  OPCObjectList.Clear;

  //if OPCSource.FNameSpaceCash.Count = 0 then
  if not OPCSource.GetNameSpace(aObjectSID, aLevelCount) then
    Exit(False);

  for i := 0 to OPCSource.FNameSpaceCash.Count - 1 do
  begin
    CurrStr  := GetBufStart(PChar(OPCSource.FNameSpaceCash[i]), ALevel);

    aCaption := ExtractData(CurrStr);


    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if Data.Strings[1] = '1' then // это группа
      begin
        // 0 - id (идентификатор)
        // 1 - вид объкта (датчик-0 или группа - 1)
        // 2 - Kind
        // 3 - NameEn
        // 4 - права доступа (rwahex)
        // 5 - ChildCount
        // 6 - SID
        // 7 - UseParentSID


        newObject := TDCObject.Create;
        newObject.Kind  := StrToIntDef(Data.Strings[2],1000);
        newObject.NameEn := Data.Strings[3];
        newObject.SID := Data.Strings[6];
        if Data.Count > 7 then
          newObject.UseParentSID := StrToBool(Data.Strings[7]);

      end
      else //это датчик
      begin
        // Наименование = ANode.Text
        // формат получаемых данных Data.Strings
        // 0 - id (идентификатор)
        // 1 - вид объкта (датчик-0 или группа - 1)
        // 2 - DisplayFormat  (форматирование)
        // 3 - UnitName       (единица измерения: строка)
        // 4 - вид датчика
        // 5 - Stairs (вид лесенки:
        //      0 - возрастает, убывает
        //      1 - лесенка
        //      2 - возрастает
        //      3 - убывает
        // 6 - refTableName (наименование таблицы-справочника расшифровки показаний датчика)
        // 7 - EnName
        // 8 - права доступа (rwahex)
        // 9 - RefValue
        // 10 - SID
        // 11 - UseParentSID

        newObject := TSensor.Create;
        newObject.Kind := StrToInt(Data.Strings[1]);
        newObject.NameEn := Data.Strings[7];
        newObject.SID := Data.Strings[10];
        if Data.Count > 11 then
          newObject.UseParentSID := StrToBool(Data.Strings[11]);

        with TSensor(newObject) do
        begin
          SensorKind := StrToIntDef(Data.Strings[1],0);
          DisplayFormat := Data.Strings[2];
          SensorUnitName := Data.Strings[3];

          //определим (и в случае необходимости создадим) LookupList для датчика
          aRefTableName := Data.Strings[6];
          if aRefTableName <> '' then
          begin
            LookupList := GetLookupByTableName(aRefTableName);
            if Data.Count >= 10 then
            begin
              if Data.Strings[9] = '1' then
                LookupList.ShowValue := svLeft
              else if Data.Strings[9] = '2' then
                LookupList.ShowValue := svRight;
            end;
          end;

          CaseStairs := StrToIntDef(Data.Strings[5],0);
          case CaseStairs of
            0:
            begin
              StairsOptions := [soIncrease,soDecrease];
              ImageIndex := 1
            end;
            1:
            begin
              StairsOptions := [];
              ImageIndex := 2
            end;
            2:
            begin
              StairsOptions := [soIncrease];
              ImageIndex := 3
            end;
            3:
            begin
              StairsOptions := [soDecrease];
              ImageIndex := 4
            end;
          end;
        end;
      end;
      OPCObjectList.Add(newObject);

      newObject.Owner := Self;
      newObject.Name  := aCaption;
      newObject.IDStr := Data.Strings[0];


      // проставляем родителя
      if lastObject = nil then
        newObject.Parent := nil
      else if lastLevel = ALevel then
        newObject.Parent := lastObject.Parent
      else if lastLevel = (ALevel - 1) then
        newObject.Parent := lastObject
      else if lastLevel > ALevel then
      begin
        aParent := lastObject.Parent;
        while lastLevel > ALevel do
        begin
          aParent := aParent.Parent;
          Dec(lastLevel);
        end;
        newObject.Parent := aParent;
      end;

      lastObject := newObject;
      lastLevel := ALevel;
    finally
      FreeAndNil(Data);
    end;
  end;

  // добавим в список лукапов подключения информацию о состояниях датчиков
  // если есть хоть один объект
  if OPCSource.FNameSpaceCash.Count > 0 then
    OPCSource.States := GetLookupByTableName('States');

  Result := True;
end;


//procedure TOPCConnectionCollectionItem.LoadLookups(aRegistrySection: string);
//var
//  i:integer;
//begin
//  for i := 0 to FLookupsList.Count - 1 do
//  begin
//    (FLookupsList.Objects[i] as TaOPCLookupList).RegistrySection := aRegistrySection;
//    (FLookupsList.Objects[i] as TaOPCLookupList).CheckForNewLookup;
//  end;
//end;

procedure TOPCConnectionCollectionItem.LoadChildsFromServer(aParent: TDCObject; aLevelCount: Integer);
var
  aParentID: Integer;
begin
  if Assigned(aParent) then
  begin
    // если по этому объекту все дети уже загружены, то
    // - либо очищаем и загружаем их по новой
    // - либо выходим (если равно)
//    if aParent.Childs.Count = aParent.ServerChildCount then
    if (aParent.Childs.Count <> 0) or (aParent.ServerChildCount = 0) then
      Exit
    else
    begin
      { TODO : Если на сервере количество изменилось, то можно все почистить и загрузить заново... }

    end;

    aParentID := aParent.ID;
  end
  else
  begin
    // если в списке уже есть объекты, то нужно
    // - либо очистить список и загрузить их по новой (для этого нужно ручками их удалить предварительно)
    // - либо ничего не делать, а ждать запроса с выбранным объктом этого списка
    if FOPCObjectList.Count > 0 then
      Exit;

    aParentID := 0;
  end;

  OPCSource.GetNameSpace(IntToStr(aParentID), aLevelCount);
  InitObjectList(OPCSource.FNameSpaceCash, aParent);
end;

procedure TOPCConnectionCollectionItem.LoadLookups(aAppStorage: TCustomIniFile;
  aKey: string);
var
  i: integer;
begin
  for i := 0 to FLookupsList.Count - 1 do
  begin
    (FLookupsList.Objects[i] as TaOPCLookupList).RegistrySection := aKey;
    (FLookupsList.Objects[i] as TaOPCLookupList).CheckForNewLookup(aAppStorage);
  end;
end;

procedure TOPCConnectionCollectionItem.SetEnable(const Value: boolean);
begin
  FEnable := Value;
end;

procedure TOPCConnectionCollectionItem.SetProtocolVersion(const Value: TOPCProtocolVersion);
var
  aSource: TaCustomOPCTCPSource;
begin
  if FProtocolVersion <> Value then
  begin
    FProtocolVersion := Value;
    // для реализации другого протокола используется другой источник данных
    aSource := CreateOPCSource;
    aSource.Assign(FOPCSource);
    FOPCSource.Free;
    
    FOPCSource := aSource;
  end;
end;

procedure TOPCConnectionCollectionItem.StringsToHierarchy(aNameSpace: TStrings; aHierarchy: TDCObjectList);
var
  ALevel, i: Integer;
  lastLevel: Integer;
  CurrStr: string;
  Data: TStringList;
  newObject, lastObject, aParent: TDCObject;
  CaseStairs: integer;
  aRefTableName: string;

  aCaption : string;

begin
  //newObject := nil;
  lastObject := nil;
  lastLevel := 0;

  for i := 0 to aNameSpace.Count - 1 do
  begin
    CurrStr  := GetBufStart(PChar(aNameSpace[i]), ALevel);
    aCaption := ExtractData(CurrStr);

    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if Data.Strings[1] = '1' then // это группа
      begin
        // 0 - id (идентификатор)
        // 1 - вид объкта (датчик-0 или группа - 1)
        // 2 - Kind
        // 3 - NameEn
        // 4 - права доступа (rwahex)
        // 5 - ChildCount
        // 6 - SID или FullSID-для верхнего элемента
        // 7 - UseParentSID

        newObject := TDCObject.Create;
        newObject.Kind  := StrToIntDef(Data.Strings[2],1000);
        newObject.NameEn := Data.Strings[3];
        newObject.SID := Data.Strings[6];
        if Data.Count > 7 then
          newObject.UseParentSID := StrToBool(Data.Strings[7]);

      end
      else //это датчик
      begin
        // Наименование = ANode.Text
        // формат получаемых данных Data.Strings
        // 0 - id (идентификатор)
        // 1 - вид объкта (датчик-0 или группа - 1)
        // 2 - DisplayFormat  (форматирование)
        // 3 - UnitName       (единица измерения: строка)
        // 4 - вид датчика
        // 5 - Stairs (вид лесенки:
        //      0 - возрастает, убывает
        //      1 - лесенка
        //      2 - возрастает
        //      3 - убывает
        // 6 - refTableName (наименование таблицы-справочника расшифровки показаний датчика)
        // 7 - EnName
        // 8 - права доступа (rwahex)
        // 9 - RefValue
        // 10 - SID или FullSID-для верхнего элемента
        // 11 - UseParentSID

        newObject := TSensor.Create;
        newObject.Kind := StrToInt(Data.Strings[1]);
        newObject.NameEn := Data.Strings[7];
        newObject.SID := Data.Strings[10];
        if Data.Count > 11 then
          newObject.UseParentSID := StrToBool(Data.Strings[11]);

        with TSensor(newObject) do
        begin
          SensorKind := StrToIntDef(Data.Strings[1],0);
          DisplayFormat := Data.Strings[2];
          SensorUnitName := Data.Strings[3];

          //определим (и в случае необходимости создадим) LookupList для датчика
          aRefTableName := Data.Strings[6];
          if aRefTableName <> '' then
          begin
            LookupList := GetLookupByTableName(aRefTableName);
            if Data.Count >= 10 then
            begin
              if Data.Strings[9] = '1' then
                LookupList.ShowValue := svLeft
              else if Data.Strings[9] = '2' then
                LookupList.ShowValue := svRight;
            end;
          end;

          CaseStairs := StrToIntDef(Data.Strings[5],0);
          case CaseStairs of
            0:
            begin
              StairsOptions := [soIncrease,soDecrease];
              ImageIndex := 1
            end;
            1:
            begin
              StairsOptions := [];
              ImageIndex := 2
            end;
            2:
            begin
              StairsOptions := [soIncrease];
              ImageIndex := 3
            end;
            3:
            begin
              StairsOptions := [soDecrease];
              ImageIndex := 4
            end;
          end;
        end;
      end;
      aHierarchy.Add(newObject);

      newObject.Owner := Self;
      newObject.Name  := aCaption;
      newObject.IDStr := Data.Strings[0];


      // проставляем родителя
      if lastObject = nil then
        newObject.Parent := nil
      else if lastLevel = ALevel then
        newObject.Parent := lastObject.Parent
      else if lastLevel = (ALevel - 1) then
        newObject.Parent := lastObject
      else if lastLevel > ALevel then
      begin
        aParent := lastObject.Parent;
        while lastLevel > ALevel do
        begin
          aParent := aParent.Parent;
          Dec(lastLevel);
        end;
        newObject.Parent := aParent;
      end;

      lastObject := newObject;
      lastLevel := ALevel;
    finally
      FreeAndNil(Data);
    end;
  end;

  // добавим в список лукапов подключения информацию о состояниях датчиков
  // если есть хоть один объект
  if OPCSource.FNameSpaceCash.Count > 0 then
    OPCSource.States := GetLookupByTableName('States');

end;

{ TOPCConnectionCollection }

constructor TOPCConnectionCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TOPCConnectionCollectionItem);
  //  FOwner := AOwner;
  FConnectionList := (AOwner as TaOPCConnectionList);
end;

destructor TOPCConnectionCollection.Destroy;
begin
  inherited Destroy;
end;

function TOPCConnectionCollection.Find(
  aOPCSource: TaCustomOPCSource): TOPCConnectionCollectionItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if aOPCSource = Items[i].OPCSource then
    begin
      Result := Items[i];
      break;
    end;
end;

function TOPCConnectionCollection.GetItem(
  Index: Integer): TOPCConnectionCollectionItem;
begin
  Result := TOPCConnectionCollectionItem(inherited Items[Index]);
end;

type
  TOPCConnectionCollectionComponent = class(TComponent)
  private
    FList: TOPCConnectionCollection;
  published
    property List: TOPCConnectionCollection read FList write FList;
  end;

procedure TOPCConnectionCollection.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TOPCConnectionCollection.LoadFromStream(Stream: TStream);
var
  Component: TOPCConnectionCollectionComponent;
begin
  Clear;
  Component := TOPCConnectionCollectionComponent.Create(nil);
  try
    Component.FList := Self;
    Stream.ReadComponentRes(Component);
  finally
    Component.Free;
  end;
end;

procedure TOPCConnectionCollection.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TOPCConnectionCollection.SaveToStream(Stream: TStream);
var
  Component: TOPCConnectionCollectionComponent;
begin
  Component := TOPCConnectionCollectionComponent.Create(nil);
  try
    Component.FList := Self;
    Stream.WriteComponentRes('OPCConnectionCollection', Component);
  finally
    Component.Free;
  end;
end;

{ TaOPCCustomConnectionList }

constructor TaOPCCustomConnectionList.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FItems := TOPCConnectionCollection.Create(Self);
end;

destructor TaOPCCustomConnectionList.Destroy;
begin
  FreeAndNil(FItems);
  inherited Destroy;
end;

function TaOPCCustomConnectionList.GetConnection(
  const Name: string): TOPCConnectionCollectionItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Items.Count - 1 do
  begin
    if Items[i].Name = Name then
    begin
      Result := Items[i];
      exit;
    end;
  end;
end;

procedure TaOPCCustomConnectionList.SetItems(Value: TOPCConnectionCollection);
begin
  FItems.Assign(Value);

end;

{ TaOPCConnectionList }

//procedure TaOPCConnectionList.Connect(aUser: string; aLoadNameSpace, aLoadLookups, aActivate: Boolean;
//  aStatusNotify: TOPCStatusNotify = nil; aPassword: string = '');
//var
//  i: integer;
//  Authorization: TaDCAuthorization;
//  Connection: TOPCConnectionCollectionItem;
//  aCancel: Boolean;
//begin
//  if Items.Count = 0 then
//    exit;
//
//  aCancel := False;
//  Authorization := TaDCAuthorization.Create(nil);
//  try
//    Authorization.ReadCommandLineExt;
//    if Authorization.User = '' then
//      Authorization.User := aUser;
//    if Authorization.Password = '' then
//      Authorization.Password := aPassword;
//
//
//    for i := 0 to Items.Count - 1 do
//    begin
//      Connection := Items[i];
//      if Connection.OPCSource.Connected then
//        Continue;
//
//      // 1. Авторизация
//      if Assigned(aStatusNotify) then
//      begin
////        aStatusNotify(
////          Format(Connection.OPCSource.GetStringRes(idxConnection_Authorization),
////          [Connection.Name, Connection.OPCSource.RemoteMachine, Connection.OPCSource.Port]), aCancel);
//        aStatusNotify(
//          Format(Connection.OPCSource.GetStringResStr('StateAuthorization'),
//          [Connection.Name, Connection.OPCSource.RemoteMachine, Connection.OPCSource.Port]), aCancel);
//
//
//        if aCancel then
//          raise EOPCTCPOperationCanceledException.Create(
//            Connection.OPCSource.GetStringRes(idxTCPCommand_OperationCanceledByUser));
//      end;
//
//      Authorization.OPCSource := Connection.OPCSource;
////      if not Authorization.CheckPermissions then
//      if not Authorization.Login then
//      begin
//        if not Authorization.Execute(nil, True) then
//          raise EOPCTCPOperationCanceledException.Create(
//            Connection.OPCSource.GetStringRes(idxTCPCommand_OperationCanceledByUser));
//      end;
//      Connection.OPCSource.User := Authorization.User;
//      Connection.OPCSource.Password := Authorization.Password;
//
//      // 2. Загрузка иерархии
//      if aLoadNameSpace then
//      begin
//        if Assigned(aStatusNotify) then
////          aStatusNotify(
////            Format(Connection.OPCSource.GetStringRes(idxConnection_LoadNameSpace),
////            [Items[i].Name, Items[i].OPCSource.RemoteMachine, Items[i].OPCSource.Port]), aCancel);
//          aStatusNotify(
//            Format(Connection.OPCSource.GetStringResStr('StateLoadNameSpace'),
//            [Items[i].Name, Items[i].OPCSource.RemoteMachine, Items[i].OPCSource.Port]), aCancel);
//
//        if aCancel then
//          raise EOPCTCPOperationCanceledException.Create(
//            Connection.OPCSource.GetStringRes(idxTCPCommand_OperationCanceledByUser));
//
//        Connection.LoadChildsFromServer(nil, 2);
////        Connection.OPCSource.GetNameSpace;
////        Connection.InitObjectList;
//      end;
//
//      // 3. Загрузка справочников
//      if aLoadLookups then
//      begin
//        if Assigned(aStatusNotify) then
////          aStatusNotify(Format(Connection.OPCSource.GetStringRes(idxConnection_LoadLookups),
////            [Items[i].Name, Items[i].OPCSource.RemoteMachine, Items[i].OPCSource.Port]), aCancel);
//          aStatusNotify(Format(Connection.OPCSource.GetStringResStr('StateLoadLookups'),
//            [Items[i].Name, Items[i].OPCSource.RemoteMachine, Items[i].OPCSource.Port]), aCancel);
//
//        if aCancel then
//          raise EOPCTCPOperationCanceledException.Create(
//            Connection.OPCSource.GetStringRes(idxTCPCommand_OperationCanceledByUser));
//
//        Connection.LoadLookups(nil, '');
//      end;
//
//      // 4. Активируем сбор данных в потоке
//      if aActivate then
//        Connection.OPCSource.Active := true;
//    end;
//  finally
//    Authorization.Free;
//  end;
//end;

function TaOPCConnectionList.FindObjectByID(aConnectionID, ID: integer): TDCObject;
begin
  Result := nil;
  if (aConnectionID >= Items.Count) or (aConnectionID < 0) then
    exit;
  Result := Items[aConnectionID].OPCObjectList.FindObjectByID(ID);
end;

function TaOPCConnectionList.FindObjectBySourceAndID(aOPCSource: TaCustomOPCSource; ID: integer): TDCObject;
begin
  Result := FindObjectByID(IndexOfOPCSource(aOPCSource), ID);
end;

function TaOPCConnectionList.GetOPCSourceByConnectionName(aConnectionName: string): TaCustomOPCSource;
var
  i: Integer;
begin
  i := IndexOfConnectionName(aConnectionName);
  if i > -1 then
    Result := TaCustomOPCTCPSource(Items[i].OPCSource)
  else
    Result := nil;
end;

function TaOPCConnectionList.IndexOf(aObject: TObject): integer;
begin
  Result := 0;
  while (Result < Items.Count) and (Items[Result] <> aObject) do
    Inc(Result);
  if Result = Items.Count then
    Result := -1;
end;

function TaOPCConnectionList.IndexOfConnectionID(aID: Integer): Integer;
begin
  Result := 0;
  while (Result < Items.Count) and (Items[Result].ID <> aID) do
    Inc(Result);
  if Result = Items.Count then
    Result := -1;
end;

function TaOPCConnectionList.IndexOfConnectionName(aName: string): Integer;
begin
  Result := 0;
  while (Result < Items.Count) and not AnsiSameText(Items[Result].Name, aName) do
    Inc(Result);
  if Result = Items.Count then
    Result := -1;
end;

function TaOPCConnectionList.IndexOfOPCSource(
  aOPCSource: TaCustomOPCSource): Integer;
begin
  Result := 0;
  while (Result < Items.Count) and (Items[Result].OPCSource <> aOPCSource) do
    Inc(Result);
  if Result = Items.Count then
    Result := -1;
end;

procedure TaOPCConnectionList.LoadSettings(aCustomIniFile: TCustomIniFile;
  aSectionName: string; aNotClearItems: Boolean = False);
var
  i: integer;
  aConnectionName: string;

  aOPCConnection: TOPCConnectionCollectionItem;
  aConnectionSection: string;
  aConnections: TStrings;
begin
  // чистим список, если не указано обратное
  if not aNotClearItems then
  	Items.Clear;

  aConnections := TStringList.Create;
  try
    aCustomIniFile.ReadSectionValues(aSectionName + '\Connection', aConnections);

    for i := 0 to aConnections.Count - 1 do
    begin
      aConnectionSection := aSectionName + '\Connection\' + aConnections.ValueFromIndex[i];
      aConnectionName := aCustomIniFile.ReadString(aConnectionSection, 'Name', '');

      // повторяющиеся пропускаем
      if IndexOfConnectionName(aConnectionName) <> -1 then
        Continue;

      aOPCConnection := TOPCConnectionCollectionItem.Create(Items);

      aOPCConnection.ID := aCustomIniFile.ReadInteger(aConnectionSection, 'ID', i);
      aOPCConnection.Name := aConnectionName;
      //aCustomIniFile.ReadString(aConnectionSection, 'Name', '');

      aOPCConnection.Enable := aCustomIniFile.ReadBool(aConnectionSection, 'Enable', true);
      aOPCConnection.ProtocolVersion :=
         TOPCProtocolVersion(aCustomIniFile.ReadInteger(aConnectionSection, 'Protocol', Ord(opv30)));

      aOPCConnection.OPCSource.RemoteMachine := aCustomIniFile.ReadString(aConnectionSection, 'RemoteMashine', '');
      aOPCConnection.OPCSource.Port := aCustomIniFile.ReadInteger(aConnectionSection, 'Port', cDefPort);
      aOPCConnection.OPCSource.AltAddress := aCustomIniFile.ReadString(aConnectionSection, 'AltAddress', '');

      aOPCConnection.OPCSource.User := aCustomIniFile.ReadString(aConnectionSection, 'UserName', '');
      aOPCConnection.OPCSource.Password := aCustomIniFile.ReadString(aConnectionSection, 'Password', '');

      aOPCConnection.OPCSource.ConnectTimeOut := aCustomIniFile.ReadInteger(aConnectionSection, 'ConnectTimeOut', cDefConnectTimeout);
      aOPCConnection.OPCSource.ReadTimeOut := aCustomIniFile.ReadInteger(aConnectionSection, 'ReadTimeOut', cDefReadTimeout);
      aOPCConnection.OPCSource.Interval := aCustomIniFile.ReadInteger(aConnectionSection, 'Interval', 1000);

      aOPCConnection.OPCSource.Encrypt := aCustomIniFile.ReadBool(aConnectionSection, 'Encrypt', cDefEncrypt);
      aOPCConnection.OPCSource.CompressionLevel := aCustomIniFile.ReadInteger(aConnectionSection, 'CompressionLevel', cDefCompressionLevel);

      aOPCConnection.OPCSource.ServerTimeID := aCustomIniFile.ReadString(aConnectionSection, 'ServerTimeID', '');
      aOPCConnection.OPCSource.Language := aCustomIniFile.ReadString(aConnectionSection, 'Language', 'ru');

      aOPCConnection.OPCSource.Description := Description;

      aOPCConnection.OPCSource.OnError := FOnError;
      aOPCConnection.OPCSource.OnActivate := FOnActivate;
      aOPCConnection.OPCSource.OnDeActivate := FOnDeActivate;
      aOPCConnection.OPCSource.OnRequest := FOnRequest;

    end;
  finally
    aConnections.Free;
  end;
end;

procedure TaOPCConnectionList.SaveSettings(aCustomIniFile: TCustomIniFile;
  aSectionName: string);
var
  i: integer;
  aConnectionSection: string;
  aConnectionName: string;
  aConnections: TStringList;
begin
  aConnections := TStringList.Create;
  try
    aCustomIniFile.ReadSectionValues(aSectionName + '\Connection', aConnections);
    for i := 0 to aConnections.Count - 1 do
    begin
      aConnectionName := aConnections.ValueFromIndex[i];
      if Connections[aConnectionName] = nil then
      begin
        aCustomIniFile.DeleteKey(aSectionName + '\Connection', aConnectionName);
        aCustomIniFile.EraseSection(aSectionName + '\Connection\' + aConnectionName);
      end;
    end;
  finally
    aConnections.Free;
  end;
  for i := 0 to Items.Count - 1 do
    aCustomIniFile.WriteString(aSectionName + '\Connection', Items[i].Name, Items[i].Name);

  for i := 0 to Items.Count - 1 do
  begin
    aConnectionSection := aSectionName + '\Connection\' + Items[i].Name;

    aCustomIniFile.WriteInteger(aConnectionSection, 'ID', Items[i].ID);
    aCustomIniFile.WriteString(aConnectionSection, 'Name', Items[i].Name);
    
    aCustomIniFile.WriteBool(aConnectionSection, 'Enable', Items[i].Enable);
    aCustomIniFile.WriteInteger(aConnectionSection, 'Protocol', Ord(Items[i].ProtocolVersion));

    aCustomIniFile.WriteString(aConnectionSection, 'RemoteMashine', Items[i].OPCSource.MainHost);
    aCustomIniFile.WriteInteger(aConnectionSection, 'Port', Items[i].OPCSource.MainPort);
    aCustomIniFile.WriteString(aConnectionSection, 'AltAddress', Items[i].OPCSource.AltAddress);

    aCustomIniFile.WriteInteger(aConnectionSection, 'ConnectTimeOut', Items[i].OPCSource.ConnectTimeOut);
    aCustomIniFile.WriteInteger(aConnectionSection, 'ReadTimeOut', Items[i].OPCSource.ReadTimeOut);
    aCustomIniFile.WriteInteger(aConnectionSection, 'Interval', Items[i].OPCSource.Interval);

    aCustomIniFile.WriteBool(aConnectionSection, 'Encrypt', Items[i].OPCSource.Encrypt);
    aCustomIniFile.WriteInteger(aConnectionSection, 'CompressionLevel', Items[i].OPCSource.CompressionLevel);

    aCustomIniFile.WriteString(aConnectionSection, 'ServerTimeID', Items[i].OPCSource.ServerTimeID);
  end;
end;

procedure TaOPCConnectionList.SetActive(const Value: boolean);
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items[i].OPCSource.Active := Value;
end;

procedure TaOPCConnectionList.SetDescription(const Value: string);
var
  i: Integer;
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    for i := 0 to Items.Count - 1 do
      Items[i].OPCSource.Description := FDescription;
  end;
end;

procedure TaOPCConnectionList.SetOnActivate(const Value: TNotifyEvent);
var
  i: Integer;
begin
  //  if FOnActivate <> Value then
  begin
    FOnActivate := Value;
    for i := 0 to Items.Count - 1 do
      Items[i].OPCSource.OnActivate := FOnActivate;
  end;
end;

procedure TaOPCConnectionList.SetOnConnect(const Value: TNotifyEvent);
var
  i: Integer;
begin
  FOnConnect := Value;
  for i := 0 to Items.Count - 1 do
    Items[i].OPCSource.OnConnect := FOnConnect;
end;

procedure TaOPCConnectionList.SetOnDeactivate(const Value: TNotifyEvent);
var
  i: Integer;
begin
  //  if FOnDeactivate <> Value then
  begin
    FOnDeactivate := Value;
    for i := 0 to Items.Count - 1 do
      Items[i].OPCSource.OnDeactivate := FOnDeactivate;
  end;
end;

procedure TaOPCConnectionList.SetOnDisconnect(const Value: TNotifyEvent);
var
  i: Integer;
begin
  FOnDisconnect := Value;
  for i := 0 to Items.Count - 1 do
    Items[i].OPCSource.OnDisconnect := FOnDisconnect;
end;

procedure TaOPCConnectionList.SetOnError(const Value: TMessageStrEvent);
var
  i: Integer;
begin
  //  if FOnError <> Value then
  begin
    FOnError := Value;
    for i := 0 to Items.Count - 1 do
      Items[i].OPCSource.OnError := FOnError;
  end;
end;

procedure TaOPCConnectionList.SetOnRequest(const Value: TNotifyEvent);
var
  i: Integer;
begin
  //  if FOnRequest <> Value then
  begin
    FOnRequest := Value;
    for i := 0 to Items.Count - 1 do
      Items[i].OPCSource.OnRequest := FOnRequest;
  end;
end;

end.

