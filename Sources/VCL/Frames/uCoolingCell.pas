unit uCoolingCell;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uOPCFrame,
  uDCObjects,
  aOPCSource, aOPCDataObject, aOPCLabel, aCustomOPCSource, aOPCLookupList, DC.StrUtils;

type
  TCoolingCellFrame = class(TaOPCFrame)
    lMode: TaOPCColorLabel;
    Cell: TaOPCColorLabel;
    lStatus: TaOPCColorLabel;
    llMode: TaOPCLookupList;
  private
    function GetModeLookupList: taOPCLookupList;
    procedure SetModeLookupList(const Value: taOPCLookupList);
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetModeID: string;
    procedure SetModeID(const Value: string);
    function GetStatusID: string;
    procedure SetStatusID(const Value: string);
    function GetStatusLookupList: TaOPCLookupList;
    procedure SetStatusLookupList(const Value: TaOPCLookupList);
  protected
    procedure SetID(const Value: TPhysID); override;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); override;
    function GetOPCSource: TaCustomMultiOPCSource; override;
  public
    procedure LocalInit(aId: integer; aOPCObjects: TDCObjectList); override;
    procedure InitLabels(aAddToChart: TNotifyEvent; aShowDetail: TNotifyEvent); override;
  published
    property OPCSource;
    property ModeLookupList: TaOPCLookupList read GetModeLookupList write SetModeLookupList;
    property StatusLookupList: TaOPCLookupList read GetStatusLookupList write SetStatusLookupList;
    property Caption: string read GetCaption write SetCaption;
    property ModeID: string read GetModeID write SetModeID;
    property StatusID: string read GetStatusID write SetStatusID;
  end;

//var
//  CoolingCellFrame: TCoolingCellFrame;

implementation

{$R *.dfm}

{ TCoolingCellFrame }

function TCoolingCellFrame.GetCaption: string;
begin
  Result := Cell.Caption;
end;

function TCoolingCellFrame.GetModeLookupList: taOPCLookupList;
begin
  Result := lMode.LookupList;
end;

function TCoolingCellFrame.GetModeID: string;
begin
  Result := lMode.PhysID;
end;

function TCoolingCellFrame.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := TaCustomMultiOPCSource(Cell.OPCSource);
end;

function TCoolingCellFrame.GetStatusID: string;
begin
  Result := lStatus.PhysID;
end;

function TCoolingCellFrame.GetStatusLookupList: TaOPCLookupList;
begin
  Result := lStatus.LookupList;
end;

procedure TCoolingCellFrame.InitLabels(aAddToChart, aShowDetail: TNotifyEvent);
begin
  inherited;

  lMode.Params.Clear;
  lMode.Params.Add('serie=' + Cell.Caption + '.Mode');
  Cell.Params.Clear;
  Cell.Params.Add('serie=' + Cell.Caption + '.Status');
  lStatus.Params := Cell.Params;
end;

procedure TCoolingCellFrame.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
var
  i: Integer;
  aOPCObject: TDCObject;
  ObjectName: string;
  id : string;
  sid: string;
  aNumber: string;
begin
  ClearIDs;

  aOPCObject := aOPCObjects.FindObjectByID(aId);
  if not Assigned(aOPCObject) then
    exit;

  Cell.Caption := aOPCObject.Name;
  for i := 0 to aOPCObject.Childs.Count - 1 do
  begin
    if Assigned(aOPCObject.Childs[i]) and (aOPCObject.Childs[i] is TDCObject) then
    begin
      ObjectName := TDCObject(aOPCObject.Childs[i]).Name;
      id         := TDCObject(aOPCObject.Childs[i]).IdStr;
      sid := TDCObject(aOPCObject.Childs[i]).SID;
      if SameText(sid, 'Mode') then
      begin
        lMode.PhysID := id;
        lMode.Params.Clear;
        lMode.Params.Add('serie=' + Cell.Caption + '.Mode');
      end
      else if SameText(sid, 'Status') then
      begin
        Cell.PhysID := id;
        lStatus.PhysID := id;
        Cell.Params.Clear;
        Cell.Params.Add('serie=' + Cell.Caption + '.Status');
        lStatus.Params := Cell.Params;
      end;
    end;
  end;
  FID := IntToStr(aId);
  //UpdateControls;

end;

procedure TCoolingCellFrame.SetCaption(const Value: string);
begin
  Cell.Caption := Value;
end;

procedure TCoolingCellFrame.SetID(const Value: TPhysID);
var
  aOPCSource: TaOPCSource;
  ALevel, i: Integer;
  CurrStr : string;
  ObjectName : string;
  Data: TStrings;
  aSID: string;
begin
  if (FID = Value) or
    (not Assigned(OPCSource)) or
    (not (OPCSource is TaOPCSource)) then
    Exit;

  ClearIDs;

  aOPCSource := TaOPCSource(OPCSource);
  FID := Value;
  aOPCSource.FNameSpaceCash.Clear;
  aOPCSource.FNameSpaceTimeStamp := 0;
  aOPCSource.GetNameSpace(Value);
  for i := 0 to aOPCSource.FNameSpaceCash.Count - 1 do
  begin
    CurrStr := GetBufStart(PChar(aOPCSource.FNameSpaceCash[i]), ALevel);
    ObjectName := ExtractData(CurrStr);

    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if FID = Data.Strings[0] then
        Cell.Caption := ObjectName;

      if Data.Strings[1] = '1' then
        Continue; // это не датчик

      aSID := Data.Strings[10];
      if SameText(aSID, 'Mode') then
      begin
        lMode.PhysID := Data.Strings[0];
        lMode.Params.Clear;
        lMode.Params.Add('serie=' + Cell.Caption + '.Mode');
      end
      else if SameText(aSID, 'Status') then
      begin
        Cell.PhysID := Data.Strings[0];
        lStatus.PhysID := Data.Strings[0];
        Cell.Params.Clear;
        Cell.Params.Add('serie=' + Cell.Caption + '.Status');
        lStatus.Params := Cell.Params;
      end;
    finally
      FreeAndNil(Data);
    end;
  end;
  //UpdateControls;
end;

procedure TCoolingCellFrame.SetModeID(const Value: string);
begin
  lMode.PhysID := Value;
end;

procedure TCoolingCellFrame.SetModeLookupList(const Value: taOPCLookupList);
begin
  lMode.LookupList := Value;
end;

procedure TCoolingCellFrame.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin
  Cell.OPCSource := Value;
  lMode.OPCSource := Value;
  lStatus.OPCSource := Value;
end;

procedure TCoolingCellFrame.SetStatusID(const Value: string);
begin
  lStatus.PhysID := Value;
  Cell.PhysID := Value;
end;

procedure TCoolingCellFrame.SetStatusLookupList(const Value: TaOPCLookupList);
begin
  lStatus.LookupList := Value;
  Cell.LookupList := Value;
end;

end.
