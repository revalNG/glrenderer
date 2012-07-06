unit uMainFunctions;

interface

uses
  dfHRenderer, dfMath, dfHEngine,
  //box2d
  uMyWorld, UPhysics2D, UPhysics2DControllers, UPhysics2DTypes;

const
  C_STEP = 1 / 60;


var
  R: IdfRenderer;

  b2World: Tdfb2World;
  t: Double;
//  b2ContactListener: TdfContactListener;
  iPlayerContacts: Integer;
  b2Earth, b2Sprite: Tb2Body;

  Sprite, SpriteEarth: IdfSprite;
  MainNode, EarthNode: IdfNode;


  procedure InitPhysics();
  procedure InitSprite();
  procedure InitEarth();


  procedure DeInitSprite();
  procedure DeInitEarth();
  procedure DeInitPhysics();

  procedure SyncObjects(b2Body: Tb2Body; renderObject: IdfSprite);


implementation

{$REGION ' [ Init functions] '}
procedure InitPhysics();
  var
    g: TVector2;
  begin
    g.SetValue(0, 10);
    b2World := Tdfb2World.Create(g, True, 2 * C_STEP, C_STEP / 16, 2);
  end;

  procedure InitSprite();
  var
    BodyDef: Tb2BodyDef;
    ShapeDef: Tb2PolygonShape;
    FixtureDef: Tb2FixtureDef;
  begin
    Sprite := dfCreateHUDSprite();
    Sprite.Position := dfVec2f(300, 300);
    Sprite.PivotPoint := ppCenter;
    Sprite.Width := 98;
    Sprite.Height := 50;
    Sprite.Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
    Sprite.Material.Texture := dfCreateTexture();
    Sprite.Material.Texture.Load('data\tractor.bmp');

    MainNode := R.RootNode.AddNewChild();
    MainNode.Renderable := Sprite;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2PolygonShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_dynamicBody;
      position.SetValue(300, 300);
      angle := 0;
    end;

    with ShapeDef do
    begin
      SetAsBox(49, 25);
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 0.1;
      friction := 0.5;
      restitution := 0.1;
    end;

    b2Sprite := b2World.CreateBody(BodyDef);
    b2Sprite.CreateFixture(FixtureDef);
    b2Sprite.SetSleepingAllowed(False);
  end;

  procedure InitEarth();
    var
      BodyDef: Tb2BodyDef;
      ShapeDef: Tb2PolygonShape;
      FixtureDef: Tb2FixtureDef;
  begin
    SpriteEarth := dfCreateHUDSprite();
    SpriteEarth.Position := dfVec2f(300, 540);
    SpriteEarth.PivotPoint := ppCenter;
    SpriteEarth.Width := 400;
    SpriteEarth.Height := 20;
    SpriteEarth.Material.MaterialOptions.Diffuse := dfVec4f(0.3, 0.3, 0.3, 1);
    SpriteEarth.Rotation := 0.3 * rad2deg;

    EarthNode := R.RootNode.AddNewChild();
    EarthNode.Renderable := SpriteEarth;

    FixtureDef := Tb2FixtureDef.Create;
    ShapeDef := Tb2PolygonShape.Create;
    BodyDef := Tb2BodyDef.Create;

    with BodyDef do
    begin
      bodyType := b2_staticBody;
      position.SetValue(300, 540);
      angle := 0.3;
    end;

    with ShapeDef do
    begin
      SetAsBox(200, 10);
    end;

    with FixtureDef do
    begin
      shape := ShapeDef;
      density := 0.1;
      friction := 0.5;
      restitution := 0.0;
    end;

    b2Earth := b2World.CreateBody(BodyDef);
    b2Earth.CreateFixture(FixtureDef);
    b2Earth.SetSleepingAllowed(False);
  end;
{$ENDREGION}

{$REGION ' [ Deinit functions] '}

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

procedure SyncObjects(b2Body: Tb2Body; renderObject: IdfSprite);
begin
  renderObject.Position := dfVec2f(b2Body.GetPosition.x, b2Body.GetPosition.y);
  renderObject.Rotation := b2Body.GetAngle * rad2deg;
end;
end.
