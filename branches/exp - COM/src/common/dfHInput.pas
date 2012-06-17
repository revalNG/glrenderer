{
  DiF Engine

  Спецификация 1.0

  dfHInput.pas

  Заголовочный файл (хидер) обработки с устройств ввода

  Copyright (c) 2009-2009 Daemon
  DiF Engine Team  
}
unit dfHInput;

interface

uses
  Windows,
  dfHEngine;

type
  TdfInput = record
  private
    vLastWheelDelta : TdfInteger;
  public
    function IsKeyDown(const vk: TdfInteger): Boolean; overload;
    function IsKeyDown(const c: Char): Boolean; overload;

    function IsKeyPressed(aCode: Integer; aPressed: PBoolean): Boolean; overload;
    function IsKeyPressed(aChar: Char; aPressed: PBoolean): Boolean; overload;

    procedure KeyboardNotifyWheelMoved(wheelDelta : Integer);
  end;

const
   VK_MOUSEWHEELUP   = VK_F23;
   VK_MOUSEWHEELDOWN = VK_F24;

var
  dfInput: TdfInput;

implementation

function TdfInput.IsKeyDown(const vk: TdfInteger): Boolean;
begin
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

function TdfInput.IsKeyDown(const c: Char): Boolean;
var
   vk: TdfInteger;
begin
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

function TdfInput.IsKeyPressed(aCode: Integer; aPressed: PBoolean): Boolean;
begin
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
