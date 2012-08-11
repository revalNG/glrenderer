unit uUserRenderable;

interface

uses
  dfHRenderer,

  uRenderable;

type
  TdfUserRenderable = class(TdfRenderable, IdfUserRenderable)
  private
    FUserRender: TdfUserRenderableCallback;
  protected
    function GetUserCallback: TdfUserRenderableCallback;
    procedure SetUserCallback(urc: TdfUserRenderableCallback);
  public
    property OnRender: TdfUserRenderableCallback read GetUserCallback write SetUserCallback;

    procedure DoRender(); override;
  end;

implementation

uses
  Windows, uRenderer;

{ TdfUserRenderable }

procedure TdfUserRenderable.DoRender;
begin
  inherited;
  if Assigned(FUserRender) then
  begin
//    wglMakeCurrent(0, 0);
    FUserRender();
//    wglMakeCurrent(TheRenderer.DC, TheRenderer.RC);
  end;
end;

function TdfUserRenderable.GetUserCallback: TdfUserRenderableCallback;
begin
  Result := FUserRender;
end;

procedure TdfUserRenderable.SetUserCallback(urc: TdfUserRenderableCallback);
begin
  FUserRender := urc;
end;

end.
