{
  перехватчик реализующий сжатие и шифрование данных
}

unit aDCIntercept;

interface

uses
  Classes, SysUtils,
  IdGlobal, IdIntercept, IdCompressionIntercept, IdBlockCipherIntercept,
  DCPcrypt2, DCPblowfish, DCPsha1;

type
  TaDCBlockCipherIntercept = class(TIdBlockCipherIntercept)
  private
    FOnDecrypt: TIdInterceptStreamEvent;
    FOnEncrypt: TIdInterceptStreamEvent;
  protected
    procedure Decrypt (var VData : TIdBytes); override;
    procedure Encrypt (var VData : TIdBytes); override;
  published
    property OnDecrypt: TIdInterceptStreamEvent read FOnDecrypt write FOnDecrypt;
    property OnEncrypt: TIdInterceptStreamEvent read FOnEncrypt write FOnEncrypt;
  end;

  TaDCIntercept = class(TIdConnectionIntercept)
  private
    FCrypter: TDCP_blockcipher;
    FBlockCipherIntercept: TaDCBlockCipherIntercept;
    FCompressionIntercept: TIdCompressionIntercept;

    FCryptKey: RawByteString;
    procedure SetCryptKey(const Value: RawByteString);

    function GetCompressionLevel: TIdCompressionLevel;
    procedure SetCompressionLevel(const Value: TIdCompressionLevel);
  protected
    procedure BlockCipherInterceptSend(ASender: TIdConnectionIntercept; var VBuffer: TIdBytes);
    procedure BlockCipherInterceptReceive(ASender: TIdConnectionIntercept; var VBuffer: TIdBytes);
  public
    destructor Destroy; override;

    procedure Receive(var VBuffer: TIdBytes); override;
    procedure Send(var VBuffer: TIdBytes); override;
  published
    property Intercept;

    property CompressionLevel: TIdCompressionLevel read GetCompressionLevel write SetCompressionLevel;
    property CryptKey: RawByteString read FCryptKey write SetCryptKey;
  end;

implementation

{ TaDCIntercept }

procedure TaDCIntercept.BlockCipherInterceptReceive(ASender: TIdConnectionIntercept; var VBuffer: TIdBytes);
var
  LCount: Byte;
  LCountPos: Byte;

begin
{.$R-}
  LCountPos := FBlockCipherIntercept.BlockSize - 1;
  //LCount := TBytes(ASrcData)[LCountPos];
  //LCount := PByte(longword(ASrcData)+LCountPos)^;
  LCount := VBuffer[LCountPos];

  FCrypter.Reset;
  FCrypter.Decrypt(VBuffer[0], VBuffer[0], LCount);
  //TBytes(ADstData)[LCountPos] := LCount;
  //PByte(longword(ADstData)+LCountPos)^ := LCount;
  VBuffer[LCountPos] := LCount;
{.$R+}
end;

procedure TaDCIntercept.BlockCipherInterceptSend(ASender: TIdConnectionIntercept; var VBuffer: TIdBytes);
var
  LCount: Byte;
  LCountPos: Byte;
begin
{.$R-}
  LCountPos := FBlockCipherIntercept.BlockSize - 1;
  //LCount := TBytes(ASrcData)[LCountPos];
  //LCount := PByte(longword(ASrcData)+LCountPos)^;
  LCount := VBuffer[LCountPos];

  FCrypter.Reset;
  FCrypter.Encrypt(VBuffer[0], VBuffer[0], LCount);
  //TBytes(ADstData)[LCountPos] := LCount;
  //PByte(longword(ADstData)+LCountPos)^ := LCount;
  VBuffer[LCountPos] := LCount;
{.$R+}
end;

destructor TaDCIntercept.Destroy;
begin
  FreeAndNil(FCompressionIntercept);
  FreeAndNil(FBlockCipherIntercept);
  FreeAndNil(FCrypter);
  inherited Destroy;
end;

function TaDCIntercept.GetCompressionLevel: TIdCompressionLevel;
begin
  if Assigned(FCompressionIntercept) then
    Result := FCompressionIntercept.CompressionLevel
  else
    Result := 0;
end;

procedure TaDCIntercept.Receive(var VBuffer: TIdBytes);
begin
  inherited Receive(VBuffer);
  // при приеме
  // сначала расшифровываем
  if Assigned(FBlockCipherIntercept) then
    FBlockCipherIntercept.Receive(VBuffer);

  // а потом разжимаем
  if Assigned(FCompressionIntercept) then
    FCompressionIntercept.Receive(VBuffer);
end;

procedure TaDCIntercept.Send(var VBuffer: TIdBytes);
begin
  inherited Send(VBuffer);
  // при отправке
  // сначала сжимаем
  if Assigned(FCompressionIntercept) then
    FCompressionIntercept.Send(VBuffer);

  // а потом шифруем
  if Assigned(FBlockCipherIntercept) then
    FBlockCipherIntercept.Send(VBuffer);

end;

procedure TaDCIntercept.SetCompressionLevel(const Value: TIdCompressionLevel);
begin
  if Value = CompressionLevel then
    Exit;

  FreeAndNil(FCompressionIntercept);
  if Value = 0 then
    Exit;

  FCompressionIntercept := TIdCompressionIntercept.Create(nil);
  FCompressionIntercept.CompressionLevel := Value;
end;

procedure TaDCIntercept.SetCryptKey(const Value: RawByteString);
begin
  if FCryptKey = Value then
    Exit;

  FreeAndNil(FBlockCipherIntercept);
  FreeAndNil(FCrypter);

  FCryptKey := Value;
  if Length(FCryptKey) = 0 then
    Exit;

  FCrypter := TDCP_blowfish.Create(nil);
  FCrypter.InitStr(FCryptKey, TDCP_sha1);

  FBlockCipherIntercept := TaDCBlockCipherIntercept.Create(nil);
  FBlockCipherIntercept.BlockSize := (FCrypter.BlockSize div 8) + 1;
  //FBlockCipherIntercept.OnReceive := BlockCipherInterceptReceive;
  //FBlockCipherIntercept.OnSend := BlockCipherInterceptSend;
  FBlockCipherIntercept.OnDecrypt := BlockCipherInterceptReceive;
  FBlockCipherIntercept.OnEncrypt := BlockCipherInterceptSend;

end;

{ TaDCBlockCipherIntercept }

procedure TaDCBlockCipherIntercept.Decrypt(var VData: TIdBytes);
begin
  if Assigned(FOnDecrypt) then
    FOnDecrypt(Self, VData);
end;

procedure TaDCBlockCipherIntercept.Encrypt(var VData: TIdBytes);
begin
  if Assigned(FOnEncrypt) then
    FOnEncrypt(Self, VData);
end;

end.
