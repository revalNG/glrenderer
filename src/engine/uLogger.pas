unit uLogger;

interface

const
  LOGFILE = 'glrenderer.log';

var
  iLog: Integer;



//������������ ������� ������� � ������������� ��� ������� �������

procedure logWriteMessage(Msg: String; DateTime: Boolean = True;
                                        NewLine: Boolean = True);
procedure logWriteWarning(Msg: String; DateTime: Boolean = True;
                                        NewLine: Boolean = True);
procedure logWriteError (Msg: String; DateTime: Boolean = True;
                                       NewLine: Boolean = True;
                                      Critical: Boolean = False);


//���������� ������� ������������� � ��������������� �������
function LogInit(): Integer;
function LogDeinit(): Integer;

implementation

uses
  dfLogger;

procedure logWriteMessage(Msg: String; DateTime: Boolean = True;
                                        NewLine: Boolean = True);
begin
  if DateTime then
    LoggerWriteDateTime(iLog, '');
  LoggerWriteUnFormated(ilog, PWideChar(Msg));
  if NewLine then
    LoggerWriteEndL(iLog);
end;

procedure logWriteWarning(Msg: String; DateTime: Boolean = True;
                                        NewLine: Boolean = True);
begin
  if DateTime then
    LoggerWriteDateTime(iLog, '');
  LoggerWriteWarning(ilog, PWideChar(Msg));
  if NewLine then
    LoggerWriteEndL(iLog);
end;

procedure logWriteError (Msg: String; DateTime: Boolean = True;
                                       NewLine: Boolean = True;
                                      Critical: Boolean = False);
begin
  if DateTime then
    LoggerWriteDateTime(iLog, '');
  if Critical then
  begin
    LoggerWriteError(ilog, PWideChar(' :CRITICAL: ' + Msg));
    LogDeInit();
    Exit;
  end
  else
    LoggerWriteError(ilog, PWideChar(Msg));
  if NewLine then
    LoggerWriteEndL(iLog);
end;




function LogInit(): Integer;
begin
  LoggerAddLog(LOGFILE);
  uLogger.iLog := LoggerFindLog(LOGFILE);
  LoggerWriteHeader(iLog, '����� ������������');

  Result := 0;
end;

function LogDeinit(): Integer;
begin
  LoggerWriteBottom(iLog, '��������� ������������');
  LoggerDelLog(LOGFILE);

  Result := 0;
end;

end.
