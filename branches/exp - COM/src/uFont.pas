unit uFont;

interface

uses
  dfHRenderer;

type
  TdfFont = class(TInterfacedObject, IdfFont)
  private
    FTexture: IdfTexture;
    procedure CreateFontResource(aFile: String);
  protected
    function GetTexture(): IdfTexture;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure LoadFromTTF(aFile: String);

    property Texture: IdfTexture read GetTexture;
  end;

implementation

{ TdfFont }

constructor TdfFont.Create;
begin
  inherited Create();
end;

procedure TdfFont.CreateFontResource(aFile: String);
begin

end;

destructor TdfFont.Destroy;
begin
  FTexture := nil;
  inherited;
end;

function TdfFont.GetTexture: IdfTexture;
begin
  Result := FTexture;
end;

procedure TdfFont.LoadFromTTF(aFile: String);
begin
  CreateFontResource(aFile);
end;

end.
