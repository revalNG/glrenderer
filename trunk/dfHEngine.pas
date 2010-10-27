{
  DiF Engine

  Модуль для описания
  глобальных типов
  данных используемых
  повсеместно

  24/07/09 - daemon - Добавил 'common error names' для возвращения кодов в
                      модулях. Если хочешь, можно перенести в dfHModule,
                      на твое усмотрение, Romanus

  Copyright (c) 2009 Daemon, Romanus
  DiF Engine Team
}

unit dfHEngine;

interface

const
  //Допустимая погрешность сравнения с нулем
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
  //пустая функция для возвращения
  //целочисленной перменной
  TdfGetIntProc = function (): Integer;stdcall;
  //флаг
  TdfGetBoolProc = function (): Boolean;stdcall;

  //перекрываемые функции
  TdfSingleFunc = function (First:Pointer):Pointer;stdcall;
  TdfSecondFunc = function (First,Second:Pointer):Pointer;stdcall;
  TdfThirdFunc = function (First,Second,Third:Pointer):Pointer;stdcall;

{$ENDREGION}


implementation

initialization
  ReportMemoryLeaksOnShutDown := True;

end.