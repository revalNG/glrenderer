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
    procedure DoRender; virtual;

    property Material: IdfMaterial read GetMaterial write SetMaterial;
  end;

implementation

{ TdfRenderable }

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
