program Checker6;

uses
  Windows,
  dfMath in '..\..\common\dfMath.pas',
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHUtility in '..\..\headers\dfHUtility.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  uBox2DImport in '..\..\headers\box2d\uBox2DImport.pas',
  UPhysics2D in '..\..\headers\box2d\UPhysics2D.pas',
  UPhysics2DTypes in '..\..\headers\box2d\UPhysics2DTypes.pas',
  uCar in 'uCar.pas',
  uUtils in 'uUtils.pas';

type
  TglrBox = record
    sprite: IdfSprite;
    body: Tb2Body;
  end;

var
  R: IdfRenderer;
  node: IdfNode;
  back: IdfSprite;
  box_texture: IdfTexture;

  b2w: Tdfb2World;
  g: TVector2;

  fpsCounter: TdfFPSCounter;
  car: TglrCar;
  carParams: TglrCarParams =
  ( position: (X: 80; Y: 150);
    rotation: 0;
    spriteFileName: 'data/lambo.tga';
    bodySizeOffset: (X: -2; Y: -6);
    massCenterOffset: (X: -10; Y: 0);
    forcePointOffset:(X: 30; Y: 0);
    density: 1.0; friction: 0.1; restitution: 0.1;
    rightWheelOffset: (X: 30; Y: 30); leftWheelOffset: (X: 30; Y: -30);
    wheelSize: (X: 20; Y: 10));

  boxes: array of TglrBox;

  procedure OnUpdate(const dt: Double);
  var
    i: Integer;
  begin
    if R.Input.IsKeyDown(VK_ESCAPE) then
      R.Stop();
    fpsCounter.Update(dt);
    b2w.Update(dt);
    for i := Low(boxes) to High(boxes) do
      SyncObjects(boxes[i].body, boxes[i].sprite);
  end;

  procedure OnSimulation(const FixedDeltaTime: Double);
  begin
    car.Update(FixedDeltaTime);
  end;

  procedure InitBoxes();

    function AddBox(aPos: TdfVec2f; aRot: Single): TglrBox;
    begin
      Result.sprite := dfCreateHUDSprite();
      with Result.sprite do
      begin
        PivotPoint := ppCenter;
        Material.Texture := box_texture;
        Position := aPos;
        Rotation := aRot;
        Width := box_texture.Width;
        Height := box_texture.Height;
      end;

      Result.body := dfb2InitBox(b2w, Result.sprite, 1, 1.5, 0.3, $0004, $FFFF);
      Result.body.LinearDamping := 2;
      Result.body.AngularDamping := 2;
      with R.RootNode.AddNewChild do
        Renderable := Result.sprite;
    end;

  begin
    SetLength(boxes, 7);
    boxes[0] := AddBox(dfVec2f(600, 330), 0);
    boxes[1] := AddBox(dfVec2f(140, 30), 40);
    boxes[2] := AddBox(dfVec2f(650, 95), 32);
    boxes[3] := AddBox(dfVec2f(400, 120), 11);
    boxes[4] := AddBox(dfVec2f(720, 420), 23);
    boxes[5] := AddBox(dfVec2f(150, 120), 127);
    boxes[6] := AddBox(dfVec2f(400, 300), 95);

    dfb2InitBoxStatic(b2w, dfVec2f(0, 300), dfVec2f(5, 600), 0, 1, 1, 0, $FFFF, $FFFF);
    dfb2InitBoxStatic(b2w, dfVec2f(800, 300), dfVec2f(5, 600), 0, 1, 1, 0, $FFFF, $FFFF);
    dfb2InitBoxStatic(b2w, dfVec2f(400, 600), dfVec2f(800, 2), 0, 1, 1, 0, $FFFF, $FFFF);
    dfb2InitBoxStatic(b2w, dfVec2f(400, 0), dfVec2f(800, 2), 0, 1, 1, 0, $FFFF, $FFFF);
  end;

begin
  LoadRendererLib();

  R := dfCreateRenderer();
  R.Init('settings.txt');
  R.OnUpdate := OnUpdate;

  g.SetValue(0, 0);
  b2w := Tdfb2World.Create(g, True, 1 / 60, 6);
  b2w.OnBeforeSimulation := OnSimulation;

  back := dfCreateHUDSprite();
  dfLoadSprite(back, 'data/back.tga', dfVec2f(400, 300), 0);

  node := R.RootNode.AddNewChild();
  node.Renderable := back;

  box_texture := dfCreateTexture();
  box_texture.Load2D('data/box.tga');
  box_texture.BlendingMode := tbmTransparency;
  box_texture.CombineMode := tcmModulate;

  car := TglrCar.Init(R, b2w, carParams);

  InitBoxes();

  fpsCounter := TdfFPSCounter.Create(R.RootNode, 'FPS:', 1, nil);

  R.Start();

  back := nil;
  box_texture := nil;
  node := nil;
  SetLength(boxes, 0);
  fpsCounter.Free;
  car.Free;
  b2w.Free;

  R.DeInit();
  UnLoadRendererLib();
end.
