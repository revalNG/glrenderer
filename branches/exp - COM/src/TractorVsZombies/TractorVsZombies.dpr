program TractorVsZombies;

{$APPTYPE CONSOLE}

uses
  Windows,
  dfHRenderer in '..\headers\dfHRenderer.pas',
  dfHEngine in '..\common\dfHEngine.pas',
  dfHInput in '..\common\dfHInput.pas',
  dfMath in '..\common\dfMath.pas',
  uMainFunctions in 'uMainFunctions.pas',
  uMyWorld in 'box2d\uMyWorld.pas',
  UPhysics2D in 'box2d\UPhysics2D.pas',
  UPhysics2DControllers in 'box2d\UPhysics2DControllers.pas',
  UPhysics2DTypes in 'box2d\UPhysics2DTypes.pas',
  uTractor in 'uTractor.pas',
  uUtils in 'uUtils.pas';

  procedure OnBeforeSimulation(const dt: Double);
  begin
    if dfInput.IsKeyDown(VK_RIGHT) then
    begin
//      b2wheel_big.ApplyTorque(10*dt);
      b2Sprite.LinearDamping := 0.1;
      joint1.EnableMotor(True);
      joint1.SetMotorSpeed(-5);
      joint1.SetMaxMotorTorque(200);

//      joint2.EnableMotor(True);
//      joint2.SetMotorSpeed(-4);
//      joint2.SetMaxMotorTorque(400);
    end
    else if dfInput.IsKeyDown(VK_LEFT) then
    begin
      b2Sprite.LinearDamping := 0.1;
      joint1.EnableMotor(True);
      joint1.SetMotorSpeed(5);
      joint1.SetMaxMotorTorque(200);

//      joint2.EnableMotor(True);
//      joint2.SetMotorSpeed(4);
//      joint2.SetMaxMotorTorque(400);
    end
    else if dfInput.IsKeyDown(VK_DOWN) then
    begin
      joint1.EnableMotor(True);
      joint1.SetMotorSpeed(0);
      joint1.SetMaxMotorTorque(0.5);

      joint2.EnableMotor(True);
      joint2.SetMotorSpeed(0);
      joint2.SetMaxMotorTorque(0.1);
      b2Sprite.LinearDamping := 1;
    end
    else
    begin
      b2Sprite.LinearDamping := 0.1;
      joint1.EnableMotor(False);
      joint2.EnableMotor(False);
      joint1.SetMaxMotorTorque(200);
    end;
  end;

  procedure OnUpdate(const dt: Double);
  begin
    b2World.Update(dt);
//    SyncObjects(b2Sprite, Sprite);
//    SyncObjects(b2wheel_big, wheel_big);
//    SyncObjects(b2wheel_small, wheel_small);
  end;

begin
  WriteLn(' ========= TRACTOR VERSUS ZOMBIES');
  WriteLn(' ========= Demo 0.0.1');
  WriteLn('');
  WriteLn(' ========= Press ESCAPE to EXIT');

  LoadRendererLib();
  R := dfCreateRenderer();
  R.Init('settings_TvsZ.txt');

  InitPhysics();
//  InitSprite();
//  InitJoints();
  InitEarth();

  R.OnUpdate := OnUpdate;
  b2World.OnBeforeSimulation := OnBeforeSimulation;

  R.Start(); //Прерывание по Escape задано внутри модуля

  R.DeInit();
  DeInitSprite();
  DeInitEarth();
  DeInitPhysics();
  UnLoadRendererLib();
end.
