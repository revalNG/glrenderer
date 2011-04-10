program Checker1;

{$APPTYPE CONSOLE}
uses
  Windows,
  Header in 'Header.pas';

var
  msg: TMsg;
  h: Integer;

begin
  WriteLn(' ========= Demonstration ======== ');
  WriteLn(' ===== Press ESCAPE to EXIT ===== ');
  WriteLn(' ===== Use LEFT MOUSE BUTTON to rotate the scene');
  WriteLn(' ===== Use RIGHT MOUSE BUTTON to pan');
  WriteLn(' ===== Use Z and X buttons to roll the scene (additional rotate angle)');
  WriteLn(' ===== Use MOUSE WHEEL to scale the scene');
  WriteLn(' ===== Use C to get back to origin camera position');
  renderInit('settings.txt');
  h := renderWindowGetHandle();
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
  renderDeInit;
end.
