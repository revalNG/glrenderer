{
  TODO:  1) Init, Step, DeInit
        +2) Основные функции для работы с источником света
         3) Анимация источника света
         4) Описание к функциям
}
unit Light;

interface

  //ВНЕШНИЕ ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ

  //Установка всех параметров источника света
  function renderLightSet(X, Y, Z,
                          AmbR, AmbG, AmbB, AmbA,
                          DifR, DifG, DifB, DifA,
                          SpecR, SpecG, SpecB, SpecA,
                          ConstAtten, LinAtten, QuadroAtten: Single): Integer; stdcall;
  //Установка позиции источника света
  function renderLightSetPos(X, Y, Z: Single): Integer; stdcall;
  //Установка позиции источника света со скоростью Speed
  function renderLightSetPosMove(X, Y, Z, Speed: Single): Integer; stdcall;
  function renderLightSetAmb(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetAmbMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  function renderLightSetDif(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetDifMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  function renderLightSetSpec(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetSpecMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;

  function LightInit(): Integer;
  function LightStep(deltaTime: Single): Integer;
  function LightDeInit(): Integer;

implementation

uses
  dglOpenGl, dfMath, dfHInput;

var
  LightPos: TdfVec4f;
  Amb, Dif, Spec: TdfVec4f;

  //debug
  f: PGLUQuadric;
  t: Single;
  stop: Boolean;

//Установка всех параметров источника света
function renderLightSet(X, Y, Z,
                          AmbR, AmbG, AmbB, AmbA,
                          DifR, DifG, DifB, DifA,
                          SpecR, SpecG, SpecB, SpecA,
                          ConstAtten, LinAtten, QuadroAtten: Single): Integer; stdcall;
begin
  glEnable(GL_LIGHT0);
  LightPos := dfVec4f(X, Y, Z, 0);
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  glLightfv(GL_LIGHT0, GL_CONSTANT_ATTENUATION, @ConstAtten);
  glLightfv(GL_LIGHT0, GL_LINEAR_ATTENUATION, @LinAtten);
  glLightfv(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, @QuadroAtten);
  Amb  := dfVec4f(AmbR, AmbG, AmbB, AmbA);
  Dif  := dfVec4f(DifR, DifG, DifB, DifA);
  Spec := dfVec4f(SpecR, SpecG, SpecB, SpecA);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @Amb);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Dif);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @Spec);
  Result := 0;
end;

//Установка позиции источника света
function renderLightSetPos(X, Y, Z: Single): Integer; stdcall;
begin
  LightPos := dfVec4f(X, Y, Z, 0);
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  Result := 0;
end;

//Установка позиции источника света со скоростью Speed
function renderLightSetPosMove(X, Y, Z, Speed: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

function renderLightSetAmb(R, G, B, A: Single): Integer; stdcall;
begin
  Amb := dfVec4f(R, G, B, A);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @Amb);
  Result := 0;
end;

function renderLightSetAmbMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

function renderLightSetDif(R, G, B, A: Single): Integer; stdcall;
begin
  Dif := dfVec4f(R, G, B, A);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Dif);
  Result := 0;
end;

function renderLightSetDifMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

function renderLightSetSpec(R, G, B, A: Single): Integer; stdcall;
begin
  Spec := dfVec4f(R, G, B, A);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @Spec);
  Result := 0;
end;

function renderLightSetSpecMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;



function LightInit(): Integer;

begin
  glEnable(GL_LIGHT0);

  f := gluNewQuadric();
  Result := 0;

  t := 0;
end;

function LightStep(deltaTime: Single): Integer;
begin
  Result := -10; //Затычка

  if dfInput.IsKeyDown($20) then
    stop := not stop;
  if not stop then
    t := t + deltaTime;
  LightPos := dfVec4f(5*sin(t), 3*sin(t), 5*cos(t), 0);
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);

  glPushAttrib(GL_COLOR);
  glColor3f(dif.x, dif.y, dif.z);
  glPushMatrix();
  glTranslatef(LightPos.x, LightPos.y, LightPos.z);
  glDisable(GL_LIGHTING);
  gluSphere(f, 0.1, 8, 8);
  glEnable(GL_LIGHTING);
  glPopMatrix();
  glPopAttrib();
end;

function LightDeInit(): Integer;
begin
  Result := -10; //Затычка
  gluDeleteQuadric(f);
end;

end.
