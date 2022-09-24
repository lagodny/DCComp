{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2022 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit uDCObjects;

interface

uses
  System.Classes,
  System.Generics.Collections, System.Generics.Defaults;

const
  sSIDDelimiter = '.';
  sSIDIdentifier = '$';

type
  TDCObject = class;

  TDCStairsOptions = (soIncrease, soDecrease);
  TDCStairsOptionsSet = set of TDCStairsOptions;

  TDataKind = (
    dkValue = 0, // показания
    dkState = 1, // состояния
    dkUser = 2); // запись пользователя

  TDataKindSet = set of TDataKind;

  TDCObjectKind = (
    okSensor = 0, // датчик
    okFlowmeter = 1,

    okStorageTank = 10, // ПК №1 Емкость хранения
    okCupagTank = 11, // ПК №1 Купажная пара
    okCounterEnergy9 = 12, // Счетчики Энергия

    okP2StorageTank = 13, // ПК №2 Ёмкость хранения
    okP2SugarTank = 14, // ПК №2 Сахарная ёмкость
    okP2LemonTank = 15, // ПК №2 Лимонка ёмкость
    okP2CupagTank = 16, // ПК №2 Купажная ёмкость
    okP2CupagPara = 17, // ПК №2 Купажная ёмкость

    ok_scs_Client = 50, // клиент SCS
    ok_scs_ClientGroup = 51, // группа клиентов SCS

    ok_scs_TrackerGroup = 59, // группа трекеров

    ok_scs_TrackerTDC = 60, // трекер TDC
    ok_scs_TrackerTeltonika = 61, // трекер Телтоника
    ok_scs_TrackerAndroid = 62, // трекер Android
    ok_scs_TrackerCicada = 63, // трекер Cicada
    ok_scs_TrackerWialonIPS = 64, // трекер с протоколом WialonIPS
    ok_scs_TrackerBCE = 65, // трекер с протоколом BCE

    okStorageTanks = 100,  // ПК №1 Фрейм "Ёмкости хранения"

    ok_kz_TanksGroup = 101, // Кременчуг : группа емкостей
    ok_dn_StorageTank = 201, // Херсон: емкость хранения


    okUnknown = 255);

//        1: OPCObject := TDCObject(FindSensorByID(ObjectID));
//        2: OPCObject := DCSrvcSettings.Groups.FindObjectByID(ObjectID);
//
//        5: OPCObject := DCSrvcSettings.SystemControls.FindObjectByID(ObjectID);
//        6: OPCObject := DCSrvcSettings.SystemControlGroups.FindObjectByID(ObjectID);
//
//        7: OPCObject := DCSrvcSettings.Projects.FindObjectByID(ObjectID);

  TDCObjectTable = (
    otUnknown = 0,

    otSensors = 1,
    otSensorGroups = 2,

    otSystemControls = 5,
    otSystemControlGroups = 6,

    otProjects = 7,
    otProjectGroups = 8
  );

  TDCObjectKindSet = set of TDCObjectKind;

  TDCSortedKind = (skNone, skID, skName, skFullSID, skFolderAndName);

  TDCObjectList = class;

  TForEachProc = reference to procedure (aItem: TDCObject);// of object;
  TForEachWithBreakFunc = reference to function (aItem: TDCObject): Boolean; // of object;

  TDCObject = class(TInterfacedObject)
  private
    FId: integer;
    FParentID: integer;
    FParent: TDCObject;
    FChilds: TDCObjectList;
    FName: string;
    FNameEn: string;
    FKind: integer;
    FActive: boolean;
    FOwner: TObject;
    FIsDeleted: Boolean;
    FTable: TDCObjectTable;
    FServerChildCount: Integer;
    FSID: string;
    FUseParentSID: Boolean;
    FFullSID: string;
    FStrParam: string;
    procedure SetOwner(const Value: TObject);
    procedure SetNameEn(const Value: string);
    procedure SetIDStr(const Value: string);
    function GetIDStr: string;
    function GetDCKind: TDCObjectKind;
    procedure SetKind(const Value: integer);
    procedure SetParentID(const Value: integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: TDCObject);
    function GetFullName: string;
    function GetSensorCount: integer;
    procedure SetIsDeleted(const Value: Boolean);
    procedure SetTable(const Value: TDCObjectTable);
    function GetLevel: integer;
    procedure SetServerChildCount(const Value: Integer);

    procedure UpdateFullSID;
    procedure SetUseParentSID(const Value: Boolean);
  protected
    procedure SetId(const Value: integer); virtual;
    procedure SetSID(const Value: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function GetRoot: TDCObject;
    function GetFullNameExt(aParent: TDCObject): string;

    function IsChildOf(aParent: TDCObject): Boolean;
    procedure SortChilds(aSortKind: TDCSortedKind);
    procedure FillChildsList(aChildsList: TDCObjectList; LevelCount: integer = -1;
      OPCKindSet: TDCObjectKindSet = [okSensor]);
    procedure SetChildsIsDeleted(const Value: Boolean; aRecurcive: Boolean);

    // выполняет aProc для каждого элемента
    procedure ForEach(aProc: TForEachProc);

    // выполняет функцию aFunc для каждого элемента
    // прерывается как только aFunc вернет True
    function ForEachWithBreak(aFunc: TForEachWithBreakFunc): Boolean;

    property ID: integer read FId write SetId;
    property IdStr: string read GetIDStr write SetIDStr;
    property Name: string read FName write SetName;
    property NameEn: string read FNameEn write SetNameEn;
    property Owner: TObject read FOwner write SetOwner;
    property Parent: TDCObject read FParent write SetParent;
    property ParentID: integer read FParentID write SetParentID;
    property FullName: string read GetFullName;

    property SID: string read FSID write SetSID;
    property FullSID: string read FFullSID;
    property UseParentSID: Boolean read FUseParentSID write SetUseParentSID;


    property Kind: integer read FKind write SetKind; //вид объекта
    property DCKind: TDCObjectKind read GetDCKind;
    property Table: TDCObjectTable read FTable write SetTable; // таблица в которой он хранится

    property Active: boolean read FActive write FActive;

    property IsDeleted: Boolean read FIsDeleted write SetIsDeleted;

    property Childs: TDCObjectList read FChilds;
    property ServerChildCount: Integer read FServerChildCount write SetServerChildCount;

    property SensorCount: integer read GetSensorCount;
    property Level: integer read GetLevel;

    property StrParam: string read FStrParam write FStrParam;
  end;

  // список не является владельцем, объекты не уничтожаются при уничтожении списка!!!
  // для полного освобождения используйте ClearAndFreeObjects вместо Free
  TDCObjectList = class(TList<TDCObject>)
  private
    FByID, FByName, FByFullSID: TDCObjectList;

    FSortedKind: TDCSortedKind;
    procedure SetSortKind(const Value: TDCSortedKind);
    procedure FreeIndexes;
  public
    destructor Destroy; override;

    function FindObjectByID(ObjectID: integer): TDCObject;
    function FindObjectByName(ObjectName: string): TDCObject;
    function FindObjectByFullSID(aFullSID: string): TDCObject;

    procedure Assign(aSource: TDCObjectList);
    procedure Resort;

    function AddInSorted(aObject: TDCObject; aNotAddIfExists: Boolean): boolean;

    procedure FreeObjects;
    class procedure ClearAndFreeObjects(var aList: TDCObjectList);

    property SortedKind: TDCSortedKind read FSortedKind write SetSortKind;
  end;

  TDCObjectIDComparer = class (TComparer<TDCObject>)
    function Compare(const Left, Right: TDCObject): Integer; override;
  end;

  TDCObjectNameComparer = class (TComparer<TDCObject>)
    function Compare(const Left, Right: TDCObject): Integer; override;
  end;

  TDCObjectFullSIDComparer = class (TComparer<TDCObject>)
    function Compare(const Left, Right: TDCObject): Integer; override;
  end;

  TDCObjectFolderAndNameComparer = class (TComparer<TDCObject>)
    function Compare(const Left, Right: TDCObject): Integer; override;
  end;

  TDCCustomSensor = class(TDCObject)
  private
    FSensorUnitName: string;
    FStairsOptions: TDCStairsOptionsSet;
    FDisplayFormat: string;
    FIsDate: boolean;
    procedure SetDisplayFormat(const Value: string);
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
    procedure SetSensorUnitName(const Value: string);
    // понизим видимость, чтобы отследить, где оно используется
    //class function UnitName: string;
  public
    property IsDate: boolean read FIsDate;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property SensorUnitName: string read FSensorUnitName write SetSensorUnitName;
    property StairsOptions: TDCStairsOptionsSet read FStairsOptions write SetStairsOptions;
  end;



  TDCBufferDataRec = packed record
    Time: TDateTime;
    Value: extended;
  end;

  TDCSensorDataRec = record
    Value: extended;
    ErrorCode: integer;
    Time: TDateTime;
  end;

  TDCSensorDataRec_V30 = packed record
    Value: Double;
    ErrorCode: Int16;
    Time: TDateTime;
  end;

const
   cDC_SCS_Trackers: TDCObjectKindSet = [
     ok_scs_TrackerTDC,
     ok_scs_TrackerTeltonika,
     ok_scs_TrackerAndroid,
     ok_scs_TrackerCicada,
     ok_scs_TrackerWialonIPS,
     ok_scs_TrackerBCE
   ];


//function CompareByID(const Item1, Item2: TDCObject): Integer;
//function CompareByName(const Item1, Item2: TDCObject): Integer;

function DC_TableTypeToName(aTableType: TDCObjectTable): string;
function DC_TableNameToType(aStr: string): TDCObjectTable;
function IntToDCObjectTable(aInt: Integer): TDCObjectTable;

function IntToStairsOptionsSet(aInt: Integer): TDCStairsOptionsSet;
function StairsOptionsSetToInt(aStairs: TDCStairsOptionsSet): Integer;

function IsSID(aAddr: string): Boolean;

implementation

uses
  Types,
  Math,
  SysUtils;

const
  // имена таблиц, из которых мы читаем наши объекты
  sUnknown = '';
  sSensors = 'Sensors';
  sSensorGroups = 'Hierarchy';
  sSystemControls = 'SystemControl';
  sSystemControlGroups = 'SystemControlGroup';
  sProjects = 'Projects';
  sProjectGroups = 'ProjectGroups';

//var
//  DCObjectIDComparer: IComparer<TDCObject>;
//  DCObjectNameComparer: IComparer<TDCObject>;
//  DCObjectFullSIDComparer: IComparer<TDCObject>;
//  DCObjectFolderAndNameComparer: IComparer<TDCObject>;


function IsSID(aAddr: string): Boolean;
begin
  if Length(aAddr) = 0 then
    Exit(False)
  else
    Result := Copy(aAddr, 1, 1) = '$';
end;

function DC_TableTypeToName(aTableType: TDCObjectTable): string;
begin
  case aTableType of
    otUnknown:
      Result := sUnknown;
    otSensors:
      Result := sSensors;
    otSensorGroups:
      Result := sSensorGroups;
    otSystemControls:
      Result := sSystemControls;
    otSystemControlGroups:
      Result := sSystemControlGroups;
    otProjects:
      Result := sProjects;
    otProjectGroups:
      Result := sProjectGroups;
    else
      Result := '';
  end;
end;

function DC_TableNameToType(aStr: string): TDCObjectTable;
begin
  Result := otUnknown;

  if SameText(aStr, sUnknown) then
    Result := otUnknown
  else if SameText(aStr, sSensors) then
    Result := otSensors
  else if SameText(aStr, sSensorGroups) then
    Result := otSensorGroups
  else if SameText(aStr, sSystemControls) then
    Result := otSystemControls
  else if SameText(aStr, sSystemControlGroups) then
    Result := otSystemControlGroups
  else if SameText(aStr, sProjects) then
    Result := otProjects
  else if SameText(aStr, sProjectGroups) then
    Result := otProjectGroups;

end;

function IntToDCObjectTable(aInt: Integer): TDCObjectTable;
begin
  case aInt of
    0: Result := otUnknown;

    1: Result := otSensors;
    2: Result := otSensorGroups;

    5: Result := otSystemControls;
    6: Result := otSystemControlGroups;

    7: Result := otProjects;
    8: Result := otProjectGroups;

    else
      Result := otUnknown;
  end;
end;

function IntToStairsOptionsSet(aInt: Integer): TDCStairsOptionsSet;
begin
  case aInt of
    0: Result := [soIncrease, soDecrease];
    1: Result := [];
    2: Result := [soIncrease];
    3: Result := [soDecrease];
  end;
end;

function StairsOptionsSetToInt(aStairs: TDCStairsOptionsSet): Integer;
begin
  if aStairs = [soIncrease, soDecrease] then
    Result := 0
  else if aStairs = [] then
    Result := 1
  else if aStairs = [soIncrease] then
    Result := 2
  else if aStairs = [soDecrease] then
    Result := 3
  else
    raise Exception.Create('Unknown Stairs');

end;


function CompareByID(const Item1, Item2: TDCObject): Integer;
begin
  Result := CompareValue(Item1.ID, Item2.ID);
end;

function CompareByFullName(const Item1, Item2: TDCObject): Integer;
begin
  Result := AnsiCompareText(Item1.FullName, Item2.FullName);
end;

//function CompareByName(const Item1, Item2: TDCObject): Integer;
//begin
//  Result := AnsiCompareText(Item1.Name, Item2.Name);
//end;

function CompareByFullSID(const Item1, Item2: TDCObject): Integer;
begin
  Result := AnsiCompareText(Item1.FullSID, Item2.FullSID);
end;

function CompareByFolderAndName(const Item1, Item2: TDCObject): Integer;
begin
  if Item1.ClassName = Item2.ClassName then
    Result := AnsiCompareText(Item1.Name, Item2.Name)
  else
    if Item1 is TDCCustomSensor then
      Result := 1
    else
      Result := -1;
end;


{ TOPCObjectList }

function TDCObjectList.AddInSorted(aObject: TDCObject; aNotAddIfExists: Boolean): Boolean;
var
  aPosition: Integer;
  aFound: Boolean;
begin
{
  case SortedKind of
    skNone:
    begin
      aPosition := Count;
      aFound := False;
    end;

    skID:
      aFound := BinarySearch(aObject, aPosition, TDCObjectIDComparer.Create);
    skName:
      aFound := BinarySearch(aObject, aPosition, TDCObjectNameComparer.Create);
    skFullSID:
      aFound := BinarySearch(aObject, aPosition, TDCObjectFullSIDComparer.Create);
    skFolderAndName:
      aFound := BinarySearch(aObject, aPosition, TDCObjectFolderAndNameComparer.Create);

    else
    begin
      aPosition := Count;
      aFound := False;
    end;
  end;

  Result := (not aFound) or (not aNotAddIfExists);

  if Result then
    Insert(aPosition, aObject);
}
//    Add(aObject);

  case SortedKind of
    skNone:
    begin
      aPosition := Count;
      aFound := False;
    end;

    skID:
      aFound := BinarySearch(aObject, aPosition,
        TComparer<TDCObject>.Construct(
          function (const Left, Right: TDCObject): Integer
          begin
            Result := CompareValue(Left.ID, Right.ID);
          end
        ));

    skName:
      aFound := BinarySearch(aObject, aPosition,
        TComparer<TDCObject>.Construct(
          function (const Left, Right: TDCObject): Integer
          begin
            Result := AnsiCompareText(Left.Name, Right.Name);
          end
        ));

    skFullSID:
      aFound := BinarySearch(aObject, aPosition,
        TComparer<TDCObject>.Construct(
          function (const Left, Right: TDCObject): Integer
          begin
            Result := AnsiCompareText(Left.FullSID, Right.FullSID);
          end
        ));

    skFolderAndName:
      aFound := BinarySearch(aObject, aPosition,
        TComparer<TDCObject>.Construct(
          function (const Left, Right: TDCObject): Integer
          begin
            Result := CompareByFolderAndName(Left, Right);
          end
        ));

    else
    begin
      aPosition := Count;
      aFound := False;
    end;
  end;

  Result := (not aFound) or (not aNotAddIfExists);

  if Result then
    Insert(aPosition, aObject);


end;

procedure TDCObjectList.Assign(aSource: TDCObjectList);
var
  i: Integer;
begin
  FreeIndexes;

  Clear;
  for i := 0 to aSource.Count - 1 do
    Add(aSource[i]);
end;

function TDCObjectList.FindObjectByFullSID(aFullSID: string): TDCObject;
var
  L, H, I: Integer;
  itemFullSID: string;
  Sl: TDCObjectList;
begin
  Result := nil;

  if SortedKind <> skFullSID then
  begin
    if not Assigned(FByFullSID) then
    begin
      FByFullSID := TDCObjectList.Create;
      FByFullSID.Assign(Self);
      FByFullSID.SortedKind := skFullSID;
    end;
    Exit(FByFullSID.FindObjectByFullSID(aFullSID));
  end;

  SortedKind := skFullSID;
  Sl := Self;

  L := 0;
  H := Sl.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    itemFullSID := TDCObject(Sl.Items[i]).FullSID;

    if AnsiCompareText(itemFullSID, aFullSID) < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if AnsiSameText(itemFullSID, aFullSID) then
      begin
        Result := TDCObject(Sl.Items[i]);
        L := I;
      end;
    end;
  end;
end;

function TDCObjectList.FindObjectByID(ObjectID: integer): TDCObject;
var
  L, H, I: Integer;
  Item1: integer;
  Sl: TDCObjectList;
begin
  Result := nil;
  if Count = 0 then
    exit;

  if SortedKind <> skID then
  begin
    if not Assigned(FByID) then
    begin
      FByID := TDCObjectList.Create;
      FByID.Assign(Self);
      FByID.SortedKind := skID;
    end;
    Exit(FByID.FindObjectByID(ObjectID));
  end;

  SortedKind := skID;

  Sl := Self;

  L := 0;
  H := Sl.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    Item1 := TDCObject(Sl.Items[i]).ID;

    if Item1 < ObjectID then
      L := I + 1
    else
    begin
      H := I - 1;
      if Item1 = ObjectID then
      begin
        Result := TDCObject(Sl.Items[i]);
        L := I;
      end;
    end;
  end;
end;

function TDCObjectList.FindObjectByName(ObjectName: string): TDCObject;
var
  L, H, I: Integer;
  ItemName: string;
  Sl: TDCObjectList;
begin
  Result := nil;

  if SortedKind <> skName then
  begin
    if not Assigned(FByName) then
    begin
      FByName := TDCObjectList.Create;
      FByName.Assign(Self);
      FByName.SortedKind := skName;
    end;
    Exit(FByName.FindObjectByName(ObjectName));
  end;

  SortedKind := skName;
  Sl := Self;

  L := 0;
  H := Sl.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    ItemName := TDCObject(Sl.Items[i]).FullName;

    //if ItemName < ObjectName then
    if AnsiCompareText(ItemName, ObjectName) < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if AnsiSameText(ItemName, ObjectName) then
      begin
        Result := TDCObject(Sl.Items[i]);
        L := I;
      end;
    end;
  end;
end;

procedure TDCObjectList.FreeIndexes;
begin
  FreeAndNil(FByID);
  FreeAndNil(FByName);
  FreeAndNil(FByFullSID);
end;

procedure TDCObjectList.FreeObjects;
var
  i: Integer;
begin
  FreeIndexes;
  for i := Count - 1 downto 0 do
    Items[i].Free;
  Clear;
end;

procedure TDCObjectList.Resort;
begin
  case FSortedKind of
    skNone: ;
    skID: Sort(TComparer<TDCObject>.Construct(CompareByID));
    skName: Sort(TComparer<TDCObject>.Construct(CompareByFullName));
    skFullSID: Sort(TComparer<TDCObject>.Construct(CompareByFullSID));
    skFolderAndName: Sort(TComparer<TDCObject>.Construct(CompareByFolderAndName));
  end;
end;

class procedure TDCObjectList.ClearAndFreeObjects(var aList: TDCObjectList);
//var
//  i: Integer;
begin
  if Assigned(aList) then
  begin
    aList.FreeObjects;
//    for i := aList.Count - 1 downto 0 do
//      aList.Items[i].Free;
//    aList.Clear;

    FreeAndNil(aList);
  end;
end;

destructor TDCObjectList.Destroy;
begin
  FreeIndexes;
  inherited;
end;

procedure TDCObjectList.SetSortKind(const Value: TDCSortedKind);
begin
  if FSortedKind = Value then
    exit;

  FSortedKind := Value;

  Resort;
end;

{ TOPCObject }

constructor TDCObject.Create;
begin
  inherited Create;
  FParentID := -1;
  FName := 'new';
  FParent := nil;
  FId := 0;
  FKind := 0;
  FTable := otUnknown;
  FChilds := TDCObjectList.Create;//(false);
end;

destructor TDCObject.Destroy;
begin
  FreeAndNil(FChilds);
  inherited;
end;

procedure TDCObject.FillChildsList(aChildsList: TDCObjectList;
  LevelCount: integer = -1; OPCKindSet: TDCObjectKindSet = [okSensor]);
var
  i: Integer;
begin
  if ((Self.DCKind in OPCKindSet) or (OPCKindSet = [])) then
    aChildsList.Add(Self);

  if (LevelCount <> 0) then
    for i := 0 to Childs.Count - 1 do
      TDCObject(Childs[i]).FillChildsList(aChildsList, LevelCount - 1,
        OPCKindSet);
end;

procedure TDCObject.ForEach(aProc: TForEachProc);
var
  i: Integer;
begin
  aProc(Self);

  for i := 0 to Self.Childs.Count - 1 do
    TDCObject(Self.Childs[i]).ForEach(aProc);
end;

function TDCObject.ForEachWithBreak(aFunc: TForEachWithBreakFunc): Boolean;
var
  i: Integer;
begin
  Result := False;

  if aFunc(Self) then
    Exit(True);

  for i := 0 to Self.Childs.Count - 1 do
    if TDCObject(Self.Childs[i]).ForEachWithBreak(aFunc) then
      Exit(True);
end;

function TDCObject.GetFullName: string;
begin
  Result := GetFullNameExt(nil);
end;

function TDCObject.GetIDStr: string;
begin
  Result := IntToStr(ID);
end;

function TDCObject.GetLevel: integer;
var
  tmp: TDCObject;
begin
  Result := 0;
  tmp := Self;
  while Assigned(tmp.Parent) do
  begin
    inc(Result);
    tmp := tmp.Parent;
  end;
end;


function TDCObject.GetRoot: TDCObject;
begin
  Result := Self;
  while Assigned(Result.Parent) do
    Result := Result.Parent;
end;

function TDCObject.GetDCKind: TDCObjectKind;
begin
  Result := TDCObjectKind(FKind);
//  case FKind of
//    0: Result := okSensor;
//    1: Result := okFlowmeter;
//
//    10: Result := okStorageTank;
//    11: Result := okCupagTank;
//
//    12: Result := okCounterEnergy9;
//    13: Result := okP2StorageTank; // ПК №2 Ёмкость хранения
//    14: Result := okP2SugarTank; // ПК №2 Сахарная ёмкость
//    15: Result := okP2LemonTank; // ПК №2 Лимонка ёмкость
//    16: Result := okP2CupagTank; // ПК №2 Купажная ёмкость
//    17: Result := okP2CupagPara; // ПК №2 Купажная пара
//
//    100: Result := okStorageTanks
//  else
//    Result := okUnknown;
//  end;
end;

function TDCObject.GetSensorCount: integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Childs.Count - 1 do
  begin
    if Childs[i] is TDCCustomSensor then
      Inc(Result)
    else
      Inc(Result, (Childs[i] as TDCObject).SensorCount);
  end;
end;

function TDCObject.IsChildOf(aParent: TDCObject): Boolean;
var
  p: TDCObject;
begin
  Result := False;
  if not Assigned(aParent) then
    Exit;

  p := Parent;
  while not Result and Assigned(p) do
  begin
    Result := (p = aParent);
    p := p.Parent;
  end;

{
  if not Assigned(aParent) or not Assigned(Parent) then
    Result := False
  else
  begin
    Result := (Parent = aParent);
    if not Result then
      Result := Parent.IsChildOf(aParent);
  end;
}
end;

procedure TDCObject.SetChildsIsDeleted(const Value: Boolean; aRecurcive: Boolean);
var
  i: Integer;
begin
  for i := 0 to Childs.Count - 1 do
  begin
    Childs[i].IsDeleted := Value;
    if aRecurcive then
      Childs[i].SetChildsIsDeleted(Value, aRecurcive);
  end;
end;

procedure TDCObject.SetId(const Value: integer);
begin
  FId := Value;
end;

procedure TDCObject.SetIDStr(const Value: string);
begin
  FId := StrToInt(Value);
end;

procedure TDCObject.SetIsDeleted(const Value: Boolean);
begin
  FIsDeleted := Value;
end;

procedure TDCObject.SetKind(const Value: integer);
begin
  FKind := Value;
end;

procedure TDCObject.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TDCObject.SetNameEn(const Value: string);
begin
  FNameEn := Value;
end;

procedure TDCObject.SetOwner(const Value: TObject);
begin
  FOwner := Value;
end;

procedure TDCObject.SetParent(const Value: TDCObject);
begin
  if Value = FParent then
    Exit;

  if Assigned(Parent) then
    FParent.Childs.Remove(Self);

  FParent := Value;
  if Assigned(FParent) then
    FParent.Childs.Add(Self);

  UpdateFullSID;
end;

procedure TDCObject.SetParentID(const Value: integer);
begin
  FParentID := Value;
end;

procedure TDCObject.SetServerChildCount(const Value: Integer);
begin
  FServerChildCount := Value;
end;


procedure TDCObject.SetSID(const Value: string);
begin
  if FSID <> Value then
  begin
    FSID := Value;
    UpdateFullSID;
  end;
end;

procedure TDCObject.SetTable(const Value: TDCObjectTable);
begin
  FTable := Value;
end;

procedure TDCObject.SetUseParentSID(const Value: Boolean);
begin
  if FUseParentSID <> Value then
  begin
    FUseParentSID := Value;
    UpdateFullSID;
  end;
end;

procedure TDCObject.SortChilds(aSortKind: TDCSortedKind);
var
  i: Integer;
begin
  Childs.SortedKind := aSortKind;
  for i := 0 to Childs.Count - 1 do
    TDCObject(Childs[i]).SortChilds(aSortKind);
end;

procedure TDCObject.UpdateFullSID;
var
  i: Integer;
begin
  if UseParentSID and Assigned(Parent) then
    FFullSID := Parent.FullSID + sSIDDelimiter + SID
  else
    FFullSID := SID;

  for i := 0 to Childs.Count - 1 do
    Childs[i].UpdateFullSID;
end;

function TDCObject.GetFullNameExt(aParent: TDCObject): string;
var
  aOPCObject: TDCObject;
begin
  aOPCObject := Parent;
  Result := Name;
  while Assigned(aOPCObject) and (aOPCObject <> aParent) and (Self <> aParent) do
  begin
    Result := aOPCObject.Name + '.' + Result;
    aOPCObject := aOPCObject.Parent;
  end;
end;

{ TOPCCustomSensor }

procedure TDCCustomSensor.SetDisplayFormat(const Value: string);
begin
  if FDisplayFormat = Value then
    exit;

  FDisplayFormat := Value;
  FIsDate := UpperCase(Copy(DisplayFormat, 1, 4)) = 'DATE'
end;

procedure TDCCustomSensor.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  FStairsOptions := Value;
end;

procedure TDCCustomSensor.SetSensorUnitName(const Value: string);
begin
  FSensorUnitName := Value;
end;

{ TDCObjectIDComparer }

function TDCObjectIDComparer.Compare(const Left, Right: TDCObject): Integer;
begin
  Result := CompareValue(Left.ID, Right.ID);
end;

{ TDCObjectNameComparer }

function TDCObjectNameComparer.Compare(const Left, Right: TDCObject): Integer;
begin
  Result := AnsiCompareText(Left.Name, Right.Name);
end;

{ TDCObjectFullSIDComparer }

function TDCObjectFullSIDComparer.Compare(const Left, Right: TDCObject): Integer;
begin
  Result := AnsiCompareText(Left.FullSID, Right.FullSID);
end;

{ TDCObjectFolderAndNameComparer }

function TDCObjectFolderAndNameComparer.Compare(const Left, Right: TDCObject): Integer;
begin
  Result := CompareByFolderAndName(Left, Right);
end;


end.

