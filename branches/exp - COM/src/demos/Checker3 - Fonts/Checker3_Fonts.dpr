{
  Непосредственная проверка Node-системы и HUD-спрайтов
}

program Checker2;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Graphics,
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHUtility in '..\..\headers\dfHUtility.pas';

var
  R: IdfRenderer;
  f: IdfFont;
  t, t2: IdfText;
  node, node2: IdfNode;

  fpsCounter: TdfFPSCounter;

  procedure OnUpdate(const dt: Double);
  var
    vp: TdfViewportParams;
  begin
    if R.Input.IsKeyDown(VK_ESCAPE) then
      R.Stop();
    fpsCounter.Update(dt);
    vp := R.Camera.GetViewport();
    t.Text := 'Viewport - X: ' + IntToStr(vp.X) + '; Y: ' + IntToStr(vp.Y) + '; W: ' + IntToStr(vp.W) + '; H: ' + IntToStr(vp.H);
  end;

  procedure OnMouseDown(X, Y: Integer; mb: TdfMouseButton; shift: TdfMouseShiftState);
  begin
    t2.Text := 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y) + ';';
  end;

begin
  WriteLn(' ========= Demonstration 3 ======== ');
  WriteLn(' ====== Press ESCAPE to EXIT ====== ');

  LoadRendererLib();

  R := dfCreateRenderer();

  R.Init('settings.txt');

  f := dfCreateFont();
  f.AddRange('!', '~');
  f.AddRange('А', 'я');
  f.AddRange(' ', ' ');
  f.FontSize := 14;
  f.FontStyle := [];
//  f.GenerateFromTTF('data\BankGothic RUSS Medium.ttf');
//  f.GenerateFromTTF('data\Journal Regular.ttf');
  f.GenerateFromFont('Times New Roman');
//
  t := dfCreateText();
  t.Font := f;
  t.Text := '!1234567890 a b c d e я а б в г';
  t.Text := 'Как это там... Съешь-ка еще этих мягких французских булок :) ';
  t.Position := dfVec2f(50, 50);
  t.Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);

  t2 := dfCreateText();
  t2.Font := f;
  t2.Position := dfVec2f(300, 5);
//
  node := R.RootNode.AddNewChild();
  node.Renderable := t;
  node2 := R.RootNode.AddNewChild();
  node2.Renderable := t2;

  fpsCounter := TdfFPSCounter.Create(R.RootNode, 'FPS:', 1, nil);

  R.OnUpdate := OnUpdate;
  R.OnMouseDown := OnMouseDown;

  R.Start();
  R.DeInit();

  UnLoadRendererLib();

  fpsCounter.Free;
end.
