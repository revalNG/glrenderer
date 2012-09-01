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
  cEPS = 0.0001;

function PCharToPWide(AChar: PAnsiChar): PWideChar;
function PWideToPChar(pw: PWideChar): PAnsiChar;

//������ ������ ��� ����������
function SizeOfP(const P: Pointer): Integer;

implementation

uses
  Windows;

function PCharToPWide(AChar: PAnsiChar): PWideChar;
var
  pw: PWideChar;
  iSize: integer;
begin
  iSize := Length(AChar) + 1;
  pw := AllocMem(iSize * 2);
  MultiByteToWideChar(CP_ACP, 0, AChar, iSize, pw, iSize * 2);

  Result := pw;
end;

function PWideToPChar(pw: PWideChar): PAnsiChar;
var
  p: PAnsiChar;
  iLen: integer;
begin
  iLen := lstrlenw(pw) + 1;
  GetMem(p, iLen);

  WideCharToMultiByte(CP_ACP, 0, pw, iLen, p, iLen * 2, nil, nil);

  Result := p;
  FreeMem(p, iLen);
end;

function SizeOfP(const P: Pointer): Integer;
begin
  if P = nil then
    Result := -1
  else
    Result := Integer(Pointer((Integer(p) - 4))^) and $7FFFFFFC - 4;
end;

initialization
  ReportMemoryLeaksOnShutDown := True;

end.