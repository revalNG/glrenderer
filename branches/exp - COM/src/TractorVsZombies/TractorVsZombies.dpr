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

var
  tp: TtzTractorParams = (
    BodyR:       0.0; BodyD:       1.0; BodyF:        0.5;
    WheelBigR:   0.0; WheelBigD:   0.1; WheelBigF:    5.0;
    WheelSmallR: 0.0; WheelSmallD: 0.1; WheelSmallF:  5.0;
    SuspR:       0.0; SuspD:       1.0; SuspF:        0.0;

    MassCenterOffset: (X: 0; Y: 0);

    WheelBigOffset: (X: -23; Y: 20);
    WheelSmallOffset: (X: 35; Y: 25);

    Susp1Offset: (X: -23; Y: 17);
    Susp2Offset: (X: 35; Y: 22);
    Susp1Limits: (X: -2; Y: 3;);
    Susp2Limits: (X: -1; Y: 1;);
    Susp1MotorSpeed: 0.2; Susp2MotorSpeed: 0.1;
    Susp1MaxMotorForce: 0.2; Susp2MaxMotorForce: 0.1);

  Tractor: TtzTractor;
  b_Enter: Boolean;


  procedure OnBeforeSimulation(const dt: Double);
  begin
    Tractor.Update(dt);
  end;

  procedure OnUpdate(const dt: Double);
  begin
//    Tractor.Update(dt);
    b2World.Update(dt);
    if dfInput.IsKeyPressed(VK_RETURN, @b_Enter) then
    begin
      Tractor.Restart(dfVec2f(70, 50));
    end;

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
  InitEarth();

  Tractor := TtzTractor.Create;
  Tractor.Init(uMainFunctions.b2World, R.RootNode, tp,
    'data\tractor.tga', 'data\wheel_big.tga', 'data\wheel_small.tga', dfVec2f(70, 50));

  R.OnUpdate := OnUpdate;
  b2World.OnBeforeSimulation := OnBeforeSimulation;

  R.Start(); //Прерывание по Escape задано внутри модуля


  Tractor.Free;
  DeInitEarth();
  DeInitPhysics();

  R.DeInit();
  UnLoadRendererLib();
end.
