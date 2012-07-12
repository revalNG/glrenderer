{
  TODO: ����������� ��������� �����
  TODO: �������� �������
}

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
  uUtils in 'uUtils.pas',
  uLevel in 'uLevel.pas',
  uSingletons in 'uSingletons.pas';


const
  C_STEP = 1 / 60;

var
  R: IdfRenderer;

  tp: TtzTractorParams = (
    BodyR:       0.0; BodyD:       1.0; BodyF:        0.5;
    WheelBigR:   0.0; WheelBigD:   0.1; WheelBigF:    5.0;
    WheelSmallR: 0.0; WheelSmallD: 0.1; WheelSmallF:  5.0;
    SuspR:       0.0; SuspD:       1.0; SuspF:        0.1;

    MassCenterOffset: (X: 0; Y: 0);

    WheelBigOffset: (X: -23; Y: 25);
    WheelSmallOffset: (X: 35; Y: 30);

    Susp1Offset: (X: -23; Y: 20);
    Susp2Offset: (X: 35; Y: 25);
    Susp1Limits: (X: -1; Y: 2;);
    Susp2Limits: (X: -1; Y: 2;);
    Susp1MotorSpeed: 0.2; Susp2MotorSpeed: 0.2;
    Susp1MaxMotorForce: 0.2; Susp2MaxMotorForce: 0.2);

//  Tractor: TtzTractor;
  b_Enter: Boolean;

  g: TVector2;


  procedure OnBeforeSimulation(const dt: Double);
  begin
    vPlayer.Update(dt);
  end;

  procedure OnUpdate(const dt: Double);
  begin
//    Tractor.Update(dt);
    vb2World.Update(dt);
    vCurrentLevel.Update(dt);
    if dfInput.IsKeyPressed(VK_RETURN, @b_Enter) then
    begin
      vPlayer.Restart(dfVec2f(70, 50));
    end;
  end;

begin
  WriteLn(' ========= TRACTOR VERSUS ZOMBIES');
  WriteLn(' ========= Demo 0.0.1');
  WriteLn('');
  WriteLn(' ========= Press ESCAPE to EXIT');

  //Renderer
  LoadRendererLib();
  R := dfCreateRenderer();
  R.Init('settings_TvsZ.txt');
  vRootNode := R.RootNode;

  //b2world
  g.SetValue(0, 3);
  vb2World := Tdfb2World.Create(g, True, C_STEP, 6);

  //player
  vPlayer := TtzTractor.Create;
  vPlayer.Init(vb2World, R.RootNode, tp,
    'data\tractor.tga', 'data\wheel_big.tga', 'data\wheel_small.tga', dfVec2f(70, 50));

  //level
  vCurrentLevel := TtzLevel.Create(R.RootNode);
  vCurrentLevel.LoadFromFile('data\level1.txt');
//  vCurrentLevel.SetBlocks();
//  vCurrentLevel.SaveToFile('data\level1.txt');

  //callbacks
  R.OnUpdate := OnUpdate;
  vb2World.OnBeforeSimulation := OnBeforeSimulation;

  R.Start(); //���������� �� Escape ������ ������ ������


  vPlayer.Free;
  vCurrentLevel.Free;
  vb2World.Free;
  R.DeInit();
  UnLoadRendererLib();
end.
