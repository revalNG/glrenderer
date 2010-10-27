{
  DiF Engine

  ������ ��� ��������
  ���������� �����
  ������ ������������
  �����������

  24/07/09 - daemon - ������� 'common error names' ��� ����������� ����� �
                      �������. ���� ������, ����� ��������� � dfHModule,
                      �� ���� ����������, Romanus

  Copyright (c) 2009 Daemon, Romanus
  DiF Engine Team
}

unit dfHEngine;

interface

const
  //���������� ����������� ��������� � �����
  cEPS = 0.01;

type
{$REGION ' Base Types'}
  //unicode string
  TdfString = WideString;
  TdfWideCharArray = array of PWideChar;
  //ansi string
  TdfStringA = AnsiString;
  TdfInteger = LongInt;
  TdfSingle = Single;
  TdfDouble = Double;
  TdfHandle = Cardinal;
{$ENDREGION}

{$REGION 'Common function types'}

  TdfGetCharProc = function: PChar;stdcall;
  //������ ������� ��� �����������
  //������������� ���������
  TdfGetIntProc = function (): Integer;stdcall;
  //����
  TdfGetBoolProc = function (): Boolean;stdcall;

  //������������� �������
  TdfSingleFunc = function (First:Pointer):Pointer;stdcall;
  TdfSecondFunc = function (First,Second:Pointer):Pointer;stdcall;
  TdfThirdFunc = function (First,Second,Third:Pointer):Pointer;stdcall;

{$ENDREGION}


implementation

initialization
  ReportMemoryLeaksOnShutDown := True;

end.