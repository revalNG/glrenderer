program Checker1;

{$APPTYPE CONSOLE}
uses
  Windows,
  dfHRenderer in 'headers\dfHRenderer.pas',
  dfMath in 'common\dfMath.pas',
  dfHEngine in 'common\dfHEngine.pas';

var
  msg: TMsg;
  h: Integer;
  R: IdfRenderer;
  N1, N2, N3: IdfNode;

begin
  WriteLn(' ========= Demonstration ======== ');
  WriteLn(' ===== Press ESCAPE to EXIT ===== ');
  WriteLn(' ===== Use LEFT MOUSE BUTTON to rotate the scene');
  WriteLn(' ===== Use RIGHT MOUSE BUTTON to pan');
  WriteLn(' ===== Use Z and X buttons to roll the scene (additional rotate angle)');
  WriteLn(' ===== Use MOUSE WHEEL to scale the scene');
  R := dfCreateRenderer();
  R.Init('settings.txt');
  h := R.WindowHandle;

  N1 := dfCreateNode(nil);
  N2 := dfCreateNode(N1);
//  N2 := nil;
//  N1 := nil;
//  N2.Position := dfVec3f(0,5,0);
  N3 := dfCreateNode(nil);
//
//  WriteLn('Pos N2: ', N2.Position.x, N2.Position.y, N2.Position.z);
//
  N1.AddChild(N3);
//  N1

  repeat
    if PeekMessage(msg, 0, 0, 0, PM_NOREMOVE) then
    begin
      if GetMessage(msg, 0, 0, 0) then
      begin
        TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      SendMessage(h, 15, 0, 0);  //WM_PAINT
    end;
  until GetAsyncKeyState(VK_ESCAPE) < 0;
  R.DeInit();
  R := nil;
end.
