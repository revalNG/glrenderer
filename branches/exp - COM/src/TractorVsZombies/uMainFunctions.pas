unit uMainFunctions;

interface

uses
  dfHRenderer, dfMath, dfHEngine,
  //box2d
  uMyWorld, UPhysics2D, UPhysics2DControllers, UPhysics2DTypes;

const
  C_STEP = 1 / 60;
  c_coef = 1 / 40;


var
  R: IdfRenderer;

  b2World: Tdfb2World;
  t: Double;
//  iPlayerContacts: Integer;
  b2Earth, b2Sprite, b2wheel_big, b2wheel_small, b2Suspension1, b2Suspension2: Tb2Body;
  joint1, joint2: Tb2RevoluteJoint;
  joint_susp1, joint_susp2: Tb2PrismaticJoint;

  Sprite, SpriteEarth, wheel_big, wheel_small: IdfSprite;
  MainNode, EarthNode, wheel_bigNode, wheel_smallNode: IdfNode;


  procedure InitPhysics();
//  procedure InitSprite();
//  procedure InitJoints();
  procedure InitEarth();


  procedure DeInitSprite();
  procedure DeInitEarth();
  procedure DeInitPhysics();


implementation

{$REGION ' [ Init functions ] '}
  procedure InitPhysics();
  var
    g: TVector2;
  begin
    g.SetValue(0, 1);
    b2World := Tdfb2World.Create(g, True, C_STEP, 16);
  end;

(*

  procedure InitSprite();
  var
    BodyDef: Tb2BodyDef;
    ShapeDef: Tb2PolygonShape;
    ShapeDef2: Tb2CircleShape;
    FixtureDef: Tb2FixtureDef;
    mass: Tb2MassData;
  begin
    Sprite := dfCreateHUDSprite();
    with Sprite do
    begin
      Position := dfVec2f(300, 300);
      PivotPoint := ppCenter;
      Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
      Material.Texture := dfCreateTexture();
      Material.Texture.Load2D('data\tractor.tga');
      Material.Texture.BlendingMode := tbmTransparency;
      Material.Texture.CombineMode := tcmModulate;
      Width := Material.Texture.Width;
      Height := Material.Texture.Height;
    end;

    MainNode := R.RootNode.AddNewChild();
    MainNode.Renderable := Sprite;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2PolygonShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position := ConvertGLToB2(Sprite.Position * c_coef);
      angle := 0;
    end;

    with ShapeDef do
    begin
      SetAsBox(Sprite.Width / 2 * c_coef, Sprite.Height / 2 * c_coef);
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 0.5;
      friction := 1.0;
      restitution := 0.0;
      filter.maskBits := $0001;
      filter.categoryBits := $0002;
    end;

    b2Sprite := b2World.CreateBody(BodyDef);
    b2Sprite.CreateFixture(FixtureDef);
    b2Sprite.SetSleepingAllowed(False);
    b2Sprite.GetMassData(mass);
    mass.center.SetValue(10 * c_coef, 0);
    b2Sprite.SetMassData(mass);

//    BodyDef.Free;
//    ShapeDef.Free;
//    FixtureDef.Free;

    { ÓÎÂÒ‡}
    wheel_big := dfCreateHUDSprite();
    with wheel_big do
    begin
      Position := Sprite.Position + dfVec2f(-23, 20);
      PivotPoint := ppCenter;
      Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
      Material.Texture := dfCreateTexture();
      Material.Texture.Load2D('data\wheel_big1.tga');
      Material.Texture.BlendingMode := tbmTransparency;
      Material.Texture.CombineMode := tcmModulate;
      Width := Material.Texture.Width;
      Height := Material.Texture.Height;
    end;


    wheel_bigNode := R.RootNode.AddNewChild();
    wheel_bigNode.Renderable := wheel_big;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef2 := Tb2CircleShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position := ConvertGLToB2(wheel_big.Position * c_coef);
      angle := 0;
      angularDamping := 0.1;
    end;

    with ShapeDef2 do
    begin
      m_radius := wheel_big.Width * c_coef / 2;
    end;

    with FixtureDef do
    begin
      shape := ShapeDef2;
      density := 0.1;
      friction := 10.0;
      restitution := 0.0;
      filter.maskBits := $0001;
      filter.categoryBits := $0004;
    end;

    b2wheel_big := b2World.CreateBody(BodyDef);
    b2wheel_big.CreateFixture(FixtureDef);
    b2wheel_big.SetSleepingAllowed(False);

//    BodyDef.Free;
//    ShapeDef2.Free;
//    FixtureDef.Free;

    //small
    wheel_small := dfCreateHUDSprite();
    with wheel_small do
    begin
      Position := Sprite.Position + dfVec2f(35, 25);
      PivotPoint := ppCenter;
      Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
      Material.Texture := dfCreateTexture();
      Material.Texture.Load2D('data\wheel_small1.tga');
      Material.Texture.BlendingMode := tbmTransparency;
      Material.Texture.CombineMode := tcmModulate;
      Width := Material.Texture.Width;
      Height := Material.Texture.Height;
    end;


    wheel_smallNode := R.RootNode.AddNewChild();
    wheel_smallNode.Renderable := wheel_small;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef2 := Tb2CircleShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position := ConvertGLToB2(wheel_small.Position * c_coef);
      angle := 0;
      angularDamping := 0.1;
    end;

    with ShapeDef2 do
    begin
      m_radius := wheel_small.Width / 2 * c_coef;
    end;

    with FixtureDef do
    begin
      shape := ShapeDef2;
      density := 0.1;
      friction := 10.0;
      restitution := 0.0;
      filter.maskBits := $0001;
      filter.categoryBits := $0004;
    end;

    b2wheel_small := b2World.CreateBody(BodyDef);
    b2wheel_small.CreateFixture(FixtureDef);
    b2wheel_small.SetSleepingAllowed(False);

//    BodyDef.Free;
//    ShapeDef2.Free;
//    FixtureDef.Free;
  end;

  procedure InitJoints();
  var
    def: Tb2RevoluteJointDef;
    def2: Tb2PrismaticJointDef;
    BodyDef: Tb2BodyDef;
    ShapeDef: Tb2CircleShape;
    FixtureDef: Tb2FixtureDef;

    vec: TVector2;
  begin
    //œŒƒ¬≈— ¿

    //œŒƒ¬≈— ¿ 1

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2CircleShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position := ConvertGLToB2((wheel_big.Position + dfVec2f(0, 1)) * c_coef);
      angle := 0;
    end;

    with ShapeDef do
    begin
      m_radius := 2 * c_coef;
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 1.0;
      friction := 0.0;
      restitution := 0.0;
      filter.maskBits := $0001;
      filter.categoryBits := $0002;
    end;

    b2Suspension1 := b2World.CreateBody(BodyDef);
    b2Suspension1.CreateFixture(FixtureDef);
    b2Suspension1.SetSleepingAllowed(False);

    vec.SetValue(0, 1);
    def2 := Tb2PrismaticJointDef.Create;
    def2.Initialize(b2Sprite, b2Suspension1, b2Suspension1.GetPosition, vec);
    with def2 do
    begin
      EnableMotor := True;
      EnableLimit := True;
    end;
    joint_susp1 := Tb2PrismaticJoint(b2World.CreateJoint(def2));
    joint_susp1.SetLimits(-0.00 * c_coef, 0.0  * c_coef);
    joint_susp1.SetMotorSpeed(10);
    joint_susp1.SetMaxMotorForce(10);


    //œŒƒ¬≈— ¿ 2

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2CircleShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position := ConvertGLToB2((wheel_small.Position + dfVec2f(0, 1)) * c_coef);
      angle := 0;
    end;

    with ShapeDef do
    begin
      m_radius := 2 * c_coef;
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 1.0;
      friction := 0.0;
      restitution := 0.0;
      filter.maskBits := $0001;
      filter.categoryBits := $0002;
    end;

    b2Suspension2 := b2World.CreateBody(BodyDef);
    b2Suspension2.CreateFixture(FixtureDef);
    b2Suspension2.SetSleepingAllowed(False);

    vec.SetValue(0, 1);
    def2 := Tb2PrismaticJointDef.Create;
    def2.Initialize(b2Sprite, b2Suspension2, b2Suspension2.GetPosition, vec);
    with def2 do
    begin
      EnableMotor := True;
      EnableLimit := True;
    end;
    joint_susp2 := Tb2PrismaticJoint(b2World.CreateJoint(def2));
    joint_susp2.SetLimits(-0.00 * c_coef, 0.0  * c_coef);
    joint_susp2.SetMotorSpeed(10);
    joint_susp2.SetMaxMotorForce(10);

// ŒÀ≈—Õ€≈ ƒ∆Œ»Õ“€

    def := Tb2RevoluteJointDef.Create;
    def.Initialize(b2wheel_big, b2Suspension1, ConvertGLToB2(wheel_big.Position * c_coef));
    def.enableLimit := false;
//    def.enableMotor := false;
    joint1 := Tb2RevoluteJoint(b2World.CreateJoint(def));
//    joint1.EnableLimit(false);

    def := Tb2RevoluteJointDef.Create;
    def.Initialize(b2wheel_small, b2Suspension2, ConvertGLToB2(wheel_small.Position * c_coef));
    def.enableLimit := false;
//    def.enableMotor := false;
    joint2 := Tb2RevoluteJoint(b2World.CreateJoint(def));
  end;

  *)
  procedure InitEarth();
  var
    BodyDef: Tb2BodyDef;
    ShapeDef: Tb2PolygonShape;
    FixtureDef: Tb2FixtureDef;
  begin
    SpriteEarth := dfCreateHUDSprite();
    SpriteEarth.Position := dfVec2f(300, 380);
    SpriteEarth.PivotPoint := ppCenter;
    SpriteEarth.Width := 600;
    SpriteEarth.Height := 20;
    SpriteEarth.Material.MaterialOptions.Diffuse := dfVec4f(0.3, 0.8, 0.3, 1);
    SpriteEarth.Rotation := 0.0 * rad2deg;

    EarthNode := R.RootNode.AddNewChild();
    EarthNode.Renderable := SpriteEarth;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2PolygonShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_staticBody;
//      position := ConvertGltoB2(SpriteEarth.Position * c_coef);
      angle := SpriteEarth.Rotation * deg2rad;
    end;

    with ShapeDef do
    begin
      SetAsBox(SpriteEarth.Width  * c_coef / 2,SpriteEarth.Height  * c_coef / 2);
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 0.1;
      friction := 2.0;
      restitution := 0.0;
    end;

    b2Earth := b2World.CreateBody(BodyDef);
    b2Earth.CreateFixture(FixtureDef);
    b2Earth.SetSleepingAllowed(True);
  end;
{$ENDREGION}

{$REGION ' [ Deinit functions ] '}

procedure DeInitSprite();
begin

end;

procedure DeInitEarth();
begin

end;

procedure DeInitPhysics();
begin
  b2World.Free;
end;

{$ENDREGION}

end.
