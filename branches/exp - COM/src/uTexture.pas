{
  Модуль для текстур. Основные цели: практика в текстурах.

  Уметь загружать нужные текстуры, активировать их


  TODO: Начато внедрение TdfTextureDescription, отложено, так как нет особой нужды

}

unit uTexture;

interface

uses
  dfHRenderer, dfHGL;

type

  TdfTextureDecription = record
     InternalFormat: TGLConst; //число компонентов
     ColorFormat: TGLConst; //GL_BGR, GL_RGB, GL_RGBA....
     DataType: TGLConst;
     WrapS, WrapT, WrapR: TGLConst;
     Target: TGLConst;
     minFilter: TGLConst;
     magFilter: TGLConst;
//     Data: pointer;
     Id: LongInt;
     FullSize: integer;
     Width, Height, Depth: integer;
  end;
  PdfTextureDecription = ^TdfTextureDecription;


  TdfTexture = class(TInterfacedObject, IdfTexture)
  private
//    FName: String;
    FTex: TdfTextureDecription;
    FLoaded: Boolean;

    FWrapS, FWrapT, FWrapR: TdfTextureWrap;
    FMinFilter: TdfTextureMinFilter;
    FMagFilter: TdfTextureMagFilter;
    FBlendingMode: TdfTextureBlendingMode;
    FCombineMode: TdfTextureCombineMode;

    procedure _SetBlendingMode();
  protected
    function GetTexTarget(): TdfTextureTarget;
    function GetTexWrapS(): TdfTextureWrap;
    function GetTexWrapT(): TdfTextureWrap;
    function GetTexWrapR(): TdfTextureWrap;
    function GetTexMinFilter(): TdfTextureMinFilter;
    function GetTexMagFilter(): TdfTextureMagFilter;
    function GetTexBlendingMode(): TdfTextureBlendingMode;
    function GetTexCombineMode(): TdfTextureCombineMode;

    procedure SetTexWrapS(aWrap: TdfTextureWrap);
    procedure SetTexWrapT(aWrap: TdfTextureWrap);
    procedure SetTexWrapR(aWrap: TdfTextureWrap);
    procedure SetTexMinFilter(aFilter: TdfTextureMinFilter);
    procedure SetTexMagFilter(aFilter: TdfTextureMagFilter);
    procedure SetTexBlendingMode(aMode: TdfTextureBlendingMode);
    procedure SetTexCombineMode(aMode: TdfTextureCombineMode);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Bind;
    procedure Unbind;
    {debug}
    procedure Load2D(const aFileName: String);

    property Target: TdfTextureTarget read GetTexTarget;
    property WrapS: TdfTextureWrap read GetTexWrapS write SetTexWrapS;
    property WrapT: TdfTextureWrap read GetTexWrapT write SetTexWrapT;
    property WrapR: TdfTextureWrap read GetTexWrapR write SetTexWrapR;
    property MinFilter: TdfTextureMinFilter read GetTexMinFilter write SetTexMinFilter;
    property MagFilter: TdfTextureMagFilter read GetTexMagFilter write SetTexMagFilter;
    property BlendingMode: TdfTextureBlendingMode read GetTexBlendingMode write SetTexBlendingMode;
    property CombineMode: TdfTextureCombineMode read GetTexCombineMode write SetTexCombineMode;
  end;

implementation

uses
  dfHEngine, TexLoad, uLogger, SysUtils;

var
  {Соответствие TGLConst параметров и свойств класса TdfTexture}
  aTarget: array[Low(TdfTextureTarget)..High(TdfTextureTarget)] of TGLConst =
    (GL_TEXTURE_1D, GL_TEXTURE_2D, GL_TEXTURE_3D);
//     GL_TEXTURE_RECTANGLE,
//     GL_TEXTURE_RECTANGLE_NV,
//     GL_TEXTURE_CUBE_MAP,
//     GL_TEXTURE_CUBE_MAP_POSITIVE_X,
//     GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
//     GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
//     GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
//     GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
//     GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
//     GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D_ARRAY,
//     GL_TEXTURE_CUBE_MAP_ARRAY
//  );
  aWraps: array[Low(TdfTextureWrap)..High(TdfTextureWrap)] of TGLConst =
    (GL_CLAMP, GL_REPEAT, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_BORDER, GL_MIRRORED_REPEAT);
  aMinFilters: array[Low(TdfTextureMinFilter)..High(TdfTextureMinFilter)] of TGLConst =
    (GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR,
     GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_LINEAR);
  aMagFilters: array[Low(TdfTextureMagFilter)..High(TdfTextureMagFilter)] of TGLConst =
    (GL_NEAREST, GL_LINEAR);
  aTextureMode: array[Low(TdfTextureCombineMode)..High(TdfTextureCombineMode)] of TGLConst =
    (GL_DECAL, GL_MODULATE, GL_BLEND, GL_REPLACE, GL_ADD);


{ TdfTexture }

procedure TdfTexture.Bind;
begin
  if FLoaded then
    gl.BindTexture(GL_TEXTURE_2D, FTex.Id);
  _SetBlendingMode();
end;

constructor TdfTexture.Create;
begin
  inherited;
  FLoaded := False;
//  FTex := 0;
end;

destructor TdfTexture.Destroy;
begin
  logWriteMessage('Удаление текстуры ID '+ IntToStr(FTex.Id));
  gl.DeleteTextures(1, @FTex.Id);
  inherited;
end;

function TdfTexture.GetTexBlendingMode: TdfTextureBlendingMode;
begin
  Result := FBlendingMode;
end;

function TdfTexture.GetTexCombineMode: TdfTextureCombineMode;
begin
  Result := FCombineMode;
end;

function TdfTexture.GetTexMagFilter: TdfTextureMagFilter;
begin
  Result := FMagFilter;
end;

function TdfTexture.GetTexMinFilter: TdfTextureMinFilter;
begin
  Result := FMinFilter;
end;

function TdfTexture.GetTexTarget: TdfTextureTarget;
var
  i: TdfTextureTarget;
begin
  for i := Low(aTarget) to High(aTarget) do
    if aTarget[i] = FTex.Target then
    begin
      Result := i;
    end;
end;

function TdfTexture.GetTexWrapR: TdfTextureWrap;
begin
  Result := FWrapR;
end;

function TdfTexture.GetTexWrapS: TdfTextureWrap;
begin
  Result := FWrapS;
end;

function TdfTexture.GetTexWrapT: TdfTextureWrap;
begin
  Result := FWrapT;
end;

procedure TdfTexture.Load2D(const aFileName: String);
var
  Data: Pointer;
  eSize: Integer;
begin
  logWriteMessage('Загрузка текстуры ' + aFileName);
  gl.GenTextures(1, @FTex.Id);
  FTex.Target := GL_TEXTURE_2D;
  gl.BindTexture(FTex.Target, FTex.Id);

  New(Data);
  Data := TexLoad.LoadTexture(aFileName, FTex.InternalFormat, FTex.ColorFormat, FTex.DataType, eSize, FTex.Width, FTex.Height); //TexLoad.LoadTexture(aFileName, Format, W, H);
  FTex.FullSize := SizeOfP(Data);
  gl.TexImage2D(GL_TEXTURE_2D, 0, FTex.InternalFormat, FTex.Width, FTex.Height, 0, FTex.ColorFormat, FTex.DataType, Data);

  MinFilter := tmnNearest;
  MagFilter := tmgNearest;
  BlendingMode := tbmOpaque;
  CombineMode := tcmModulate;
//  gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_NEAREST );
//	gl.TexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST );

//  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  gl.BindTexture(GL_TEXTURE_2D, 0);
  logWriteMessage('Загрузка текстуры завершена. ID = ' + IntToStr(FTex.Id) +
    ' Размер текстуры: ' + IntToStr(FTex.Width) + 'x' + IntToStr(FTex.Height) + '; ' + IntToStr(SizeOfP(Data)) + ' байт');
  Dispose(Data);

  FLoaded := True;
end;

procedure TdfTexture.SetTexBlendingMode(aMode: TdfTextureBlendingMode);
begin
  FBlendingMode := aMode;
end;

procedure TdfTexture.SetTexCombineMode(aMode: TdfTextureCombineMode);
begin
  FCombineMode := aMode;
  gl.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, aTextureMode[FCombineMode]);
end;

procedure TdfTexture.SetTexMagFilter(aFilter: TdfTextureMagFilter);
begin
  Assert(FTex.Target <> GL_FALSE, 'Текстура не загружена');
  FMagFilter := aFilter;
  FTex.magFilter := aMagFilters[FMagFilter];
  gl.BindTexture(FTex.Target, FTex.ID);
  gl.TexParameteri(FTex.Target, GL_TEXTURE_MAG_FILTER, FTex.magFilter);
  gl.BindTexture(FTex.Target, 0);
end;

procedure TdfTexture.SetTexMinFilter(aFilter: TdfTextureMinFilter);
begin
  Assert(FTex.Target <> GL_FALSE, 'Текстура не загружена');
  FMinFilter := aFilter;
  FTex.minFilter := aMinFilters[FMinFilter];
  gl.BindTexture(FTex.Target, FTex.ID);
  gl.TexParameteri(FTex.Target, GL_TEXTURE_MIN_FILTER, FTex.minFilter);
  gl.BindTexture(FTex.Target, 0);
end;

procedure TdfTexture.SetTexWrapR(aWrap: TdfTextureWrap);
begin
  Assert(FTex.Target <> GL_FALSE, 'Текстура не загружена');
  FWrapR := aWrap;
  FTex.WrapR := aWraps[FWrapR];
  gl.BindTexture(FTex.Target, FTex.ID);
  gl.TexParameteri(FTex.Target, GL_TEXTURE_WRAP_R, FTex.WrapR);
  gl.BindTexture(FTex.Target, 0);
end;

procedure TdfTexture.SetTexWrapS(aWrap: TdfTextureWrap);
begin
  Assert(FTex.Target <> GL_FALSE, 'Текстура не загружена');
  FWrapS := aWrap;
  FTex.WrapS := aWraps[FWrapS];
  gl.BindTexture(FTex.Target, FTex.ID);
  gl.TexParameteri(FTex.Target, GL_TEXTURE_WRAP_S, FTex.WrapS);
  gl.BindTexture(FTex.Target, 0);
end;

procedure TdfTexture.SetTexWrapT(aWrap: TdfTextureWrap);
begin
  Assert(FTex.Target <> GL_FALSE, 'Текстура не загружена');
  FWrapT := aWrap;
  FTex.WrapT := aWraps[FWrapT];
  gl.BindTexture(FTex.Target, FTex.ID);
  gl.TexParameteri(FTex.Target, GL_TEXTURE_WRAP_T, FTex.WrapT);
  gl.BindTexture(FTex.Target, 0);
end;

procedure TdfTexture.Unbind;
begin
  gl.BindTexture(GL_TEXTURE_2D, 0);
  gl.Disable(GL_BLEND);
  gl.Disable(GL_ALPHA_TEST);
end;

procedure TdfTexture._SetBlendingMode;
begin
case FBlendingMode of
    tbmOpaque:
      begin
        gl.Disable(GL_BLEND);
        gl.Disable(GL_ALPHA_TEST);
      end;
    tbmTransparency:
      begin
        gl.Enable(GL_BLEND);
        gl.Enable(GL_ALPHA_TEST);
        gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        gl.AlphaFunc(GL_GREATER, 0);
      end;
    tbmAdditive:
      begin
        gl.Enable(GL_BLEND);
        gl.Enable(GL_ALPHA_TEST);
        gl.BlendFunc(GL_SRC_ALPHA,GL_ONE);
        gl.AlphaFunc(GL_GREATER, 0);
      end;
    tbmAlphaTest50:
      begin
        gl.Disable(GL_BLEND);
        gl.Enable(GL_ALPHA_TEST);
        gl.AlphaFunc(GL_GEQUAL, 0.5);
      end;
    tbmAlphaTest100:
      begin
        gl.Disable(GL_BLEND);
        gl.Enable(GL_ALPHA_TEST);
        gl.AlphaFunc(GL_GEQUAL, 1);
      end;
    tbmModulate:
      begin
        gl.Enable(GL_BLEND);
        gl.Enable(GL_ALPHA_TEST);
        gl.BlendFunc(GL_DST_COLOR,GL_ZERO);
        gl.AlphaFunc(GL_GREATER, 0);
      end;
  end;
end;

end.
