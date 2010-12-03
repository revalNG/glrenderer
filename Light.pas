{
  TODO:  1) Init, Step, DeInit
        +2) �������� ������� ��� ������ � ���������� �����
         3) �������� ��������� �����
         4) �������� � ��������
}
unit Light;

interface

uses
  dfMath;

  //������� �������������� �������

  //��������� ���� ���������� ��������� �����
  function renderLightSet(X, Y, Z,
                          AmbR, AmbG, AmbB, AmbA,
                          DifR, DifG, DifB, DifA,
                          SpecR, SpecG, SpecB, SpecA,
                          ConstAtten, LinAtten, QuadroAtten: Single): Integer; stdcall;
  //��������� ������� ��������� �����
  function renderLightSetPos(X, Y, Z: Single): Integer; stdcall;
  //��������� ������� ��������� ����� �� ��������� Speed
  function renderLightSetPosMove(X, Y, Z, Speed: Single): Integer; stdcall;
  function renderLightSetAmb(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetAmbMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  function renderLightSetDif(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetDifMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  function renderLightSetSpec(R, G, B, A: Single): Integer; stdcall;
  function renderLightSetSpecMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;

  function LightGetPos: TdfVec3f;

  function LightInit(): Integer;
  function LightStep(deltaTime: Single): Integer;
  function LightDeInit(): Integer;


implementation

uses
  dfHGL, dfHInput;

var
  LightPos: TdfVec4f;
  Amb, Dif, Spec: TdfVec4f;

  //debug
  t: Single;
  stop: Boolean;

//��������� ���� ���������� ��������� �����
function renderLightSet(X, Y, Z,
                          AmbR, AmbG, AmbB, AmbA,
                          DifR, DifG, DifB, DifA,
                          SpecR, SpecG, SpecB, SpecA,
                          ConstAtten, LinAtten, QuadroAtten: Single): Integer; stdcall;
begin
  gl.Enable(GL_LIGHT0);
  LightPos := dfVec4f(X, Y, Z, 0);
  gl.Lightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  gl.Lightfv(GL_LIGHT0, GL_CONSTANT_ATTENUATION, @ConstAtten);
  gl.Lightfv(GL_LIGHT0, GL_LINEAR_ATTENUATION, @LinAtten);
  gl.Lightfv(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, @QuadroAtten);
  Amb  := dfVec4f(AmbR, AmbG, AmbB, AmbA);
  Dif  := dfVec4f(DifR, DifG, DifB, DifA);
  Spec := dfVec4f(SpecR, SpecG, SpecB, SpecA);
  gl.Lightfv(GL_LIGHT0, GL_AMBIENT, @Amb);
  gl.Lightfv(GL_LIGHT0, GL_DIFFUSE, @Dif);
  gl.Lightfv(GL_LIGHT0, GL_SPECULAR, @Spec);
  Result := 0;
end;

//��������� ������� ��������� �����
function renderLightSetPos(X, Y, Z: Single): Integer; stdcall;
begin
  LightPos := dfVec4f(X, Y, Z, 0);
  gl.Lightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  Result := 0;
end;

//��������� ������� ��������� ����� �� ��������� Speed
function renderLightSetPosMove(X, Y, Z, Speed: Single): Integer; stdcall;
begin
  Result := -10; //�������
end;

function renderLightSetAmb(R, G, B, A: Single): Integer; stdcall;
begin
  Amb := dfVec4f(R, G, B, A);
  gl.Lightfv(GL_LIGHT0, GL_AMBIENT, @Amb);
  Result := 0;
end;

function renderLightSetAmbMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //�������
end;

function renderLightSetDif(R, G, B, A: Single): Integer; stdcall;
begin
  Dif := dfVec4f(R, G, B, A);
  gl.Lightfv(GL_LIGHT0, GL_DIFFUSE, @Dif);
  Result := 0;
end;

function renderLightSetDifMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //�������
end;

function renderLightSetSpec(R, G, B, A: Single): Integer; stdcall;
begin
  Spec := dfVec4f(R, G, B, A);
  gl.Lightfv(GL_LIGHT0, GL_SPECULAR, @Spec);
  Result := 0;
end;

function renderLightSetSpecMove(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //�������
end;


function LightGetPos: TdfVec3f;
begin
  Result.x := LightPos.x;
  Result.y := LightPos.y;
  Result.z := LightPos.z;
end;



function LightInit(): Integer;

begin
  gl.Enable(GL_LIGHT0);

  Result := 0;
  t := 0;
end;

function LightStep(deltaTime: Single): Integer;
begin
  Result := -10; //�������

  if dfInput.IsKeyDown($20) then
    stop := not stop;
  if not stop then
    t := t + deltaTime;
  LightPos := dfVec4f(5*sin(t), 3*sin(t), 5*cos(t), 0);
  gl.Lightfv(GL_LIGHT0, GL_POSITION, @LightPos);

  gl.PushAttrib(GL_COLOR);
  gl.Color3f(dif.x, dif.y, dif.z);
  gl.Disable(GL_LIGHTING);
  gl.Beginp(GL_POINTS);
    gl.Vertex3f(LightPos.x, LightPos.y, LightPos.z);
  gl.Endp;
  gl.Enable(GL_LIGHTING);
  gl.PopAttrib();
end;

function LightDeInit(): Integer;
begin
  Result := -10; //�������
end;

end.
