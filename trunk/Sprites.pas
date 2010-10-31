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
  dglOpengl;
var
//  links: array of record
//    p1, p2: TdfVec3f;
//    Col: TdfVec4f;
//  end;

  q: TdfVec3f;
  psize: Single;
  particles: TList;
  MaxX, MaxY: Single;

//const
//  cRange = 20;
//  cRad = 4;
//  cStep = 1;
//  cAtomsPerRound = 12;
//  cRounds = 4;



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
//var
//  i: Integer;
begin
  if not dglCheckExtension('GL_ARB_point_parameters') then
  begin
    Result := -1;
    Exit;
  end;
//  SetLength(particles, cAtomsPerRound * cRounds);
//  SetLength(links, 2 * Length(particles) - cAtomsPerRound);
//  Randomize;
//  for i := 0 to High(particles) do
//  begin
//    with particles[i] do
//    begin
//      Pos := dfVec3f(cRad * cos((i mod cAtomsPerRound)*(6.28 / cAtomsPerRound)), cStep * (i div cAtomsPerRound), cRad * sin((i mod cAtomsPerRound)*(6.28 / cAtomsPerRound)));
//      Pos := dfVec3f(cRange / 2 - Random(cRange * 100) / 100, cRange / 2 - Random(cRange * 100) / 100, cRange / 2 - Random(cRange * 100) / 100);
//      Col := dfVec3f(Random(100) / 100, Random(100) / 100, Random(100) / 100);
//    end;
//
//    with links[i*2] do
//    begin
//      if (i mod cAtomsPerRound) = cAtomsPerRound - 1 then
//      begin
//        p1 := particles[i].Pos;
//        p2 := particles[i - cAtomsPerRound].Pos;
//        Col := dfVec4f(0.7, 0.7, 0.7, 1.0);
//      end
//      else
//      begin
//        p1 := particles[i].Pos;
//        p2 := particles[i + 1].Pos;
//        Col := dfVec4f(0.7, 0.7, 0.7, 1.0);
//      end;
//    end;
//    if (Length(particles) - i - 1 > cAtomsPerRound) then
//      with links[i*2 + 1] do
//      begin
//        p1 := particles[i].Pos;
//        p2 := particles[i - cAtomsPerRound].Pos;
//        Col := dfVec4f(0.2, 0.2, 0.9, 1.0);
//      end;
//  end;
//  i := 0;
//  while i < High(links) do
//  begin
//    with links[i] do
//    begin
//      if (i mod cAtomsPerRound) = cAtomsPerRound - 1 then
//      begin
//        p1 := particles[i].Pos;
//        p2 := particles[i - cAtomsPerRound+1].Pos;
//        Col := dfVec4f(0.7, 0.7, 0.7, 0.5);
//      end
//      else
//      begin
//        p1 := particles[i].Pos;
//        p2 := particles[i + 1].Pos;
//        Col := dfVec4f(0.7, 0.7, 0.7, 0.5);
//      end;
//    end;
////    if (Length(particles) - i > cAtomsPerRound - 1) then
////    begin
////      with links[i + 1] do
////      begin
////        p1 := particles[i].Pos;
////        p2 := particles[i - cAtomsPerRound].Pos;
////        Col := dfVec4f(0.2, 0.2, 0.9, 1.0);
////      end;
////      i := i + 2;
////    end
////      else
//        i := i + 1;
//  end;

  particles := TList.Create();
  q := dfVec3f(0.5, 0.5, 0.5);
  glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION_ARB, @q);
  psize := 0;
  glGetFloatv(GL_POINT_SIZE_MAX_ARB, @psize);
  psize := Min(psize, 50);
  glPointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, 10.0);
  glPointParameterf(GL_POINT_SIZE_MIN, 1.5);
  glPointParameterf(GL_POINT_SIZE_MAX, psize);

  Result := -10;
end;

function SpriteStep(deltaTime: Single): Integer;
var
  i: Integer;
begin
  glTranslatef(-MaxX / 2, -MaxY / 2, 0);
  glPushAttrib(GL_LIGHTING);
  glDisable(GL_LIGHTING);

//  glBegin(GL_LINES);
//    for i := 0 to High(links) do
//    begin
//      glColor3f(links[i].Col.x, links[i].Col.y,
//                links[i].Col.z);
////      glColor3ub(255, 0, 0);
//      glVertex3f(links[i].p1.x, links[i].p1.y, links[i].p1.z);
//      glVertex3f(links[i].p2.x, links[i].p2.y, links[i].p2.z);
//    end;
////    glVertex3f(0, 0, 0);
////    glVertex3f(4, 4, 4);
//  glEnd();

//  for i := High(particles) downto  0 do
//  begin
//    with particles[i] do
//    begin
//      if pos.y > cEPS then
//      begin
//        pos.y := pos.y - Accel * deltaTime;
//        Accel := Accel + 0.003;
//      end
//      else if pos.y < -cEPS then
//      begin
//        pos.y := pos.y + Accel * deltaTime;
//        Accel := Accel + 0.003;
//      end;
//    end;
//  end;
  glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);

  glEnable(GL_POINT_SPRITE);

  glPointSize(psize);

  glTexEnvf( GL_POINT_SPRITE_ARB, GL_COORD_REPLACE_ARB, GL_TRUE );

	glBegin( GL_POINTS );
    for i := 0 to particles.Count - 1 do
      with PParticle(particles[i])^ do
      begin
        glColor4f(Col.x, Col.y, Col.z, 1.0);
        glVertex3f(Pos.x, Pos.y, Pos.z);
      end;

	glEnd();

	glDisable(GL_POINT_SPRITE);

  glDisable(GL_BLEND);

  glPopAttrib();

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
