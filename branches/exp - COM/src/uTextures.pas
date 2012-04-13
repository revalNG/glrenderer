{
  ������ ��� �������. �������� ����: �������� � ���������.

  ����� ��������� ������ ��������, ������������ ��
}

unit uTextures;

interface

uses
  dfHRenderer;

type
  TdfTexture = class(TInterfacedObject, IdfTexture)
  private
    FLoaded: Boolean;
    FTex: Integer;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Bind;
    procedure Unbind;
    procedure Load(const aFileName: String);
  end;

//���������� ��� ���������� �������
//function renderTexLoad(FileName: PAnsiChar): Integer; stdcall;
//function renderTexBind(ID: Integer): Integer; stdcall;
//function renderTexUnbind(): Integer; stdcall;
//function renderTexDel(ID: Integer): Integer; stdcall;
//
//function TexInit(): Integer;
//function TexStep(deltaTime: Single): Integer;
//function TexDeInit(): Integer;

implementation

uses
  dfHGL, dfHEngine, TexLoad, Logger, SysUtils;
{
function renderTexLoad(FileName: PAnsiChar): Integer; stdcall;
var
  Format: Cardinal;
  Data: Pointer;
  W, H: Integer;
begin
  logWriteMessage('�������� �������� ' + FileName);
  gl.GenTextures(1, @Result);
  gl.BindTexture(GL_TEXTURE_2D, Result);
  New(Data);
  Data := TexLoad.LoadTexture(FileName, Format, W, H, False);
  gl.TexImage2D(GL_TEXTURE_2D, 0, TGLConst(Format), W, H, 0, TGLConst(Format), GL_UNSIGNED_BYTE, Data);
  gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  gl.BindTexture(GL_TEXTURE_2D, 0);
  logWriteMessage('�������� �������� ���������. ID = ' + IntToStr(Result) +' ������ ��������: ' + IntToStr(W) + 'x' + IntToStr(H) + '; ' + IntToStr(SizeOfP(Data)) + ' ����');
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
  logWriteMessage('�������� �������� ID '+ IntToStr(ID));
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
end;      }


{ TdfTexture }

procedure TdfTexture.Bind;
begin
  if FLoaded then
    gl.BindTexture(GL_TEXTURE_2D, FTex);
end;

constructor TdfTexture.Create;
begin
  inherited;
  FLoaded := False;
  FTex := 0;
end;

destructor TdfTexture.Destroy;
begin
  logWriteMessage('�������� �������� ID '+ IntToStr(FTex));
  gl.DeleteTextures(1, @FTex);
  inherited;
end;

procedure TdfTexture.Load(const aFileName: String);
var
  Format: Cardinal;
  Data: Pointer;
  W, H: Integer;
begin
  logWriteMessage('�������� �������� ' + aFileName);
  gl.GenTextures(1, @FTex);
  gl.BindTexture(GL_TEXTURE_2D, FTex);
  New(Data);
  Data := TexLoad.LoadTexture(aFileName, Format, W, H, False);
  gl.TexImage2D(GL_TEXTURE_2D, 0, TGLConst(Format), W, H, 0, TGLConst(Format), GL_UNSIGNED_BYTE, Data);
  gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  gl.BindTexture(GL_TEXTURE_2D, 0);
  logWriteMessage('�������� �������� ���������. ID = ' + IntToStr(FTex) +' ������ ��������: ' + IntToStr(W) + 'x' + IntToStr(H) + '; ' + IntToStr(SizeOfP(Data)) + ' ����');
  Dispose(Data);
end;

procedure TdfTexture.Unbind;
begin
  gl.BindTexture(GL_TEXTURE_2D, 0);
end;

end.