{
  Юнит для осуществления рендера сфер через point sprites
}
unit Sprites;

interface

uses
  dfMath, dfHRenderer, uRenderable;

type

  TdfHUDSprite = class(TdfRenderable, IdfSprite)
  private
    {debug - для проверки вывода спрайта, смещение вывода}
    {/debug}
    FWidth, FHeight: Single;
  protected
      Fdx, Fdy: Integer;
    function GetWidth(): Single;
    procedure SetWidth(const aWidth: Single);
    function GetHeight(): Single;
    procedure SetHeight(const aHeight: Single);
  public
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    procedure DoRender(); override;

    {debug - для проверки смещения вывода спрайта}
    procedure AddX(aX: Integer);
    procedure AddY(aY: Integer);
    function GetX: Integer;
    function GetY: Integer;
  end;

//  TParticle = record
//    ind: Integer;
//    Pos, Col: TdfVec3f;
//  end;
//
//  PParticle = ^TParticle;
//
//function renderSpritesAddFromFile(FileName: PAnsiChar): Integer; stdcall;
//
//function SpriteInit(AtomColor: TdfVec3f): Integer;
//function SpriteStep(deltaTime: Single): Integer;
//function SpriteDeInit(): Integer;

implementation

uses
  dfHGL;

//uses
//  Classes, SysUtils,
//  dfHEngine, dfHInput,
//  dfHGL,
//  Logger;
//
//var
//  q: TdfVec3f;
//  psize: Single;
//  particles: TList;
//  MaxX, MaxY: Single;
//  particleColor: TdfVec3f;
//
//
//
//
//function renderSpritesAddFromFile(FileName: PAnsiChar): Integer; stdcall;
//var
//  p: TParser;
//  particle: PParticle;
//  f: TFileStream;
//begin
//  logWriteMessage('Загрузка данных по спрайтам из файла ' + FileName);
//  particles.Clear();
//  f := TFileStream.Create(FileName, $0000);
//  p := TParser.Create(f);
//
//  repeat
//    New(particle);
//    with particle^ do
//    begin
//      ind := p.TokenInt;
//      p.NextToken;
//      pos.x := p.TokenFloat;
//      if pos.x > maxX then maxX := pos.x;
//      p.NextToken;
//      pos.y := p.TokenFloat;
//      if pos.y > maxY then maxY := pos.y;
//      p.NextToken;
//      pos.z := p.TokenFloat;
//      col := particleColor;
//    end;
//    particles.Add(particle);
//  until (p.NextToken = toEOF);
//  f.Free;
//  p.Free;
//  logWriteMessage('Загрузка данных завершена, добавлено ' + IntToStr(particles.Count) + ' спрайтов');
//  Result := 0;
//end;
//
//function SpriteInit(AtomColor: TdfVec3f): Integer;
//begin
//  //TODO: check extension GL_ARB_POINT_PARAMETERS
//  logWriteMessage('Инициализация модуля Sprites');
//  particles := TList.Create();
//  q := dfVec3f(0.5, 0.5, 0.5);
//  gl.PointParameterfv(GL_POINT_DISTANCE_ATTENUATION, @q);
//  psize := 0;
//  gl.GetFloatv(GL_POINT_SIZE_MAX, @psize);
//  logWriteMessage('Sprites: GL_POINT_SIZE_MAX = ' + FloatToStr(psize));
//  psize := Min(psize, 100);
//  gl.PointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, 100.0);
//  gl.PointParameterf(GL_POINT_SIZE_MIN, 1.0);
//  gl.PointParameterf(GL_POINT_SIZE_MAX, psize);
//
//  gl.TexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, $0001 );
//
//  particleColor := AtomColor;
//
//  Result := -10;
//end;
//
//function SpriteStep(deltaTime: Single): Integer;
//var
//  i: Integer;
//begin
//  gl.Translatef(-MaxX / 2, -MaxY / 2, 0);
//  gl.PushAttrib(GL_LIGHTING);
//  gl.Disable(GL_LIGHTING);
//
//  gl.Enable(GL_BLEND);
////  gl.BlendFunc(GL_ONE, GL_ONE);
////  gl.BlendFunc(GL_ONE, GL_SRC_ALPHA);
//	gl.BlendFunc(GL_SRC_ALPHA, GL_ONE);
//
//  gl.Enable(GL_POINT_SPRITE);
//
//  gl.PointSize(psize);
//
//	gl.Beginp( GL_POINTS );
//    for i := 0 to particles.Count - 1 do
//      with PParticle(particles[i])^ do
//      begin
//        gl.Color4f(Col.x, Col.y, Col.z, 1.0);
//        gl.Vertex3f(Pos.x, Pos.y, Pos.z);
//      end;
//
//	gl.Endp();
//
//	gl.Disable(GL_POINT_SPRITE);
//
//  gl.Disable(GL_BLEND);
//
//  gl.PopAttrib();
//
//  Result := -10;
//end;
//
//function SpriteDeInit(): Integer;
//var
//  i: Integer;
//begin
//  logWriteMessage('Деинициализация модуля Sprites');
//  for i := 0 to particles.Count - 1 do
//    Dispose(particles[i]);
//  particles.Free;
//  Result := -10;
//end;


{ TdfHUDSprite }

procedure TdfHUDSprite.AddX(aX: Integer);
begin
  Fdx := Fdx + aX;
end;

procedure TdfHUDSprite.AddY(aY: Integer);
begin
  Fdy := Fdy + aY;
end;

procedure TdfHUDSprite.DoRender;
begin
  inherited;
  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  gl.Ortho(0, 800, 600, 0, -1, 1);
//  gl.Ortho(-8, 800, 630, 22, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity();
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);
  gl.Color3f(1, 0, 0);
  gl.Beginp(GL_TRIANGLE_STRIP);
//    gl.Vertex2f(0, FHeight);
//    gl.Vertex2f(0, 0);
//    gl.Vertex2f(FWidth, 0);
    gl.Vertex2f(FWidth + Fdx, Fdy);
    gl.Vertex2f(Fdx, Fdy);
    gl.Vertex2f(Fdx, FHeight + Fdy);
//    gl.Vertex2f(-0.5 * FWidth, -0.5 * FHeight);
//    gl.Vertex2f( 0.5 * FWidth, -0.5 * FHeight);
//    gl.Vertex2f( 0.5 * FWidth,  0.5 * FHeight);
  gl.Endp();
  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_DEPTH_TEST);
  gl.MatrixMode(GL_PROJECTION);
  gl.PopMatrix();
  gl.MatrixMode(GL_MODELVIEW);
end;

function TdfHUDSprite.GetHeight: Single;
begin
  Result := FHeight;
end;

function TdfHUDSprite.GetWidth: Single;
begin
  Result := FWidth;
end;

function TdfHUDSprite.GetX: Integer;
begin
  Result := Fdx;
end;

function TdfHUDSprite.GetY: Integer;
begin
  Result := Fdy;
end;

procedure TdfHUDSprite.SetHeight(const aHeight: Single);
begin
  FHeight := aHeight;
end;

procedure TdfHUDSprite.SetWidth(const aWidth: Single);
begin
  FWidth := aWidth;
end;

end.
