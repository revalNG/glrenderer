{
 Pirate copy from Fantom's project glsnewton from code.google

 Куча говнокода, в который не вникал.

 =)
}

unit TexLoad;

interface

uses
  dfHGL,
  Windows, Graphics, Classes, SysUtils;

function LoadTexture(Filename: String; var Format: TGLConst; var Width, Height: Integer): Pointer;overload;
function LoadTexture(Filename: String; var iFormat,cFormat,dType: TGLConst; var pSize: Integer; var Width, Height: Integer): Pointer; overload;

implementation

//const
//  GL_LUMINANCE = $1909;
//  GL_BGR = $80E0;
//  GL_LUMINANCE8 = $8040;
//  GL_RGB8 = $8051;
//  GL_UNSIGNED_SHORT = $1403;
//  GL_UNSIGNED_BYTE = $1401;
//  GL_LUMINANCE16 = $8042;
//  GL_LUMINANCE_ALPHA = $190A;
//  GL_LUMINANCE16_ALPHA16 = $8048;
//  GL_LUMINANCE8_ALPHA8 = $8045;
//  GL_RGB   = $1907;
//  GL_RGB16 = $8054;
//  GL_RGBA  = $1908;
//  GL_RGBA16 = $805B;
//  GL_RGBA8 = $8058;
//  GL_BGRA  = $80E1;

Type
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

{------------------------------------------------------------------}
{  Swap bitmap format from BGR to RGB                              }
{------------------------------------------------------------------}
procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;

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

{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String; var Format : TGLConst; var Width, Height: Integer): Pointer;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: LongWord;
  PaletteLength: LongWord;
  ReadBytes: LongWord;
  pData : Pointer;
  //For 256 color bitmap
  bmp: TBitmap;
  bpp:byte;
  i,j, offs: integer;
  p: PByteArray;
  sLength: integer;
  fLength,temp: integer;
begin
  result :=nil;
  Width:=-1; Height:=-1;
  // Load image from file
    BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if (BitmapFile = INVALID_HANDLE_VALUE) then begin
      MessageBox(0, PChar('Error opening ' + Filename), PChar('BMP Unit'), MB_OK);
      Exit;
    end;

    // Get header information
    ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
    ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);
    Width  := InfoHeader.biWidth;
    Height := InfoHeader.biHeight;

    if InfoHeader.biClrUsed<>0 then begin
       CloseHandle(BitmapFile);
       bmp:=TBitmap.Create; bmp.LoadFromFile(Filename);
       bmp.PixelFormat:=pf24bit; bpp:=3;
       getmem(pData,bmp.Width*bmp.Height*bpp);
       for i:=bmp.Height-1 downto 0 do begin
         p:=bmp.ScanLine[i]; offs:=i*bmp.Width*bpp;
         for j:=0 to bmp.Width-1 do begin
            PByteArray(pData)[offs+j*bpp]:=p[j*bpp+2];
            PByteArray(pData)[offs+j*bpp+1]:=p[j*bpp+1];
            PByteArray(pData)[offs+j*bpp+2]:=p[j*bpp];
         end;
       end; Width:=bmp.Width; Height:=bmp.Height;
       result:=pData; Format:=GL_RGB; exit;
    end;

    //BitmapLength := InfoHeader.biSizeImage;
    //if BitmapLength = 0 then
    bpp:=InfoHeader.biBitCount Div 8;
    BitmapLength := Width * Height * bpp;
    sLength:=Width*bpp; fLength:=0;
    if frac(sLength/4)>0 then fLength:=((sLength div 4)+1)*4-sLength;
    // Get the actual pixel data
    GetMem(pData, BitmapLength);
    result:=pData;
    for i:=0 to Height-1 do begin
      ReadFile(BitmapFile, pData^, sLength , ReadBytes, nil);
      ReadFile(BitmapFile, Temp, fLength , ReadBytes, nil);
      inc(integer(pData),sLength);
    end;
{    ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
    if (ReadBytes <> BitmapLength) then begin
      MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
      Exit;
    end;
}
    CloseHandle(BitmapFile);

  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  if bpp=3 then begin SwapRGB(Result, Width*Height); Format:=GL_RGB; end;
  if bpp=4 then begin Format:=GL_BGRA; end;

end;


{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String; var Format: TGLConst; var Width, Height: integer): pointer;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;
  TGAFile   : File;
  bytesRead : Integer;
  image     : Pointer;    {or PRGBTRIPLE}
  CompImage : Pointer;
  ColorDepth    : Integer;
  ImageSize     : Integer;
  BufferIndex : Integer;
  currentByte : Integer;
  CurrentPixel : Integer;
  I : Integer;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;

  ResStream : TResourceStream;      // used for loading from resource

  // Copy a pixel from source to dest and Swap the RGB color values
  procedure CopySwapPixel(const Source, Destination : Pointer);
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
var loaded: boolean;
begin
  result :=nil;
  if FileExists(Filename) then begin
    AssignFile(TGAFile, Filename);
    Reset(TGAFile, 1);

    // Read in the bitmap file header
    BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
    loaded:=true;
  end
  else
  begin
    MessageBox(0, PChar('File not found  - ' + Filename), PChar('TGA Texture'), MB_OK);
    Exit;
  end;

  if loaded then begin
    Result := nil;

    // Only support 24, 32 bit images
    if (TGAHeader.ImageType <> 2) AND    { TGA_RGB }
       (TGAHeader.ImageType <> 10) then  { Compressed RGB }
    begin
      Result := nil;
      CloseFile(tgaFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32bit TGA supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    // Don't support colormapped files
    if TGAHeader.ColorMapType <> 0 then
    begin
      Result := nil;
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    // Get the width, height, and color depth
    Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
    Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
    ColorDepth := TGAHeader.BPP;
    ImageSize  := Width*Height*(ColorDepth div 8);

    if ColorDepth < 24 then
    begin
      Result := nil;
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32 bit TGA files supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    GetMem(Image, ImageSize);

    if TGAHeader.ImageType = 2 then begin  // Standard 24, 32 bit TGA file
        BlockRead(TGAFile, image^, ImageSize, bytesRead);
        if bytesRead <> ImageSize then begin
          Result := nil;
          CloseFile(TGAFile);
          MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
          Exit;
        end;
      // TGAs are stored BGR and not RGB, so swap the R and B bytes.
      // 32 bit TGA files have alpha channel and gets loaded differently
      if TGAHeader.BPP = 24 then begin
        for I :=0 to Width * Height - 1 do begin
          Front := Pointer(Integer(Image) + I*3);
          Back := Pointer(Integer(Image) + I*3 + 2);
          Temp := Front^;
          Front^ := Back^;
          Back^ := Temp;
        end;
        Result := Image; Format := GL_RGB;
      end else begin
        for I :=0 to Width * Height - 1 do begin
          Front := Pointer(Integer(Image) + I*4);
          Back := Pointer(Integer(Image) + I*4 + 2);
          Temp := Front^;
          Front^ := Back^;
          Back^ := Temp;
        end;
        Result := Image; Format := GL_RGBA;
      end;
    end;

    // Compressed 24, 32 bit TGA files
    if TGAHeader.ImageType = 10 then begin
      ColorDepth :=ColorDepth DIV 8;
      CurrentByte :=0;
      CurrentPixel :=0;
      BufferIndex :=0;

        GetMem(CompImage, FileSize(TGAFile)-sizeOf(TGAHeader));
        BlockRead(TGAFile, CompImage^, FileSize(TGAFile)-sizeOf(TGAHeader), BytesRead);   // load compressed data into memory
        if bytesRead <> FileSize(TGAFile)-sizeOf(TGAHeader) then
        begin
          Result := nil;
          CloseFile(TGAFile);
          MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
          Exit;
        end;

      // Extract pixel information from compressed data
      repeat
        Front := Pointer(Integer(CompImage) + BufferIndex);
        Inc(BufferIndex);
        if Front^ < 128 then begin
          for I := 0 to Front^ do begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex+I*ColorDepth), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
        end else begin
          for I := 0 to Front^ -128 do begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + ColorDepth
        end;
      until CurrentPixel >= Width*Height;
      Result := Image;
      if ColorDepth = 3 then Format := GL_RGB
      else Format := GL_RGBA;
    end;
  end;
end;



var

  LoadPNG: procedure (var Data: pointer; FileName: PWideChar;
    var IntFormat,ColorFormat,DataType: TGLConst; var ElementSize: Integer;
    var width,height: integer);
  ImgLibHandle: THandle = 0;

{------------------------------------------------------------------}
{  Determines file type and sends to correct function              }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Format: TGLConst;
  var Width, Height: integer): Pointer; overload;
var
  ext: string;
  ColorFormat,DataType: TGLConst;
  eSize: Integer;
begin
  Result := nil;
  ext := copy(Uppercase(filename), length(filename) - 3, 4);
  if ext = '.BMP' then
    Result := LoadBMPTexture(Filename, Format, Width, Height);
  if ext = '.TGA' then
    Result := LoadTGATexture(Filename, Format, Width, Height);
  if ext = '.PNG' then
  begin
    LoadPNG(result,PWideChar(FileName),ColorFormat,Format,DataType,eSize,Width,Height);
  end;

//  flipSurface(result,Width,Height,eSize);
end;

function LoadTexture(Filename: String; var iFormat,cFormat,dType: TGLConst; var pSize: Integer;
  var Width, Height: integer): pointer; overload;
var
  ext: String;
begin
  Result := nil;
  ext := copy(Uppercase(filename), length(filename) - 3, 4);
  if ext = '.BMP' then
  begin
    Result := LoadBMPTexture(Filename, cFormat, Width, Height);
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
  end;
  if ext = '.TGA' then
  begin
    Result := LoadTGATexture(Filename, cFormat, Width, Height);
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
  end;

  if ext = '.PNG' then
  begin
    LoadPNG(result,PWideChar(FileName),iFormat,cFormat,dType,pSize,Width,Height);
  end;

  flipSurface(result,Width,Height,pSize)
end;


end.