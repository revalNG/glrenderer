unit uTractor;

interface

uses
  Windows,

  dfHRenderer, dfMath, dfHInput,
  //current project
  uUtils,
  //box2d
  uMyWorld, UPhysics2D, UPhysics2DControllers, UPhysics2DTypes;

type
  {b2 Параметры трактора}
  TtzTractorParams = record
    {r - restitution, отскок
     d - density, плотность
     f - friction, трение}
    BodyR, BodyD, BodyF,
    WheelBigR, WheelBigD, WheelBigF,
    WheelSmallR, WheelSmallD, WheelSmallF,
    SuspR, SuspD, SuspF: Double;

    MassCenterOffset: TdfVec2f;

    WheelBigOffset, WheelSmallOffset: TdfVec2f;

    Susp1Offset, Susp2Offset: TdfVec2f;
    Susp1Limits, Susp2Limits: TdfVec2f;
    Susp1MotorSpeed, Susp2MotorSpeed,
    Susp1MaxMotorForce, Susp2MaxMotorForce: Double;
  end;

  TtzTractor = class
  private
    //Спрайты
    FGLBody, FGLWheelBig, FGLWheelSmall: IdfSprite;
    //Ноды сцены
    FNodeBody, FNodeWheelBig, FNodeWheelSmall: IdfNode;
    //Тела box2d
    Fb2Body, Fb2WheelBig, Fb2WheelSmall, Fb2Susp1 {big}, Fb2Susp2 {small}: Tb2Body;
    //Сочленения box2d
    Fb2WheelJoint1, Fb2WheelJoint2: Tb2RevoluteJoint;
    Fb2SuspJoint1, Fb2SuspJoint2: Tb2PrismaticJoint;
  protected
    procedure SetMotorToJoint(aJoint: Tb2RevoluteJoint; aMotorEnable: Boolean; aSpeed, aMaxTorque: Double);
    procedure TractorHandling(const dt: Double);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure Init(b2World: Tdfb2World; RootNode: IdfNode; aParams: TtzTractorParams;
      BodyTexture, WheelBigTexture, WheelSmallTexture: String; aPos: TdfVec2f);

    procedure Update(const dt: Double);
  end;

implementation

uses
  uMainFunctions;

{ TtzTractor }

constructor TtzTractor.Create;
begin
  inherited Create();
end;

destructor TtzTractor.Destroy;
begin

  inherited;
end;

procedure TtzTractor.Init(b2World: Tdfb2World; RootNode: IdfNode;
  aParams: TtzTractorParams; BodyTexture, WheelBigTexture,
  WheelSmallTexture: String; aPos: TdfVec2f);
var
  rev_def: Tb2RevoluteJointDef;
  pri_def: Tb2PrismaticJointDef;
  susp_axis: TVector2;
begin
  //OpenGL
  FGLBody := dfNewSpriteWithNode(RootNode);
  FGLWheelBig := dfNewSpriteWithNode(RootNode);
  FGLWheelSmall := dfNewSpriteWithNode(RootNode);

  dfLoadSprite(FGLBody, BodyTexture, aPos, 0);
  dfLoadSprite(FGLWheelBig, WheelBigTexture, aPos + aParams.WheelBigOffset, 0);
  dfLoadSprite(FGLWheelSmall, WheelSmallTexture, aPos + aParams.WheelSmallOffset, 0);

  //Box2d bodies
  Fb2Body := dfb2InitBox(b2World, FGLBody, aParams.BodyD, aParams.BodyF, aParams.BodyR, 0, 0, $0001, $0004);
  Fb2WheelBig := dfb2InitCircle(b2World, FGLWheelBig, aParams.WheelBigD, aParams.WheelBigF, aParams.WheelBigR, 0, 0, $0001, $0004);
  Fb2WheelSmall := dfb2InitCircle(b2World, FGLWheelSmall, aParams.WheelSmallD, aParams.WheelSmallF, aParams.WheelSmallR, 0, 0, $0001, $0004);
  Fb2Susp1 := dfb2InitCircle(b2World, 2, FGLBody.Position + aParams.Susp1Offset, aParams.SuspD, aParams.SuspF, aParams.SuspR, 0, 0, $0001, $0004);
  Fb2Susp2 := dfb2InitCircle(b2World, 2, FGLBody.Position + aParams.Susp2Offset, aParams.SuspD, aParams.SuspF, aParams.SuspR, 0, 0, $0001, $0004);

  //=====JOINTS=====

  //Box2d joints
  susp_axis.SetValue(0, 1);

  //Suspension prismatic joint 1
  pri_def := Tb2PrismaticJointDef.Create;
  pri_def.Initialize(Fb2Body, Fb2Susp1, Fb2Susp1.GetPosition, susp_axis);
  pri_def.enableLimit := True;
  pri_def.enableMotor := True;
  Fb2SuspJoint1 := Tb2PrismaticJoint(b2World.CreateJoint(pri_def));
  Fb2SuspJoint1.SetLimits(aParams.Susp1Limits.x * C_COEF, aParams.Susp1Limits.y * C_COEF);
  Fb2SuspJoint1.SetMotorSpeed(aParams.Susp1MotorSpeed);
  Fb2SuspJoint1.SetMaxMotorForce(aParams.Susp1MaxMotorForce);

  //Suspension prismatic joint 2
  pri_def := Tb2PrismaticJointDef.Create;
  pri_def.Initialize(Fb2Body, Fb2Susp2, Fb2Susp2.GetPosition, susp_axis);
  pri_def.enableLimit := True;
  pri_def.enableMotor := True;
  Fb2SuspJoint2 := Tb2PrismaticJoint(b2World.CreateJoint(pri_def));
  Fb2SuspJoint2.SetLimits(aParams.Susp2Limits.x * C_COEF, aParams.Susp2Limits.y * C_COEF);
  Fb2SuspJoint2.SetMotorSpeed(aParams.Susp2MotorSpeed);
  Fb2SuspJoint2.SetMaxMotorForce(aParams.Susp2MaxMotorForce);

  //Wheel revolution joint 1

  rev_def := Tb2RevoluteJointDef.Create;
  rev_def.Initialize(Fb2WheelBig, Fb2Susp1, Fb2WheelBig.GetPosition);
  rev_def.enableLimit := False;
  Fb2WheelJoint1 := Tb2RevoluteJoint(b2World.CreateJoint(rev_def));
end;

procedure TtzTractor.SetMotorToJoint(aJoint: Tb2RevoluteJoint; aMotorEnable: Boolean; aSpeed,
  aMaxTorque: Double);
begin
  aJoint.EnableMotor(aMotorEnable);
  aJoint.SetMotorSpeed(aSpeed);
  aJoint.SetMaxMotorTorque(aMaxTorque);
end;

procedure TtzTractor.TractorHandling(const dt: Double);
begin
  if dfInput.IsKeyDown(VK_RIGHT) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, -5, 200);
  end
  else if dfInput.IsKeyDown(VK_LEFT) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, 5, 200);
  end
  else if dfInput.IsKeyDown(VK_DOWN) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, 0, 0.01);
    SetMotorToJoint(Fb2WheelJoint2, True, 0, 0.01);
  end
  else
  begin
    SetMotorToJoint(Fb2WheelJoint1, False, 0, 200);
  end;
end;

procedure TtzTractor.Update(const dt: Double);
begin
  SyncObjects(Fb2Body, FGLBody);
  SyncObjects(Fb2WheelBig, FGLWheelBig);
  SyncObjects(Fb2WheelSmall, FGLWheelSmall);
  TractorHandling(dt);
end;

end.
