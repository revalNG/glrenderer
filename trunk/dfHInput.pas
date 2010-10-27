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

end.
