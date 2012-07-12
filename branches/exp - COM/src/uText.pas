unit uText;

interface

uses
  uRenderable,
  dfHRenderer, dfMath;

type
  TdfText = class(Tdf2DRenderable, IdfText)
  private
  protected
    function GetFont(): IdfFont;
    procedure SetFont(aFont: IdfFont);
    function GetText(): String;
    procedure SetText(aText: String);

//    function GetWidth(): Single; override;
    procedure SetWidth(const aWidth: Single); override;
//    function GetHeight(): Single; override;
    procedure SetHeight(const aHeight: Single); override;
  public

    property Font: IdfFont read GetFont write SetFont;
    property Text: String read GetText write SetText;

//    property Width: Single read GetWidth write SetWidth;
//    property Height: Single read GetHeight write SetHeight;
  end;

implementation

{ TdfText }

function TdfText.GetFont: IdfFont;
begin

end;

function TdfText.GetText: String;
begin

end;

procedure TdfText.SetFont(aFont: IdfFont);
begin

end;

procedure TdfText.SetHeight(const aHeight: Single);
begin

end;

procedure TdfText.SetText(aText: String);
begin

end;

procedure TdfText.SetWidth(const aWidth: Single);
begin

end;

end.
