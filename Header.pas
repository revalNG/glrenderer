{
  TODO: +1)функции для работы с данными.
}
unit Header;

interface

uses
  Windows;

const
  dllName = 'glRenderer.dll';

var
  //ОСНОВНЫЕ ФУНКЦИИ

  renderInit: function (Width, Height, X,Y: Integer; FOV, ZNear, ZFar: Single): Integer; stdcall;
  renderInit2: function(FileName: PAnsiChar): Integer; stdcall;
  renderStep: function: Integer; stdcall;
  renderDeInit: function: Integer; stdcall;

  //РАБОТА С ОКНОМ
  renderWindowSetCaption: function(aCaption: PAnsiChar): Integer; stdcall;
  renderWindowGetHandle: function: Integer; stdcall;

  //РАБОТА С КАМЕРОЙ

  //Установка всех параметров камеры: Позиция, Точка наблюдения, Вектор "верха"
  renderCameraSet: function(X, Y, Z, LookX, LookY, LookZ, UpX, UpY, UpZ: Single): Integer; stdcall;
  //Установка точки наблюдения с сохранением остальных параметров
  renderCameraSetTarget: function(LookX, LookY, LookZ: Single): Integer; stdcall;
  //Плавное передвижение камеры к новой точке с максимальной скоростью MaxSpeed и ускорением Accel
  renderCameraSetTargetMove: function(LookX, LookY, LookZ, MaxSpeed, Accel: Single): Integer; stdcall;
  //Установка позиции камеры с сохранием остальных параметров
  renderCameraSetPos: function(X,Y,Z: Single): Integer; stdcall;
  //Плавное перемещение позиции камеры с максимальной скоростью MaxSpeed и ускорением Accel с сохранением остальных параметров
  renderCameraSetPosMove: function(X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
  //Установка вектора "верха" камеры с сохранением  остальных параметров
  renderCameraSetUp: function (UpX, UpY, UpZ: Single): Integer; stdcall;
  //Плавное изменение вектора "верха" камеры с максимальной скоростью MaxSpeed и ускорением Accel с сохранением остальных параметров
  renderCameraSetUpMove: function (UpX, UpY, UpZ, MaxSpeed, Accel: Single): Integer; stdcall;
  //Вращение камеры вокруг позиции наблюдения с сохранением расстояния до нее
  renderCameraMoveAroundTarget: function(HorDelta, VerDelta: Single): Integer; stdcall;

  //РАБОТА С ДАННЫМИ

  //Загрузка данных для рендера из внешнего файла.
  renderDataAddFromFile: function(FileName: PAnsiChar): Integer; stdcall;

  renderDataSaveToFile: function(FileName: PAnsiChar): Integer; stdcall;

  //Добавление сферы в позицию X, Y, Z радиусом Radius и цветом RGB.
  //Возвращаемое значение - имя данной сферы для манипулирования
  renderDataSphereAdd: function(X, Y, Z, Radius, R, G, B, A: Single): Integer; stdcall;
  //Изменение позиции сферы с именем/номером Name
  renderDataSpherePos: function(Name: Integer; X, Y, Z: Single): Integer; stdcall;
  //Изменение позиции сферы с именем/номером Name с максимальной скоростью MaxSpeed и ускорением Accel
  renderDataSpherePosMove: function(Name: Integer; X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
  //Изменение радиуса сферы с именем/номером Name
  renderDataSphereRad: function(Name: Integer; Radius: Single): Integer; stdcall;
  //Изменение радиуса сферы с именем/номером Name с максимальной скоростью MaxSpeed и ускорением Accel
  renderDataSphereRadMove: function(Name: Integer; Radius, MaxSpeed, Accel: Single): Integer; stdcall;
  //Изменение цвета сферы с именем/номером Name
  renderDataSphereRGB: function(Name: Integer; R, G, B, A: Single): Integer; stdcall;
  //Изменение цвета сферы с именем/номером Name с максимальной скоростью MaxSpeed и ускорением Accel
  renderDataSphereRGBMove: function(Name: Integer; R, G, B, A,  MaxSpeed, Accel: Single): Integer; stdcall;

  renderDataCylinderAdd: function(X, Y, Z, Radius, ALength, R, G, B, A, DirX, DirY, DirZ, UpX, UpY, UpZ: Single): Integer; stdcall;

  //РАБОТА С АНИМАЦИЕЙ
  renderAnimAddFromFile: function(FileName: PAnsiChar): Integer; stdcall;
  renderAnimSetSpeed: function(Speed: Single): Integer; stdcall;
  renderAnimGetSpeed: function: Single; stdcall;
  renderAnimPlay: function: Integer; stdcall;
  renderAnimPause: function: Integer; stdcall;
  renderAnimStop: function: Integer; stdcall;
  renderAnimNextBlock: function: Integer; stdcall;
  renderAnimPrevBlock: function: Integer; stdcall;
  renderAnimJumpToA: function(blockName: PAnsiChar): Integer; stdcall;
  renderAnimJumpToB: function(blockNumber: Integer): Integer; stdcall;

  //РАБОТА С ИСТОЧНИКОМ СВЕТА

  //Установка всех параметров источника света
  renderLightSet: function(X, Y, Z,
                          AmbR, AmbG, AmbB, AmbA,
                          DifR, DifG, DifB, DifA,
                          SpecR, SpecG, SpecB, SpecA,
                          ConstAtten, LinAtten, QuadroAtten: Single): Integer; stdcall;
  //Установка позиции источника света
  renderLightSetPos: function(X, Y, Z: Single): Integer; stdcall;
  //Установка позиции источника света со скоростью Speed
  renderLightSetPosMove: function(X, Y, Z, Speed: Single): Integer; stdcall;
  renderLightSetAmb: function(R, G, B, A: Single): Integer; stdcall;
  renderLightSetAmbMove: function(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  renderLightSetDif: function(R, G, B, A: Single): Integer; stdcall;
  renderLightSetDifMove: function(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
  renderLightSetSpec: function(R, G, B, A: Single): Integer; stdcall;
  renderLightSetSpecMove: function(R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;


  renderSpritesAddFromFile: function(FileName: PAnsiChar): Integer; stdcall;

  dllHandle: THandle;

implementation

initialization
  dllHandle := LoadLibrary(dllname);
  renderInit := GetProcAddress(dllHandle, 'renderInit');
  renderInit2 := GetProcAddress(dllHandle, 'renderInit2');
  renderStep := GetProcAddress(dllHandle, 'renderStep');
  renderDeInit := GetProcAddress(dllHandle, 'renderDeInit');

  renderWindowSetCaption := GetProcAddress(dllHandle, 'renderWindowSetCaption');
  renderWindowGetHandle := GetProcAddress(dllHandle, 'renderWindowGetHandle');

  renderCameraSet := GetProcAddress(dllHandle, 'renderCameraSet');
  renderCameraSetTarget := GetProcAddress(dllHandle, 'renderCameraSetTarget');
  renderCameraSetTargetMove := GetProcAddress(dllHandle, 'renderCameraSetTargetMove');
  renderCameraSetPos := GetProcAddress(dllHandle, 'renderCameraSetPos');
  renderCameraSetPosMove := GetProcAddress(dllHandle, 'renderCameraSetPosMove');
  renderCameraSetUp := GetProcAddress(dllHandle, 'renderCameraSetUp');
  renderCameraSetUpMove := GetProcAddress(dllHandle, 'renderCameraSetUpMove');
  renderCameraMoveAroundTarget := GetProcAddress(dllHandle, 'renderCameraMoveAroundTarget');

  renderDataAddFromFile := GetProcAddress(dllHandle, 'renderDataAddFromFile');
  renderDataSaveToFile := GetProcAddress(dllhandle, 'renderDataSaveToFile');
  renderDataSphereAdd := GetProcAddress(dllHandle, 'renderDataSphereAdd');
  renderDataSpherePos := GetProcAddress(dllHandle, 'renderDataSpherePos');
  renderDataSpherePosMove := GetProcAddress(dllHandle, 'renderDataSpherePosMove');
  renderDataSphereRad := GetProcAddress(dllHandle, 'renderDataSphereRad');
  renderDataSphereRadMove := GetProcAddress(dllHandle, 'renderDataSphereRadMove');
  renderDataSphereRGB := GetProcAddress(dllHandle, 'renderDataSphereRGB');
  renderDataSphereRGBMove := GetProcAddress(dllHandle, 'renderDataSphereRGBMove');

  renderDataCylinderAdd := GetProcAddress(dllHandle, 'renderDataCylinderAdd');

  renderAnimAddFromFile := GetProcAddress(dllHandle, 'renderAnimAddFromFile');
  renderAnimSetSpeed := GetProcAddress(dllHandle, 'renderAnimSetSpeed');
  renderAnimGetSpeed := GetProcAddress(dllHandle, 'renderAnimGetSpeed');
  renderAnimPlay := GetProcAddress(dllHandle, 'renderAnimPlay');
  renderAnimPause := GetProcAddress(dllHandle, 'renderAnimPause');
  renderAnimStop := GetProcAddress(dllHandle, 'renderAnimStop');
  renderAnimNextBlock := GetProcAddress(dllHandle, 'renderAnimNextBlock');
  renderAnimPrevBlock := GetProcAddress(dllHandle, 'renderAnimPrevBlock');
  renderAnimJumpToA := GetProcAddress(dllHandle, 'renderAnimJumpToA');
  renderAnimJumpToB := GetProcAddress(dllHandle, 'renderAnimJumpToB');

  renderLightSet := GetProcAddress(dllHandle, 'renderLightSet');
  renderLightSetPos := GetProcAddress(dllHandle, 'renderLightSetPos');
  renderLightSetPosMove := GetProcAddress(dllHandle, 'renderLightSetPosMove');
  renderLightSetAmb := GetProcAddress(dllHandle, 'renderLightSetAmb');
  renderLightSetAmbMove := GetProcAddress(dllHandle, 'renderLightSetAmbMove');
  renderLightSetDif := GetProcAddress(dllHandle, 'renderLightDifPos');
  renderLightSetDifMove := GetProcAddress(dllHandle, 'renderLightSetDifMove');
  renderLightSetSpec := GetProcAddress(dllHandle, 'renderLightSpecPos');
  renderLightSetSpecMove := GetProcAddress(dllHandle, 'renderLightSetSpecMove');

  renderSpritesAddFromFile := GetProcAddress(dllHandle, 'renderSpritesAddFromFile');

finalization
  FreeLibrary(dllHandle);
end.
