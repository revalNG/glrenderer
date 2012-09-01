{
  TODO: CheckHit для повернутого изображения
  TODO: CheckHit для альфа-изображений
}

unit uGUIElement;

interface

uses
  dfHEngine,
  uRenderable,
  //debug
  uSprite,
  dfHRenderer;

type
  TdfGUIElement = class(TdfHUDSprite, IdfGUIElement)
  private
  protected
    //Относительная позиция мыши по отношению к элементу
    FMousePos: TdfMousePos;
    FHitMode: TdfGUIHitMode;
    FOnClick, FOnOver, FOnOut, FOnDown, FOnUp: TdfMouseEvent;
    FOnWheel: TdfWheelEvent;
    FZIndex: Integer;

    procedure CalcHitZone(); virtual;

    function GetHitMode(): TdfGUIHitMode; virtual;
    procedure SetHitMode(aMode: TdfGUIHitMode); virtual;

    function GetOnClick(): TdfMouseEvent; virtual;
    function GetOnOver(): TdfMouseEvent; virtual;
    function GetOnOut(): TdfMouseEvent; virtual;
    function GetOnDown(): TdfMouseEvent; virtual;
    function GetOnUp(): TdfMouseEvent; virtual;
    function GetOnWheel(): TdfWheelEvent; virtual;

    procedure SetOnClick(aProc: TdfMouseEvent); virtual;
    procedure SetOnOver(aProc: TdfMouseEvent); virtual;
    procedure SetOnOut(aProc: TdfMouseEvent); virtual;
    procedure SetOnDown(aProc: TdfMouseEvent); virtual;
    procedure SetOnUp(aProc: TdfMouseEvent); virtual;
    procedure SetOnWheel(aProc: TdfWheelEvent); virtual;

    function GetZIndex(): Integer;
    procedure SetZIndex(aIndex: Integer);

    function GetMousePos(): TdfMousePos;
  public
    //Для внутреннего использования. Либо для принудительного вызова события
    procedure _MouseMove (X, Y: Integer; Shift: TdfMouseShiftState); virtual;
    procedure _MouseOver (X, Y: Integer; Shift: TdfMouseShiftState); virtual;
    procedure _MouseOut (X, Y: Integer; Shift: TdfMouseShiftState); virtual;
    procedure _MouseDown (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState); virtual;
    procedure _MouseUp   (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState); virtual;
    procedure _MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer); virtual;
    procedure _MouseClick(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState); virtual;

    //Режим проверки попадания по элементу.
    property HitMode: TdfGUIHitMode read GetHitMode write SetHitMode;
    //Проверка на попадание по элементу
    function CheckHit(X, Y: Integer): Boolean;
    //Коллбэки для пользователя
    property OnMouseClick: TdfMouseEvent read GetOnClick write SetOnClick;
    property OnMouseOver: TdfMouseEvent read GetOnOver write SetOnOver;
    property OnMouseOut: TdfMouseEvent read GetOnOut write SetOnOut;
    property OnMouseDown: TdfMouseEvent read GetOnDown write SetOnDown;
    property OnMouseUp: TdfMouseEvent read GetOnUp write SetOnUp;
    property OnMouseWheel: TdfWheelEvent read GetOnWheel write SetOnWheel;

    property MousePos: TdfMousePos read GetMousePos;

    //Порядок сортировки при обработке ввода.
    // При конфликте двух GUI-элементов обработка
    // перейдет к тому, чей ZIndex МЕНЬШЕ
    property ZIndex: Integer read GetZIndex write SetZIndex;
  end;


implementation

type
  TdfBB = record
    Left, Right, Top, Bottom: Single;
  end;

procedure TdfGUIElement.CalcHitZone();
begin
//  if Assigned(FTexNormal) then
//  begin
//
//  end;
end;

function TdfGUIElement.CheckHit(X, Y: Integer): Boolean;

  function GetBB(): TdfBB;
  var
    i: Integer;
  begin
    Result.Left := 1/0;
    for i := 0 to 3 do
      if (FCoords[i].x + FPos.x) < Result.Left then
        Result.Left := FPos.x + FCoords[i].x;
    Result.Right := - 1/0;
    for i := 0 to 3 do
      if (FCoords[i].x + FPos.x) > Result.Right then
        Result.Right := FPos.x + FCoords[i].x;
    Result.Top :=  1/0;
    for i := 0 to 3 do
      if (FCoords[i].y + FPos.y) < Result.Top then
        Result.Top := FPos.y + FCoords[i].y;
    Result.Bottom := - 1/0;
    for i := 0 to 3 do
      if (FCoords[i].y + FPos.y) > Result.Bottom then
        Result.Bottom := FPos.y + FCoords[i].y;
  end;

  //Предпроверка для всех типов по баундинг боксу
  //для hmBox при нулевом уле поворота соответствует полной
  //проверке
  function CheckBB(X, Y: Integer): Boolean;
  var
    bb: TdfBB;
  begin
    bb := GetBB();
    Result := ( (X > bb.Left) and (X < bb.Right) )
           and( (Y > bb.Top) and (Y < bb.Bottom) );
  end;

  function CheckWithAlpha(): Boolean;
  begin
    Result := True;
  end;

begin
  // + debug
  Exit(CheckBB(X, Y));
  // - debug
  case HitMode of
    hmBox:
      if Abs(FRot) < cEPS then
        Result := CheckBB(X, Y);
    hmAlpha0: ;
    hmAlpha50: ;
  end;
end;

function TdfGUIElement.GetHitMode: TdfGUIHitMode;
begin
  Result := FHitMode;
end;

function TdfGUIElement.GetMousePos: TdfMousePos;
begin
  Result := FMousePos;
end;

function TdfGUIElement.GetOnClick: TdfMouseEvent;
begin
  Result := FOnClick;
end;

function TdfGUIElement.GetOnDown: TdfMouseEvent;
begin
  Result := FOnDown;
end;

function TdfGUIElement.GetOnOut: TdfMouseEvent;
begin
  Result := FOnOut;
end;

function TdfGUIElement.GetOnOver: TdfMouseEvent;
begin
  Result := FOnOver;
end;

function TdfGUIElement.GetOnUp: TdfMouseEvent;
begin
  Result := FOnUp;
end;

function TdfGUIElement.GetOnWheel: TdfWheelEvent;
begin
  Result := FOnWheel;
end;

function TdfGUIElement.GetZIndex: Integer;
begin
  Result := FZIndex;
end;

procedure TdfGUIElement.SetHitMode(aMode: TdfGUIHitMode);
begin
  FHitMode := aMode;
  if FHitMode in [hmAlpha0, hmAlpha50] then
    CalcHitZone();
end;

procedure TdfGUIElement.SetOnClick(aProc: TdfMouseEvent);
begin
  FOnClick := aProc;
end;

procedure TdfGUIElement.SetOnDown(aProc: TdfMouseEvent);
begin
  FOnDown := aProc;
end;

procedure TdfGUIElement.SetOnOut(aProc: TdfMouseEvent);
begin
  FOnOut := aProc;
end;

procedure TdfGUIElement.SetOnOver(aProc: TdfMouseEvent);
begin
  FOnOver := aProc;
end;

procedure TdfGUIElement.SetOnUp(aProc: TdfMouseEvent);
begin
  FOnUp := aProc;
end;

procedure TdfGUIElement.SetOnWheel(aProc: TdfWheelEvent);
begin
  FOnWheel := aProc;
end;

procedure TdfGUIElement.SetZIndex(aIndex: Integer);
begin
  FZIndex := aIndex;
end;

procedure TdfGUIElement._MouseClick(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
begin
  if Assigned(FOnClick) then
    FOnClick(Self, X, Y, MouseButton, Shift);
end;

procedure TdfGUIElement._MouseDown(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
begin
  if Assigned(FOnDown) then
    FOnDown(Self, X, Y, MouseButton, Shift);
end;

procedure TdfGUIElement._MouseMove(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  if (FMousePos = mpOver) and (not CheckHit(X, Y)) then
    FMousePos := mpOut;

end;

procedure TdfGUIElement._MouseOut(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  FMousePos := mpOut;
  if Assigned(FOnOut) then
    FOnOut(Self, X, Y, mbNone, Shift);
end;

procedure TdfGUIElement._MouseOver(X, Y: Integer; Shift: TdfMouseShiftState);
begin
  FMousePos := mpOver;
  if Assigned(FOnOver) then
    FOnOver(Self, X, Y, mbNone, Shift);
end;

procedure TdfGUIElement._MouseUp(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
begin
  if Assigned(FOnUp) then
    FOnUp(Self, X, Y, MouseButton, Shift);
end;

procedure TdfGUIElement._MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState;
  WheelDelta: Integer);
begin
  if Assigned(FOnWheel) then
    FOnWheel(Self, X, Y, Shift, WheelDelta);
end;

end.
