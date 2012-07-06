unit uRenderable;

interface

uses
  uMaterial,
  dfHRenderer;

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

implementation

{ TdfRenderable }

uses
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

end.
