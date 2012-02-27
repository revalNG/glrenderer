unit uRenderable;

interface

uses
  dfHRenderer;

type
  TdfRenderable = class(TInterfacedObject, IdfRenderable)
  private
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

end;

procedure TdfRenderable.SetMaterial(const aMat: IdfMaterial);
begin

end;

end.
