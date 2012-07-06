unit uMyWorld;

interface

uses
  UPhysics2D, UPhysics2DTypes;

type
  Tdfb2SimulationEvent = procedure (const FixedDeltaTime: Double);

  Tdfb2World = class(Tb2World)
  private
    FBefore, FAfter: Tdfb2SimulationEvent;
    FStep, FStepEvery, Ft: Single;
    FIter: Integer;
  public
    constructor Create(const gravity: TVector2; doSleep: Boolean;
      aStepDelta, aStepEvery: Single; aIterations: Integer); reintroduce;

    procedure Update(const DeltaTime: Double);

    property OnAfterSimulation: Tdfb2SimulationEvent read FAfter write FAfter;
    property OnBeforeSimulation: Tdfb2SimulationEvent read FBefore write FBefore;
  end;

implementation

{ Tdfb2World }

constructor Tdfb2World.Create(const gravity: TVector2; doSleep: Boolean;
  aStepDelta, aStepEvery: Single; aIterations: Integer);
begin
  inherited Create(gravity, doSleep);
  FStep := aStepDelta;
  FStepEvery := aStepEvery;
  FIter := aIterations;
end;

procedure Tdfb2World.Update(const DeltaTime: Double);
begin
  Ft := Ft + deltaTime;
  if Ft >= FStepEvery then
  begin
    Ft := 0;
    if Assigned(FBefore) then
      FBefore(FStep);

    Step(FStep, FIter, FIter, False);

    if Assigned(FAfter) then
      FAfter(FStep);
  end;
end;

end.
