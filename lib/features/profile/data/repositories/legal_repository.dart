import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/features/profile/domain/models/legal_document_model.dart';

class LegalRepository {
  LegalRepository({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  // In-memory cache for fast tab switching
  final Map<String, LegalDocumentModel> _cache = {};

  Future<LegalDocumentModel> getPrivacyPolicy({String? lang}) async {
    final languageCode = lang ?? LocalStorageService.getLanguage().name;
    final cacheKey = 'privacy_$languageCode';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final url = Uri.parse(
      '${AppConfig.baseUrl}${AppConfig.portalLegalPrivacyPolicy}?lang=$languageCode',
    );

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': languageCode,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final model = LegalDocumentModel.fromJson(decoded);
        _cache[cacheKey] = model;
        return model;
      }
    } catch (_) {}

    return _getFallbackPrivacyPolicy(languageCode);
  }

  Future<LegalDocumentModel> getTermsOfService({String? lang}) async {
    final languageCode = lang ?? LocalStorageService.getLanguage().name;
    final cacheKey = 'terms_$languageCode';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final url = Uri.parse(
      '${AppConfig.baseUrl}${AppConfig.portalLegalTermsOfService}?lang=$languageCode',
    );

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': languageCode,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final model = LegalDocumentModel.fromJson(decoded);
        _cache[cacheKey] = model;
        return model;
      }
    } catch (_) {}

    return _getFallbackTermsOfService(languageCode);
  }

  LegalDocumentModel _getFallbackPrivacyPolicy(String lang) {
    if (lang == 'ru') {
      return const LegalDocumentModel(
        title: 'Политика Конфиденциальности (Privacy Policy)',
        lastUpdated: '2026-08-31',
        summary: 'Настоящая Политика конфиденциальности определяет порядок сбора, использования и защиты персональных данных пользователей мобильного приложения и ERP системы JarvisX.',
        sections: [
          LegalSectionModel(
            heading: '1. Какие данные мы собираем?',
            content: 'Для функционирования системы собираются следующие данные:\n• Личные данные: Имя, фамилия, дата рождения, номер телефона.\n• Фото и Face ID: Фотография лица для автоматического учета посещаемости в учебном центре.\n• Учебный процесс: Группы, история посещений, баллы, домашние задания и оценки.\n• Финансы: История ежемесячных платежей, задолженности и квитанции.\n• Технические данные: Тип устройства, IP-адрес и FCM токены для Push-уведомлений.',
          ),
          LegalSectionModel(
            heading: '2. Цели использования данных',
            content: 'Собранные данные используются исключительно для:\n• Предоставления образовательных услуг и контроля качества обучения;\n• Уведомления родителей в Telegram о входе и выходе ребенка из учебного центра;\n• Расчета успеваемости и контрактных баллов;\n• Обеспечения безопасности и защиты от несанкционированного доступа.',
          ),
          LegalSectionModel(
            heading: '3. Безопасность и неразглашение данных',
            content: 'Персональные данные хранятся в зашифрованном виде на защищенных серверах. Мы не передаем и не продаем данные третьим лицам, за исключением случаев, предусмотренных законодательством.',
          ),
          LegalSectionModel(
            heading: '4. Права пользователя и Удаление аккаунта (Account Deletion)',
            content: 'Пользователь имеет право полностью управлять своими данными:\n• Прямо в приложении: Профиль -> Настройки -> «Удалить аккаунт» для мгновенного безвозвратного удаления.\n• Через внешний веб-ресурс: https://m-it-academy.jarvisx.uz/legal/privacy-policy/?lang=ru\n• Сохранение архивных записей: При удалении профиля личные данные стираются, а официальные академические сертификаты и финансовые квитанции сохраняются в архиве согласно законодательству об образовании.',
          ),
          LegalSectionModel(
            heading: '5. Контактная информация',
            content: 'По вопросам политики конфиденциальности вы можете обратиться к администрации учебного центра: info@mit-academy.uz | +998 71 200 00 00',
          ),
        ],
      );
    }

    if (lang == 'en') {
      return const LegalDocumentModel(
        title: 'Privacy Policy',
        lastUpdated: '2026-08-31',
        summary: 'This Privacy Policy governs the collection, use, and security of personal data in the JarvisX M-IT Student Platform.',
        sections: [
          LegalSectionModel(
            heading: '1. What Data Do We Collect?',
            content: 'The platform collects:\n• Personal Identifiers: Full name, date of birth, phone number, Student ID.\n• Photo & Face ID: Facial recognition for turnstile lab access control.\n• Academic Activity: Attendance history, grades, homework, and test scores.\n• Financial Records: Tuition payment history, balances, and receipts.\n• Technical Diagnostics: Device type, IP address, and FCM Push tokens.',
          ),
          LegalSectionModel(
            heading: '2. Purposes of Data Processing',
            content: 'Data is used solely for:\n• Delivering educational services and tracking academic progress;\n• Real-time Telegram alerts to parents regarding student check-in/check-out;\n• Transparent performance and contract score evaluation;\n• Security and preventing unauthorized account access.',
          ),
          LegalSectionModel(
            heading: '3. Data Security & Non-Disclosure',
            content: 'Data is transmitted over SSL/TLS encrypted channels and stored on secure servers. User data is never sold or shared with commercial entities.',
          ),
          LegalSectionModel(
            heading: '4. User Rights & Account Deletion',
            content: 'Users have full control over their personal data:\n• In-app deletion: Profile -> Settings -> "Delete Account" button.\n• External web deletion request: https://m-it-academy.jarvisx.uz/legal/privacy-policy/?lang=en\n• Retention: Upon deletion, personal profile and cache data are erased while certified academic diplomas and taxation payment receipts are retained in statutory archives.',
          ),
        ],
      );
    }

    // Default UZ
    return const LegalDocumentModel(
      title: 'Maxfiylik Siyosati (Privacy Policy)',
      lastUpdated: '2026-08-31',
      summary: 'Ushbu Maxfiylik siyosati JarvisX mobil ilovasi va ERP tizimi tomonidan foydalanuvchilarning shaxsiy ma\'lumotlarini qanday yig\'ilishi, ishlatilishi va himoya qilinishini belgilaydi.',
      sections: [
        LegalSectionModel(
          heading: '1. Qanday ma\'lumotlar to\'planadi?',
          content: 'Tizimdan to\'laqonli foydalanish uchun quyidagi ma\'lumotlar yig\'iladi:\n• Shaxsiy ma\'lumotlar: Ism, familiya, tug\'ilgan sana, telefon raqami.\n• Biometrik va tashqi ma\'lumotlar: O\'quv markazida davomatni avtomatlashtirish uchun yuz surati (Face ID / foto).\n• Ta\'lim jarayoni: Guruh nomi, davomat tarixi, darslardagi ballar, vazifa javoblari va baholar.\n• Moliya ma\'lumotlari: Oylik to\'lovlar, qarz va kvitansiyalar tarixi.\n• Texnik ma\'lumotlar: Qurilma turi, IP-manzil va Firebase Push xabarnomalari uchun FCM token.',
        ),
        LegalSectionModel(
          heading: '2. Ma\'lumotlardan qanday maqsadda foydalaniladi?',
          content: 'Yig\'ilgan barcha ma\'lumotlar faqat quyidagi maqsadlarda ishlatiladi:\n• O\'quv markazi xizmatlarini taqdim etish va ta\'lim sifatini monitoring qilish;\n• Ota-onalarga farzandining darsga kelganligi (check-in) yoki ketganligi (check-out) haqida Telegram orqali xabar yuborish;\n• O\'zlashtirish foizi va shartnoma ballarini shaffof hisoblab borish;\n• Xavfsizlikni ta\'minlash va tizimdagi ruxsatsiz harakatlarning oldini olish.',
        ),
        LegalSectionModel(
          heading: '3. Ma\'lumotlar xavfsizligi va uchinchi shaxslarga berilmasligi',
          content: 'Sizning shaxsiy ma\'lumotlaringiz shifrlangan holda xavfsiz serverlarda saqlanadi. Biz foydalanuvchilarning shaxsiy ma\'lumotlarini uchinchi tomonlarga sotmaymiz, ijaraga bermaymiz yoki tijoriy maqsadda ulashmaymiz (qonunchilikda belgilangan hollar bundan mustasno).',
        ),
        LegalSectionModel(
          heading: '4. Foydalanuvchi huquqlari va Hisobni o\'chirish (Account Deletion)',
          content: 'Foydalanuvchi o\'z ma\'lumotlarini boshqarish bo\'yicha to\'liq huquqlarga ega:\n• Ilova ichidan to\'g\'ridan-to\'g\'ri: Profil -> Sozlamalar -> "Hisobni o\'chirish" tugmasi orqali hisobni butunlay o\'chirish mumkin.\n• Veb-portal orqali: Ilovadan tashqari tashqi veb-resurs orqali o\'chirish so\'rovini yuborish: https://m-it-academy.jarvisx.uz/legal/privacy-policy/?lang=uz\n• Ma\'lumotlarni saqlash: Hisob o\'chirilganda shaxsiy akkaunt va kesh ma\'lumotlari o\'chiriladi, ta\'lim qonunchiligiga muvofiq rasmiy bitiruv sertifikatlari va to\'lov cheklari arxiv hisobida saqlanadi.',
        ),
        LegalSectionModel(
          heading: '5. Aloqa ma\'lumotlari',
          content: 'Maxfiylik siyosati bo\'yicha savollaringiz bo\'lsa, o\'quv markazingiz ma\'muriyatiga yoki qo\'llab-quvvatlash xizmatiga murojaat qilishingiz mumkin: info@mit-academy.uz | +998 71 200 00 00',
        ),
      ],
    );
  }

  LegalDocumentModel _getFallbackTermsOfService(String lang) {
    if (lang == 'ru') {
      return const LegalDocumentModel(
        title: 'Оферта и Условия Использования (Terms of Service)',
        lastUpdated: '2026-08-31',
        summary: 'Настоящий документ является публичной офертой об оказании образовательных услуг между учебным центром, студентом и родителем.',
        sections: [
          LegalSectionModel(
            heading: '1. Предмет договора',
            content: 'Учебный центр обязуется предоставить качественное обучение по выбранному направлению, а студент — регулярно посещать занятия и своевременно вносить ежемесячную оплату.',
          ),
          LegalSectionModel(
            heading: '2. Порядок ежемесячной оплаты',
            content: '• Ежемесячная сумма фиксируется при зачислении в группу и оплачивается до установленной даты каждого месяца.\n• Оплата принимается наличными, банковской картой или через онлайн платежные системы.\n• При несвоевременной оплате доступ к занятиям может быть временно ограничен.',
          ),
          LegalSectionModel(
            heading: '3. Система баллов и дисциплина',
            content: 'В центре действует контрактная система баллов и штрафов:\n• Своевременное посещение и активность: +5 баллов;\n• Отличное выполнение ДЗ: +10 баллов;\n• 1 неделя идеального посещения: +15 баллов;\n• Невыполнение ДЗ: -15 баллов;\n• Опоздание более 10 минут: -5 баллов;\n• Пропуск без причины: -20 баллов;\n• Нарушение дисциплины: -5 баллов.',
          ),
          LegalSectionModel(
            heading: '4. Права и обязанности',
            content: '• Центр обеспечивает квалифицированных преподавателей и оборудование.\n• Студент обязан бережно относиться к имуществу и соблюдать распорядок.\n• Студент имеет право подать жалобу руководству через приложение при несогласии с качеством.',
          ),
        ],
      );
    }

    return const LegalDocumentModel(
      title: 'Ommaviy Oferta va Foydalanish Shartlari (Terms of Service)',
      lastUpdated: '2026-08-31',
      summary: 'Ushbu hujjat o\'quv markazi xizmatlaridan foydalanish bo\'yicha o\'quvchi, ota-ona va o\'quv markaz o\'rtasidagi ommaviy oferta shartnomasi hisoblanadi.',
      sections: [
        LegalSectionModel(
          heading: '1. Shartnoma predmeti',
          content: 'O\'quv markaz o\'quvchiga tanlangan kurs va yo\'nalish bo\'yicha sifatli ta\'lim xizmatlarini ko\'rsatish, o\'quvchi esa darslarda muntazam qatnashish va belgilangan oylik to\'lovni o\'z vaqtida amalga oshirish majburiyatini oladi.',
        ),
        LegalSectionModel(
          heading: '2. Oylik to\'lov va hisob-kitob qoidalari',
          content: '• Oylik to\'lov summasi o\'quvchi guruhga biriktirilgan vaqtda belgilanadi va har oyning belgilangan sanasigacha to\'lanishi shart.\n• To\'lovlar naqd pul, bank kartasi yoki onlayn to\'lov tizimlari orqali qabul qilinadi.\n• O\'z vaqtida to\'lov qilinmaganda o\'quvchining tizimdagi faolligi va darslarga qatnashishi vaqtincha cheklanishi mumkin.',
        ),
        LegalSectionModel(
          heading: '3. Intizom, ballar va jarimalar tizimi',
          content: 'O\'quv markazida shartnomaga asoslangan ball/jarima tartibi amal qiladi:\n• Darsga o\'z vaqtida kelish va faol qatnashish: +5 ball;\n• Uyga vazifani mukammal bajarish: +10 ball;\n• 1 hafta namunali qatnashish: +15 ball;\n• Uyga vazifani bajarmaslik: -15 ball;\n• Darsga 10 minutdan ko\'p kechikish: -5 ball;\n• Sababsiz dars qoldirish: -20 ball;\n• Darsda tartib buzish: -5 ball.',
        ),
        LegalSectionModel(
          heading: '4. Tomonlarning huquq va majburiyatlari',
          content: '• O\'quv markaz malakali o\'qituvchilar va qulay o\'quv xonalarini ta\'minlaydi.\n• O\'quvchi markaz mulkiga ehtiyotkorona munosabatda bo\'lishi va ichki tartib-qoidalarga qat\'iy rioya qilishi lozim.\n• O\'quvchi dars sifatidan norozi bo\'lsa, mobil ilova orqali rahbariyatga shikoyat yuborish huquqiga ega.',
        ),
        LegalSectionModel(
          heading: '5. Yakuniy qoidalar',
          content: 'Mobil ilovada ro\'yxatdan o\'tish yoki tizimga kirish ushbu Oferta shartlarini to\'liq va so\'zsiz qabul qilish (aksept) hisoblanadi.',
        ),
      ],
    );
  }
}
