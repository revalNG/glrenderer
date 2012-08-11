{
  Непосредственная проверка Node-системы и HUD-спрайтов
}

program Checker2;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHInput in '..\..\common\dfHInput.pas';

var
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

  procedure OnMouseDown(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  begin
    case IdfSprite(NewNode.Renderable).PivotPoint of
      ppTopLeft:
      begin
        IdfSprite(NewNode.Renderable).PivotPoint := ppTopRight;
        R.WindowCaption := 'TopRight';
      end;
      ppTopRight:
      begin
        IdfSprite(NewNode.Renderable).PivotPoint := ppBottomLeft;
        R.WindowCaption := 'BottomLeft';
      end;
      ppBottomLeft:
      begin
        IdfSprite(NewNode.Renderable).PivotPoint := ppBottomRight;
        R.WindowCaption := 'BottomRight';
      end;
      ppBottomRight:
      begin
        IdfSprite(NewNode.Renderable).PivotPoint := ppCenter;
        R.WindowCaption := 'Center';
      end;
      ppCenter:
      begin
        IdfSprite(NewNode.Renderable).PivotPoint := ppTopLeft;
        R.WindowCaption := 'TopLeft';
      end;
    end;
  end;

  procedure OnUpdate(const dt: Double);
  begin
    if dfInput.IsKeyDown(VK_ESCAPE) then
      R.Stop();
  end;

begin
  WriteLn(' ========= Demonstration 2 ======== ');
  WriteLn(' ====== Press ESCAPE to EXIT ====== ');

  LoadRendererLib();

  R := dfCreateRenderer();
  R.Init('settings.txt');
//  R.OnMouseMove := OnMouseMove;
  R.OnMouseDown := OnMouseDown;
  R.OnUpdate := OnUpdate;

  NewNode := R.RootNode.AddNewChild();

  NewNode.Renderable := dfCreateHUDSprite();

  with IdfSprite(NewNode.Renderable) do
  begin
    Width := 200;
    Height := 100;
    Position := dfVec2f(300, 300);
  end;

//  NewNode.Renderable.Material := dfCreateMaterial();
  NewNode.Renderable.Material.Texture := dfCreateTexture();
  NewNode.Renderable.Material.Texture.Load2D('data\tile.bmp');
  NewNode.Renderable.Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);

  R.Start();

  R.DeInit();
//Зануления интерфейсов не нужны, они самозануляются при окончании программы
//  NewNode := nil;
//  R := nil;

  UnLoadRendererLib();
end.
