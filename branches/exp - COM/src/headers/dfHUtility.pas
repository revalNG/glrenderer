{Функции, облегчающие жизнь}

unit dfHUtility;

interface

uses
  dfHRenderer, dfMath;

type
  TdfFPSCounter = class
  private
    FFrames: Integer;
    FNode: IdfNode;
    FTime, FFreq: Double;
    FText: String;

    FPS: Double;
  public
    TextObject: IdfText;
    FontObject: IdfFont;
    constructor Create(aRootNode: IdfNode; aText: String; aFreq: Double; aFont: IdfFont); virtual;
    destructor Destroy;

    procedure Update(const dt: Double);
  end;

  {Упрощенное задание спрайта, скрывает создание рендер-узла}
  function dfNewSpriteWithNode(const aParent: IdfNode): IdfSprite; overload;
  {Упрощенное задание спрайта, скрывает создание рендер-узла, который возвращает в ResultNode}
  function dfNewSpriteWithNode(const aParent: IdfNode; var ResultNode: IdfNode): IdfSprite; overload;

implementation

uses
  Windows, SysUtils;

function dfNewSpriteWithNode(const aParent: IdfNode): IdfSprite;
var
  rNode: IdfNode;
begin
  Result := dfNewSpriteWithNode(aParent, rNode);
  rNode := nil;
end;

function dfNewSpriteWithNode(const aParent: IdfNode; var ResultNode: IdfNode): IdfSprite;
begin
  ResultNode := dfCreateNode(aParent);
  Result := dfCreateHUDSprite();
  ResultNode.Renderable := Result;
end;

{ TdfFPSCounter }

constructor TdfFPSCounter.Create(aRootNode: IdfNode; aText: String; aFreq: Double; aFont: IdfFont);
begin
  inherited Create();
  FFreq := aFreq;
  FText := aText;
  if not Assigned(aFont) then
  begin
    FontObject := dfCreateFont();
//    FontObject.AddRange('!', '~');
//    FontObject.AddRange('А', 'я');
//    FontObject.AddRange(' ', ' ');
    FontObject.AddSymbols(FText + ' :.,0123456789');
    FontObject.FontSize := 14;
    FontObject.GenerateFromFont('Courier New');
  end
  else
    FontObject := aFont;

  TextObject := dfCreateText();
  TextObject.Font := FontObject;
  TextObject.Position := dfVec2f(1, 1);

  FNode := aRootNode.AddNewChild();
  FNode.Renderable := TextObject;
end;

destructor TdfFPSCounter.Destroy;
begin
  FontObject := nil;
  TextObject := nil;
  FNode := nil;
  inherited;
end;

procedure TdfFPSCounter.Update(const dt: Double);
begin
  FTime := FTime + dt;
  Inc(FFrames);
  if FTime >= FFreq then
  begin
    FPS := FFrames / FTime;
    TextObject.Text := FText + ' ' + Format('%.2f', [FPS]);
    FTime := 0.0;
    FFrames := 0;
  end;
end;

end.
