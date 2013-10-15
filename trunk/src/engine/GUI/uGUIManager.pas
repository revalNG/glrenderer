unit uGUIManager;

interface

uses
  Classes,
  glr, uBaseInterfaceObject;

type
  TglrGUIManager = class(TglrInterfacedObject, IglrGUIManager)
  private
    FElements: TInterfaceList;
    FFocused: IglrGUIElement;

    function GetFocused(): IglrGUIElement;
    procedure SetFocused(aElement: IglrGUIElement);

    function GetElementIndexAtPos(X, Y: Integer): Integer;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    //����������������/����������������� �������
    procedure RegisterElement(aElement: IglrGUIElement);
    procedure UnregisterElement(aElement: IglrGUIElement);

    //�������, ����������� � ������
    property Focused: IglrGUIElement read GetFocused write SetFocused;

    //��� ����������� ������������� IdfRenderer-��.
    procedure MouseMove (X, Y: Integer; Shift: TglrMouseShiftState);
    procedure MouseDown (X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState);
    procedure MouseUp   (X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState);
    procedure MouseWheel(X, Y: Integer; Shift: TglrMouseShiftState; WheelDelta: Integer);
    procedure KeyDown   (KeyCode: Word; KeyData: Integer);
  end;

implementation

{ TdfGUIManager }

constructor TglrGUIManager.Create;
begin
  inherited;
  FElements := TInterfaceList.Create();
  FFocused := nil;
end;

destructor TglrGUIManager.Destroy;
begin
  FFocused := nil;
  FElements.Free;
  inherited;
end;

function TglrGUIManager.GetElementIndexAtPos(X, Y: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FElements.Count - 1 do //��� ������� ��������
    with IglrGUIElement(FElements[i]) do
    begin
      if CheckHit(X, Y) then //���� ���� ���������
        if Result <> -1 then // ���� �� ����� ��� ���� ��������
        begin
          if Position.z < IglrGUIElement(FElements[Result]).Position.z then
            Result := i
        end
        else
          Result := i;
    end;
end;

function TglrGUIManager.GetFocused: IglrGUIElement;
begin
  Result := FFocused;
end;

procedure TglrGUIManager.KeyDown(KeyCode: Word; KeyData: Integer);
begin
  if Assigned(FFocused) then
    FFocused._KeyDown(KeyCode, KeyData);
end;

procedure TglrGUIManager.MouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  if ind <> -1 then
  begin
    Focused := IglrGUIElement(FElements[ind]);
    //Trunc(FFocused.AbsoluteMatrix.Pos.y) -- debug. If works - delete
    FFocused._MouseDown(X, Y, MouseButton, Shift);
  end
  else
    Focused := nil;
end;

procedure TglrGUIManager.MouseMove(X, Y: Integer; Shift: TglrMouseShiftState);

  //������� ��� ��������, � ������� ����� ���� � ���, ��� ���� ��� ����
  //��� ����� ExceptIndex �������� ����, exceptIndex - ��� �������, �������
  //�� �������
  procedure SetMouseOut(exceptIndex: Integer);
  var
    i: Integer;
  begin
    for i := 0 to FElements.Count - 1 do
      with IglrGUIElement(FElements[i]) do
        if (MousePos = mpOver) and (i <> exceptIndex) then
          _MouseOut(X, Y, Shift);
  end;

var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  SetMouseOut(ind);

  //���� ���� �� ������, �� ������� ��������� �������� ���������
  if ((ssLeft in Shift) or (ssRight in Shift) or (ssMiddle in Shift) )
    and Assigned(FFocused) then
    FFocused._MouseMove(X, Y, Shift);

  if ind <> -1 then
    with IglrGUIElement(FElements[ind]) do
      //���� ���� ����� �� ���� �� ��������, �� ���������� omMouseOver
      if MousePos = mpOut then
        _MouseOver(X, Y, Shift)
      //����� - ������ �������� ���� �� ��������
      else
        _MouseMove(X, Y, Shift);
end;

procedure TglrGUIManager.MouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);

  if Assigned(FFocused) and ( (ind = -1) or (FElements[ind] <> FFocused) ) then
    with FFocused do
      _MouseUp(X, Y, MouseButton, Shift);

  if ind <> -1 then
  begin
    with IglrGUIElement(FElements[ind]) do
      if MousePos  = mpOver then
      begin
        _MouseClick(X, Y, MouseButton, Shift);
        _MouseUp(X, Y, MouseButton, Shift);
      end
      else
        _MouseUp(X, Y, MouseButton, Shift);
  end;
end;

procedure TglrGUIManager.MouseWheel(X, Y: Integer; Shift: TglrMouseShiftState;
  WheelDelta: Integer);
//var
//  ind: Integer;
begin
//  ind := GetElementIndexAtPos(X, Y);
//  if (ind <> -1) then
//    IdfGUIElement(FElements[ind])._MouseWheel(X, Y, Shift, WheelDelta);
end;

procedure TglrGUIManager.RegisterElement(aElement: IglrGUIElement);
begin
  FElements.Add(aElement);
  aElement.Reset();
//  aElement._MouseOut(0, 0, []); //������� ��������� ��������� ������������ ����
end;

procedure TglrGUIManager.SetFocused(aElement: IglrGUIElement);
begin
  if Assigned(FFocused) then
    FFocused._Unfocused();
  if Assigned(aElement) then
    aElement._Focused();

  FFocused := aElement;
end;

procedure TglrGUIManager.UnregisterElement(aElement: IglrGUIElement);
begin
  if aElement = FFocused then
    FFocused := nil;
  FElements.Remove(aElement);
end;

end.
