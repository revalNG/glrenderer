{
  TODO: рефакотринг - убрать закомментированные строки - функционал ушел в TdfGUIElement
}

unit uGUIButton;

interface

uses
  dfHRenderer,
  uGUIElement;

type
  TdfGUIButton = class(TdfGUIElement, IdfGUIButton)
  private
  protected

    FTexNormal, FTexOver, FTexClick: IdfTexture;

    FTextureAutoChange: Boolean;

    procedure CalcHitZone(); override;

    function GetTextureNormal(): IdfTexture;
    function GetTextureOver(): IdfTexture;
    function GetTextureClick(): IdfTexture;

    procedure SetTextureNormal(aTexture: idfTexture);
    procedure SetTextureOver(aTexture: idfTexture);
    procedure SetTextureClick(aTexture: idfTexture);

    function GetAutoChange: Boolean;
    procedure SetAutoChange(aChange: Boolean);
  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure _MouseMove (X, Y: Integer; Shift: TdfMouseShiftState); override;
    procedure _MouseDown (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState); override;
    procedure _MouseUp   (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState); override;
    procedure _MouseOver (X, Y: Integer; Shift: TdfMouseShiftState); override;
    procedure _MouseOut (X, Y: Integer; Shift: TdfMouseShiftState); override;

    property TextureNormal: IdfTexture read GetTextureNormal write SetTextureNormal;
    property TextureOver: IdfTexture read GetTextureOver write SetTextureOver;
    property TextureClick: IdfTexture read GetTextureClick write SetTextureClick;

    //Текстуры будут меняться автоматически при наведении, клие и уходе мыши
    property TextureAutoChange: Boolean read GetAutoChange write SetAutoChange;
  end;

implementation

{ TdfGUIButton }

procedure TdfGUIButton.CalcHitZone;
begin
  if Assigned(FTexNormal) then
  begin

  end;
end;

constructor TdfGUIButton.Create;
begin
  inherited;
  FTexNormal := nil;
  FTexOver := nil;
  FTexClick := nil;

  FOnClick := nil;
  FOnOver := nil;
  FOnOut := nil;

  FTextureAutoChange := True;
  FHitMode := hmBox;
end;

destructor TdfGUIButton.Destroy;
begin
  FTexNormal := nil;
  FTexOver := nil;
  FTexClick := nil;
  inherited;
end;

function TdfGUIButton.GetAutoChange: Boolean;
begin
  Result := FTextureAutoChange;
end;

function TdfGUIButton.GetTextureClick: IdfTexture;
begin
  Result := FTexClick;
end;

function TdfGUIButton.GetTextureNormal: IdfTexture;
begin
  Result := FTexNormal;
end;

function TdfGUIButton.GetTextureOver: IdfTexture;
begin
  Result := FTexOver;
end;

procedure TdfGUIButton.SetAutoChange(aChange: Boolean);
begin
  FTextureAutoChange := aChange;
end;

procedure TdfGUIButton.SetTextureClick(aTexture: idfTexture);
begin
  FTexClick := aTexture;
end;

procedure TdfGUIButton.SetTextureNormal(aTexture: idfTexture);
begin
  FTexNormal := aTexture;

  if FHitMode in [hmAlpha0, hmAlpha50] then
    CalcHitZone();

  Material.Texture := FTexNormal;
end;

procedure TdfGUIButton.SetTextureOver(aTexture: idfTexture);
begin
  FTexOver := aTexture;
end;

procedure TdfGUIButton._MouseDown(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
begin
  inherited;
  if FTextureAutoChange and Assigned(FTexClick) then
    Material.Texture := FTexClick;
end;

procedure TdfGUIButton._MouseMove(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  inherited;
  if FTextureAutoChange and Assigned(FTexOver) and not (ssLeft in Shift) then
    FMaterial.Texture := FTexOver;
end;

procedure TdfGUIButton._MouseOut(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  inherited;
  if FTextureAutoChange and Assigned(FTexNormal) then
    FMaterial.Texture := FTexNormal;
end;

procedure TdfGUIButton._MouseOver(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  inherited;
  if FTextureAutoChange and Assigned(FTexOver) then
    FMaterial.Texture := FTexOver;
end;

procedure TdfGUIButton._MouseUp(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
begin
  inherited;
  if FTextureAutoChange and Assigned(FTexNormal) then
    Material.Texture := FTexOver;
end;

end.
