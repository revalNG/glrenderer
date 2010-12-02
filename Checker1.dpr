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
  renderInit('settings.txt');
  h := renderWindowGetHandle();
//  renderSpritesAddFromFile('inf.txt');
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
