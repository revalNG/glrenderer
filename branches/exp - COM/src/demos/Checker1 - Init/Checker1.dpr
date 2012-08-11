{
  ������������ ���������� � ������ ����� �� ������������� ������
}

program Checker1;

{$APPTYPE CONSOLE}
uses
  Windows,
  SysUtils,
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfHInput in '..\..\common\dfHInput.pas';

var
  R: IdfRenderer;
  dx, dy: Integer;

  procedure OnMouseDown(X, Y: TdfInteger; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  begin
    dx := x;
    dy := y;
    R.WindowCaption := PWideChar('���� ��: ' + IntToStr(x) + ' : ' + IntToStr(y));
  end;

  procedure OnMouseMove(X, Y: Integer; Shift: TdfMouseShiftState);
  begin
    if Shift = [] then
      R.WindowCaption := PWideChar('���� ���������: ' + IntToStr(x) + ' : ' + IntToStr(y))
    else if ssLeft in Shift then
    begin
      R.WindowCaption := PWideChar('���� ���������: ' + IntToStr(x) + ' : ' + IntToStr(y) + ' � ������� ����� �������');
      with R.Camera do
      begin
        Rotate(deg2rad*(x - dx), Up);
        Rotate(deg2rad*(y - dy), Left);
      end;
      dx := x;
      dy := y;
    end;
  end;

  procedure OnUpdate(const dt: Double);
  begin
    if dfInput.IsKeyDown(VK_ESCAPE) then
      R.Stop();
  end;

//  procedure OnMouseMove(X, Y: TdfInteger; Shift: TdfMouseShiftState);
//  begin
//    if ssLeft in Shift then
//      with RM.Renderer.Camera.LocalMatrix do
//      begin
//        Rotate(deg2rad*(x - dx), dfVec3f(0, 1, 0));
//        Rotate(deg2rad*(y - dy), dfVec3f(e00, e01, e02));
//        dx := x;
//        dy := y;
//      end;
//  end;

begin
  WriteLn(' ========= Demonstration ======== ');
  WriteLn(' ===== Press ESCAPE to EXIT ===== ');
  WriteLn(' ===== Use LEFT MOUSE BUTTON to rotate the scene');
  WriteLn(' ===== Use RIGHT MOUSE BUTTON to pan');
  WriteLn(' ===== Use Z and X buttons to roll the scene (additional rotate angle)');
  WriteLn(' ===== Use MOUSE WHEEL to scale the scene');

  LoadRendererLib();

  R := dfCreateRenderer();
  R.Init('settings.txt');
  R.OnMouseDown := OnMouseDown;
  R.OnMouseMove := OnMouseMove;
  R.OnUpdate := OnUpdate;

  R.Start();
  R.DeInit();
  R := nil;

  UnLoadRendererLib();
end.
