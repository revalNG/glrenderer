{
  Модуль для текстур. Основные цели: практика в текстурах.

  Уметь загружать нужные текстуры, активировать их
}

unit Textures;

interface

uses
  dfHRenderer;

type
  TdfTexture = class(TInterfacedObject, IdfTexture)
  private
  protected
  public
  end;

//Возвращает код тектурного объекта
function renderTexLoad(FileName: PAnsiChar): Integer; stdcall;
function renderTexBind(ID: Integer): Integer; stdcall;
function renderTexUnbind(): Integer; stdcall;
function renderTexDel(ID: Integer): Integer; stdcall;

function TexInit(): Integer;
function TexStep(deltaTime: Single): Integer;
function TexDeInit(): Integer;

implementation

uses
  dfHGL, dfHEngine, TexLoad, Logger, SysUtils;

function renderTexLoad(FileName: PAnsiChar): Integer; stdcall;
var
  Format: Cardinal;
  Data: Pointer;
  W, H: Integer;
begin
  logWriteMessage('Загрузка текстуры ' + FileName);
  gl.GenTextures(1, @Result);
  gl.BindTexture(GL_TEXTURE_2D, Result);
  New(Data);
  Data := TexLoad.LoadTexture(FileName, Format, W, H, False);
  gl.TexImage2D(GL_TEXTURE_2D, 0, TGLConst(Format), W, H, 0, TGLConst(Format), GL_UNSIGNED_BYTE, Data);
  gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  gl.BindTexture(GL_TEXTURE_2D, 0);
  logWriteMessage('Загрузка текстуры завершена. ID = ' + IntToStr(Result) +' Размер текстуры: ' + IntToStr(W) + 'x' + IntToStr(H) + '; ' + IntToStr(SizeOfP(Data)) + ' байт');
  Dispose(Data);
end;

function renderTexBind(ID: Integer): Integer;
begin
  if gl.IsTexture(ID) then
  begin
    gl.BindTexture(GL_TEXTURE_2D, 0);
    gl.BindTexture(GL_TEXTURE_2D, ID);
    Result := 0;
  end
  else
    Result := -1;
end;

function renderTexUnbind(): Integer;
begin
  gl.BindTexture(GL_TEXTURE_2D, 0);
  Result := 0;
end;

function renderTexDel(ID: Integer): Integer;
begin
  logWriteMessage('Удаление текстуры ID '+ IntToStr(ID));
  gl.DeleteTextures(1, @ID);
  Result := -10;
end;

function TexInit(): Integer;
begin
  Result := -10;
end;

function TexStep(deltaTime: Single): Integer;
begin
  Result := -10;
end;

function TexDeInit(): Integer;
begin
  Result := -10;
end;


end.
