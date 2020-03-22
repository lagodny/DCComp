unit DC.mORMot.Model;

interface

uses
  SynCommons,
  mORMot;

type
  // история изменения записей дополненная информацией о пользователе и расшифровкой записи
  TSQLDCRecordHistory = class(TSQLRecordHistory)
  private
    FRecID: TID;
    FTableName: RawUTF8;
    FLogonName: RawUTF8;
  protected
    class procedure InitializeFields(const Fields: array of const; var JSON: RawUTF8); override;
  public
//    procedure HistoryAdd(Rec: TSQLRecord; Hist: TSQLRecordHistory);
//    function HistoryGet(Index: integer; out Event: TSQLHistoryEvent; out Timestamp: TModTime; out SentData: RawUTF8;
//      out LogonName: RawUTF8; Rec: TSQLRecord): boolean; overload;
  published
    property RecID: TID read FRecID write FRecID;
    property TableName: RawUTF8 index 50 read FTableName write FTableName;
    property LogonName: RawUTF8 index 50 read FLogonName write FLogonName;
  end;

implementation

{ TSQLDCRecordHistory }

//procedure TSQLDCRecordHistory.HistoryAdd(Rec: TSQLRecord; Hist: TSQLRecordHistory);
//begin
//  if (self = nil) or (fHistoryModel = nil) or (Rec.RecordClass <> fHistoryTable) then
//    exit;
//
//  if fHistoryAdd = nil then
//    fHistoryAdd := TFileBufferWriter.Create(TRawByteStringStream);
//
//  AddInteger(fHistoryAddOffset, fHistoryAddCount, fHistoryAdd.TotalWritten);
//  fHistoryAdd.Write1(Ord(Hist.Event));
//  fHistoryAdd.WriteVarUInt64(Hist.Timestamp);
//  if Hist.Event <> heDelete then
//    Rec.GetBinaryValuesSimpleFields(fHistoryAdd);
//end;
//
//function TSQLDCRecordHistory.HistoryGet(Index: integer; out Event: TSQLHistoryEvent; out Timestamp: TModTime;
//  out SentData: RawUTF8; out LogonName: RawUTF8; Rec: TSQLRecord): boolean;
//var
//  P: PAnsiChar;
//begin
//  if cardinal(Index) >= cardinal(HistoryCount) then
//    result := false
//  else
//  begin
//    P := pointer(fHistoryUncompressed);
//    inc(P, fHistoryUncompressedOffset[Index]);
//
//    Event := TSQLHistoryEvent(P^);
//    inc(P);
//    Timestamp := FromVarUInt64(PByte(P));
//    if (Rec <> nil) and (Rec.RecordClass = fHistoryTable) then
//    begin
//      if Event = heDelete then
//        Rec.ClearProperties
//      else
//        Rec.SetBinaryValuesSimpleFields(P);
//      Rec.IDValue := ModifiedID;
//    end;
//    result := true;
//  end;
//end;

class procedure TSQLDCRecordHistory.InitializeFields(const Fields: array of const; var JSON: RawUTF8);
var
  lFields: TDocVariantData;
begin
//  inherited;
//  Exit;
  if Assigned(ServiceContext.Request) then
  begin
    JSON := JSONEncode(Fields);
    lFields.InitJSON(JSON);

  //lFields.InitObject(Fields);
    lFields.AddValue('LogonName', ServiceContext.Request.SessionUserName);
    lFields.AddValue('RecID', lFields.Value['ModifiedRecord'] shr 6);
    lFields.AddValue('TableName', ServiceContext.Request.Server.Model.Tables[lFields.I['ModifiedRecord'] and 63].SQLTableName);

    JSON := lFields.ToJSON;
  end;
end;

end.
