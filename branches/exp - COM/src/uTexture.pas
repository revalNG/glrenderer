{
  ������ ��� �������. �������� ����: �������� � ���������.

  ����� ��������� ������ ��������, ������������ ��


  TODO: ������ ��������� TdfTextureDescription, ��������, ��� ��� ��� ������ �����
}

unit uTexture;

interface

uses
  dfHRenderer, dfHGL;

type

  TdfTextureDecription = record
     InternalFormat: LongInt;
     Precision: LongInt;
     ColorChanels: LongInt;
     PixelSize: cardinal;
     WrapS, WrapT, WrapR: LongInt;
     Target: LongInt;
     minFilter: TGLConst;
     magFilter: TGLConst;
//     TextureGenS: TGLConst;
//     TextureGenT: TGLConst;
//     TextureGenR: TGLConst;
     GenerateMipMaps: boolean;
//     Data: pointer;
     Id: LongInt;
     FullSize: integer;
     Width, Height, Depth: integer;
     Created: boolean;
  end;
  PdfTextureDecription = ^TdfTextureDecription;


  TdfTexture = class(TInterfacedObject, IdfTexture)
  private
    FName: String;
    FTex: TdfTextureDecription;
    FLoaded: Boolean;
//    FTex: Integer;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Bind;
    procedure Unbind;
    procedure Load(const aFileName: String);
  end;

implementation

uses
  dfHEngine, TexLoad, uLogger, SysUtils;

{ TdfTexture }

procedure TdfTexture.Bind;
begin
  if FLoaded then
    gl.BindTexture(GL_TEXTURE_2D, FTex.Id);
end;

constructor TdfTexture.Create;
begin
  inherited;
  FLoaded := False;
//  FTex := 0;
end;

destructor TdfTexture.Destroy;
begin
  logWriteMessage('�������� �������� ID '+ IntToStr(FTex.Id));
  gl.DeleteTextures(1, @FTex.Id);
  inherited;
end;

procedure TdfTexture.Load(const aFileName: String);
var
  Format: Cardinal;
  Data: Pointer;
  W, H: Integer;
begin
  logWriteMessage('�������� �������� ' + aFileName);
  gl.GenTextures(1, @FTex.Id);
  gl.BindTexture(GL_TEXTURE_2D, FTex.Id);
  New(Data);
  Data := TexLoad.LoadTexture(aFileName, Format, W, H, False);
  gl.TexImage2D(GL_TEXTURE_2D, 0, TGLConst(Format), W, H, 0, TGLConst(Format), GL_UNSIGNED_BYTE, Data);
  gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST );
  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  gl.BindTexture(GL_TEXTURE_2D, 0);
  logWriteMessage('�������� �������� ���������. ID = ' + IntToStr(FTex.Id) +' ������ ��������: ' + IntToStr(W) + 'x' + IntToStr(H) + '; ' + IntToStr(SizeOfP(Data)) + ' ����');
  Dispose(Data);

  FLoaded := True;
end;

procedure TdfTexture.Unbind;
begin
  gl.BindTexture(GL_TEXTURE_2D, 0);
end;

end.
