unit uGUIButton;

interface

uses
  dfHRenderer,
  uGUIElement;

type
  TdfGUIButton = class(TdfGUIElement, IdfGUIButton)
  private
  protected
    FOnClick, FOnOver, FOnOut: TdfButtonEvent;

    FTexNormal, FTexOver, FTexClick: IdfTexture;

    FHitMode: TdfButtonHitMode;
    FTextureAutoChange: Boolean;

    procedure CalcHitZone();

    function GetOnClick(): TdfButtonEvent;
    function GetOnOver(): TdfButtonEvent;
    function GetOnOut(): TdfButtonEvent;

    procedure SetOnClick(aProc: TdfButtonEvent);
    procedure SetOnOver(aProc: TdfButtonEvent);
    procedure SetOnOut(aProc: TdfButtonEvent);

    function GetTextureNormal(): IdfTexture;
    function GetTextureOver(): IdfTexture;
    function GetTextureClick(): IdfTexture;

    procedure SetTextureNormal(aTexture: idfTexture);
    procedure SetTextureOver(aTexture: idfTexture);
    procedure SetTextureClick(aTexture: idfTexture);

    function GetAutoChange: Boolean;
    procedure SetAutoChange(aChange: Boolean);

    function GetHitMode(): TdfButtonHitMode;
    procedure SetHitMode(aMode: TdfButtonHitMode);
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    property OnMouseClick: TdfButtonEvent read GetOnClick write SetOnClick;
    property OnMouseOver: TdfButtonEvent read GetOnOver write SetOnOver;
    property OnMouseOut: TdfButtonEvent read GetOnOut write SetOnOut;

    property TextureNormal: IdfTexture read GetTextureNormal write SetTextureNormal;
    property TextureOver: IdfTexture read GetTextureOver write SetTextureOver;
    property TextureClick: IdfTexture read GetTextureClick write SetTextureClick;

    //Текстуры будут меняться автоматически при наведении, клие и уходе мыши
    property TextureAutoChange: Boolean read GetAutoChange write SetAutoChange;
    //Режим проверки попадания по кнопке. Проверка только по TextureNormal
    property HitMode: TdfButtonHitMode read GetHitMode write SetHitMode;
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

function TdfGUIButton.GetHitMode: TdfButtonHitMode;
begin
  Result := FHitMode;
end;

function TdfGUIButton.GetOnClick: TdfButtonEvent;
begin
  Result := FOnClick;
end;

function TdfGUIButton.GetOnOut: TdfButtonEvent;
begin
  Result := FOnOut;
end;

function TdfGUIButton.GetOnOver: TdfButtonEvent;
begin
  Result := FOnOver;
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

procedure TdfGUIButton.SetHitMode(aMode: TdfButtonHitMode);
begin
  FHitMode := aMode;
  if FHitMode in [hmAlpha0, hmAlpha50] then
    CalcHitZone();
end;

procedure TdfGUIButton.SetOnClick(aProc: TdfButtonEvent);
begin
  FOnClick := aProc;
end;

procedure TdfGUIButton.SetOnOut(aProc: TdfButtonEvent);
begin
  FOnOut := aProc;
end;

procedure TdfGUIButton.SetOnOver(aProc: TdfButtonEvent);
begin
  FOnOver := aProc;
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
end;

procedure TdfGUIButton.SetTextureOver(aTexture: idfTexture);
begin
  FTexOver := aTexture;
end;

end.
