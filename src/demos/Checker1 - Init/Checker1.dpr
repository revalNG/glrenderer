{
  ������������ ���������� � ������ ����� �� ������������� ������
}

program Checker1;

{$APPTYPE CONSOLE}
uses
  ShareMem,
  Windows,
  SysUtils,
  glr in '..\..\headers\glr.pas',
  glrMath in '..\..\headers\glrMath.pas',
  ogl in '..\..\headers\ogl.pas';

var
  R: IglrRenderer;
  dx, dy: Integer;

  procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState);
  begin
    dx := x;
    dy := y;
    R.WindowCaption := PWideChar('���� ��: ' + IntToStr(x) + ' : ' + IntToStr(y));
  end;

  procedure OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState);
  begin
    if Shift = [] then
      R.WindowCaption := PWideChar('���� ���������: ' + IntToStr(x) + ' : ' + IntToStr(y))
    else if ssLeft in Shift then
    begin
      R.WindowCaption := PWideChar('���� ���������: ' + IntToStr(x) + ' : ' + IntToStr(y) + ' � ������� ����� �������');
      with R.Camera do
      begin
        Rotate(deg2rad*(x - dx), Up);
        Rotate(deg2rad*(y - dy), Right);
      end;
      dx := x;
      dy := y;
    end;
  end;

  procedure OnUpdate(const dt: Double);
  begin
    if R.Input.IsKeyDown(VK_ESCAPE) then
      R.Stop();
    if R.Input.IsKeyDown(VK_LEFT) then
      R.Camera.Position := R.Camera.Position + dfVec3f(50 * dt, 0, 0);
    if R.Input.IsKeyDown(VK_RIGHT) then
      R.Camera.Position := R.Camera.Position + dfVec3f(-50 * dt, 0, 0);
    if R.Input.IsKeyDown(VK_UP) then
      R.Camera.Position := R.Camera.Position + dfVec3f(0, 50 * dt, 0);
    if R.Input.IsKeyDown(VK_DOWN) then
      R.Camera.Position := R.Camera.Position + dfVec3f(0, -50 * dt, 0);
  end;

begin
  WriteLn(' ========= Demonstration ======== ');
  WriteLn(' ===== Press ESCAPE to EXIT ===== ');
  WriteLn(' ===== Use LEFT MOUSE BUTTON to rotate the scene');

  LoadRendererLib();

  R := glrGetRenderer();
  R.Init('settings.txt');
  R.OnMouseDown := OnMouseDown;
  R.OnMouseMove := OnMouseMove;
  R.OnUpdate := OnUpdate;

  R.Start();
  R.DeInit();
  R := nil;

  UnLoadRendererLib();
end.
