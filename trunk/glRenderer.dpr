{
  LD - Last Developed - Над чем работал в последний раз в этот день

  2010-10-31 - LD Sprites - Добалвена функция экспорта файла вида I X Y Z ...
  2010-09-28 - LD Camera, Main - Поборол камеру. Метод SetCamera переработан.
                                 В соответствие с ним необходимо выстроить
                                 другие методы модуля.
                                 Анимация камеры в WndProc Main.pas
  2010-09-08 - LD Camera   - Решил заняться анимацией камеры и привязкой мыши
                           - Спустя пару часов понял, что ничего не понял.
                             Вращение не получается совсем. Точнее Y составляющая.
                             См. WndProc в Main.pas
  2010-08-25 - LD Textures - Привязаны текстуры. Спасибо Fantom за модуль загрузки
  2010-08-08 - LD Sprites - Создание модуля текстур.
  2010-07-01 - LD Anim   - Работа над renderAnimAddFromFile(). Парсинг time.
  2010-06-27 - LD Anim   - Переименованы классы - добавлен префик render.
               LD Main   - Исправление renderInit, renderInit2 - не учитывался
                           параметр позиции окна.
               LD Main   - Добавлены параметры высота, ширины и позиции окна
                           по умолчанию (renderInit2)
               LD Main   - Добавлены параметры источника света по умолчанию
                           (renderInit2)
               LD Main   - renderInit обозначен как deprecated.

               LD ----   - Поправлены многочисленные warnings, связанные с
                           отсутствием в некоторых функциях возвращения значений.
               LD Anim   - Работа над renderAnimAddFromFile(). Каркас для парсинга.

  2010-04-26 - LD Anim   - Работа над специцикацией формата файла анимаций
  2010-04-20 - LD Main   - renderInit2. Загрузка параметров из файла через парсер.
  2010-04-16 - LD Data   - renderDataAddFromFile. Сделал парсинг для сфер. Работает
  2010-04-15 - LD Data   - renderDataAddFromFile. Сделать парсинг через TParser
  2010-04-13 - LD Data   - renderDataAddSphere. Закончить.
  2010-04-07 - LD Light  - Работа с параметрами источника света
  2010-04-06 - LD Camera - Анимация. Кажется, работает SetPos и Set.
                           Сделать по аналогии остальное.
  2010-04-04 - LD Camera - Анимация. Сделал Transpose у SetPos. Проверить остальное.
  2010-04-01 - LD Camera - Анимация камеры, камера куда-то улетает,
                           не срабатывает ограничение.
  2010-03-31 - LD Camera - анимация камеры.
  2010-03-31 - LD Light
  2010-03-30 - LD Камера - Set, SetTarget.

  TODO:  \2010-04-13\
         0)Отладка и реализация существующего функционала.
           Добавление нового функционала только в случае острой необходимости.
        +1)Экспорт функций камеры
        +2)Продумать как хранить данные и как ими манипулировать
        ?3)Закончить спецификацию
        +4)light.pas. Управление источником света
       +-5)Возможность загрузки всех начальных параметров из файла:
         + параметры окна,
         + параметры камеры,
         + параметры источника света,
           используемые технологии (вкл/выкл VBO, shaders и прочее)
         6)   Result := -10; //Затычка
              Данная строка содержится во всех функциях, требующих внимания
         7) Добавление / Удаление объектов. Имена объектов.

}

{
  glRenderer

  Проект 3Д визуализатора для Трухманова Дмитрия (МР-061)

  ЗАДАЧИ:
   - Трехмерная визуализация группы атомов
   - Визуализация связей, полей
   - Анимация структуры
   - Возможность "среза" - отсечение слоев атомов в реальном времени
   - Запись анимации

  ЗАДАЧИ РЕАЛИЗАЦИИ:
   - Вывод геометрии
   - Поддержка материалов
   - Управляемая камера
   - Вывод текста
   - Шейдеры?
   - Запись видео в файл

  ИСПОЛЬЗУЕМЫЕ ТЕХНОЛОГИИ:
   - VBO - для визуализации массивов данных
     P.S. Также можно организовать работу через дисплейные списки для поддержки
          устаревших видеокарт и видеокарт с плохими дровами
   - Shaders - для визуализации эффектов
     P.S. Исключительно для красоты. Предусмотреть возможность отключения.
   - FBO - для RTT.
     P.S. Факультатив - т.к. возможна неполная поддержка.

  СПЕЦИФИКАЦИЯ ЭКСПОРТА:
   - Экспортирование функционала из DLL с использованием функций.
   - Каждая экспортируемая функция для предотвращения конфликта имен
     снабжена префиксом 'render'.
   - Второй префикс функции определяет область ее действия:
     * (нет)  - основные функции для работы с визуализатором
     * Camera - функции работы с камерой
     * Data   - работа с данными
     * Light  - работа с источником света
     * ...
   - Каждая функция (кроме некоторых, специально обозначенных) возвращают
     целочисленный код ошибки. Стандартные коды:
     *  0 - Код удачного завершения
     * -1 - Неизвестная ошибка
     Дальнейшая расшифровка приводится для каждой соответствующей функции
       Если функция не предусматривает несколько типов ошибок, то значение "-1"
     означает ошибку выполнения основной и/или единственной операции.
   - Функции, принимающие параметры MaxSpeed и Accel, изменяют соответствующую характеристику
     с некоторой максимальной скоростью и некоторым ускорением.

  ПРАВИЛА ПОЛЬЗОВАНИЯ
   - Подключить библиотеку к программе. Импортировать функции.
   - Вызвать функцию renderInit(), передав ей на вход необходимые параметры
     (Либо воспользоваться функцией renderInit2(), передав ей на вход файл конфигураций)
     2010-04-20
   - По окончании работы вызывать renderDeInit()
}
library glRenderer;

{$R *.res}

uses
  Main in 'Main.pas',
  dglOpenGL in 'dglOpenGL.pas',
  dfHInput in 'dfHInput.pas',
  dfMath in 'dfMath.pas',
  dfHEngine in 'dfHEngine.pas',
  Camera in 'Camera.pas',
  Data in 'Data.pas',
  Light in 'Light.pas',
  Animation in 'Animation.pas',
  VBO in 'VBO.pas',
  Sprites in 'Sprites.pas',
  Log in 'Log.pas',
  Textures in 'Textures.pas';

exports
  renderInit,
  renderInit2,
  renderStep,
  renderDeInit,

  renderWindowSetCaption,
  renderWindowGetHandle,

  renderCameraSet,
  renderCameraSetTarget, renderCameraSetTargetMove,
  renderCameraSetPos, renderCameraSetPosMove,
  renderCameraSetUp, renderCameraSetUpMove,
  renderCameraMoveAroundTarget,

  renderDataAddFromFile,
  renderDataSaveToFile,
  renderDataSphereAdd,
  renderDataSpherePos, renderDataSpherePosMove,
  renderDataSphereRad, renderDataSphereRadMove,
  renderDataSphereRGB, renderDataSphereRGBMove,

  renderDataCylinderAdd,

  renderAnimAddFromFile,
  renderAnimSetSpeed,
  renderAnimGetSpeed,
  renderAnimPlay,
  renderAnimPause,
  renderAnimStop,
  renderAnimNextBlock,
  renderAnimPrevBlock,
  renderAnimJumpToA,
  renderAnimJumpToB,

  renderLightSet,
  renderLightSetPos,  renderLightSetPosMove,
  renderLightSetAmb, renderLightSetAmbMove,
  renderLightSetDif, renderLightSetDifMove,
  renderLightSetSpec, renderLightSetSpecMove,

  renderSpritesAddFromFile;
begin
end.
