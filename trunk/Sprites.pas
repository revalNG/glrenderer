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

function SpriteInit(): Integer;
function SpriteStep(deltaTime: Single): Integer;
function SpriteDeInit(): Integer;

implementation

uses
  Classes, SysUtils,
  dfHEngine, dfHInput,
  dfHGL;

var
  q: TdfVec3f;
  psize: Single;
  particles: TList;
  MaxX, MaxY: Single;




function renderSpritesAddFromFile(FileName: PAnsiChar): Integer; stdcall;
var
  p: TParser;
  particle: PParticle;
  f: TFileStream;
begin
  particles.Clear();
  f := TFileStream.Create(FileName, $0000);
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
      col := dfVec3f(1.0, 1.0, 1.0);
    end;
    particles.Add(particle);
  until (p.NextToken = toEOF);
  f.Free;
  p.Free;
end;

function SpriteInit(): Integer;
begin
//  if not dglCheckExtension('GL_ARB_point_parameters') then
//  begin
//    Result := -1;
//    Exit;
//  end;
  particles := TList.Create();
  q := dfVec3f(0.5, 0.5, 0.5);
  gl.PointParameterfv(GL_POINT_DISTANCE_ATTENUATION, @q);
  psize := 0;
  gl.GetFloatv(GL_POINT_SIZE_MAX, @psize);
  psize := Min(psize, 50);
  gl.PointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, 10.0);
  gl.PointParameterf(GL_POINT_SIZE_MIN, 1.5);
  gl.PointParameterf(GL_POINT_SIZE_MAX, psize);

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
	gl.BlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);

  gl.Enable(GL_POINT_SPRITE);

  gl.PointSize(psize);

  gl.TexEnvf( GL_POINT_SPRITE, GL_COORD_REPLACE, 1.0 );

	gl.Beginp( GL_POINTS );
    for i := 0 to particles.Count - 1 do
      with PParticle(particles[i])^ do
      begin
        gl.Color4f(Col.x, Col.y, Col.z, 1.0);
        gl.Vertex3f(Pos.x, Pos.y, Pos.z);
      end;

	gl.Endp();

	gl.Disable(GL_POINT_SPRITE);

  gl.Disable(GL_BLEND);

  gl.PopAttrib();

  Result := -10;
end;

function SpriteDeInit(): Integer;
var
  i: Integer;
begin
  for i := 0 to particles.Count - 1 do
    Dispose(particles[i]);
  particles.Free;
  Result := -10;
end;


end.
