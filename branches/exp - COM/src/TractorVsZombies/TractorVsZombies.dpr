program TractorVsZombies;

{$APPTYPE CONSOLE}

uses
  Windows,

  //glrenderer headers
  dfHRenderer in '..\headers\dfHRenderer.pas',
  dfHEngine in '..\common\dfHEngine.pas',
  dfHInput in '..\common\dfHInput.pas',
  dfMath in '..\common\dfMath.pas',

  //game modules
  uMainFunctions in 'uMainFunctions.pas',

  //box2d
  uMyWorld in 'box2d\uMyWorld.pas',
  UPhysics2D in 'box2d\UPhysics2D.pas',
  UPhysics2DControllers in 'box2d\UPhysics2DControllers.pas',
  UPhysics2DTypes in 'box2d\UPhysics2DTypes.pas';

//type
//  TdfContactListener = class(Tb2ContactListener)
//  private
//  public
//    procedure BeginContact(var contact: Tb2Contact); override;
//    procedure EndContact(var contact: Tb2Contact); override;
//  end;

  procedure OnUpdate(const dt: Double);
  begin
    if dfInput.IsKeyDown(VK_RIGHT) then
      Sprite.Position := Sprite.Position + dfVec2f(50 * dt, 0)
    else if dfInput.IsKeyDown(VK_LEFT) then
      Sprite.Position := Sprite.Position + dfVec2f(-50 * dt, 0);

    b2World.Update(dt);
    SyncObjects(b2Sprite, Sprite);
  end;

//var
//  u: Integer;
//  n1, n2: IdfNode;

begin
  WriteLn(' ========= TRACTOR VERSUS ZOMBIES');
  WriteLn(' ========= Demo 0.0.1');
  WriteLn('');
  WriteLn(' ========= Press ESCAPE to EXIT');

  LoadRendererLib();
  R := dfCreateRenderer();
  R.Init('settings_TvsZ.txt');

  InitPhysics();
//  n1 := R.RootNode.AddNewChild();
//  n2 := R.RootNode.AddNewChild();
  InitSprite();
  InitEarth();

  R.OnUpdate := OnUpdate;

  R.Start(); //Прерывание по Escape задано внутри модуля

  R.DeInit();
  DeInitSprite();
  DeInitEarth();
  DeInitPhysics();
  UnLoadRendererLib();
//  readln(u);
end.
