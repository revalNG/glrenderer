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
//  renderInit(600, 400, 100, 100, 90, 0.1, 500);
  renderInit2('settings.txt');
  h := renderWindowGetHandle();
//  renderDataAddFromFile('my.txt');
//  renderCameraSetPosMove(0, -3, 10, 2, 0.001);
  renderSpritesAddFromFile('inf.txt');
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
      SendMessage(h, 15, 0, 0);
    end;
  until GetAsyncKeyState(VK_ESCAPE) < 0;
  renderDeInit;
end.
