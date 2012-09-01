unit uInput;

interface

uses
  Windows,
  dfHRenderer;

type
  TdfInput = class(TInterfacedObject, IdfInput)
  private
    FAllow: Boolean;
    vLastWheelDelta : Integer;
    function GetAllow(): Boolean;
    procedure SetAllow(aAllow: Boolean);
  protected
  public
    constructor Create(); virtual;

    function IsKeyDown(const vk: Integer): Boolean; overload;
    function IsKeyDown(const c: Char): Boolean; overload;

    function IsKeyPressed(aCode: Integer; aPressed: PBoolean): Boolean; overload;
    function IsKeyPressed(aChar: Char; aPressed: PBoolean): Boolean; overload;

    procedure KeyboardNotifyWheelMoved(wheelDelta : Integer);
    //–азрешить захват клавиш.
    //јвтоматически мен€етс€ в зависимости от того, активно окно или нет
    property AllowKeyCapture: Boolean read GetAllow write SetAllow;
  end;

const
   VK_MOUSEWHEELUP   = VK_F23;
   VK_MOUSEWHEELDOWN = VK_F24;

implementation

function TdfInput.IsKeyDown(const vk: Integer): Boolean;
begin
  if not FAllow then
    Exit(False);

   case vk of
      VK_MOUSEWHEELUP :
      begin
        Result := (vLastWheelDelta > 0);
        if Result then
          vLastWheelDelta := 0;
      end;
      VK_MOUSEWHEELDOWN :
      begin
        Result := (vLastWheelDelta < 0);
        if Result then
          vLastWheelDelta := 0;
      end;
   else
      Result := (GetAsyncKeyState(vk) < 0);
   end;
end;

constructor TdfInput.Create;
begin
  inherited;
  FAllow := True;
end;

function TdfInput.GetAllow: Boolean;
begin
  Result := FAllow;
end;

function TdfInput.IsKeyDown(const c: Char): Boolean;
var
   vk: Integer;
begin
  if not FAllow then
    Exit(False);

   vk := VkKeyScan(c) and $FF;
   if vk <> $FF then
     Result := (GetAsyncKeyState(vk) < 0)
   else
     Result := False;
end;

procedure TdfInput.KeyboardNotifyWheelMoved(wheelDelta : Integer);
begin
   vLastWheelDelta := wheelDelta;
end;

procedure TdfInput.SetAllow(aAllow: Boolean);
begin
  FAllow := aAllow;
end;

function TdfInput.IsKeyPressed(aCode: Integer; aPressed: PBoolean): Boolean;
begin
  if not FAllow then
    Exit(False);

  Result := False;

  if (not aPressed^) and (GetAsyncKeyState(aCode) < 0) then
  begin
    Result := True;
    aPressed^ := True;
  end;

  if (GetAsyncKeyState(aCode) >= 0) then
    aPressed^ := False;
end;


function TdfInput.IsKeyPressed(aChar: Char; aPressed: PBoolean): Boolean;
var
  aCode: Integer;
begin
  if not FAllow then
    Exit(False);

  Result := False;

  aCode := VkKeyScan(aChar) and $FF;
  if aCode <> $FF then
  begin
    if (not aPressed^) and (GetAsyncKeyState(aCode) < 0) then
    begin
      Result := True;
      aPressed^ := True;
    end;

    if (GetAsyncKeyState(aCode) >= 0) then
      aPressed^ := False;
  end
  else
    Result := False;
end;

end.
