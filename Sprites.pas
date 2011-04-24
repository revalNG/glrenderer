{
  Юнит для осуществления рендера сфер через point sprites
}
unit Sprites;

interface

uses
  dfMath;

type

  TParticle = record
    ind: Integer;
    Pos, Col: TdfVec3f;
  end;

  PParticle = ^TParticle;

function renderSpritesAddFromFile(FileName: PAnsiChar): Integer; stdcall;

function SpriteInit(AtomColor: TdfVec3f; AtomSize: Single): Integer;
function SpriteStep(deltaTime: Single): Integer;
function SpriteDeInit(): Integer;

implementation

uses
  Classes, SysUtils,
  dfHEngine, dfHInput,
  dfHGL,
  Logger;

var
  q: TdfVec3f;
  psize: Single;
  particles: TList;
  MaxX, MaxY: Single;
  particleColor: TdfVec3f;




function renderSpritesAddFromFile(FileName: PAnsiChar): Integer; stdcall;
var
  p: TParser;
  particle: PParticle;
  f: TFileStream;
  aFileName: String;
begin
  //Агли хак, иначе после первого же использования FileName оно превращается в бред
  aFileName := FileName;
  logWriteMessage('Загрузка данных по спрайтам из файла ' + aFileName);
  particles.Clear();
  f := TFileStream.Create(aFileName, $0000);

  p := TParser.Create(f);

  repeat
    New(particle);
    with particle^ do
    begin
      ind := p.TokenInt;
      p.NextToken;
      pos.x := p.TokenFloat;
      if pos.x > maxX then maxX := pos.x;
      p.NextToken;
      pos.y := p.TokenFloat;
      if pos.y > maxY then maxY := pos.y;
      p.NextToken;
      pos.z := p.TokenFloat;
      col := particleColor;
    end;
    particles.Add(particle);
  until (p.NextToken = toEOF);
  f.Free;
  p.Free;
  logWriteMessage('Загрузка данных завершена, добавлено ' + IntToStr(particles.Count) + ' спрайтов');
  Result := 0;
end;

function SpriteInit(AtomColor: TdfVec3f; AtomSize: Single): Integer;
begin
  //TODO: check extension GL_ARB_POINT_PARAMETERS
  logWriteMessage('Инициализация модуля Sprites');
  particles := TList.Create();
  q := dfVec3f(0.5, 0.5, 0.5);
  gl.PointParameterfv(GL_POINT_DISTANCE_ATTENUATION, @q);
  psize := 0;
  gl.GetFloatv(GL_POINT_SIZE_MAX, @psize);
  logWriteMessage('Sprites: GL_POINT_SIZE_MAX = ' + FloatToStr(psize));
  if psize > AtomSize then
    psize := AtomSize;

  gl.PointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, 100.0);
  gl.PointParameterf(GL_POINT_SIZE_MIN, 1.0);
  gl.PointParameterf(GL_POINT_SIZE_MAX, psize);

  gl.TexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, $0001 );

  particleColor := AtomColor;

  Result := -10;
end;

function SpriteStep(deltaTime: Single): Integer;
var
  i: Integer;
begin
  gl.Translatef(-MaxX / 2, -MaxY / 2, 0);
  gl.PushAttrib(GL_LIGHTING);
  gl.Disable(GL_LIGHTING);

  gl.Enable(GL_BLEND);
//  gl.BlendFunc(GL_ONE, GL_ONE);
//  gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	gl.BlendFunc(GL_SRC_ALPHA, GL_ONE);

  gl.Enable(GL_POINT_SPRITE);
  gl.Enable(GL_ALPHA_TEST);
  gl.Disable(GL_DEPTH_TEST);

  gl.PointSize(psize);

	gl.Beginp( GL_POINTS );
    for i := 0 to particles.Count - 1 do
      with PParticle(particles[i])^ do
      begin
        gl.Color4f(Col.x, Col.y, Col.z, 1.0);
        gl.Vertex3f(Pos.x, Pos.y, Pos.z);
      end;

	gl.Endp();

  gl.Enable(GL_DEPTH_TEST);
  gl.Disable(GL_ALPHA_TEST);
	gl.Disable(GL_POINT_SPRITE);

  gl.Disable(GL_BLEND);

  gl.PopAttrib();

  Result := -10;
end;

function SpriteDeInit(): Integer;
var
  i: Integer;
begin
  logWriteMessage('Деинициализация модуля Sprites');
  for i := 0 to particles.Count - 1 do
    Dispose(particles[i]);
  particles.Free;
  Result := -10;
end;


end.
