# package strings_ru;

# use base 'Exporter';
use utf8;

use constant S_HOME   => 'Домой';           # Forwards to home page
use constant S_ADMIN  => 'А';         # Forwards to Management Panel
use constant S_RETURN => 'Назад';    # Returns to image board
use constant S_POSTING => 'Ответ';    # Prints message in red bar atop the reply screen

use constant S_NAME       => 'Имя';           # Describes name field
use constant S_EMAIL      => 'E-Mail';         # Describes e-mail field
use constant S_SUBJECT    => 'Тема';        # Describes subject field
use constant S_SUBMIT     => 'Отправить';     # Describes submit button
use constant S_COMMENT    => 'Текст';      # Describes comment field
use constant S_UPLOADFILE => 'Файлы';          # Describes file field
use constant S_NOFILE     => 'Без файла';    # Describes file/no file checkbox
use constant S_CAPTCHA    => 'Капча';        # Describes captcha field
use constant S_PARENT => 'Тред No.';    # Describes parent field on admin post page
use constant S_DELPASS => 'Пароль';    # Describes password field
use constant S_DELEXPL =>
  ' (для удаления поста и файлов)';    # Prints explanation for password box (to the right)
use constant S_SPAMTRAP => '';
use constant S_ALLOWED => 'Allowed file formats (max. %s or given)';

use constant S_THUMB => '';    # Prints instructions for viewing real source
use constant S_HIDDEN =>
  '';    # Prints instructions for viewing hidden image reply
use constant S_NOTHUMB =>
  'Нет миниатюры';    # Printed when there's no thumbnail
use constant S_PICNAME => '';             # Prints text before upload name/link
use constant S_REPLY   => 'Ответ';    # Prints text for reply link
use constant S_OLD => 'Помечено для удаления (old).'; 
  # Prints text to be displayed before post is marked for deletion, see: retention

use constant S_HIDE => 'Скрыть тред %d';

use constant S_ABBR1 => '1 Сообщение ';       # Prints text to be shown when replies are hidden
use constant S_ABBR2 => '%d сообщений ';
use constant S_ABBRIMG1 => 'и 1 файл ';   # Prints text to be shown when replies and files are hidden
use constant S_ABBRIMG2 => 'и %d файлов ';
use constant S_ABBR_END => 'скрыто.'; 

use constant S_ABBRTEXT1 => 'Раскрыть пост полностью (+1 строка)';
use constant S_ABBRTEXT2 => 'Раскрыть пост полностью (+%d строк)';

use constant S_BANNED  => '<p class="ban">(User was banned for this post)</p>';

use constant S_REPDEL => ' ';    # Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => '';    # Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Пароль ';    # Prints text next to password field for deletion (left)
use constant S_DELETE => 'Удалить';    # Defines deletion button's name

use constant S_PREV    => 'Предыдущая';    # Defines previous button
use constant S_FIRSTPG => 'Предыдущая';    # Defines previous button
use constant S_NEXT    => 'Следующая';            # Defines next button
use constant S_LASTPG  => 'Следующая';            # Defines next button
use constant S_TOP     => 'Вверх';
use constant S_BOTTOM  => 'Вниз'; 

use constant S_SEARCHTITLE    => 'Поиск';
use constant S_SEARCH     => 'Поиск';
use constant S_SEARCHCOMMENT  => 'Поиск по комментарию';
use constant S_SEARCHSUBJECT  => 'Поиск по теме';
use constant S_SEARCHFILES    => 'Поиск по имени файла';
use constant S_SEARCHOP     => 'Искать только в оп-постах';
use constant S_SEARCHSUBMIT   => 'Поиск';
use constant S_SEARCHFOUND    => 'Найдено:';
use constant S_OPTIONS      => 'Опции';
use constant S_MINLENGTH    => '(мин. 3 символа)';

use constant S_WEEKDAYS => ('Вс','Пн','Вт','Ср','Чт','Пт','Сб'); # Defines abbreviated weekday names.

use constant S_STICKYTITLE => 'Тред прикреплен';    # Defines the title of the tiny sticky image on a thread if it is sticky
use constant S_LOCKEDTITLE => 'Тред закрыт';    # Defines the title of the tiny locked image on a thread if it is locked

# javascript message strings (do not use HTML entities; mask single quotes with \\\')
use constant S_JS_EXPAND => 'Expand textfield';
use constant S_JS_SHRINK => 'Shrink textfield';
use constant S_JS_REMOVEFILE => 'Remove file';
use constant S_JS_STYLES => 'Стили';
# javascript strings END

use constant S_MANARET => 'Назад';    # Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
use constant S_MANAMODE => 'Управление';   # Prints heading on top of Manager page

use constant S_MANALOGIN => 'Логин'
; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_ADMINPASS => 'Пароль:';    # Prints login prompt

use constant S_MANAPANEL => 'Посты'
; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_MANATOOLS => 'Инструменты';
use constant S_MANAGEOINFO => 'GeoIP-Information';
use constant S_MANABANS    => 'Баны';         # Defines Bans Panel button
use constant S_MANAPROXY   => 'Прокси';
use constant S_MANAORPH => 'Файлы-сироты';
use constant S_MANALOGOUT  => 'Выход';
use constant S_MANASAVE => 'Запомнить';    # Defines Label for the login cookie checbox
use constant S_MANASUB => 'Го!';          # Defines name for submit button in Manager Mode
use constant S_MANALOG  => 'Лог';

use constant S_NOTAGS => '<p>HTML tags are also possible. No WakabaMark.</p>';
               # Prints message on Management Board

use constant S_POSTASADMIN => 'Пост как админ';
use constant S_NOTAGS2 => 'Не форматировать комментарий';
use constant S_MPSETSAGE => 'Toggle Sage';
use constant S_MPUNSETSAGE => 'Toggle Sage';

use constant S_BTNEWTHREAD => 'Создать новый тред';
use constant S_BTREPLY => 'Ответ на';
use constant S_SAGE => 'Sage';
use constant S_SAGEDESC => 'Не поднимать тред';
use constant S_IMGEXPAND => 'Увеличить поле';
use constant S_NOKO => 'Перейти к';
use constant S_NOKOOFF => 'доске';
use constant S_NOKOON => 'треду';

use constant S_NOPOMF => 'POMF';
use constant S_NOPOMFDESC => 'Не загружать файлы на внешний сервер';

use constant S_THREADLOCKED => '<strong>Тред %s</strong> закрыт. Вы не можете отвечать в этот тред.';
use constant S_FILEINFO => 'Информация';
use constant S_FILEDELETED => 'Файл удален';


use constant S_POSTINFO => 'IP-Informationen';
use constant S_MPDELETEIP => 'Уд.&nbsp;все';
use constant S_MPDELETE => 'Удалить';    # Defines for deletion button in Management Panel
use constant S_MPEDIT => 'Редактировать';    # Defines for deletion button in Management Panel
use constant S_MPDELFILE  => 'Удалить файл';
use constant S_MPARCHIVE  => 'Архив';
use constant S_MPSTICKY   => 'Прикрепить';
use constant S_MPUNSTICKY => 'Открепить';
use constant S_MPLOCK     => 'Закрыть';
use constant S_MPUNLOCK   => 'Открыть';
use constant S_MPRESET => 'Сброс';        # Defines name for field reset button in Management Panel
use constant S_MPONLYPIC => 'Только файл';  # Sets whether or not to delete only file, or entire post/thread
use constant S_MPDELETEALL => 'Удалить все посты с этого IP';    #
use constant S_MPBAN => 'Ban';    # Sets whether or not to delete only file, or entire post/thread
use constant S_MPTABLE => '<th>No.</th><th>Date</th><th>Subject</th>'
  . '<th>Name</th><th>Comment</th><th>IP</th>';
            # Explains names for Management Panel
use constant S_IMGSPACEUSAGE => '[ Использовано места: %s, %s Файлов, %s Постов (%s Тредов) ]';
          # Prints space used KB by the board under Management Panel
use constant S_DELALLMSG => 'Затронуто';
use constant S_DELALLCOUNT => '%s Posts (%s Threads)';

use constant S_BANFILTER => 'Скрыть истекшие баны';
use constant S_BANSHOWALL => 'Показать истекшие баны';
use constant S_BANTABLE =>
  '<th>Тип</th><th colspan="2">Значение</th><th>Текст</th><th>Дата</th><th>Истекает</th><th>Действие</th>';
            # Explains names for Ban Panel
use constant S_BANIPLABEL      => 'IP';
use constant S_BANMASKLABEL    => 'Маска';
use constant S_BANCOMMENTLABEL => 'Текст';
use constant S_BANWORDLABEL    => 'Слово';
use constant S_BANIP           => 'IP бан';
use constant S_BANWORD         => 'Бан слова';
use constant S_BANWHITELIST    => 'Белый список';
use constant S_BANREMOVE       => 'Удалить';
use constant S_BANEDIT         => 'Ред';
use constant S_BANCOMMENT      => 'Комментарий';
use constant S_BANTRUST        => 'Без капчи';
use constant S_BANTRUSTTRIP    => 'Трипкод';
use constant S_BANEXPIRESLABEL => 'Истекает';
use constant S_BANEXPIRESDESC  => 'Example: 5 Days, 10 Hours, 30 Minutes<br />Permaban - leave field empty';
use constant S_BANREASONLABEL => 'Причина';
use constant S_BANASNUMLABEL => 'AS-Nummer';
use constant S_BANASNUM => 'Бан сети';
use constant S_BANSECONDS => 'Секунды';

use constant S_ORPHTABLE     => '<th>Link</th><th>File</th><th>Modify&nbsp;date</th><th>Size</th>';
use constant S_MANASHOW      => 'Show';

use constant S_LOCKED => 'Тред закрыт';
use constant S_BADIP         => 'Incorrect IP address';
use constant S_BADDELIP      => 'Wrong IP.';
    # Returns error for wrong ip (when user tries to delete file)
use constant S_INVALID_PAGE => "Ошибка: страницы не существует.";
use constant S_STOP_FOOLING => "Lass das sein, Kevin!";

use constant S_TOOBIG => 'Это изображение слишком велико. Добавь что-то поменьше.';
use constant S_TOOBIGORNONE => 'Либо это изображение слишком велико либо изображения нет вообще. Такие дела.';
use constant S_REPORTERR => 'Ошибка: не удается найти ответ.';
use constant S_UPFAIL => 'Ошибка: Сбой при загрузке.';
use constant S_NOREC => 'Ошибка: Не удается найти запись.';
use constant S_NOCAPTCHA => 'Ошибка: Капча протухла, so slow';
use constant S_BADCAPTCHA => 'Ошибка: Неверно введена капча';
use constant S_BADFORMAT => 'Ошибка: Формат файла не поддерживается.';
use constant S_STRREF => 'Ошибка: строка отклонена.';
use constant S_UNJUST => 'Ошибка: неверное сообщение.';
use constant S_NOPIC => 'Ошибка: Файл не выбран. Вы забыли нажать на кнопку "Ответить"?';
use constant S_NOTEXT => 'Ошибка: Текст не введен';
use constant S_TOOLONG => 'Ошибка: Слишком много символов в текстовом поле.';
use constant S_NOTALLOWED => 'Ошибка: Сообщения без изображений запрещены.';
use constant S_NONEWTHREADS => 'Ошибка: Нельзя создавать новые треды.';
use constant S_UNUSUAL => 'Ошибка: Неверный ответ.';
use constant S_BADHOST => 'Ошибка: хост забанен.';
use constant S_BADHOSTPROXY => 'Ошибка: прокси забанен.';
use constant S_RENZOKU => 'Ошибка: Обнаружен флуд, сообщение отклонено.';
use constant S_RENZOKU2 => 'Ошибка: Обнаружен флуд, файл отклонён.';
use constant S_RENZOKU3 => 'Ошибка: Обнаружен флуд.';
use constant S_RENZOKU4 => 'Ошибка: Период ожидания удаления поста еще не истек.';
use constant S_RENZOKU5 => 'Ошибка: Обнаружен флуд. Жди 10 минут.';
use constant S_PROXY => 'Ошибка: Обнаружена открытая прокси.';
use constant S_DUPE => 'Ошибка: Этот файл уже размещен <a href="%s">тут</a>.';
use constant S_DUPENAME => 'Ошибка: файл с таким же именем уже существует.';
use constant S_NOTHREADERR => 'Ошибка: Тред не существует.';
use constant S_BADDELPASS => 'Неверный пароль для удаления.';
use constant S_WRONGPASS => 'Ошибка: Неверный пароль.';
use constant S_VIRUS => 'Ошибка: Возможно зараженный вирусом файл.';
use constant S_NOTWRITE => 'Ошибка: не удалось записать в директорию.';
use constant S_SPAM => 'Спамерам здесь не рады.';
use constant S_NOBOARDACC => 'You don\'t have access to this board, accessible: %s<br /><a href="%s?task=logout">Logout</a>';
use constant S_NOPRIVILEGES => 'Insufficient privileges';

use constant S_SQLCONF => 'MySQL-Database error'; # Database connection failure
use constant S_SQLFAIL => 'MySQL-Database error ufoporno'; # SQL Failure

use constant S_EDITPOST => 'Редактировать';
use constant S_EDITHEAD => 'Editing No.<a href="%s">%d</a>';
use constant S_UPDATE => 'Update';

use constant S_REDIR =>
  'If the redirect didn\'t work, please choose one of the following mirrors:'
  ;    # Redir message for html in REDIR_DIR

use constant S_DNSBL =>
  'Error: TOR nodes are not allowed!';    # error string for tor node check

1;

