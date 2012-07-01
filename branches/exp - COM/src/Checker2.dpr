{
  Непосредственная проверка Node-системы и HUD-спрайтов
}

program Checker2;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  dfHRenderer in 'headers\dfHRenderer.pas',
  dfHEngine in 'common\dfHEngine.pas',
  dfMath in 'common\dfMath.pas';

var
  msg: TMsg;
  h: Integer;
  R: IdfRenderer;
  NewNode: IdfNode;

  dx, dy: Integer;

  procedure OnMouseMove(X, Y: Integer; Shift: TdfMouseShiftState);
  begin
    if Shift = [] then
      R.WindowCaption := PWideChar('Мышь двигается: ' + IntToStr(x) + ' : ' + IntToStr(y))
    else if ssLeft in Shift then
    begin
      R.WindowCaption := PWideChar('Мышь двигается: ' + IntToStr(x) + ' : ' + IntToStr(y) + ' с зажатой левой кнопкой');
      with R.Camera do
      begin
        Rotate(deg2rad*(x - dx), Up);
        Rotate(deg2rad*(y - dy), Left);
      end;
      dx := x;
      dy := y;
    end;
  end;

begin
  WriteLn(' ========= Demonstration 2 ======== ');
  WriteLn(' ====== Press ESCAPE to EXIT ====== ');

  LoadRendererLib();

  R := dfCreateRenderer();
  R.Init('settings.txt');
  R.OnMouseMove := OnMouseMove;
  h := R.WindowHandle;

  NewNode := R.RootNode.AddNewChild();

  NewNode.Renderable := dfCreateHUDSprite();

  with IdfSprite(NewNode.Renderable) do
  begin
    Width := 800;
    Height := 600;
  end;

  NewNode.Position := dfVec3f(0, 0, 0);

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
//Зануления интерфейсов не нужны, они самозануляются при окончании программы
//  NewNode := nil;
//  R := nil;

  UnLoadRendererLib();
//  ReadLn(h);
end.
