Тестовое задание. Автодок

Описание
Разработайте приложение, отображающее новостную ленту.

Источник данных
https://webapi.autodoc.ru/api/news/1/15

Технологии
MVVM + Combine,
UICollectionView + CompositionalLayout

Внешний вид
Прототип ячейки должен содержать изображение и заголовок новости. По нажатию необходимо отображать новость целиком.

Требования
• Загрузка и отображение постранично;
• Все запросы async / await;
• Оптимизация для iPad;
• Без использования сторонних библиотек
(Alamofire, Kingfisher и т.д.).

При проверке обращается внимание на быстродействие и масштабируемость решения. 
Общая чистота кода будет преимуществом.
Приветствуется творческий подход.

--- 

Этап 1 - Подготовительный
 - Сырой набросок collectionView с customCell и dummy data
 - CompositionLayout позволяет удобно подстраиваться под разные размеры
    - iPhone будет отображать 1 ячейку в строку 
    - iPad - сколько влезет
Этап 2 - Прикручиваем MVVM
    - Выделил VM
        - Выбрал UICollectionViewDiffableDataSource - меньше кода и безопасней
        - Repository - абстракция над данными. Возвращает нам сразу доменный объект
            - Выделил для модели DTO (что к нам приходит), Domain(избавился от optinal, преобразовал типы), Presentation (отображение и закреплены за коллекцией)
        - Прикрыл протоколами
    - Сделал загрузку картинок
        - Вынес в отдельную view из cell
        - Добавил отмену загрузки
        - Установил кэш
    - Сделал пагинацию
    - Оптимизация
        - Уменьшил размер картинок
        - Установил лимит на кэш
    - Новости даны как обычная ссылка, самое простое показать их через WebView
        - Навигацию выделил в Router
Этап 3 - Приукрашивание 
    - SearchBar
    - Pull to refresh
    - Проверка и исправление багов
Этап 4 - Исправление комментариев
    - dequeueConfiguredReusableCell вместо dequeueReusableCell
    - combine + state in ViewModel 
