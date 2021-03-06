Процедура Инициализация() Экспорт
	
	Если НЕ СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Создаем пользователя информационной базы Помощник
	ПользовательИнформационнойБазыПомощник = ПользователиИнформационнойБазы.НайтиПоИмени("Помощник");
	Если ПользовательИнформационнойБазыПомощник = Неопределено Тогда
		
		ПользовательИнформационнойБазыПомощник = ПользователиИнформационнойБазы.СоздатьПользователя();
		ПользовательИнформационнойБазыПомощник.Имя = "Помощник";
		ПользовательИнформационнойБазыПомощник.ПолноеИмя = "Помощник";
		ПользовательИнформационнойБазыПомощник.ПоказыватьВСпискеВыбора = Ложь;
		ПользовательИнформационнойБазыПомощник.Роли.Добавить(Метаданные.Роли.Помощник);
		ПользовательИнформационнойБазыПомощник.Записать();
		
	КонецЕсли;
	
	Попытка
		
		ИдентификаторПользователяСистемыВзаимодействияПомощник =
			СистемаВзаимодействия.ПолучитьИдентификаторПользователя(ПользовательИнформационнойБазыПомощник.УникальныйИдентификатор);
		
	Исключение		
		
		ПользовательСистемыВзаимодействияПомощник = СистемаВзаимодействия.СоздатьПользователя(ПользовательИнформационнойБазыПомощник);
		ПользовательСистемыВзаимодействияПомощник.Записать();
		
	КонецПопытки;
	
	
	// Создаем пользователей системы взаимодействия
	Для Каждого ПользовательИБ ИЗ ПользователиИнформационнойБазы.ПолучитьПользователей() Цикл	
		
		Если ПользовательИБ.Роли.Содержит(Метаданные.Роли.Администратор) ИЛИ
			 ПользовательИБ.Роли.Содержит(Метаданные.Роли.МенеджерПоЗакупкам) ИЛИ
			 ПользовательИБ.Роли.Содержит(Метаданные.Роли.МенеджерПоПродажам) ИЛИ
			 ПользовательИБ.Роли.Содержит(Метаданные.Роли.Продавец)
		Тогда
			
			Попытка
				
				ИдентификаторПользователяСистемыВзаимодействия =
					СистемаВзаимодействия.ПолучитьИдентификаторПользователя(ПользовательИБ.УникальныйИдентификатор);
				ПользовательСистемыВзаимодействия = 
					СистемаВзаимодействия.ПолучитьПользователя(ИдентификаторПользователяСистемыВзаимодействия);
				
			Исключение		
					
				ПользовательСистемыВзаимодействия = СистемаВзаимодействия.СоздатьПользователя(ПользовательИБ);
				ПользовательСистемыВзаимодействия.Записать();
				
			КонецПопытки;
		
		КонецЕсли;
		
	КонецЦикла;
	
	// Обсуждение для неотработанных заказов
	Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждение("НеотработанныеЗаказы");
	Если Обсуждение = Неопределено Тогда
	
		// Если не найдено, создаем новое
		Обсуждение = СистемаВзаимодействия.СоздатьОбсуждение();
		Обсуждение.Заголовок = НСтр("ru = 'Неотработанные заказы'", "ru");
		Обсуждение.Ключ = "НеотработанныеЗаказы";
		
		Обсуждение.Участники.Добавить(ИдентификаторПользователяСистемыВзаимодействияПомощник);
		
		Для Каждого ПользовательИБ ИЗ ПользователиИнформационнойБазы.ПолучитьПользователей() Цикл	
		
			Если ПользовательИБ.Роли.Содержит(Метаданные.Роли.Администратор) ИЛИ
				 ПользовательИБ.Роли.Содержит(Метаданные.Роли.МенеджерПоПродажам)
			Тогда
		
				ИдентификаторПользователяСистемыВзаимодействия = 
					СистемаВзаимодействия.ПолучитьИдентификаторПользователя(ПользовательИБ.УникальныйИдентификатор);
					
				Если НЕ Обсуждение.Участники.Содержит(ИдентификаторПользователяСистемыВзаимодействия) Тогда
					
					Обсуждение.Участники.Добавить(ИдентификаторПользователяСистемыВзаимодействия);
					
				КонецЕсли;
			
			КонецЕсли;
		
		КонецЦикла;
		
		Обсуждение.Записать();
		
	КонецЕсли;
	
	// Включаем регламентные задания
	Задание = РегламентныеЗадания.НайтиПредопределенное("ПомощникНеотработанныеЗаказы");
	Задание.Использование = Истина;
	Задание.ИмяПользователя = "Помощник";
	Задание.Записать();
	
	// Записываем приветственное сообщение
	ПериодПроверки = Константы.ПериодПроверкиНеотработанныхЗаказов.Получить();
	Если ПериодПроверки = 0 Тогда
		
		ПериодПроверки = 30;

	КонецЕсли;
	
	Текст = НСтр("ru = 'Добро пожаловать в обсуждения!'", "ru") + Символы.ПС +
	        НСтр("ru = 'В этом обсуждении помощник будет сообщать раз в '", "ru") +
			СтрокаСЧислом(НСтр("ru = ';%1 день;;%1 дня;%1 дней;%1 дня'", "ru"), Задание.Расписание.ПериодПовтораДней, ВидЧисловогоЗначения.Количественное) +
	        НСтр("ru = ' о заказах, которые не закрыты более '", "ru") +
			СтрокаСЧислом(НСтр("ru = ';%1 дня;;%1 дней;%1 дней;%1 дней'", "ru"), ПериодПроверки, ВидЧисловогоЗначения.Количественное);
	
	Сообщение = СистемаВзаимодействия.СоздатьСообщение(Обсуждение.Идентификатор);
	Сообщение.Автор = ИдентификаторПользователяСистемыВзаимодействияПомощник;
	Сообщение.Текст = Новый ФорматированнаяСтрока(Текст);
	Сообщение.Действия.Добавить("Settings", НСтр("ru = 'Настройка'", "ru"));
	Сообщение.Действия.Добавить("CheckNow", НСтр("ru = 'Проверить сейчас'", "ru"));
	Сообщение.Записать();
	
КонецПроцедуры

Процедура Отключение() Экспорт
	
	// Отключаем регламентные задания
	Задание = РегламентныеЗадания.НайтиПредопределенное("ПомощникНеотработанныеЗаказы");
	Задание.Использование = Ложь;
	Задание.Записать();

КонецПроцедуры

Процедура ПомощникНеотработанныеЗаказы() Экспорт
	
	Если НЕ СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована() Тогда
		Возврат;
	КонецЕсли;
	
	Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждение("НеотработанныеЗаказы");
	Если Обсуждение = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	// Выбираем заказы
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Заказ.Ссылка КАК Ссылка,
	               |	Заказ.Сумма КАК Сумма,
	               |	Заказ.Покупатель КАК Покупатель
	               |ИЗ
	               |	Документ.Заказ КАК Заказ
	               |ГДЕ
	               |	Заказ.ПометкаУдаления = ЛОЖЬ
	               |	И Заказ.СостояниеЗаказа <> ЗНАЧЕНИЕ(Перечисление.СостоянияЗаказов.Закрыт)
	               |	И Заказ.СостояниеЗаказа <> ЗНАЧЕНИЕ(Перечисление.СостоянияЗаказов.Выполнен)
	               |	И Заказ.Дата < &Дата
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	Заказ.Дата";
	
	ПериодПроверки = Константы.ПериодПроверкиНеотработанныхЗаказов.Получить();
	Если ПериодПроверки = 0 Тогда
		
		ПериодПроверки = 30;

	КонецЕсли;
	
	Запрос.УстановитьПараметр("Дата", НачалоДня(ТекущаяДата()) - ПериодПроверки * 24 * 60 * 60);

	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ПользовательИнформационнойБазыПомощник = ПользователиИнформационнойБазы.НайтиПоИмени("Помощник");
	ИдентификаторПользователяСистемыВзаимодействияПомощник =
		СистемаВзаимодействия.ПолучитьИдентификаторПользователя(ПользовательИнформационнойБазыПомощник.УникальныйИдентификатор);
		
	Сообщение = СистемаВзаимодействия.СоздатьСообщение(Обсуждение.Идентификатор);
	Сообщение.Автор = ИдентификаторПользователяСистемыВзаимодействияПомощник;
	Текст = НСтр("ru = 'Заказы, незакрытые более '", "ru") +
		СтрокаСЧислом(НСтр("ru = ';%1 дня;;%1 дней;%1 дней;%1 дней'", "ru"), ПериодПроверки, ВидЧисловогоЗначения.Количественное);
	
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Текст = Текст + Символы.ПС;
		Текст = Текст + ПолучитьНавигационнуюСсылку(Выборка.Ссылка) +
		        " (" + НСтр("ru = 'Сумма: '", "ru") + Формат(Выборка.Сумма, "ЧДЦ=2") +
		        "  " + НСтр("ru = 'Покупатель: '", "ru") + ПолучитьНавигационнуюСсылку(Выборка.Покупатель) + ")";
		
	КонецЦикла;
	
	Сообщение.Текст = Новый ФорматированнаяСтрока(Текст);
	Сообщение.Действия.Добавить("Settings", НСтр("ru = 'Настройка'", "ru"));
	Сообщение.Действия.Добавить("CheckNow", НСтр("ru = 'Проверить сейчас'", "ru"));
	Сообщение.Записать();
	
КонецПроцедуры

Процедура ИзменениеНастройки() Экспорт
	
	Если НЕ СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждение("НеотработанныеЗаказы");
	Если Обсуждение = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПериодПроверки = Константы.ПериодПроверкиНеотработанныхЗаказов.Получить();
	Если ПериодПроверки = 0 Тогда
		
		ПериодПроверки = 30;

	КонецЕсли;
	
	Задание = РегламентныеЗадания.НайтиПредопределенное("ПомощникНеотработанныеЗаказы");
	
	ПользовательИнформационнойБазыПомощник = ПользователиИнформационнойБазы.НайтиПоИмени("Помощник");
	ИдентификаторПользователяСистемыВзаимодействияПомощник =
		СистемаВзаимодействия.ПолучитьИдентификаторПользователя(ПользовательИнформационнойБазыПомощник.УникальныйИдентификатор);
		
		
	Текст = НСтр("ru = 'Помощник будет сообщать раз в '", "ru") +
			СтрокаСЧислом(НСтр("ru = ';%1 день;;%1 дня;%1 дней;%1 дня'", "ru"), Задание.Расписание.ПериодПовтораДней, ВидЧисловогоЗначения.Количественное) +
	        НСтр("ru = ' о заказах, которые не закрыты более '", "ru") +
			СтрокаСЧислом(НСтр("ru = ';%1 дня;;%1 дней;%1 дней;%1 дней'", "ru"), ПериодПроверки, ВидЧисловогоЗначения.Количественное);
	
	Сообщение = СистемаВзаимодействия.СоздатьСообщение(Обсуждение.Идентификатор);
	Сообщение.Автор = ИдентификаторПользователяСистемыВзаимодействияПомощник;
	Сообщение.Текст = Новый ФорматированнаяСтрока(Текст);
	Сообщение.Действия.Добавить("Settings", НСтр("ru = 'Настройка'", "ru"));
	Сообщение.Действия.Добавить("CheckNow", НСтр("ru = 'Проверить сейчас'", "ru"));
	Сообщение.Записать();
	
КонецПроцедуры

Процедура ДобавитьФайлКТовару(Ссылка, Адрес, ИмяФайла, УстановитьКартинку) Экспорт
	
	ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
	ХранимыйФайл.Владелец = Ссылка;
	ХранимыйФайл.Наименование = ИмяФайла;
	ХранимыйФайл.ИмяФайла = ИмяФайла;
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(Адрес);
	ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
	ХранимыйФайл.Записать(); 

	Если УстановитьКартинку Тогда
		Объект = Ссылка.ПолучитьОбъект();
		Объект.ФайлКартинки = ХранимыйФайл.Ссылка;
		Объект.Записать();
	КонецЕсли;
	
КонецПроцедуры