unit uGUITextBox;

interface

uses
  glr, glrMath, uGUIElement;

type
  TglrGUITextBox = class (TglrGUIElement, IglrGUITextBox)
  protected
    FTextObj: IglrText;
    FCursor: IglrSprite;

    FTextOffset, FCursorOffset: TdfVec2f;

    FMaxTextLength: Integer;

    function GetTextObject(): IglrText;
    procedure SetTextObject(const aTextObject: IglrText);
    function GetMaxTextLength(): Integer;
    procedure SetMaxTextLength(aLength: Integer);
    function GetTextOffset(): TdfVec2f;
    procedure SetTextOffset(aOffset: TdfVec2f);
    function GetCurOffset(): TdfVec2f;
    procedure SetCurOffset(aOffset: TdfVec2f);
    function GetCursor: IglrSprite;
    procedure SetCursor(const aCursor: IglrSprite);
    procedure SetPos(const aPos: TdfVec3f); override;
    procedure SetVis(const aVis: Boolean); override;

    procedure _Focused(); override;
    procedure _Unfocused(); override;

    procedure UpdateCursor();
  public
    property TextObject: IglrText read GetTextObject write SetTextObject;
    property CursorObject: IglrSprite read GetCursor write SetCursor;
    property MaxTextLength: Integer read GetMaxTextLength write SetMaxTextLength;

    procedure _KeyDown(KeyCode: Word; KeyData: Integer); override;

    constructor Create(); override;
    destructor Destroy(); override;
  end;

implementation

uses
  Windows,
  ExportFunc;

{ TdfGUITextBox }

constructor TglrGUITextBox.Create;
begin
  inherited;
  FTextObj := GetObjectFactory().NewText();
  FCursor := GetObjectFactory().NewHudSprite();
  Self.AddChild(FTextObj);
  Self.AddChild(FCursor);
  FTextObj.PPosition.z := 1;
  FCursor.PPosition.z := 1;
  FTextOffset.Reset();
  FCursorOffset.Reset();
  FMaxTextLength := 100;
  _Unfocused();
end;

destructor TglrGUITextBox.Destroy;
begin
  inherited;
end;

function TglrGUITextBox.GetCurOffset: TdfVec2f;
begin
  Result := FCursorOffset;
end;

function TglrGUITextBox.GetCursor: IglrSprite;
begin
  Result := FCursor;
end;

function TglrGUITextBox.GetMaxTextLength: Integer;
begin
  Result := FMaxTextLength;
end;

function TglrGUITextBox.GetTextObject: IglrText;
begin
  Result := FTextObj;
end;

function TglrGUITextBox.GetTextOffset: TdfVec2f;
begin
  Result := FTextOffset;
end;

procedure TglrGUITextBox.SetCurOffset(aOffset: TdfVec2f);
begin
  FCursorOffset := aOffset;
  //FCursor.Position := aOffset;
  UpdateCursor();
end;

procedure TglrGUITextBox.SetCursor(const aCursor: IglrSprite);
begin
  FCursor := aCursor;
end;

procedure TglrGUITextBox.SetMaxTextLength(aLength: Integer);
begin
  FMaxTextLength := aLength;
end;

procedure TglrGUITextBox.SetPos(const aPos: TdfVec3f);
begin
  inherited;
  //FTextObj.Position := FPos + FTextOffset;
  UpdateCursor();

  FTextObj.PPosition.z := aPos.z + 1;
  FCursor.PPosition.z := aPos.z + 1;
end;

procedure TglrGUITextBox.SetTextObject(const aTextObject: IglrText);
begin
  FTextObj := aTextObject;
end;


procedure TglrGUITextBox.SetTextOffset(aOffset: TdfVec2f);
begin
  FTextOffset := aOffset;
  FTextObj.Position2D := {FPos + }FTextOffset;
  UpdateCursor();
end;

procedure TglrGUITextBox.SetVis(const aVis: Boolean);
begin
  inherited;
  FTextObj.Visible := aVis;
  FCursor.Visible := False;
end;

procedure TglrGUITextBox.UpdateCursor;
begin
  with FCursor do
  begin
    Height := Self.Height - 2 * FCursorOffset.y;
    Position2D := {Self.Position + }FCursorOffset + dfVec2f(FTextObj.Width + FTextOffset.x, 0);
  end;
end;

procedure TglrGUITextBox._Focused;
begin
  inherited;
  FCursor.Visible := True;
  UpdateCursor();
end;

procedure TglrGUITextBox._KeyDown(KeyCode: Word; KeyData: Integer);
var
  Buf: WideChar;
  kbState: TKeyboardState;
  keybLayout: HKL;
begin
  inherited;
  if KeyCode = $08 then //BACKSPACE
    FTextObj.Text := Copy(FTextObj.Text, 0, Length(FTextObj.Text) - 1)
  else
  begin
    if KeyCode = VK_RETURN then
      Exit();
    if Length(FTextObj.Text) >= FMaxTextLength then
      Exit();
    GetKeyboardState(kbState);
    KeybLayout := GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow, nil));
    ToUnicodeEx(KeyCode,(KeyData and $FF0000), @kbState, @Buf, (KeyData and $FFFF),0, keybLayout);
    FTextObj.Text := FTextObj.Text + Buf;
  end;
  UpdateCursor();
end;

procedure TglrGUITextBox._Unfocused;
begin
  inherited;
  FCursor.Visible := False;
end;

end.
