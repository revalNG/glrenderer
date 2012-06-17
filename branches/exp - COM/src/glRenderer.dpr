{
  LD - Last Developed - Над чем работал в последний раз в этот день


  2012-04-15 - LD - Баг с вьюпортом и выводом спрайта поборот:
                    AdjustWindowRect должен затрагивать только создание окна
                    В остальном - использовать первоначальные данные
  2012-02-27 - LD - Баг с вьюпортом и вывод спрайта
  2012-02-?? - LD - TdfTexture, TdfMaterial, TdfSprite. Начал делать рендер спрайта

  BUGS:
+  1. TdfNode пустой - не обрабатывает left, up и dir
-  2. TdfNode - Добавить CreateAsChild и сопутствующий функционал
+     Вероятно, проще заглянуть в соответсствующий юнит DiF Engine
+  3. TdfNode - поправить функционал в целом. Слишком много багов
?  4. TInterfaceList странно зануляет ссылки в конце. Переделал под TList, но
      надо разобраться
   5. TdfLight - наследник TdfNode, неверно. Лучше сделать его как TdfRenderable
      Но как тогда быть с перехватом SetPos?
   6. Баг с размером вьюпорта. Смотреть Camera.Init и Renderer.Init()



  2011-10-11: TODO:
    1. Миграция на интерфейсы уже существующих базовых классов:
+     1. Camera - Базово сделано
+     2. Light - Базово сделано, но заточено под один источник света
      3. Shaders
      4. Textures
    2. Создание новых классов и интерфейсов графического движка:
+     1. Node - Базово сделано
      2. Scene
      3. VBOBuffer
      4. Mesh
      5. Sprite
      6. Material
      7. Actor
    3. Создание вспомогательных классов и интерфейсов:
      1. Resource
      2. ResourceManager

    4. Сборка воедино, проверка работоспособности

    5. Привязка звуков, физики и прочих свистелок


  2011-04-09//
              Новое ответвление - передел под COM-стандарт: интерфейсы и классы
}
library glRenderer;

{$R *.res}

uses
  Main in 'Main.pas',
  Camera in 'Camera.pas',
  Light in 'Light.pas',
  Sprites in 'Sprites.pas',
  uTextures in 'uTextures.pas',
  Shaders in 'Shaders.pas',
  Logger in 'Logger.pas',
  dfHEngine in 'common\dfHEngine.pas',
  dfHGL in 'common\dfHGL.pas',
  dfHInput in 'common\dfHInput.pas',
  dfLogger in 'common\dfLogger.pas',
  dfMath in 'common\dfMath.pas',
  dfHRenderer in 'headers\dfHRenderer.pas',
  Node in 'Node.pas',
  ExportFunc in 'ExportFunc.pas',
  TexLoad in 'TexLoad.pas',
  uRenderable in 'uRenderable.pas',
  uMaterial in 'uMaterial.pas';

exports
  CreateRenderer, CreateNode;
begin
end.
