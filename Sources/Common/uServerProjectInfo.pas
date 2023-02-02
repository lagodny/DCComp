unit uServerProjectInfo;

interface

uses
  Classes,
  IniFiles;

type
  TServerProject = class
    Name: string;
    ConnectionName: string;

    ProjectPathID: string;
    ProjectFileName: string;

    ReloadConnections: Boolean;

    procedure Load(aIniFile: TCustomIniFile; aSectionName: string);
  end;


implementation

{ TServerProjectInfo }

procedure TServerProject.Load(aIniFile: TCustomIniFile; aSectionName: string);
begin
  Name := aIniFile.ReadString(aSectionName, 'Name', '');
  ConnectionName := aIniFile.ReadString(aSectionName, 'ConnectionName', '');
  ProjectPathID := aIniFile.ReadString(aSectionName, 'ProjectPathID', '');
end;

end.
