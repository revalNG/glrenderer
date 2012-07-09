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
  {b2 ��������� ��������}
  TtzTractorParams = record
    {r - restitution, ������
     d - density, ���������
     f - friction, ������}
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
    //�������
    FGLBody, FGLWheelBig, FGLWheelSmall: IdfSprite;
    //���� �����
//    FNodeBody, FNodeWheelBig, FNodeWheelSmall: IdfNode;
    //���� box2d
    Fb2World: Tb2World;
    Fb2Body, Fb2WheelBig, Fb2WheelSmall, Fb2Susp1 {big}, Fb2Susp2 {small}: Tb2Body;
    //���������� box2d
    Fb2WheelJoint1, Fb2WheelJoint2: Tb2RevoluteJoint;
    Fb2SuspJoint1, Fb2SuspJoint2: Tb2PrismaticJoint;
    //��������� ���������
    Ftp: TtzTractorParams;

//    fsusp1, fsusp2: IdfSprite;

    b_A, b_D: Boolean; //��� ������� ������
  protected
    procedure SetMotorToJoint(aJoint: Tb2RevoluteJoint; aMotorEnable: Boolean; aSpeed, aMaxTorque: Double);
    procedure TractorHandling(const dt: Double);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure Init(b2World: Tdfb2World; RootNode: IdfNode; aParams: TtzTractorParams;
      BodyTexture, WheelBigTexture, WheelSmallTexture: String; aPos: TdfVec2f);

    procedure Restart(aPos: TdfVec2f);

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
  FGLBody := nil;
  FGLWheelBig := nil;
  FGLWheelSmall := nil;
//  FNodeBody := nil;
//  FNodeWheelBig := nil;
//  FNodeWheelSmall := nil;
  inherited;
end;

procedure TtzTractor.Init(b2World: Tdfb2World; RootNode: IdfNode;
  aParams: TtzTractorParams; BodyTexture, WheelBigTexture,
  WheelSmallTexture: String; aPos: TdfVec2f);
begin
  //OpenGL
  Fb2World := b2World;

  FGLBody := dfNewSpriteWithNode(RootNode);
  FGLWheelBig := dfNewSpriteWithNode(RootNode);
  FGLWheelSmall := dfNewSpriteWithNode(RootNode);

  dfLoadSprite(FGLBody, BodyTexture, aPos, 0);
  dfLoadSprite(FGLWheelBig, WheelBigTexture, aPos + aParams.WheelBigOffset, 0);
  dfLoadSprite(FGLWheelSmall, WheelSmallTexture, aPos + aParams.WheelSmallOffset, 0);

//  fsusp1 := dfNewSpriteWithNode(RootNode);
//  with fsusp1 do
//  begin
//    Width := 10;
//    Height := 10;
//    Position := FGLBody.Position + aParams.Susp1Offset;
//    PivotPoint := ppCenter;
//  end;
//
//  fsusp2 := dfNewSpriteWithNode(RootNode);
//  with fsusp2 do
//  begin
//    Width := 10;
//    Height := 10;
//    Position := FGLBody.Position + aParams.Susp2Offset;
//    PivotPoint := ppCenter;
//  end;



  Ftp := aParams;
  Restart(aPos);
end;

procedure TtzTractor.Restart(aPos: TdfVec2f);
var
  rev_def: Tb2RevoluteJointDef;
  pri_def: Tb2PrismaticJointDef;
  susp_axis: TVector2;
  mass: Tb2MassData;
begin
  if Assigned(Fb2Body) then
  begin
    Fb2World.DestroyJoint(Fb2SuspJoint1);
    Fb2World.DestroyJoint(Fb2SuspJoint2);
    Fb2World.DestroyJoint(Fb2WheelJoint1);
    Fb2World.DestroyJoint(Fb2WheelJoint2);
    Fb2World.DestroyBody(Fb2Body);
    Fb2World.DestroyBody(Fb2WheelBig);
    Fb2World.DestroyBody(Fb2WheelSmall);
    Fb2World.DestroyBody(Fb2Susp1);
    Fb2World.DestroyBody(Fb2Susp2);
  end;

  FGLBody.Position := aPos;
  FGLBody.Rotation := 0;
  FGLWheelBig.Position := aPos + Ftp.WheelBigOffset;
  FGLWheelSmall.Position := aPos + Ftp.WheelSmallOffset;

  //Box2d bodies
  Fb2Body := dfb2InitBox(Fb2World, FGLBody, Ftp.BodyD, Ftp.BodyF, Ftp.BodyR, $0002, $0004);
  Fb2Body.GetMassData(mass);
  Fb2Body.AngularDamping := 1;
  mass.center.SetValue(Ftp.MassCenterOffset.x * C_COEF, Ftp.MassCenterOffset.y * C_COEF);
//  mass.I := 15;
  Fb2Body.SetMassData(mass);

  Fb2WheelBig := dfb2InitCircle(Fb2World, FGLWheelBig, Ftp.WheelBigD, Ftp.WheelBigF, Ftp.WheelBigR, $0002, $0004);
  Fb2WheelBig.GetMassData(mass); mass.I := 0.1; Fb2WheelBig.SetMassData(mass);

  Fb2WheelSmall := dfb2InitCircle(Fb2World, FGLWheelSmall, Ftp.WheelSmallD, Ftp.WheelSmallF, Ftp.WheelSmallR, $0002, $0004);
//  Fb2WheelSmall.GetMassData(mass); mass.I := 0.5; Fb2WheelSmall.SetMassData(mass);

//  Fb2Susp1 := dfb2InitCircle(b2World, fsusp1, aParams.SuspD, aParams.SuspF, aParams.SuspR, $0002, $0004);
  Fb2Susp1 := dfb2InitCircle(Fb2World, 10, FGLBody.Position + Ftp.Susp1Offset, Ftp.SuspD, Ftp.SuspF, Ftp.SuspR, $0002, $0004);
//  Fb2Susp1.GetMassData(mass); mass.I := 5; Fb2Susp1.SetMassData(mass);

//  Fb2Susp2 := dfb2InitCircle(b2World, fsusp2, aParams.SuspD, aParams.SuspF, aParams.SuspR, $0002, $0004);
  Fb2Susp2 := dfb2InitCircle(Fb2World, 10, FGLBody.Position + Ftp.Susp2Offset, Ftp.SuspD, Ftp.SuspF, Ftp.SuspR, $0002, $0004);
//  Fb2Susp2.GetMassData(mass); mass.I := 5; Fb2Susp2.SetMassData(mass);


  //=====JOINTS=====

  //Box2d joints
  //Suspension prismatic joint 1
  susp_axis.SetValue(0, 1);
  pri_def := Tb2PrismaticJointDef.Create;
  pri_def.Initialize(Fb2Body, Fb2Susp1, Fb2Susp1.GetPosition, susp_axis);
  pri_def.enableLimit := True;
  pri_def.enableMotor := True;
  Fb2SuspJoint1 := Tb2PrismaticJoint(b2World.CreateJoint(pri_def));
  Fb2SuspJoint1.SetLimits(Ftp.Susp1Limits.x * C_COEF, Ftp.Susp1Limits.y * C_COEF);
  Fb2SuspJoint1.SetMotorSpeed(Ftp.Susp1MotorSpeed);
  Fb2SuspJoint1.SetMaxMotorForce(Ftp.Susp1MaxMotorForce);

  //Suspension prismatic joint 2
  susp_axis.SetValue(0, 1);
  pri_def := Tb2PrismaticJointDef.Create;
  pri_def.Initialize(Fb2Body, Fb2Susp2, Fb2Susp2.GetPosition, susp_axis);
  pri_def.enableLimit := True;
  pri_def.enableMotor := True;
  Fb2SuspJoint2 := Tb2PrismaticJoint(b2World.CreateJoint(pri_def));
  Fb2SuspJoint2.SetLimits(Ftp.Susp2Limits.x * C_COEF, Ftp.Susp2Limits.y * C_COEF);
  Fb2SuspJoint2.SetMotorSpeed(Ftp.Susp2MotorSpeed);
  Fb2SuspJoint2.SetMaxMotorForce(Ftp.Susp2MaxMotorForce);

  //Wheel revolution joint 1

  rev_def := Tb2RevoluteJointDef.Create;
  rev_def.Initialize(Fb2WheelBig, Fb2Susp1, Fb2WheelBig.GetPosition);
//  rev_def.enableLimit := False;
  Fb2WheelJoint1 := Tb2RevoluteJoint(b2World.CreateJoint(rev_def));

  rev_def := Tb2RevoluteJointDef.Create;
  rev_def.Initialize(Fb2WheelSmall, Fb2Susp2, Fb2WheelSmall.GetPosition);
//  rev_def.enableLimit := False;
  Fb2WheelJoint2 := Tb2RevoluteJoint(b2World.CreateJoint(rev_def));
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
  Fb2WheelSmall.AngularDamping := 0.1;
  Fb2WheelSmall.LinearDamping := 0.1;
  Fb2WheelBig.AngularDamping := 0.1;
  Fb2WheelBig.LinearDamping := 0.1;
  if dfInput.IsKeyDown(VK_UP) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, -5, 50);
  end
  else if dfInput.IsKeyDown(VK_DOWN) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, 5, 50);
  end
  else
  begin
    SetMotorToJoint(Fb2WheelJoint1, False, 0, 50);
  end;

  if dfInput.IsKeyDown(VK_SPACE) then
  begin
    SetMotorToJoint(Fb2WheelJoint1, True, 0, 0.1);
    SetMotorToJoint(Fb2WheelJoint2, True, 0, 0.1);
    Fb2WheelSmall.AngularDamping := 10;
    Fb2WheelBig.AngularDamping := 10;
    Fb2WheelSmall.LinearDamping := 10;
    Fb2WheelBig.LinearDamping := 10;
  end;
  if dfInput.IsKeyPressed(VK_LEFT, @b_A) {or dfInput.IsKeyPressed('�', @b_a)} then
  begin
    Fb2Body.ApplyTorque(-250);
  end
  else if dfInput.IsKeyPressed(VK_RIGHT, @b_D) {or dfInput.IsKeyPressed('�', @b_D)} then
  begin
    Fb2Body.ApplyTorque(250);
  end;
end;

procedure TtzTractor.Update(const dt: Double);
begin
  SyncObjects(Fb2Body, FGLBody);
  SyncObjects(Fb2WheelBig, FGLWheelBig);
  SyncObjects(Fb2WheelSmall, FGLWheelSmall);

//  SyncObjects(Fb2Susp1, fsusp1);
//  SyncObjects(Fb2Susp2, fsusp2);
  TractorHandling(dt);
end;

end.
