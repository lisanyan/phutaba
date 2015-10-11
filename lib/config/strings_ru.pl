use utf8;
my %translation;

$translation{S_HOME} = 'Домой';           # Forwards to home page
$translation{S_ADMIN} = 'А';         # Forwards to Management Panel
$translation{S_RETURN} = 'Назад';    # Returns to image board
$translation{S_POSTING} = 'Ответ';    # Prints message in red bar atop the reply screen

$translation{S_NAME} = 'Имя';           # Describes name field
$translation{S_EMAIL} = 'E-Mail';         # Describes e-mail field
$translation{S_SUBJECT} = 'Тема';        # Describes subject field
$translation{S_SUBMIT} = 'Отправить';     # Describes submit button
$translation{S_COMMENT} = 'Текст';      # Describes comment field
$translation{S_UPLOADFILE} = 'Файлы';          # Describes file field
$translation{S_NOFILE} = 'Без файла';    # Describes file/no file checkbox
$translation{S_CAPTCHA} = 'Капча';        # Describes captcha field
$translation{S_PARENT} = 'Тред No.';    # Describes parent field on admin post page
$translation{S_DELPASS} = 'Пароль';    # Describes password field
$translation{S_DELEXPL} =
  ' (для удаления поста и файлов)';    # Prints explanation for password box (to the right)
$translation{S_SPAMTRAP} = '';
$translation{S_ALLOWED} = 'Allowed file formats (max. %s or given)';

$translation{S_THUMB} = '';    # Prints instructions for viewing real source
$translation{S_HIDDEN} =
  '';    # Prints instructions for viewing hidden image reply
$translation{S_NOTHUMB} =
  'Нет миниатюры';    # Printed when there's no thumbnail
$translation{S_PICNAME} = '';             # Prints text before upload name/link
$translation{S_REPLY} = 'Ответ';    # Prints text for reply link
$translation{S_OLD} = 'Помечено для удаления (old).'; 
  # Prints text to be displayed before post is marked for deletion, see: retention

$translation{S_HIDE} = 'Скрыть тред %d';

$translation{S_ABBR1} = '1 Сообщение ';       # Prints text to be shown when replies are hidden
$translation{S_ABBR2} = '%d сообщений ';
$translation{S_ABBRIMG1} = 'и 1 файл ';   # Prints text to be shown when replies and files are hidden
$translation{S_ABBRIMG2} = 'и %d файлов ';
$translation{S_ABBR_END} = 'скрыто.'; 

$translation{S_ABBRTEXT1} = 'Раскрыть пост полностью (+1 строка)';
$translation{S_ABBRTEXT2} = 'Раскрыть пост полностью (+%d строк)';

$translation{S_BANNED} = '<p class="ban">(User was banned for this post)</p>';

$translation{S_REPDEL} = ' ';    # Prints text next to S_DELPICONLY (left)
$translation{S_DELPICONLY} = '';    # Prints text next to checkbox for file deletion (right)
$translation{S_DELKEY} = 'Пароль ';    # Prints text next to password field for deletion (left)
$translation{S_DELETE} = 'Удалить';    # Defines deletion button's name

$translation{S_PREV} = 'Предыдущая';    # Defines previous button
$translation{S_FIRSTPG} = 'Предыдущая';    # Defines previous button
$translation{S_NEXT} = 'Следующая';            # Defines next button
$translation{S_LASTPG} = 'Следующая';            # Defines next button
$translation{S_TOP} = 'Вверх';
$translation{S_BOTTOM} = 'Вниз'; 

$translation{S_SEARCHTITLE} = 'Поиск';
$translation{S_SEARCH} = 'Поиск';
$translation{S_SEARCHCOMMENT} = 'Поиск по комментарию';
$translation{S_SEARCHSUBJECT} = 'Поиск по теме';
$translation{S_SEARCHFILES} = 'Поиск по имени файла';
$translation{S_SEARCHOP} = 'Искать только в оп-постах';
$translation{S_SEARCHSUBMIT} = 'Поиск';
$translation{S_SEARCHFOUND} = 'Найдено:';
$translation{S_OPTIONS} = 'Опции';
$translation{S_MINLENGTH} = '(мин. 3 символа)';

$translation{S_DATENAMES} = {
  weekdays => [qw/Вс Пн Вт Ср Чт Пт Сб/], # Defines abbreviated weekday names.
  months => [qw/Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь/] # Defines full month names
};

$translation{S_STICKYTITLE} = 'Тред прикреплен';    # Defines the title of the tiny sticky image on a thread if it is sticky
$translation{S_LOCKEDTITLE} = 'Тред закрыт';    # Defines the title of the tiny locked image on a thread if it is locked

# javascript message strings (do not use HTML entities; mask single quotes with \\\')
$translation{S_JS_EXPAND} = 'Expand textfield';
$translation{S_JS_SHRINK} = 'Shrink textfield';
$translation{S_JS_REMOVEFILE} = 'Remove file';
$translation{S_JS_STYLES} = 'Стили';
$translation{S_JS_DONE} = 'Готово';
$translation{S_JS_CONTEXT} = 'Свистоперделки';
$translation{S_JS_UPDATE} = 'Обновить тред';
$translation{S_JS_BOTTOMFORM} = 'Форма внизу';
# javascript strings END

$translation{S_MANARET} = 'Назад';    # Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
$translation{S_MANAMODE} = 'Управление';   # Prints heading on top of Manager page

$translation{S_MANALOGIN} = 'Логин'
; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_ADMINPASS} = 'Пароль:';    # Prints login prompt

$translation{S_MANAPANEL} = 'Посты'
; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_MANATOOLS} = 'Инструменты';
$translation{S_MANAGEOINFO} = 'GeoIP-Information';
$translation{S_MANABANS} = 'Баны';         # Defines Bans Panel button
$translation{S_MANAPROXY} = 'Прокси';
$translation{S_MANAORPH} = 'Файлы-сироты';
$translation{S_MANALOGOUT} = 'Выход';
$translation{S_MANASAVE} = 'Запомнить';    # Defines Label for the login cookie checbox
$translation{S_MANASUB} = 'Го!';          # Defines name for submit button in Manager Mode
$translation{S_MANALOG} = 'Лог';

$translation{S_NOTAGS} = '<p>HTML tags are also possible. No WakabaMark.</p>';
               # Prints message on Management Board

$translation{S_POSTASADMIN} = 'Пост как админ';
$translation{S_NOTAGS2} = 'Не форматировать комментарий';
$translation{S_MPSETSAGE} = 'Toggle Sage';
$translation{S_MPUNSETSAGE} = 'Toggle Sage';

$translation{S_BTNEWTHREAD} = 'Создать новый тред';
$translation{S_BTREPLY} = 'Ответ на';
$translation{S_SAGE} = 'Sage';
$translation{S_SAGEDESC} = 'Не поднимать тред';
$translation{S_IMGEXPAND} = 'Увеличить поле';
$translation{S_NOKO} = 'Перейти к';
$translation{S_NOKOOFF} = 'доске';
$translation{S_NOKOON} = 'треду';

$translation{S_NOPOMF} = 'POMF';
$translation{S_NOPOMFDESC} = 'Не загружать файлы на внешний сервер';

$translation{S_THREADLOCKED} = '<strong>Тред %s</strong> закрыт. Вы не можете отвечать в этот тред.';
$translation{S_FILEINFO} = 'Информация';
$translation{S_FILEDELETED} = 'Файл удален';

$translation{S_POSTINFO} = 'Информация IP';
$translation{S_MPDELETEIP} = 'Уд.&nbsp;все';
$translation{S_MPDELETE} = 'Удалить';    # Defines for deletion button in Management Panel
$translation{S_MPEDIT} = 'Редактировать';    # Defines for deletion button in Management Panel
$translation{S_MPDELFILE} = 'Удалить файл';
$translation{S_MPARCHIVE} = 'Архив';
$translation{S_MPSTICKY} = 'Прикрепить';
$translation{S_MPUNSTICKY} = 'Открепить';
$translation{S_MPLOCK} = 'Закрыть';
$translation{S_MPUNLOCK} = 'Открыть';
$translation{S_MPRESET} = 'Сброс';        # Defines name for field reset button in Management Panel
$translation{S_MPONLYPIC} = 'Только файл';  # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPDELETEALL} = 'Удалить все посты с этого IP';    #
$translation{S_MPBAN} = 'Ban';    # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPTABLE} = '<th>No.</th><th>Дата</th><th>Тема</th>'
                        . '<th>Имя</th><th>Текст</th><th>IP</th>'; # Explains names for Management Panel
$translation{S_IMGSPACEUSAGE} = '[ Использовано места: %s, %s Файлов, %s Постов (%s Тредов) ]';
          # Prints space used KB by the board under Management Panel
$translation{S_DELALLMSG} = 'Затронуто';
$translation{S_DELALLCOUNT} = '%s Posts (%s Threads)';

$translation{S_BANFILTER} = 'Скрыть истекшие баны';
$translation{S_BANSHOWALL} = 'Показать истекшие баны';
$translation{S_BANTABLE} =
  '<th>Тип</th><th colspan="2">Значение</th><th>Текст</th><th>Дата</th><th>Истекает</th><th>Действие</th>';
            # Explains names for Ban Panel
$translation{S_BANIPLABEL} = 'IP';
$translation{S_BANMASKLABEL} = 'Маска';
$translation{S_BANCOMMENTLABEL} = 'Текст';
$translation{S_BANWORDLABEL} = 'Слово';
$translation{S_BANIP} = 'IP бан';
$translation{S_BANWORD} = 'Бан слова';
$translation{S_BANWHITELIST} = 'Белый список';
$translation{S_BANREMOVE} = 'Удалить';
$translation{S_BANEDIT} = 'Ред';
$translation{S_BANCOMMENT} = 'Комментарий';
$translation{S_BANTRUST} = 'Без капчи';
$translation{S_BANTRUSTTRIP} = 'Трипкод';
$translation{S_BANEXPIRESLABEL} = 'Истекает';
$translation{S_BANEXPIRESDESC} = 'Example: 5 Days, 10 Hours, 30 Minutes<br />Permaban - leave field empty';
$translation{S_BANREASONLABEL} = 'Причина';
$translation{S_BANASNUMLABEL} = 'AS-Nummer';
$translation{S_BANASNUM} = 'Бан сети';
$translation{S_BANSECONDS} = 'Секунды';

$translation{S_ORPHTABLE} = '<th>Ссылка</th><th>Файл</th><th>Дата изменения</th><th>Размер</th>';
$translation{S_MANASHOW} = 'Show';

$translation{S_LOCKED} = 'Тред закрыт';
$translation{S_BADIP} = 'Неправильный IP адрес';
$translation{S_BADDELIP} = 'Неправильный IP.'; # Returns error for wrong ip (when user tries to delete file)
$translation{S_INVALID_PAGE} = "страницы не существует.";
$translation{S_STOP_FOOLING} = "Lass das sein, Kevin!";

$translation{S_TOOBIG} = 'Это изображение слишком велико. Добавь что-то поменьше.';
$translation{S_TOOBIGORNONE} = 'Либо это изображение слишком велико либо изображения нет вообще. Такие дела.';
$translation{S_REPORTERR} = 'Не удается найти ответ.';
$translation{S_UPFAIL} = 'Сбой при загрузке.';
$translation{S_NOREC} = 'Не удается найти запись.';
$translation{S_NOCAPTCHA} = 'Капча протухла, so slow';
$translation{S_BADCAPTCHA} = 'Неверно введена капча';
$translation{S_BADFORMAT} = 'Формат файла не поддерживается.';
$translation{S_STRREF} = 'Строка отклонена.';
$translation{S_UNJUST} = 'Не POST запрос.';
$translation{S_NOPIC} = 'Файл не выбран. Вы забыли нажать на кнопку "Ответить"?';
$translation{S_NOTEXT} = 'Текст не введен';
$translation{S_TOOLONG} = 'Слишком много символов в текстовом поле.';
$translation{S_NOTALLOWED} = 'Сообщения без изображений запрещены.';
$translation{S_NONEWTHREADS} = 'Нельзя создавать новые треды.';
$translation{S_UNUSUAL} = 'Неверный ответ.';
$translation{S_BADHOST} = 'Бан :&lt;';
$translation{S_BADHOSTPROXY} = 'Найдена прокси.';
$translation{S_RENZOKU} = 'Обнаружен флуд, сообщение отклонено.';
$translation{S_RENZOKU2} = 'Обнаружен флуд, файл отклонён.';
$translation{S_RENZOKU3} = 'Обнаружен флуд.';
$translation{S_RENZOKU4} = 'Период ожидания перед удалением поста еще не истек.';
$translation{S_RENZOKU5} = 'Обнаружен флуд. Жди 10 минут.';
$translation{S_PROXY} = 'Обнаружена открытая прокси.';
$translation{S_DUPE} = 'Этот файл уже размещен <a href="%s">тут</a>.';
$translation{S_DUPENAME} = 'файл с таким же именем уже существует.';
$translation{S_NOTHREADERR} = 'Тред не существует.';
$translation{S_BADDELPASS} = 'Неверный пароль для удаления.';
$translation{S_WRONGPASS} = 'Неверный пароль.';
$translation{S_VIRUS} = 'Возможно зараженный вирусом файл.';
$translation{S_NOTWRITE} = 'Не удалось записать в директорию.';
$translation{S_SPAM} = 'Спамерам здесь не рады.';
$translation{S_NOBOARDACC} = 'You don\'t have access to this board, accessible: %s<br /><a href="%s?task=logout">Logout</a>';
$translation{S_NOPRIVILEGES} = 'Insufficient privileges';

$translation{S_SQLCONF} = 'MySQL-Database connect error'; # Database connection failure
$translation{S_SQLFAIL} = 'MySQL-Database query error'; # SQL Failure

$translation{S_EDITPOST} = 'Редактировать';
$translation{S_EDITHEAD} = 'Editing No.<a href="%s">%d</a>';
$translation{S_UPDATE} = 'Update';

$translation{S_REDIR} =
  'If the redirect didn\'t work, please choose one of the following mirrors:'
  ;    # Redir message for html in REDIR_DIR

$translation{S_DNSBL} =
  # 'Error: TOR nodes are not allowed!';    # error string for tor node check
  'This IP was listed in <em>%s</em> blacklist!';

\%translation;
