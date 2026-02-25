import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'kaa': {
      // App
      'app_name': 'Gastronomic',
      'welcome': 'Qos keliníz',

      // Search & Navigation
      'find_restaurants': 'Restoranlardan izleń',
      'search_restaurants': 'Restoran yamasa taam izleń...',
      'search_hint': 'Restoran yamasa taam izleń...',
      'no_restaurants': 'Restoran tabılmadı',
      'all_restaurants': 'Barlıq restoranlar',
      'restaurants': 'Restoranlar',
      'natija': 'nátiyje',
      'list_view': 'Dizim',
      'nearby_restaurants': 'Jaqın atırapdaǵı restoranlar',
      'nearest_restaurants': 'Eń jaqın restoranlar',
      'no_restaurants_on_map': 'Kartada restoran tabılmadı',

      'banner_text': 'En\' jaqin bolg\'an Restoranlar',
      'view_map': 'Kartanı kóriw',

      // Status
      'open': 'Ashıq',
      'closed': 'Jabıq',
      'open_restaurants': 'Ashıq Restoranlar',

      // Menu Categories
      'menu': 'Menyu',
      'all_items': 'Barlıq',
      'hot_dishes': 'Issı taamlar',
      'salads': 'Salatlar',
      'desserts': 'Desertler',
      'drinks': 'Ishimlikler',

      // Navigation
      'home': 'Bas bet',
      'qr_scanner': 'QR Skaner',
      'settings': 'Sazlawlar',
      'scan': 'Skanerlew',

      // Settings
      'language': 'Til',
      'select_language': 'Til saylań',
      'about_app': 'Qollanba haqqında',
      'version_info': 'Versiya hám maǵlıwmat',
      'version': 'Versiya',
      'created': 'Jasalǵan',
      'project_partners': 'Joba hámkorları',
      'about_description': 'Bul qollanba Qaraqalpaqstan Respublikası turızm salayatın asırıw hám xızmet kórsetiw sıpatın jaqsılaw maqsetinde islep shıǵıldı.',

      // Actions
      'close': 'Jabıw',
      'skip': 'Ótkerip jiberiw',
      'next': 'Keyingi',
      'start': 'Baslaw',
      'retry': 'Qayta urınıw',
      'save': 'Saqlaw',
      'cancel': 'Bıykarlaw',
      'back': 'Artqa',

      // Location
      'enable_location': 'Jaylasıwdı qosıw',
      'location_description': 'Sizge eń jaqın restoranlarıdı kórsetiw ushın joylasıwıńızdı paydalanıwǵa ruxsat beriń.',
      'no_thanks': 'Kerek emes',
      'enable': 'Qosıw',

      // Internet & Errors
      'no_internet': 'Internet baylanısı joq',
      'check_internet': 'Qollanbanı paydalanıw ushın internet kerek.',
      'error_loading': 'Júklew qátelik',
      'nothing_found': 'Hesh nárse tabılmadı',
      'loading': 'Júklenip atır...',

      // QR Scanner
      'qr_scan_guide': 'QR kódti skanerlew ushın tuwrilan',
      'qr_code_found': 'QR kód tabıldı',
      'content': 'Mazmunı',
      'invalid_qr_code': 'QR kód durıs emes',
      'try_again': 'Qaytadan urınıp kóriń',
      'go_to_restaurant': 'Restoran betine',

      // Categories
      'popular_cafes': 'Eng\' zo\'r kafeler',
      'popular_cafes_subtitle': 'Mazmunli hám umıtılmas tag\'amlar maskenı',
      'popular_restaurants': 'Ommabop restoranlar',
      'popular_restaurants_subtitle': 'Mehmonlar tanlagan eng\' sara joylar',
      'fast_food': 'Street Food álemı',
      'fast_food_subtitle': 'Tezkor hám Dámlı',

      // Restaurant Details
      'address': 'Mánzil',
      'address_not_specified': 'Mánzil kórsetilmegen',
      'distance_unknown': 'Araqashıqlıq belgisiz',
      'location_unknown': 'Jaylasıw belgisiz',
      'phone': 'Telefon',
      'working_hours': 'Jumıs waqtı',
      'rating': 'Reytin',
      'reviews': 'Pikírler',
      'view_menu': 'Menyudi kóriw',
      'view_on_map': 'Kartada kóriw',
      'write_review': 'Pikír qaldırıw',

      // Reviews
      'restaurant': 'Restoran',
      'why_recommend': 'Bul jerdı nege usınıs etesiz?',
      'food_taste': 'Tagam hám tám',
      'service_price': 'Xızmet hám baha',
      'atmosphere': 'Ortaliq hám qolaylıq',
      'tag_large_portion': 'Úlken porsiya',
      'tag_fresh_ingredients': 'Taza ónimler',
      'tag_nice_decoration': 'Shırayıl bezew',
      'tag_delicious_food': 'Dámlí tagam',
      'leave_comment': 'Pikíríńizdi qaldırıń...',
      'submit_review': 'Pikír qaldırıw',
      'review_submitted': 'Pikíríńiz qabıl etildi!',
      'review_intro': 'Biz sizin qolaylıǵıńız hám tásirleríńiz haqqında qayǵıramız! Iltimas, vizitıńız haqqındaǵı pikiríńizdi bólisin. Bul birneshe minutqa ǵana waqtıńızdı aladi, biz sizge ne jaqsı kóringen hám ne jaqsılawǵa bolatugını biliw júda áhmiyetli.',
      'review_thanks': 'Ózińizdegi tájiriybe bóleskeniniz ushın raxmet! Sizdiń sebepińiz menen biz hár kún jaxsılanıp baramız. Sizdi qayta kútemiz!',

      // Low rating sections
      'low_rating_a_title': 'Sizge ne jaqpadı?',
      'low_rating_b_title': 'Ne narazılıqqa sebep boldı?',
      'low_rating_c_title': 'Neni jaqsılaw múmkin?',
      'low_a_slow_service': 'Aste xızmet',
      'low_a_rude_staff': 'Sipatsiz xizmet',
      'low_a_order_errors': 'Buyırtpada qáteler',
      'low_a_cleanliness': 'Jetkilikli tazalıq joq',
      'low_a_noisy': 'Shawqınlı ortaliq',
      'low_a_bad_lighting': 'Jaman qaraldi',
      'low_a_uncomfortable_seating': 'Qolaylı emes orınlıqlar',
      'low_b_food_quality': 'Taam/ishimlik: dámi',
      'low_b_wait_time': 'Taamdı kútiw waqtı',
      'low_b_staff_politeness': 'Xızmetkerdıń tájribesizligı',
      'low_b_atmosphere': 'Ortaliq ulıwma tásiri',
      'low_b_price_quality': 'Baha/sapaligqa qatnası',

      // High rating sections
      'high_rating_a_title': 'Sizge ne jaqtı?',
      'high_rating_b_title': 'Neni eslesiz?',
      'high_rating_c_title': 'Neni jaqsılaw múmkin edi?',
      'high_a_food_taste': 'Taamdıń dámı',
      'high_a_food_presentation': 'Taamdıń shırayıl bezewi',
      'high_a_polite_staff': 'Tájrıbelı xızmetkerler',
      'high_a_fast_service': 'Tez xızmet',
      'high_a_comfortable_atmosphere': 'Qolaylı ortaliq',
      'high_a_cleanliness': 'Tazalıq hám tartıplılık',
      'high_a_convenient_location': 'Qolaylı jay / interyer',

      // General questions
      'general_q1_title': 'Qanday kategoriyani ajratasiz?',
      'general_q2_title': 'Qaytadan kelesizbemi?',
      'general_q3_title': 'Qosimsha pikir qaldırıwdı qáleysizbe?',
      'visit_breakfast': 'Ertełı tamaq',
      'visit_lunch': 'Gúnortaǵı tamaq',
      'visit_dinner': 'Keshki tamaq',
      'visit_coffee': 'Kofe',
      'visit_dessert': 'Desert',
      'visit_other': 'Baskası',
      'return_yes': 'Áwet',
      'return_maybe': 'Múmkin',
      'return_no': 'Joq',
      'other': 'Baskası',
      'write_here_optional': 'Mında jazıń (ixtiyariy)...',

      // Review examples - Food & Taste
      'example_food_positive_1': 'Taam júda dámlí edi',
      'example_food_positive_2': 'Porsiyalar úlken',
      'example_food_positive_3': 'Taza ónimlerden tayarlanǵan',
      'example_food_negative_1': 'Taam suwıq edi',
      'example_food_negative_2': 'Porsiya kishi',
      'example_food_negative_3': 'Dám jaqpadı',

      // Review examples - Service & Price
      'example_service_positive_1': 'Xızmet tez hám sıpatlı',
      'example_service_positive_2': 'Bahalar qolaylı',
      'example_service_positive_3': 'Xızmetkerler dosane',
      'example_service_negative_1': 'Xızmet baǵır',
      'example_service_negative_2': 'Bahalar qımmat',
      'example_service_negative_3': 'Kóp kúttiw kerek boldı',

      // Review examples - Atmosphere
      'example_atmosphere_positive_1': 'Muhit shırayıl',
      'example_atmosphere_positive_2': 'Taza hám qolaylı',
      'example_atmosphere_positive_3': 'Orınlıqlar qolaylı',
      'example_atmosphere_negative_1': 'Shawqınlı',
      'example_atmosphere_negative_2': 'Tar joy',
      'example_atmosphere_negative_3': 'Tazalıq jaqpadı',
    },
    'uz': {
      // App
      'app_name': 'Gastronomic',
      'welcome': 'Xush kelibsiz',

      // Search & Navigation
      'find_restaurants': 'Restoranlarni toping',
      'search_restaurants': 'Restoran yoki taom izlang...',
      'search_hint': 'Restoran yoki taom izlang...',
      'no_restaurants': 'Restoran topilmadi',
      'all_restaurants': 'Barcha restoranlar',
      'restaurants': 'Restoranlar',
      'natija': 'natija',
      'list_view': 'Ro\'yxat',
      'nearby_restaurants': 'Yaqin atrofdagi restoranlar',
      'nearest_restaurants': 'Eng yaqin restoranlar',
      'no_restaurants_on_map': 'Xaritada restoran topilmadi',

      'banner_text': 'Eng yaqin bo\'lgan Restoranlar',
      'view_map': 'Xaritani ko\'rish',

      // Status
      'open': 'Ochiq',
      'closed': 'Yopiq',
      'open_restaurants': 'Ochiq Restoranlar',

      // Menu Categories
      'menu': 'Menyu',
      'all_items': 'Barchasi',
      'hot_dishes': 'Issiq taomlar',
      'salads': 'Salatlar',
      'desserts': 'Desertlar',
      'drinks': 'Ichimliklar',

      // Navigation
      'home': 'Bosh sahifa',
      'qr_scanner': 'QR Skaner',
      'settings': 'Sozlamalar',
      'scan': 'Skanerlash',

      // Settings
      'language': 'Til',
      'select_language': 'Tilni tanlang',
      'about_app': 'Ilova haqida',
      'version_info': 'Versiya va ma\'lumot',
      'version': 'Versiya',
      'created': 'Yaratilgan',
      'project_partners': 'Loyiha hamkorlari',
      'about_description': 'Ushbu ilova Qoraqalpog\'iston Respublikasi turizm salohiyatini oshirish va xizmat ko\'rsatish sifatini yaxshilash maqsadida ishlab chiqildi.',

      // Actions
      'close': 'Yopish',
      'skip': 'O\'tkazib yuborish',
      'next': 'Keyingi',
      'start': 'Boshlash',
      'retry': 'Qayta urinish',
      'save': 'Saqlash',
      'cancel': 'Bekor qilish',
      'back': 'Orqaga',

      // Location
      'enable_location': 'Joylashuvni yoqish',
      'location_description': 'Sizga eng yaqin restoranlarni ko\'rsatish uchun joylashuvingizni ishlatishga ruxsat bering.',
      'no_thanks': 'Kerak emas',
      'enable': 'Yoqish',

      // Internet & Errors
      'no_internet': 'Internet aloqasi yo\'q',
      'check_internet': 'Ilovani ishlatish uchun internet kerak.',
      'error_loading': 'Yuklashda xatolik',
      'nothing_found': 'Hech narsa topilmadi',
      'loading': 'Yuklanmoqda...',

      // QR Scanner
      'qr_scan_guide': 'QR kodni skanerlash uchun yo\'naltiring',
      'qr_code_found': 'QR kod topildi',
      'content': 'Mazmuni',
      'invalid_qr_code': 'QR kod noto\'g\'ri',
      'try_again': 'Qaytadan urinib ko\'ring',
      'go_to_restaurant': 'Restoran sahifasiga',

      // Categories
      'popular_cafes': 'Eng zo\'r kafelar',
      'popular_cafes_subtitle': 'Maroqli hordiq va unutilmas ta\'mlar maskani',
      'popular_restaurants': 'Ommabop restoranlar',
      'popular_restaurants_subtitle': 'Mehmonlar tanlagan eng sara joylar',
      'fast_food': 'Street Food olami',
      'fast_food_subtitle': 'Tezkor va Mazali',

      // Restaurant Details
      'address': 'Manzil',
      'address_not_specified': 'Manzil ko\'rsatilmagan',
      'distance_unknown': 'Masofa noma\'lum',
      'location_unknown': 'Joylashuv noma\'lum',
      'phone': 'Telefon',
      'working_hours': 'Ish vaqti',
      'rating': 'Reyting',
      'reviews': 'Sharhlar',
      'view_menu': 'Menyuni ko\'rish',
      'view_on_map': 'Xaritada ko\'rish',
      'write_review': 'Sharh qoldirish',

      // Reviews
      'restaurant': 'Restoran',
      'why_recommend': 'Bu joyni nega tavsiya qilasiz?',
      'food_taste': 'Taom va mazasi',
      'service_price': 'Xizmat va narx',
      'atmosphere': 'Muhit va qulaylik',
      'tag_large_portion': 'Katta porsiya',
      'tag_fresh_ingredients': 'Yangi mahsulotlar',
      'tag_nice_decoration': 'Chiroyli bezak',
      'tag_delicious_food': 'Mazali taom',
      'leave_comment': 'Sharhingizni qoldiring...',
      'submit_review': 'Sharh qoldirish',
      'review_submitted': 'Sharhingiz qabul qilindi!',
      'review_intro': 'Biz sizning qulayligingiz va taassurotlaringiz haqida qayg\'uramiz! Iltimos, tashrifingiz haqidagi fikringizni baham ko\'ring. Bu atigi bir necha daqiqangizni oladi, va bizga nima yoqqani va nima yaxshilanishi mumkinligini bilish juda muhim.',
      'review_thanks': 'Tajribangizni baham ko\'rganingiz uchun rahmat! Sizning tufaylingizda biz har kuni yaxshilanib boramiz. Sizni yana kutamiz!',

      // Low rating sections
      'low_rating_a_title': 'Sizga nima yoqmadi?',
      'low_rating_b_title': 'Nima norozilikka sabab bo\'ldi?',
      'low_rating_c_title': 'Nima yaxshilanishi mumkin?',
      'low_a_slow_service': 'Sekin xizmat',
      'low_a_rude_staff': 'Qo\'pol yoki e\'tiborsiz xodimlar',
      'low_a_order_errors': 'Buyurtmada xatolar',
      'low_a_cleanliness': 'Yetarli tozalik yo\'q',
      'low_a_noisy': 'Shovqinli muhit',
      'low_a_bad_lighting': 'Yomon yoritish',
      'low_a_uncomfortable_seating': 'Noqulay o\'rindiqlar',
      'low_b_food_quality': 'Taom/ichimlik: maza, sifat, harorat',
      'low_b_wait_time': 'Taomni kutish vaqti',
      'low_b_staff_politeness': 'Ofitsiantning muomalasi',
      'low_b_atmosphere': 'Muhitning umumiy taassuroti',
      'low_b_price_quality': 'Narx/sifat nisbati',

      // High rating sections
      'high_rating_a_title': 'Sizga nima yoqdi?',
      'high_rating_b_title': 'Ayniqsa nima esda qoldi?',
      'high_rating_c_title': 'Nima yaxshilanishi mumkin edi?',
      'high_a_food_taste': 'Taomning mazzasi',
      'high_a_food_presentation': 'Taomning go\'zal bezatilishi',
      'high_a_polite_staff': 'Muloyim va e\'tiborli xodimlar',
      'high_a_fast_service': 'Tez xizmat ko\'rsatish',
      'high_a_comfortable_atmosphere': 'Qulay muhit',
      'high_a_cleanliness': 'Tozalik va tartib',
      'high_a_convenient_location': 'Qulay joylashuv / interyer',

      // General questions
      'general_q1_title': 'Qanday kategoriyani ajratib ko\'rsatasiz?',
      'general_q2_title': 'Bu restoranga yana kelasizmi?',
      'general_q3_title': 'Qo\'shimcha izoh qoldirishni xohlaysizmi?',
      'visit_breakfast': 'Nonushta',
      'visit_lunch': 'Tushlik',
      'visit_dinner': 'Kechki ovqat',
      'visit_coffee': 'Kofe',
      'visit_dessert': 'Desert',
      'visit_other': 'Boshqa',
      'return_yes': 'Ha',
      'return_maybe': 'Ehtimol',
      'return_no': 'Yo\'q',
      'other': 'Boshqa',
      'write_here_optional': 'Bu yerga yozing (ixtiyoriy)...',

      // Review examples - Food & Taste
      'example_food_positive_1': 'Taom juda mazali edi',
      'example_food_positive_2': 'Porsiyalar katta',
      'example_food_positive_3': 'Yangi mahsulotlardan tayyorlangan',
      'example_food_negative_1': 'Taom sovuq edi',
      'example_food_negative_2': 'Porsiya kichik',
      'example_food_negative_3': 'Maza yoqmadi',

      // Review examples - Service & Price
      'example_service_positive_1': 'Xizmat tez va sifatli',
      'example_service_positive_2': 'Narxlar qulay',
      'example_service_positive_3': 'Xodimlar do\'stona',
      'example_service_negative_1': 'Xizmat sekin',
      'example_service_negative_2': 'Narxlar qimmat',
      'example_service_negative_3': 'Ko\'p kutish kerak bo\'ldi',

      // Review examples - Atmosphere
      'example_atmosphere_positive_1': 'Muhit chiroyli',
      'example_atmosphere_positive_2': 'Toza va qulay',
      'example_atmosphere_positive_3': 'O\'rindiqlar qulay',
      'example_atmosphere_negative_1': 'Shovqinli',
      'example_atmosphere_negative_2': 'Tor joy',
      'example_atmosphere_negative_3': 'Tozalik yoqmadi',
    },
    'ru': {
      // App
      'app_name': 'Gastronomic',
      'welcome': 'Добро пожаловать',

      // Search & Navigation
      'find_restaurants': 'Найдите рестораны',
      'search_restaurants': 'Поиск ресторанов...',
      'search_hint': 'Ресторан или блюдо...',
      'no_restaurants': 'Рестораны не найдены',
      'all_restaurants': 'Все рестораны',
      'restaurants': 'Рестораны',
      'natija': 'результат',
      'list_view': 'Список',
      'nearby_restaurants': 'Рестораны поблизости',
      'nearest_restaurants': 'Ближайшие рестораны',
      'no_restaurants_on_map': 'Рестораны на карте не найдены',

      // Status
      'open': 'Открыто',
      'closed': 'Закрыто',
      'open_restaurants': 'Открытые Рестораны',

      // Menu Categories
      'menu': 'Меню',
      'all_items': 'Все',
      'hot_dishes': 'Горячие блюда',
      'salads': 'Салаты',
      'desserts': 'Десерты',
      'drinks': 'Напитки',

      // Navigation
      'home': 'Главная',
      'qr_scanner': 'QR Сканер',
      'settings': 'Настройки',
      'scan': 'Сканировать',

      // Settings
      'language': 'Язык',
      'select_language': 'Выберите язык',
      'about_app': 'О приложении',
      'version_info': 'Версия и информация',
      'version': 'Версия',
      'created': 'Создано',
      'project_partners': 'Партнёры проекта',
      'about_description': 'Это приложение разработано для повышения туристического потенциала Республики Каракалпакстан и улучшения качества обслуживания.',

      // Actions
      'close': 'Закрыть',
      'skip': 'Пропустить',
      'next': 'Далее',
      'start': 'Начать',
      'retry': 'Повторить',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'back': 'Назад',

      // Location
      'enable_location': 'Включить геолокацию',
      'location_description': 'Разрешите использовать ваше местоположение, чтобы показать ближайшие рестораны.',
      'no_thanks': 'Не нужно',
      'enable': 'Включить',

      'banner_text': 'Ближайшие рестораны',
      'view_map': 'Открыть карту',

      // Internet & Errors
      'no_internet': 'Нет интернета',
      'check_internet': 'Для использования приложения требуется интернет.',
      'error_loading': 'Ошибка загрузки',
      'nothing_found': 'Ничего не найдено',
      'loading': 'Загрузка...',

      // QR Scanner
      'qr_scan_guide': 'Наведите на QR код для сканирования',
      'qr_code_found': 'QR код найден',
      'content': 'Содержание',
      'invalid_qr_code': 'Неверный QR код',
      'try_again': 'Попробуйте ещё раз',
      'go_to_restaurant': 'На страницу ресторана',

      // Categories
      'popular_cafes': 'Лучшие кафе',
      'popular_cafes_subtitle': 'Уютный отдых и незабываемые вкусы',
      'popular_restaurants': 'Популярные рестораны',
      'popular_restaurants_subtitle': 'Лучшие места по выбору гостей',
      'fast_food': 'Мир Street Food',
      'fast_food_subtitle': 'Быстро и вкусно',

      // Restaurant Details
      'address': 'Адрес',
      'address_not_specified': 'Адрес не указан',
      'distance_unknown': 'Расстояние неизвестно',
      'location_unknown': 'Местоположение неизвестно',
      'phone': 'Телефон',
      'working_hours': 'Время работы',
      'rating': 'Рейтинг',
      'reviews': 'Отзывы',
      'view_menu': 'Посмотреть меню',
      'view_on_map': 'На карте',
      'write_review': 'Написать отзыв',

      // Reviews
      'restaurant': 'Ресторан',
      'why_recommend': 'Почему вы рекомендуете это место?',
      'food_taste': 'Еда и вкус',
      'service_price': 'Сервис и цены',
      'atmosphere': 'Атмосфера и комфорт',
      'tag_large_portion': 'Большие порции',
      'tag_fresh_ingredients': 'Свежие продукты',
      'tag_nice_decoration': 'Красивая подача',
      'tag_delicious_food': 'Вкусная еда',
      'leave_comment': 'Оставьте комментарий...',
      'submit_review': 'Оставить отзыв',
      'review_submitted': 'Ваш отзыв принят!',
      'review_intro': 'Мы заботимся о вашем комфорте и впечатлениях! Поделитесь, пожалуйста, своим мнением о вашем визите. Это займёт всего пару минут, а нам очень важно знать, что вам понравилось, а что можно улучшить.',
      'review_thanks': 'Спасибо, что поделились своим опытом! Благодаря вам мы можем становиться лучше каждый день. Ждём вас снова!',

      // Low rating sections
      'low_rating_a_title': 'Что вам не понравилось?',
      'low_rating_b_title': 'Что конкретно вызвало недовольство?',
      'low_rating_c_title': 'Что можно улучшить?',
      'low_a_slow_service': 'Медленное обслуживание',
      'low_a_rude_staff': 'Грубый или невнимательный персонал',
      'low_a_order_errors': 'Ошибки в заказе',
      'low_a_cleanliness': 'Недостаточная чистота (зал, стол, туалет)',
      'low_a_noisy': 'Шумная атмосфера (музыка, другие гости)',
      'low_a_bad_lighting': 'Плохое освещение',
      'low_a_uncomfortable_seating': 'Неудобная посадка или расположение столов',
      'low_b_food_quality': 'Еда / напитки: вкус, качество, температура',
      'low_b_wait_time': 'Время ожидания блюд',
      'low_b_staff_politeness': 'Вежливость официанта',
      'low_b_atmosphere': 'Общее впечатление от атмосферы',
      'low_b_price_quality': 'Соотношение цена/качество',

      // High rating sections
      'high_rating_a_title': 'Что вам понравилось?',
      'high_rating_b_title': 'Что особенно запомнилось?',
      'high_rating_c_title': 'Что можно было бы улучшить?',
      'high_a_food_taste': 'Вкус блюд',
      'high_a_food_presentation': 'Красивое оформление блюд',
      'high_a_polite_staff': 'Вежливый и внимательный персонал',
      'high_a_fast_service': 'Быстрое обслуживание',
      'high_a_comfortable_atmosphere': 'Комфортная атмосфера',
      'high_a_cleanliness': 'Чистота и порядок',
      'high_a_convenient_location': 'Удобное расположение / интерьер',

      // General questions
      'general_q1_title': 'Какую категорию вы бы выделили?',
      'general_q2_title': 'Вернётесь ли вы снова?',
      'general_q3_title': 'Хотите оставить дополнительные комментарии?',
      'visit_breakfast': 'Завтрак',
      'visit_lunch': 'Ланч',
      'visit_dinner': 'Ужин',
      'visit_coffee': 'Кофе',
      'visit_dessert': 'Десерт',
      'visit_other': 'Другое',
      'return_yes': 'Да',
      'return_maybe': 'Возможно',
      'return_no': 'Нет',
      'other': 'Другое',
      'write_here_optional': 'Напишите здесь (опционально)...',

      // Review examples - Food & Taste
      'example_food_positive_1': 'Еда очень вкусная',
      'example_food_positive_2': 'Большие порции',
      'example_food_positive_3': 'Из свежих продуктов',
      'example_food_negative_1': 'Еда была холодной',
      'example_food_negative_2': 'Маленькая порция',
      'example_food_negative_3': 'Вкус не понравился',

      // Review examples - Service & Price
      'example_service_positive_1': 'Быстрое и качественное обслуживание',
      'example_service_positive_2': 'Доступные цены',
      'example_service_positive_3': 'Дружелюбный персонал',
      'example_service_negative_1': 'Медленное обслуживание',
      'example_service_negative_2': 'Дорогие цены',
      'example_service_negative_3': 'Долго ждали',

      // Review examples - Atmosphere
      'example_atmosphere_positive_1': 'Красивая атмосфера',
      'example_atmosphere_positive_2': 'Чисто и уютно',
      'example_atmosphere_positive_3': 'Удобные места',
      'example_atmosphere_negative_1': 'Шумно',
      'example_atmosphere_negative_2': 'Тесное место',
      'example_atmosphere_negative_3': 'Не понравилась чистота',
    },
    'en': {
      // App
      'app_name': 'Gastronomic',
      'welcome': 'Welcome',

      // Search & Navigation
      'find_restaurants': 'Find restaurants',
      'search_restaurants': 'Search restaurants...',
      'search_hint': 'Restaurant or dish...',
      'no_restaurants': 'No restaurants found',
      'all_restaurants': 'All restaurants',
      'restaurants': 'Restaurants',
      'natija': 'results',
      'list_view': 'List',
      'nearby_restaurants': 'Nearby restaurants',
      'nearest_restaurants': 'Nearest restaurants',
      'no_restaurants_on_map': 'No restaurants found on map',

      // Status
      'open': 'Open',
      'closed': 'Closed',
      'open_restaurants': 'Open Restaurants',

      // Menu Categories
      'menu': 'Menu',
      'all_items': 'All',
      'hot_dishes': 'Hot Dishes',
      'salads': 'Salads',
      'desserts': 'Desserts',
      'drinks': 'Drinks',

      // Navigation
      'home': 'Home',
      'qr_scanner': 'QR Scanner',
      'settings': 'Settings',
      'scan': 'Scan',

      'banner_text': 'Nearest restaurants',
      'view_map': 'View Map',

      // Settings
      'language': 'Language',
      'select_language': 'Select language',
      'about_app': 'About App',
      'version_info': 'Version & Info',
      'version': 'Version',
      'created': 'Created',
      'project_partners': 'Project Partners',
      'about_description': 'This app was developed to enhance the tourism potential of the Republic of Karakalpakstan and improve service quality.',

      // Actions
      'close': 'Close',
      'skip': 'Skip',
      'next': 'Next',
      'start': 'Start',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'back': 'Back',

      // Location
      'enable_location': 'Enable Location',
      'location_description': 'Allow us to use your location to show you the nearest restaurants.',
      'no_thanks': 'No thanks',
      'enable': 'Enable',

      // Internet & Errors
      'no_internet': 'No Internet Connection',
      'check_internet': 'Internet connection is required to use the app.',
      'error_loading': 'Error loading',
      'nothing_found': 'Nothing found',
      'loading': 'Loading...',

      // QR Scanner
      'qr_scan_guide': 'Point at QR code to scan',
      'qr_code_found': 'QR code found',
      'content': 'Content',
      'invalid_qr_code': 'Invalid QR code',
      'try_again': 'Please try again',
      'go_to_restaurant': 'Go to restaurant',

      // Categories
      'popular_cafes': 'Best Cafes',
      'popular_cafes_subtitle': 'Cozy relaxation and unforgettable flavors',
      'popular_restaurants': 'Popular Restaurants',
      'popular_restaurants_subtitle': 'Top places chosen by guests',
      'fast_food': 'Street Food World',
      'fast_food_subtitle': 'Fast and Delicious',

      // Restaurant Details
      'address': 'Address',
      'address_not_specified': 'Address not specified',
      'distance_unknown': 'Distance unknown',
      'location_unknown': 'Location unknown',
      'phone': 'Phone',
      'working_hours': 'Working hours',
      'rating': 'Rating',
      'reviews': 'Reviews',
      'view_menu': 'View menu',
      'view_on_map': 'View on map',
      'write_review': 'Write review',

      // Reviews
      'restaurant': 'Restaurant',
      'why_recommend': 'Why do you recommend this place?',
      'food_taste': 'Food & Taste',
      'service_price': 'Service & Price',
      'atmosphere': 'Atmosphere & Comfort',
      'tag_large_portion': 'Large portions',
      'tag_fresh_ingredients': 'Fresh ingredients',
      'tag_nice_decoration': 'Nice decoration',
      'tag_delicious_food': 'Delicious food',
      'leave_comment': 'Leave your comment...',
      'submit_review': 'Submit review',
      'review_submitted': 'Your review has been submitted!',
      'review_intro': 'We care about your comfort and experience! Please share your opinion about your visit. It will only take a couple of minutes, and it\'s very important for us to know what you liked and what can be improved.',
      'review_thanks': 'Thank you for sharing your experience! Thanks to you, we can get better every day. We look forward to seeing you again!',

      // Low rating sections
      'low_rating_a_title': 'What didn\'t you like?',
      'low_rating_b_title': 'What specifically caused dissatisfaction?',
      'low_rating_c_title': 'What can be improved?',
      'low_a_slow_service': 'Slow service',
      'low_a_rude_staff': 'Rude or inattentive staff',
      'low_a_order_errors': 'Order errors',
      'low_a_cleanliness': 'Insufficient cleanliness (hall, table, restroom)',
      'low_a_noisy': 'Noisy atmosphere (music, other guests)',
      'low_a_bad_lighting': 'Poor lighting',
      'low_a_uncomfortable_seating': 'Uncomfortable seating or table layout',
      'low_b_food_quality': 'Food / drinks: taste, quality, temperature',
      'low_b_wait_time': 'Wait time for dishes',
      'low_b_staff_politeness': 'Waiter\'s politeness',
      'low_b_atmosphere': 'Overall impression of the atmosphere',
      'low_b_price_quality': 'Price/quality ratio',

      // High rating sections
      'high_rating_a_title': 'What did you like?',
      'high_rating_b_title': 'What was especially memorable?',
      'high_rating_c_title': 'What could be improved?',
      'high_a_food_taste': 'Food taste',
      'high_a_food_presentation': 'Beautiful food presentation',
      'high_a_polite_staff': 'Polite and attentive staff',
      'high_a_fast_service': 'Fast service',
      'high_a_comfortable_atmosphere': 'Comfortable atmosphere',
      'high_a_cleanliness': 'Cleanliness and order',
      'high_a_convenient_location': 'Convenient location / interior',

      // General questions
      'general_q1_title': 'What category would you highlight?',
      'general_q2_title': 'Will you visit again?',
      'general_q3_title': 'Would you like to leave additional comments?',
      'visit_breakfast': 'Breakfast',
      'visit_lunch': 'Lunch',
      'visit_dinner': 'Dinner',
      'visit_coffee': 'Coffee',
      'visit_dessert': 'Dessert',
      'visit_other': 'Other',
      'return_yes': 'Yes',
      'return_maybe': 'Maybe',
      'return_no': 'No',
      'other': 'Other',
      'write_here_optional': 'Write here (optional)...',

      // Review examples - Food & Taste
      'example_food_positive_1': 'The food was delicious',
      'example_food_positive_2': 'Large portions',
      'example_food_positive_3': 'Made with fresh ingredients',
      'example_food_negative_1': 'Food was cold',
      'example_food_negative_2': 'Small portion',
      'example_food_negative_3': 'Didn\'t like the taste',

      // Review examples - Service & Price
      'example_service_positive_1': 'Fast and quality service',
      'example_service_positive_2': 'Affordable prices',
      'example_service_positive_3': 'Friendly staff',
      'example_service_negative_1': 'Slow service',
      'example_service_negative_2': 'Expensive prices',
      'example_service_negative_3': 'Had to wait too long',

      // Review examples - Atmosphere
      'example_atmosphere_positive_1': 'Beautiful atmosphere',
      'example_atmosphere_positive_2': 'Clean and cozy',
      'example_atmosphere_positive_3': 'Comfortable seating',
      'example_atmosphere_negative_1': 'Too noisy',
      'example_atmosphere_negative_2': 'Cramped space',
      'example_atmosphere_negative_3': 'Cleanliness could be better',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
           _localizedValues['kaa']?[key] ??
           key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['kaa', 'uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}