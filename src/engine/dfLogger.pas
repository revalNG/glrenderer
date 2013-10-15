{
  DiF Engine

  ������ ��������

  Copyright (c) 2009 Romanus
  DiF Engine Team
}
unit dfLogger;

interface

uses
  Classes;

const
  ConstNameEngine           =         'glRenderer';
  //���������
  ConstFormatHeader         =         '/glRenderer ------------------';
  //���
  ConstFormatBottom         =         '\glRenderer ------------------';
  //��������� html
  ConstFormatHeaderHtml     =         ConstNameEngine + ' log start';
  //��� html
  ConstFormatBottomHtml     =         ConstNameEngine + ' log end';
  //��������
  ConstFormatWarning        =         'Warning: ';
  //������
  ConstFormatError          =         'Error: ';
  //html-����� ������
  ConstFormatHtmlSpace      =         '&nbsp;';

  //������� ������
  ConstEndl     : array[0..1] of Char
                            =         #13#10;
  //���������
  ConstTab      : Char =         #9;
  //����������� �������
  ConstChars    : String =  '[]():. <>';

type
  //������� ���������
  //��� ������ ���������
  //(��������� ������ ����)
  TdfUniProc = function (Msg: AnsiString): AnsiString;

  {$REGION 'dfLogger'}

  //������� ����� ����
  TdfLogger = class
  private
    //�������� �����
    FStream:TMemoryStream;
    //��� �����
    FFileName: AnsiString;
    //����� � �����
    procedure WriteToStream(Buffer:AnsiString);
  public
    //������ �� �����
    property Stream:TMemoryStream read FStream;
    //��� �����
    property FileName:AnsiString read FFileName;
    //�����������
    constructor Create(const FName:AnsiString='');
    //����������
    destructor Destroy;override;
    //����������� �����������
    //���������
    procedure WriteMessage(Msg:AnsiString);overload;
    //��������� � ������� ������
    procedure WriteLnMessage(const Msg:AnsiString = '');
    //��������� � ���������� ����������
    procedure WriteMessage(Msg:AnsiString;UniProc:TdfUniProc);overload;
    //������� ����� ������
    procedure WriteEndl;
    //������� ���������
    procedure WriteTabChar;
    //������� ���
    procedure WriteTag(Msg:AnsiString);
  end;

  {$ENDREGION}

  {$REGION 'dfFormatLogger'}

  TdfFormatlogger = class(TdfLogger)
  public
    //���������
    procedure WriteHeader(Msg:AnsiString);virtual;
    //���
    procedure WriteBottom(Msg:AnsiString);virtual;
    //��� �������
    procedure WriteUnFormated(Msg:AnsiString);virtual;
    //das ahtung
    procedure WriteWarning(Msg:AnsiString);virtual;
    //������
    procedure WriteError(Msg:AnsiString);virtual;
    //��������������� �����
    procedure WriteText(Msg:AnsiString;UniProc:TdfUniProc);virtual;
    //������� � �����������
    procedure WriteTab(Msg:AnsiString;const Count:byte = 1);virtual;
    //������� � ����� � ��������
    procedure WriteDateTime(Msg:AnsiString);virtual;
  end;

  {$ENDREGION}

  {$REGION 'dfHtmlLogger'}

  TdfHtmlLogger = class(TdfFormatlogger)
  public
    //���������
    procedure WriteHeader(Msg:AnsiString);override;
    //���
    procedure WriteBottom(Msg:AnsiString);override;
    //��� ������� (������� ����������)
    //procedure WriteUnFormated(Msg:AnsiString);virtual;
    //das ahtung
    procedure WriteWarning(Msg:AnsiString);override;
    //������
    procedure WriteError(Msg:AnsiString);override;
    //��������������� ����� (������� ����������)
    //procedure WriteText(Msg:AnsiString;UniProc:TdfUniProc);virtual;
    //������� � �����������
    procedure WriteTab(Msg:AnsiString;const Count:byte = 1);override;
    //������� � ����� � ��������
    procedure WriteDateTime(Msg:AnsiString);override;
  end;

  {$ENDREGION}



var
  //��������� �������
  LoggerCollection: TList;

//��������� ���
function LoggerAddLog(FileName:PWideChar):Boolean;stdcall;
//������� ��� (����� ��� � ����)
function LoggerDelLog(FileName:PWideChar):Boolean;stdcall;
//���� ��� �� �����
function LoggerFindLog(FileName:PWideChar):Integer;stdcall;
//����� ���������
function LoggerWriteHeader(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//����� ���
function LoggerWriteBottom(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//����� ������������ ������
function LoggerWriteUnFormated(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//� ���� ������� ��������
function LoggerWriteWarning(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//����� ������
function LoggerWriteError(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//����� ��������������� �����
function LoggerWriteText(Index:Integer;Msg:PWideChar;Proc:TdfUniProc):Boolean;stdcall;
//����� � ����������
function LoggerWriteTab(Index:Integer;Msg:PWideChar;Count:Byte):Boolean;stdcall;
//����� � ����� � ��������
function LoggerWriteDateTime(Index:Integer;Msg:PWideChar):Boolean;stdcall;
//perfect.daemon:
//����� ����� ������
function LoggerWriteEndL(Index: Integer): Boolean; stdcall;


implementation

uses
  Windows, SysUtils, glr;

{$REGION 'dfLogger'}

//����� � �����
procedure TdfLogger.WriteToStream(Buffer:AnsiString);
begin
  FStream.Write(PAnsiChar(Buffer)^,length(Buffer));
end;

//�����������
constructor TdfLogger.Create(const FName:AnsiString='');
begin
  FFileName:=FName;
  FStream:=TMemoryStream.Create;
end;

//����������
destructor TdfLogger.Destroy;
begin
  //���� ������ ����
  if FFileName <> '' then
    //��������� ����� � ����
    FStream.SaveToFile(WideString(FFileName));
  //������ �� �����
  FStream.Free;
end;

//����������� �����������
//���������
procedure TdfLogger.WriteMessage(Msg:AnsiString);
begin
  Self.WriteToStream(Msg);
end;

//��������� � ������� ������
procedure TdfLogger.WriteLnMessage(const Msg:AnsiString = '');
begin
  Self.WriteToStream(Msg + ConstEndl);
end;

//��������� � ���������� ����������
procedure TdfLogger.WriteMessage(Msg:AnsiString;UniProc:TdfUniProc);
var
  MarkedMsg:AnsiString;
begin
  //��������� ���������
  MarkedMsg:=UniProc(Msg);
  //����� � �����
  Self.WriteMessage(MarkedMsg);
end;

//������� ����� ������
procedure TdfLogger.WriteEndl;
begin
  Self.WriteMessage(ConstEndl);
end;

//������� ���������
procedure TdfLogger.WriteTabChar;
begin
  Self.WriteMessage(ConstTab);
end;

//������� ���
procedure TdfLogger.WriteTag(Msg:AnsiString);
begin
  Self.WriteMessage(ConstChars[7]+Msg+ConstChars[8]);
end;

{$ENDREGION}

{$REGION 'dfFormatLogger'}

//���������
procedure TdfFormatlogger.WriteHeader(Msg:AnsiString);
begin
  Self.WriteLnMessage(ConstFormatHeader);
  Self.WriteLnMessage(Msg);
end;

//���
procedure TdfFormatlogger.WriteBottom(Msg:AnsiString);
begin
  Self.WriteLnMessage(Msg);
  Self.WriteLnMessage(ConstFormatBottom);
end;

//��� �������
procedure TdfFormatlogger.WriteUnFormated(Msg:AnsiString);
begin
  //������������ �����
  Self.WriteMessage(Msg); 
end;

//das ahtung
procedure TdfFormatlogger.WriteWarning(Msg:AnsiString);
begin
  Self.WriteMessage(ConstFormatWarning);
  Self.WriteLnMessage(Msg);  
end;

//������
procedure TdfFormatlogger.WriteError(Msg:AnsiString);
begin
  Self.WriteMessage(ConstFormatError);
  Self.WriteLnMessage(Msg);  
end;

//��������������� �����
procedure TdfFormatlogger.WriteText(Msg:AnsiString;UniProc:TdfUniProc);
begin
  Self.WriteMessage(Msg,UniProc);
end;

//������� � �����������
procedure TdfFormatlogger.WriteTab(Msg:AnsiString;const Count:byte = 1);
var
  Pos:byte;
begin
  for Pos := 0 to Count do
    Self.WriteTabChar;
  Self.WriteMessage(Msg);
end;

//������� � ����� � ��������
procedure TdfFormatlogger.WriteDateTime(Msg:AnsiString);
var
  StrTime:String;
  ResStr:AnsiString;
begin
  DateTimeToString(StrTime,'hh:nn:ss.zzz',Time);
  ResStr:=ConstChars[1] + DateToStr(Date);
  ResStr:=ResStr + ConstChars[7] + StrTime;
  ResStr:=ResStr + ConstChars[2];
  ResStr:=ResStr + Msg;
  Self.WriteMessage(ResStr);
end;

{$ENDREGION}

{$REGION 'dfHtmlLogger'}

//���������
procedure TdfHtmlLogger.WriteHeader(Msg:AnsiString);
begin
  WriteLnMessage('<html>'#13#10'<header>' +
                  '<title>DiF Engine Log Html Output</title>'+
                  '</header>'#13#10'<body>'+
                  '<center><b>' + ConstFormatHeaderHtml +
                  '</b></center><br>');
  WriteLnMessage(Msg);
end;

//���
procedure TdfHtmlLogger.WriteBottom(Msg:AnsiString);
begin
  WriteLnMessage('<center>' + Msg + '</center>');
  WriteLnMessage('</body></html>');
end;

//das ahtung
procedure TdfHtmlLogger.WriteWarning(Msg:AnsiString);
begin
  WriteLnMessage('<b style="color:blue;">'+
                 ConstFormatWarning + Msg + '</b>');
end;

//������
procedure TdfHtmlLogger.WriteError(Msg:AnsiString);
begin
  WriteLnMessage('<b style="color:red;">'+
                 ConstFormatError + Msg + '</b>');
end;

//������� � �����������
procedure TdfHtmlLogger.WriteTab(Msg:AnsiString;const Count:byte = 1);
var
  NewCount,
  GetPos:Integer;
begin
  NewCount:=Count shl 1;
  for GetPos:=0 to NewCount do
    WriteLnMessage(ConstFormatHtmlSpace+ConstFormatHtmlSpace);
end;

//������� � ����� � ��������
procedure TdfHtmlLogger.WriteDateTime(Msg:AnsiString);
begin
  inherited WriteDateTime(Msg);
  WriteLnMessage('<br>');
end;

{$ENDREGION}

procedure FreeLoggerCollection;
var
  GetPos:Integer;
begin
  //������ �� �����
  for GetPos:=0 to LoggerCollection.Count-1 do
    TdfFormatLogger(LoggerCollection.Items[GetPos]).Free;
  LoggerCollection.Free;
end;

//��������� ���
function LoggerAddLog(FileName:PWideChar):Boolean;
var
  Logger:TdfFormatlogger;
  LoggerHtml:TdfHtmlLogger;
  AString:AnsiString;
begin
  Result:=false;
  //��������� ����������
  //�� ���-�� ��� ���� ����
  if LoggerFindLog(FileName) <> -1 then
    Exit;
  AString:=FileName;
  if Pos('html',FileName) <> 0 then
  begin
    LoggerHtml:=TdfHtmlLogger.Create(FileName);
    LoggerCollection.Add(LoggerHtml);
  end else
  begin
    Logger:=TdfFormatlogger.Create(AString);
    LoggerCollection.Add(Logger);
  end;
  Result:=true;
end;

//������� ��� (����� ��� � ����)
function LoggerDelLog(FileName:PWideChar):Boolean;
var
  Index:Integer;
begin
  Result:=false;
  Index:=LoggerFindLog(FileName);
  if Index = -1 then
    Exit;
  if TObject(LoggerCollection.Items[Index]) is TdfFormatLogger then
    TdfFormatLogger(LoggerCollection.Items[Index]).Free
  else
    TdfHtmlLogger(LoggerCollection.Items[Index]).Free;
  LoggerCollection.Delete(Index);
end;

//���� ��� �� �����
function LoggerFindLog(FileName:PWideChar):Integer;
var
  GetPos:Integer;
begin
  Result:=-1;
  for GetPos:=0 to LoggerCollection.Count-1 do
  begin
    if TdfFormatLogger(LoggerCollection.Items[GetPos]).FileName = FileName then
    begin
      Result:=GetPos;
      Exit;
    end;
  end;
end;

//����� ���������
function LoggerWriteHeader(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteHeader(Msg);
end;

//����� ���
function LoggerWriteBottom(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteBottom(PWideToPChar(Msg));
end;

//����� ������������ ������
function LoggerWriteUnFormated(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteUnFormated(PWideToPChar(Msg));
end;

//� ���� ������� ��������
function LoggerWriteWarning(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteWarning(PWideToPChar(Msg));
end;

//����� ������
function LoggerWriteError(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteError(PWideToPChar(Msg));
end;

//����� ��������������� �����
function LoggerWriteText(Index:Integer;Msg:PWideChar;Proc:TdfUniProc):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteText(PWideToPChar(Msg),Proc);
end;

//����� � ����������
function LoggerWriteTab(Index:Integer;Msg:PWideChar;Count:Byte):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteTab(PWideToPChar(Msg),Count);
end;

//����� � ����� � ��������
function LoggerWriteDateTime(Index:Integer;Msg:PWideChar):Boolean;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteDateTime(PWideToPChar(Msg));
end;

//perfect.daemon:
//����� ����� ������
function LoggerWriteEndL(Index: Integer): Boolean; stdcall;
begin
  if Index >= LoggerCollection.Count then
    Exit;
  TdfFormatLogger(LoggerCollection.Items[Index]).WriteEndl();
end;

initialization

  LoggerCollection := TList.Create;

finalization

  FreeLoggerCollection;

end.
