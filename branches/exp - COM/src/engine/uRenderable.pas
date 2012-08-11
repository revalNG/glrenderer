unit uRenderable;

interface

uses
  uMaterial,
  dfHRenderer, dfMath;

type
  TdfRenderable = class(TInterfacedObject, IdfRenderable)
  private
    FMaterial: IdfMaterial;
  protected
    function GetMaterial(): IdfMaterial;
    procedure SetMaterial(const aMat: IdfMaterial);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure DoRender; virtual;

    property Material: IdfMaterial read GetMaterial write SetMaterial;
  end;

  Tdf2DRenderable = class(TdfRenderable, Idf2DRenderable)
  private
  protected
    FWidth, FHeight: Single;
    FPos, FScale: TdfVec2f;
    FRot: Single;
    FPivot: Tdf2DPivotPoint;
    FCoords: array[0..3] of TdfVec2f;
    procedure RecalcCoords(); virtual;

    function GetWidth(): Single; virtual;
    procedure SetWidth(const aWidth: Single); virtual;
    function GetHeight(): Single; virtual;
    procedure SetHeight(const aHeight: Single); virtual;
    function GetPos(): TdfVec2f; virtual;
    procedure SetPos(const aPos: TdfVec2f); virtual;
    function GetScale(): TdfVec2f; virtual;
    procedure SetScale(const aScale: TdfVec2f); virtual;
    function GetRot(): Single; virtual;
    procedure SetRot(const aRot: Single); virtual;
    function GetPivot(): Tdf2DPivotPoint; virtual;
    procedure SetPivot(const aPivot: Tdf2DPivotPoint); virtual;
  public
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    property Position: TdfVec2f read GetPos write SetPos;
    property Scale: TdfVec2f read GetScale write SetScale;
    procedure ScaleMult(const aScale: TdfVec2f); virtual;
    property Rotation: Single read GetRot write SetRot;
    property PivotPoint: Tdf2DPivotPoint read GetPivot write SetPivot;
  end;

implementation

{ TdfRenderable }

uses
  Windows, uRenderer,
  {debug}
  ExportFunc;

constructor TdfRenderable.Create;
begin
  inherited;
  {debug}
  FMaterial := CreateMaterial();
end;

destructor TdfRenderable.Destroy;
begin
  FMaterial := nil;
  inherited;
end;

procedure TdfRenderable.DoRender;
begin
//  wglMakeCurrent(TheRenderer.DC, TheRenderer.RC);
  //*
end;

function TdfRenderable.GetMaterial: IdfMaterial;
begin
  Result := FMaterial;
end;

procedure TdfRenderable.SetMaterial(const aMat: IdfMaterial);
begin
  FMaterial := aMat;
end;

{ Tdf2DRenderable }

function Tdf2DRenderable.GetHeight: Single;
begin
  Result := FHeight;
end;

function Tdf2DRenderable.GetPivot: Tdf2DPivotPoint;
begin
  Result := FPivot;
end;

function Tdf2DRenderable.GetPos: TdfVec2f;
begin
  Result := FPos;
end;

function Tdf2DRenderable.GetRot: Single;
begin
  Result := FRot;
end;

function Tdf2DRenderable.GetScale: TdfVec2f;
begin
  Result := FScale;
end;

function Tdf2DRenderable.GetWidth: Single;
begin
  Result := FWidth;
end;

{TODO: улучшить быстродействие, не считать уже посчитанное}
procedure Tdf2DRenderable.RecalcCoords;
begin
  case FPivot of
    ppTopLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
      FCoords[1] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[2] := dfVec2f(0, 0);
      FCoords[3] := dfVec2f(0, FHeight * FScale.y);
    end;
    ppTopRight:
    begin
      FCoords[0] := dfVec2f(0, FHeight * FScale.y);
      FCoords[1] := dfVec2f(0, 0);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, 0);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y);
    end;
    ppBottomLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(0, 0);
    end;
    ppBottomRight:
    begin
      FCoords[0] := dfVec2f(0, 0);
      FCoords[1] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, 0);
    end;
    ppCenter:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y) * 0.5;
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y) * 0.5;
    end;
  end;
end;

procedure Tdf2DRenderable.ScaleMult(const aScale: TdfVec2f);
begin
  FScale := FScale * aScale;
  RecalcCoords();
end;

procedure Tdf2DRenderable.SetHeight(const aHeight: Single);
begin
  FHeight := aHeight;
  RecalcCoords();
end;

procedure Tdf2DRenderable.SetPivot(const aPivot: Tdf2DPivotPoint);
begin
  if FPivot <> aPivot then
  begin
    FPivot := aPivot;
    RecalcCoords;
  end;
end;

procedure Tdf2DRenderable.SetPos(const aPos: TdfVec2f);
begin
  FPos := aPos;
  RecalcCoords();
end;

procedure Tdf2DRenderable.SetRot(const aRot: Single);
begin
  FRot := aRot;
  RecalcCoords();
end;

procedure Tdf2DRenderable.SetScale(const aScale: TdfVec2f);
begin
  FScale := aScale;
  RecalcCoords();
end;

procedure Tdf2DRenderable.SetWidth(const aWidth: Single);
begin
  FWidth := aWidth;
  RecalcCoords();
end;

end.
