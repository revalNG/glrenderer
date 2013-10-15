{
��� ����������, ������ ������������� �����������

- Pirate copy from Fantom's project glsnewton from code.google

-  ���� ���������, � ������� �� ������.

+ TODO: ���������� �������� tga � bmp. ������ �����

 =)
}

unit TexLoad;

interface

uses
  ogl, glr,
  Windows, Graphics, {Classes,} SysUtils;

function LoadTexture(const Stream: TglrStream; ext: String; var iFormat,cFormat,dType: TGLConst; var pSize: Integer; var Width, Height: Integer): Pointer; overload;
//function LoadTexture(Filename: String; var Format: TGLConst; var Width, Height: Integer): Pointer;overload;
function LoadTexture(Filename: String; var iFormat,cFormat,dType: TGLConst; var pSize: Integer; var Width, Height: Integer): Pointer; overload;

implementation

uses
  uLogger;

{------------------------------------------------------------------}
{  Swap bitmap format from BGR to RGB                              }
{------------------------------------------------------------------}
//procedure SwapRGB(data : Pointer; Size : Integer);
//asm
//  mov ebx, eax
//  mov ecx, size
//
//@@loop :
//  mov al,[ebx+0]
//  mov ah,[ebx+2]
//  mov [ebx+2],al
//  mov [ebx+0],ah
//  add ebx,3
//  dec ecx
//  jnz @@loop
//end;

procedure flipSurface(chgData: Pbyte; w, h, pSize: integer);
var
  lineSize: integer;
  sliceSize: integer;
  tempBuf: Pbyte;
  j: integer;
  top, bottom: Pbyte;
begin
  lineSize := pSize * w;
  sliceSize := lineSize * h;
  GetMem(tempBuf, lineSize);

  top := chgData;
  bottom := top;
  Inc(bottom, sliceSize - lineSize);

  for j := 0 to (h div 2) - 1 do begin
    Move(top^, tempBuf^, lineSize);
    Move(bottom^, top^, lineSize);
    Move(tempBuf^, bottom^, lineSize);
    Inc(top, lineSize);
    Dec(bottom, lineSize);
  end;
  FreeMem(tempBuf);
end;

function myLoadBMPTexture(Stream: TglrStream; var Format : TGLConst; var Width, Height: Integer): Pointer;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  BytesPP: Integer;
  imageSize: Integer;
  image: Pointer;
  sLength, fLength, tmp: Integer;
  absHeight: Integer;
  i: Integer;
begin
  Result := nil;

  Stream.Read(FileHeader, SizeOf(FileHeader));
  Stream.Read(InfoHeader, SizeOf(InfoHeader));

  if InfoHeader.biClrUsed <> 0 then
  begin
    logWriteError('TexLoad: ������ �������� BMP �� ������. ColorMaps �� ��������������');
    Exit(nil);
  end;

  Width := InfoHeader.biWidth;
  Height := InfoHeader.biHeight;
  //���� ������ �������������, �� ������ �������� ������ ����
  //flip �� �����
  absHeight := Abs(Height);
  BytesPP := InfoHeader.biBitCount div 8;
  case BytesPP of
    3: Format := GL_BGR;
    4: Format := GL_BGRA;
  end;
  imageSize := Width * absHeight * BytesPP;

  sLength := Width * BytesPP;
  fLength := 0;
  if frac(sLength / 4) > 0 then
    fLength := ((sLength div 4) + 1) * 4 - sLength;
  GetMem(image, imageSize);
  Result := image;
  for i := 0 to absHeight - 1 do
  begin
    Stream.Read(image^, sLength);
    Stream.Read(tmp, fLength);
    Inc(integer(image), sLength);
  end;
end;

{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}

type
   TTGAHeader = packed record
     IDLength          : Byte;
     ColorMapType      : Byte;
     ImageType         : Byte;
     ColorMapOrigin    : Word;
     ColorMapLength    : Word;
     ColorMapEntrySize : Byte;
     XOrigin           : Word;
     YOrigin           : Word;
     Width             : Word;
     Height            : Word;
     PixelSize         : Byte;
     ImageDescriptor   : Byte;
  end;

function myLoadTGATexture(Stream: TglrStream; var Format: TGLConst; var Width, Height: Integer): Pointer; overload;
var
  //tgaFile: File;
  tgaHeader: TTGAHeader;
  colorDepth: Integer; //����� ��� �� �������
  bytesPP: Integer; //����� ���� �� �������
  imageSize: Integer; //������ ����������� � ������

  image: Pointer; //���� �����������

  procedure ReadUncompressedTGA();
  var
    bytesRead: Integer;
    i: Integer;
    Blue, Red: ^Byte;
    Tmp: Byte;
  begin
    bytesRead := Stream.Read(image^, imageSize);
    //������� ������, ��� ����������
    if (bytesRead <> imageSize) then
    begin
      logWriteError('TexLoad: ������ �������� TGA �� ������. ������ ��� ������ �������� ������');
      Exit();
    end;
    //������� bgr(a) � rgb(a)
    for i :=0 to Width * Height - 1 do
    begin
      Blue := Pointer(Integer(image) + i * bytesPP + 0);
      Red  := Pointer(Integer(image) + i * bytesPP + 2);
      Tmp := Blue^;
      Blue^ := Red^;
      Red^ := Tmp;
    end;
  end;

  procedure CopySwapPixel(const Source, Destination: Pointer);
  asm
    push ebx
    mov bl,[eax+0]
    mov bh,[eax+1]
    mov [edx+2],bl
    mov [edx+1],bh
    mov bl,[eax+2]
    mov bh,[eax+3]
    mov [edx+0],bl
    mov [edx+3],bh
    pop ebx
  end;

  procedure ReadCompressedTGA();
  var
    bufferIndex, currentByte, currentPixel: Integer;
    compressedImage: Pointer;

    bytesRead: Integer;

    i: Integer;

    First: ^Byte;
  begin
    currentByte := 0;
    currentPixel := 0;
    bufferIndex := 0;

    GetMem(compressedImage, Stream.Size - SizeOf(tgaHeader));
    bytesRead := Stream.Read(compressedImage^, Stream.Size - SizeOf(tgaHeader));
    if bytesRead <> Stream.Size - SizeOf(tgaHeader) then
    begin
      logWriteError('TexLoad: ������ �������� TGA �� ������. ������ ��� ������ ������ ������');
      Exit();
    end;

    //��������� ������ � ��������, ������ �� RLE
    repeat
      First := Pointer(Integer(compressedImage) + BufferIndex);
      Inc(BufferIndex);
      if First^ < 128 then //�������������� ������
      begin
        for i := 0 to First^ do
        begin
          CopySwapPixel(Pointer(Integer(compressedImage)+ BufferIndex + i * bytesPP), Pointer(Integer(image) + CurrentByte));
          CurrentByte := CurrentByte + bytesPP;
          inc(CurrentPixel);
        end;
        BufferIndex := BufferIndex + (First^ + 1) * bytesPP
      end
      else  //������������ ������
      begin
        for i := 0 to First^ - 128 do
        begin
          CopySwapPixel(Pointer(Integer(compressedImage) + BufferIndex), Pointer(Integer(image) + CurrentByte));
          CurrentByte := CurrentByte + bytesPP;
          inc(CurrentPixel);
        end;
        BufferIndex := BufferIndex + bytesPP;
      end;
    until CurrentPixel >= Width * Height;

    FreeMem(compressedImage, Stream.Size - SizeOf(tgaHeader));
  end;

begin
  Result := nil;
  //������ ���������
  Stream.Read(tgaHeader, SizeOf(TTGAHeader));

  Width := tgaHeader.Width;
  Height := tgaHeader.Height;
  colorDepth := tgaHeader.PixelSize;
  bytesPP := ColorDepth div 8;
  imageSize := Width * Height * bytesPP;

  GetMem(image, ImageSize);

  case bytesPP of
    3: Format := GL_RGB;
    4: Format := GL_RGBA;
  end;

  {$REGION ' ���������������� ���� tga '}

  if (colorDepth <> 24) and (colorDepth <> 32) then
  begin
    logWriteError('TexLoad: ������ �������� TGA �� ������. BPP ������� �� 24 � 32');
    Exit(nil);
  end;

  if tgaHeader.ColorMapType <> 0 then
  begin
    logWriteError('TexLoad: ������ �������� TGA �� ������. ColorMap �� ��������������');
    Exit(nil);
  end;

  {$ENDREGION}

  case tgaHeader.ImageType of
    2: {�������� tga} ReadUncompressedTGA();
    10: {������ tga} ReadCompressedTGA();
    else
    begin
      logWriteError('TexLoad: ������ �������� TGA �� ������. �������������� ������ �������� � RLE-������ tga');
      Exit(nil);
    end;
  end;
  Result := image;
end;


function LoadTexture(const Stream: TglrStream; ext: String; var iFormat, cFormat, dType: TGLConst;
  var pSize: Integer; var Width, Height: Integer): Pointer; overload;
begin
  Result := nil;
  if ext = 'BMP' then
  begin
    Result := myLoadBMPTexture(Stream, cFormat, Width, Height);
    if cFormat = GL_BGRA then
    begin
      iFormat := GL_RGBA8;
      dType := GL_UNSIGNED_BYTE;
      pSize := 4;
    end
    else
    begin
      iFormat := GL_RGB8;
      dType := GL_UNSIGNED_BYTE;
      pSize := 3;
    end;
    if Height > 0 then
      flipSurface(Result, Width, Height, pSize);
  end;
  if ext = 'TGA' then
  begin
    Result := myLoadTGATexture(Stream, cFormat, Width, Height);
    if cFormat = GL_RGB then
    begin
      iFormat := GL_RGB8;
      pSize := 3;
    end
    else
    begin
      iFormat := GL_RGBA8;
      pSize := 4;
    end;
    dType := GL_UNSIGNED_BYTE;

    flipSurface(Result, Width, Height, pSize);
  end;

  if ext = 'PNG' then
  begin
    Assert(ext <> 'PNG', 'PNG is not supported yet');
    //LoadPNG(result,PWideChar(FileName),iFormat,cFormat,dType,pSize,Width,Height);
  end;
end;

function LoadTexture(Filename: String; var iFormat, cFormat, dType: TGLConst;
  var pSize: Integer; var Width, Height: Integer): Pointer; overload;
var
  ext: String;
  Stream: TglrStream;
begin
  ext := Copy(UpperCase(FileName), Length(FileName) - 2, 3);
  Stream := TglrStream.Init(FileName, False);
  Result := LoadTexture(Stream, ext, iFormat, cFormat, dType, pSize, Width, Height);
  if Assigned(Stream) then
    Stream.Free;
end;


end.