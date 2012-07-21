{
  Непосредственная проверка Node-системы и HUD-спрайтов
}

program Checker2;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Graphics,
  dfHRenderer in 'headers\dfHRenderer.pas',
  dfHEngine in 'common\dfHEngine.pas',
  dfMath in 'common\dfMath.pas';

var
  R: IdfRenderer;
  f: IdfFont;
  t: IdfText;
  node: IdfNode;

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

  t := dfCreateText();
  t.Font := f;
//  t.Text := '!1234567890 a b c d e я а б в г';
  t.Text := 'Как это там... Съешь еще этих мягких французских булок :) ';
  t.Position := dfVec2f(50, 50);
  t.Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);

  node := R.RootNode.AddNewChild();
  node.Renderable := t;

  R.Start();
  R.DeInit();

  UnLoadRendererLib();
end.
