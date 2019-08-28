unit uOPCCash;

interface

type
  TaOPCCash = class
  private
    FPath: string;
    FActive: boolean;
    procedure SetPath(const Value: string);
  public
    property Path: string read FPath write SetPath;
    property Active:boolean read FActive;
  end;

var
  OPCCash : TaOPCCash;

implementation

uses
  //Windows, ActiveX, ShlObj,
  System.IOUtils,
  SysUtils;

{ TaOPCCash }

procedure TaOPCCash.SetPath(const Value: string);
begin
  FPath := Value;
  FActive := DirectoryExists(FPath);
end;

initialization
  OPCCash := TaOPCCash.Create;
  //OPCCash.Path := GetSpecialFolderLocation(CSIDL_PERSONAL)+'\OPCCash';
  OPCCash.Path := TPath.GetTempPath + TPath.AltDirectorySeparatorChar + 'OPCCash';
  if not DirectoryExists(OPCCash.Path) then
    CreateDir(OPCCash.Path);


finalization
  FreeAndNil(OPCCash);

end.
