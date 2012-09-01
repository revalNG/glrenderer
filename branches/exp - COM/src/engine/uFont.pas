unit uFont;

interface

uses
  Windows,
  Graphics,
  dfHRenderer;

type
  TdfCharData = record
    ID   : WideChar; //символ
    w, h : Word;  //Размеры в пикселях
    tx, ty, tw, th : Single; //текстурные координаты и размер в текстурных единицах
  end;
  PdfCharData = ^TdfCharData;

  TdfFont = class(TInterfacedObject, IdfFont)
  private
    FFontName: String;
    FFontSize: Integer;
    FFontStyle: TFontStyles;

    FTable: array[WideChar] of PdfCharData;

    FTexture: IdfTexture;

    function AlreadyHaveSymbol(aSymbol: Word): Boolean;
    procedure CreateFontResource(aFile: String);
    procedure RenderRangesToTexture();
  protected
    function GetTexture(): IdfTexture;
    function GetFontSize(): Integer;
    procedure SetFontSize(aSize: Integer);
    function GetFontStyle(): TFontStyles;
    procedure SetFontStyle(aStyle: TFontStyles);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure AddRange(aStart, aStop: Word); overload;
    procedure AddRange(aStart, aStop: Char); overload;
    procedure AddSymbols(aText: String);

    property FontSize: Integer read GetFontSize write SetFontSize;
    property FontStyle: TFontStyles read GetFontStyle write SetFontStyle;

    procedure GenerateFromTTF(aFile: String);
    procedure GenerateFromFont(aFontName: String);

    property Texture: IdfTexture read GetTexture;

    procedure PrintText(aText: String);
  end;

implementation

uses
  dfHGL,
  uLogger,
  SysUtils,
  ExportFunc;

{ TdfFont }

procedure TdfFont.AddRange(aStart, aStop: Word);
var
  i: Word;
  cdata: PdfCharData;
begin
  for i := aStart to aStop do
    if not AlreadyHaveSymbol(i) then
    begin
      New(cdata);
      with cdata^ do
        ID := WideChar(i);
      FTable[WideChar(i)] := cdata;
    end;
end;

procedure TdfFont.AddRange(aStart, aStop: WideChar);
begin
  AddRange(Word(aStart), Word(aStop));
end;

procedure TdfFont.AddSymbols(aText: String);
var
  i: Word;
  cdata: PdfCharData;
begin
  for i := 1 to Length(aText) do
    if not AlreadyHaveSymbol(Word(aText[i])) then
    begin
      New(cdata);
      with cdata^ do
        ID := aText[i];
      FTable[aText[i]] := cdata;
    end;
end;

function TdfFont.AlreadyHaveSymbol(aSymbol: Word): Boolean;
begin
  Result := FTable[WideChar(aSymbol)] <> nil;
end;

constructor TdfFont.Create;
begin
  inherited Create();
  FFontSize := 10;
  FFontStyle := [];
end;

procedure TdfFont.CreateFontResource(aFile: String);
begin
  if (FileExists(aFile)) then
    if AddFontResourceEx(PChar(aFile), FR_PRIVATE, nil) <> 1 then
      logWriteError('uFont.pas: Ошибка добавления шрифта ' + aFile + ' в систему', true, true, true);
end;

destructor TdfFont.Destroy;
var
  i: WideChar;
begin
  for i := Low(FTable) to High(FTable) do
    if Assigned(FTable[i]) then
      Dispose(FTable[i]);
  FTexture := nil;
  inherited;
end;

function TdfFont.GetFontSize: Integer;
begin
  Result := FFontSize;
end;

function TdfFont.GetFontStyle: TFontStyles;
begin
  Result := FFontStyle;
end;

function TdfFont.GetTexture: IdfTexture;
begin
  Result := FTexture;
end;

procedure TdfFont.GenerateFromFont(aFontName: String);
begin
  FFontName := aFontName;
  RenderRangesToTexture();
  logWriteMessage('uFont.pas: Шрифт «' + FFontName + '» отрендерен в текстуру');
end;

procedure TdfFont.GenerateFromTTF(aFile: String);
begin
  FFontName := Copy(ExtractFileName(aFile), 0, Pos('.', ExtractFileName(aFile)) - 1);
  logWriteMessage('uFont.pas: Загрузка шрифта «' + FFontName + '» из ' + aFile);
  CreateFontResource(aFile);
  logWriteMessage('uFont.pas: Шрифт «' + FFontName + '» добавлен в систему');
  RenderRangesToTexture();
  logWriteMessage('uFont.pas: Шрифт «' + FFontName + '» отрендерен в текстуру');
end;

procedure TdfFont.PrintText(aText: String);
var
  i, px: Integer;
begin
  FTexture.Bind;
  gl.Beginp(GL_QUADS);
    px := 0;
    for i := 1 to Length(aText) do
      if FTable[aText[i]] <> nil then
        with FTable[aText[i]]^ do
        begin
          gl.TexCoord2f(tx, ty);           gl.Vertex2f(px, 0);
          gl.TexCoord2f(tx, ty + th);      gl.Vertex2f(px, 0 + h);
          gl.TexCoord2f(tx + tw, ty + th); gl.Vertex2f(px + w, 0 + h);
          gl.TexCoord2f(tx + tw, ty);      gl.Vertex2f(px + w, 0);
          Inc(px, w);
        end;
  gl.Endp;
  FTexture.Unbind();
end;

procedure TdfFont.RenderRangesToTexture;

{Данные типы используются для считывания и записи информации в битмапах
 при помощи TBitmap.ScanLine()}
type
  TdfRGBA = record
    B, G, R, A: Byte;
  end;
  TdfRGBAArray = array[0..MaxInt div SizeOf(TdfRGBA)-1] of TdfRGBA;
  PdfRGBAArray = ^TdfRGBAArray;

  TdfRGB = record
    B, G, R: Byte;
  end;
  TdfRGBArray = array[0..MaxInt div SizeOf(TdfRGB)-1] of TdfRGB;
  PdfRGBArray = ^TdfRGBArray;

var
  bmp24, bmp32: TBitmap;
  rect: TRect; //используется для заливки тексуры
  row_height: Integer; //счетчики и высота строки
  i: WideChar;
  offsetX, offsetY: Integer; //смещение внутри битмапа для текущего выводимого символа
  {

  function GetTextSize(DC: HDC; Str: PWideChar; Count: Integer): TSize;
    var tm: TTextMetricW;
  begin
    Result.cx := 0;
    Result.cy := 0;
    GetTextExtentPoint32W(DC, Str, Count, Result);
    GetTextMetricsW(DC, tm);
    if tm.tmPitchAndFamily and TMPF_TRUETYPE <> 0 then
      Result.cx := Result.cx - tm.tmOverhang
    else
      Result.cx := tm.tmAveCharWidth * Count;
  end;

  }

  {Перемещаем информацию из 24-битного битмапа в 32-битный
   Используем RGB-составляющие входящего битмапа и записываем их среднее
   арифметическое в алька-канал 32-битного белого битмапа}
  function CreateBitmap32FromBitmap24(bmp24: TBitmap): TBitmap;
  var
    line1: PdfRGBArray;
    line2: PdfRGBAArray;
    i, j: Integer;
  begin
    Result := TBitmap.Create();
    Result.PixelFormat := pf32bit;
    Result.Width := bmp24.Width;
    Result.Height := bmp24.Height;

    for i := 0 to bmp24.Height - 1 do
    begin
      line1 := bmp24.ScanLine[i];
      line2 := Result.ScanLine[i];
      for j := 0 to bmp24.Width - 1 do
        line2[j].A := (line1[j].B + line1[j].G + line1[j].R) div 3;
    end;
  end;

begin
  bmp24 := TBitmap.Create();
  with bmp24 do
  begin
    {DEBUG!!!}
    Width := 256;
    Height := 256;
    {/DEBUG}
    PixelFormat := pf24bit;
    with Canvas.Font do
    begin
      Name := FFontName;
      Color := clWhite;
      Size := FFontSize;
      Style := FFontStyle;
    end;
  end;


  with rect do
  begin
    Left := 0;
    Top := 0;
    Right := bmp24.Width;
    Bottom := bmp24.Height;
  end;
  bmp24.Canvas.Brush.Color := clBlack;
  bmp24.Canvas.FillRect(rect);

  offsetX := 1;
  offsetY := 0;
  row_height := bmp24.Canvas.TextExtent('A').cy + 2;
  i := Low(FTable);

  repeat
    if FTable[i] <> nil then
    begin
      repeat
        if FTable[i] <> nil then
          with FTable[i]^ do
          begin
            w := bmp24.Canvas.TextExtent(ID).cx;//GetTextSize(bmp.Canvas.Handle, @ID, 1).cx;
            h := row_height;
            tx := offsetX / bmp24.Width;
            ty := offsetY / bmp24.Height;
            tw := w / bmp24.Width;
            th := h / bmp24.Height;
            bmp24.Canvas.TextOut(offsetX, offsetY, ID);
            if w > 0 then
              offsetX := offsetX + w + 2
            else
              Dispose(FTable[i]);
          end;
        Inc(i);
      until (offsetX + bmp24.Canvas.TextExtent(i + ' ').cx > bmp24.Width) or (i >= High(FTable));
      offsetY := offsetY + row_height;
      offsetX := 1;
    end
    else
      Inc(i);
  until i >= High(FTable);

  bmp32 := CreateBitmap32FromBitmap24(bmp24);
  {DEBUG}
  bmp24.SaveToFile('data\2.bmp');
  bmp32.SaveToFile('data\2a.bmp');
  {/DEBUG}
  logWriteMessage(IntToStr(Word(i)));
  FTexture := CreateTexture;
  FTexture.Load2D('data\2a.bmp'); //DEBUG
  FTexture.CombineMode := tcmReplace;
  FTexture.BlendingMode := tbmTransparency;
  FTexture.MinFilter := tmnLinear;
  FTexture.MagFilter := tmgLinear;

  bmp24.Free;
  bmp32.Free;
end;

procedure TdfFont.SetFontSize(aSize: Integer);
begin
  if aSize > 0 then
    FFontSize := aSize;
end;

procedure TdfFont.SetFontStyle(aStyle: TFontStyles);
begin
  FFontStyle := aStyle;
end;

end.
