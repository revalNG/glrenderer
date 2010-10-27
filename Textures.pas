{
  Модуль для текстур. Основные цели: практика в текстурах.

  Уметь загружать нужные текстуры, активировать их
}

unit Textures;

interface

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
  dglOpenGL, TexLoad;

function renderTexLoad(FileName: PAnsiChar): Integer; stdcall;
var
  Format: Cardinal;
  Data: Pointer;
  W, H: Integer;
begin
  glGenTextures(1, @Result);
  glBindTexture(GL_TEXTURE_2D, Result);
  New(Data);
  Data := TexLoad.LoadTexture(FileName, Format, W, H, False);
  glTexImage2D(GL_TEXTURE_2D, 0, Format, W, H, 0, Format, GL_UNSIGNED_BYTE, Data);
  glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glBindTexture(GL_TEXTURE_2D, 0);
  Dispose(Data);
end;

function renderTexBind(ID: Integer): Integer;
begin
  if glIsTexture(ID) then
  begin
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindTexture(GL_TEXTURE_2D, ID);
    Result := 0;
  end
  else
    Result := -1;
end;

function renderTexUnbind(): Integer;
begin
  glBindTexture(GL_TEXTURE_2D, 0);
  Result := 0;
end;

function renderTexDel(ID: Integer): Integer;
begin
  glDeleteTextures(1, @ID);
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
