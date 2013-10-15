unit uGUITextButton;

interface

uses
  glr, glrMath,
  uGUIButton;

type
  TglrGUITextButton = class (TglrGUIButton, IglrGUITextButton)
  protected
    FText: IglrText;
    FTextOffset: TdfVec2f;
    function GetText(): IglrText;
    procedure SetText(const aText: IglrText);
    function GetTextOffset(): TdfVec2f;
    procedure SetTextOffset(aOffset: TdfVec2f);
    procedure SetPos(const aPos: TdfVec3f); override;
    procedure SetVis(const aVis: Boolean); override;
  public
    property TextObject: IglrText read GetText write SetText;
    property TextOffset: TdfVec2f read GetTextOffset write SetTextOffset;

    constructor Create(); override;
    destructor Destroy(); override;
  end;

implementation

uses
  ExportFunc;

{ TdfGUITextButton }

constructor TglrGUITextButton.Create;
begin
  inherited;
  FText := GetObjectFactory().NewText();
  Self.AddChild(FText);
end;

destructor TglrGUITextButton.Destroy;
begin
  FText := nil;
  inherited;
end;

function TglrGUITextButton.GetText: IglrText;
begin
  Result := FText;
end;

function TglrGUITextButton.GetTextOffset: TdfVec2f;
begin
  Result := FTextOffset;
end;

procedure TglrGUITextButton.SetPos(const aPos: TdfVec3f);
begin
  inherited;
  FText.PPosition.z := aPos.z + 1;
end;

procedure TglrGUITextButton.SetText(const aText: IglrText);
begin
  FText := aText;
end;

procedure TglrGUITextButton.SetTextOffset(aOffset: TdfVec2f);
begin
  FTextOffset := aOffset;
  FText.Position2D := aOffset;
end;

procedure TglrGUITextButton.SetVis(const aVis: Boolean);
begin
  inherited;
  FText.Visible := aVis;
end;

end.
