import 'package:m_it_student_platform/features/home/domain/models/ai_mentor_model.dart';

class AiMentorService {
  AiMentorService._();

  static AiMentorResponse generateAnswer(String query) {
    final clean = query.trim();
    if (clean.isEmpty) {
      return const AiMentorResponse(
        text: 'Savolingizni yozing, sizga dasturlash va o\'quv markaz darslari bo\'yicha yordam berishdan xursandman! 🚀',
        category: AiQueryCategory.general,
      );
    }

    final lower = clean.toLowerCase();

    // 1. Flutter State Management (BLoC, Provider, Riverpod, setState, Cubit, ValueNotifier)
    if (lower.contains('bloc') || lower.contains('blok') || lower.contains('cubit')) {
      return const AiMentorResponse(
        text: '### ⚡ Flutter BLoC Pattern Haqida\n\n'
            '**BLoC (Business Logic Component)** — bu Flutterda eng ko\'p ishlatiladigan professional State Management arxitekturasi bo\'lib, UI va biznes logikani bir-biridan to\'liq ajratadi.\n\n'
            '**Asosiy qismlari:**\n'
            '1. **Event**: Foydalanuvchi harakati (masalan: `FetchLessonsEvent`, `AddPaymentEvent`).\n'
            '2. **State**: UI holati (masalan: `LoadingState`, `LoadedState`, `ErrorState`).\n'
            '3. **Bloc**: Eventni qabul qilib, yangi State qaytaruvchi logika markazi.\n\n'
            '💡 **Tavsiya**: Yirik va jamoaviy loyihalarda BLoC kodni sinovdan o\'tkazish (testing) va masshtablash uchun idealdir!',
        category: AiQueryCategory.flutter,
        codeLanguage: 'dart',
        codeSnippet: '// 1. Event\n'
            'abstract class CounterEvent {}\n'
            'class IncrementEvent extends CounterEvent {}\n\n'
            '// 2. State\n'
            'class CounterState {\n'
            '  final int count;\n'
            '  CounterState(this.count);\n'
            '}\n\n'
            '// 3. Bloc\n'
            'class CounterBloc extends Bloc<CounterEvent, CounterState> {\n'
            '  CounterBloc() : super(CounterState(0)) {\n'
            '    on<IncrementEvent>((event, emit) {\n'
            '      emit(CounterState(state.count + 1));\n'
            '    });\n'
            '  }\n'
            '}',
        followUpPrompts: [
          'BLoC va Provider farqi nima?',
          'Cubit va Bloc farqi qanday?',
          'BlocBuilder va BlocListener farqi nima?',
        ],
      );
    }

    if (lower.contains('provider') || lower.contains('riverpod')) {
      return const AiMentorResponse(
        text: '### 📦 Provider va Riverpod Taqqoslashi\n\n'
            '**Provider**: Flutter jamoasi tomonidan tavsiya etilgan, `InheritedWidget` asosida ishlovchi yengil state management kutubxonasi.\n\n'
            '**Riverpod**: Provider muallifi (Remi Rousselet) tomonidan yaratilgan yangi avlod kutubxonasi. U `BuildContext`ga bog\'liq emas, compile-time xatoliklarni oldini oladi va auto-dispose xususiyatiga ega.\n\n'
            '🎯 **12-16 yoshli o\'quvchilar uchun maslahat**: Dastlab Provider bilan boshlab, keyin BLoC yoki Riverpodga o\'tish osonroq!',
        category: AiQueryCategory.flutter,
        codeLanguage: 'dart',
        codeSnippet: '// ChangeNotifierProvider misoli\n'
            'class StudentProvider extends ChangeNotifier {\n'
            '  int _score = 85;\n'
            '  int get score => _score;\n\n'
            '  void addBonus(int points) {\n'
            '    _score += points;\n'
            '    notifyListeners(); // UI ni yangilaydi\n'
            '  }\n'
            '}',
        followUpPrompts: [
          'ChangeNotifier nima vazifa bajaradi?',
          'BLoC ga o\'tish qachon kerak?',
        ],
      );
    }

    if (lower.contains('setstate') || lower.contains('stateless') || lower.contains('stateful')) {
      return const AiMentorResponse(
        text: '### 🔄 StatelessWidget vs StatefulWidget & setState()\n\n'
            '1. **StatelessWidget**: Ekranda o\'zgarmaydigan statik elementlar uchun (masalan: Logo, Matn, Ikonka).\n'
            '2. **StatefulWidget**: Foydalanuvchi harakati bilan o\'zgaradigan holatga ega vidjetlar (masalan: Forma kiritish, Timer, Hisoblagich).\n'
            '3. **`setState(() {})`**: Flutter freymvorkiga vidjet holati o\'zgarganini xabar qiladi va `build()` metodini qayta ishga tushiradi.\n\n'
            '⚠️ **Muhim qoida**: `setState()` ni `dispose()` chaqirilgandan keyin yoki asinxron jarayon tugagach vidjet `mounted` bo\'lmaganda chaqirmang!',
        category: AiQueryCategory.flutter,
        codeLanguage: 'dart',
        codeSnippet: 'if (mounted) {\n'
            '  setState(() {\n'
            '    _counter++;\n'
            '  });\n'
            '}',
        followUpPrompts: [
          'mounted nima uchun kerak?',
          'Widget lifecycle metodlari qanday?',
        ],
      );
    }

    // 2. Flutter UI Overflow & Layout Errors (RenderFlex, Column, Row, Expanded)
    if (lower.contains('overflow') ||
        lower.contains('renderflex') ||
        lower.contains('sariq qora') ||
        lower.contains('siqil') ||
        lower.contains('sigmayap')) {
      return const AiMentorResponse(
        text: '### 🛠️ RenderFlex Overflow Xatosini To\'g\'rilash\n\n'
            '**Sababi**: Vidjet o\'ziga ajratilgan ekrandan kattaroq joy egallaganda sariq-qora chiziqli `A RenderFlex overflowed by X pixels` xatosi chiqadi.\n\n'
            '**3 ta eng samarali yechim:**\n'
            '1. **`Expanded` / `Flexible`**: `Row` yoki `Column` ichidagi uzun matn yoki rasmni o\'rab oling.\n'
            '2. **`SingleChildScrollView`**: Katta vertikal shakllar yoki modallar uchun skroll qo\'shing.\n'
            '3. **`Wrap`**: Gorizontal elementlar ekranga sig\'masa, keyingi qatorga avtomatik tushiradi.',
        category: AiQueryCategory.debugging,
        codeLanguage: 'dart',
        codeSnippet: '// Matn sig\'may qolganda to\'g\'ri yozish:\n'
            'Row(\n'
            '  children: [\n'
            '    const Icon(Icons.star),\n'
            '    const SizedBox(width: 8),\n'
            '    Expanded(\n'
            '      child: Text(\n'
            '        "Juda uzun kurs nomi yoki xabar",\n'
            '        overflow: TextOverflow.ellipsis,\n'
            '      ),\n'
            '    ),\n'
            '  ],\n'
            ')',
        followUpPrompts: [
          'Expanded va Flexible farqi nima?',
          'ListView va SingleChildScrollView farqi?',
        ],
      );
    }

    // 3. Clean Architecture
    if (lower.contains('clean') || lower.contains('arxitektura') || lower.contains('qatlam')) {
      return const AiMentorResponse(
        text: '### 🏛️ Flutterda Clean Architecture Tuzilishi\n\n'
            'Clean Architecture dasturni bir-biriga qattiq bog\'lanmagan 3 asosiy qatlamga ajratadi:\n\n'
            '1. **Domain Layer (Yurak)**: `Entities`, `UseCases`, `Repository Interfaces`. Tashqi freymvorklarga bog\'liq emas.\n'
            '2. **Data Layer (Ma\'lumotlar)**: `Models (DTO)`, `DataSources (Remote API / Local DB)`, `Repository Implementations`.\n'
            '3. **Presentation Layer (Foydalanuvchi interfeysi)**: `Screens`, `Widgets`, `BLoC / State Notifiers`.\n\n'
            '🎯 **Foydasi**: Backend yoki bazani o\'zgartirganda UI ga ta\'sir qilmaydi!',
        category: AiQueryCategory.flutter,
        codeLanguage: 'dart',
        codeSnippet: '// Clean Architecture papkalar strukturasi:\n'
            'lib/\n'
            '├── core/           # Umumiy ranglar, mavzular, utils\n'
            '└── features/       # Funksiyalar (auth, lessons, payments)\n'
            '    ├── domain/     # entities, usecases, repositories (abstract)\n'
            '    ├── data/       # models, datasources, repo_impl\n'
            '    └── presentation/ # screens, widgets, controllers',
        followUpPrompts: [
          'UseCase nima va u nima uchun kerak?',
          'DTO (Data Transfer Object) nima?',
        ],
      );
    }

    // 4. Dart Null Safety (null, ?, !, late, required)
    if (lower.contains('null') || lower.contains('safety') || lower.contains('late') || lower.contains('xatolik')) {
      return const AiMentorResponse(
        text: '### 🛡️ Dart Sound Null Safety Qoidalari\n\n'
            'Dart Null Safety dasturlashda `NullPointerException` (null xatolari) ni deyarli 100% yo\'qotish uchun yaratilgan:\n\n'
            '1. **`String name`**: Hech qachon null bo\'la olmaydi.\n'
            '2. **`String? name`**: Null bo\'lishi mumkin (nullable).\n'
            '3. **`!` (bang operator)**: "Men aminman, bu qiymat null emas" deb kompilyatorga aytish (ehtiyotkorlik bilan ishlating!).\n'
            '4. **`??` (default operator)**: Agar qiymat null bo\'lsa, o\'rniga boshqa qiymat qo\'yish (masalan: `name ?? "Mehmon"`).\n'
            '5. **`late`**: Keyinroq `initState` yoki boshqa joyda qiymat berilishini va\'da qilish.',
        category: AiQueryCategory.dart,
        codeLanguage: 'dart',
        codeSnippet: 'String? userName;\n\n'
            '// 1. Xavfsiz tekshirish:\n'
            'String displayName = userName ?? "Noma\'lum o\'quvchi";\n\n'
            '// 2. Null-aware chaqiruv:\n'
            'int length = userName?.length ?? 0;\n\n'
            '// 3. late o\'zgaruvchi:\n'
            'late final AnimationController controller;',
        followUpPrompts: [
          'lateInitializationError qachon chiqadi?',
          'required kalit so\'zi nima vazifa bajaradi?',
        ],
      );
    }

    // 5. Dart Asinxronlik (Future, async, await, Stream)
    if (lower.contains('async') ||
        lower.contains('await') ||
        lower.contains('future') ||
        lower.contains('stream') ||
        lower.contains('asinxron')) {
      return const AiMentorResponse(
        text: '### ⏳ Dart Asinxron Dasturlash: Future va Stream\n\n'
            'Tarmoqdan ma\'lumot yuklash yoki fayl o\'qish vaqt talab qiladi. UI qotib qolmasligi uchun asinxron metodlar ishlatiladi:\n\n'
            '1. **`Future<T>`**: Kelajakda bir marta qaytadigan bitta natija (masalan: API dan profil ma\'lumotini olish).\n'
            '2. **`async / await`**: Asinxron kodni xuddi sinxron kabi oson va tartibli o\'qiladigan qiladi.\n'
            '3. **`Stream<T>`**: Vaqt davomida bir nechta ma\'lumotlar oqimi (masalan: real-vaqt chat xabarlari, sensorlar).\n'
            '4. **`FutureBuilder` va `StreamBuilder`**: Asinxron ma\'lumotlarni UI da avtomatik render qiluvchi vidjetlar.',
        category: AiQueryCategory.dart,
        codeLanguage: 'dart',
        codeSnippet: 'Future<StudentProfile> fetchProfile() async {\n'
            '  try {\n'
            '    final response = await http.get(Uri.parse("https://api.mit.uz/profile"));\n'
            '    if (response.statusCode == 200) {\n'
            '      return StudentProfile.fromJson(jsonDecode(response.body));\n'
            '    }\n'
            '    throw Exception("Yuklashda xatolik: \${response.statusCode}");\n'
            '  } catch (e) {\n'
            '    print("Xato: \$e");\n'
            '    rethrow;\n'
            '  }\n'
            '}',
        followUpPrompts: [
          'FutureBuilder qanday ishlatiladi?',
          'try-catch orqali xatolarni qanday ushlaymiz?',
        ],
      );
    }

    // 6. Python & Algorithms for Teens
    if (lower.contains('python') || lower.contains('algoritm') || lower.contains('pithon')) {
      return const AiMentorResponse(
        text: '### 🐍 Python va Algoritmlar (12-16 yoshlar uchun)\n\n'
            '**Python** — bu eng sodda, o\'qilishi qulay va sun\'iy intellekt (AI) hamda veb-dasturlashda yetakchi til!\n\n'
            '**Algoritm nima?** — bu ma\'lum bir masalani yechish uchun aniq ketma-ketlikdagi qadamlar to\'plami.\n\n'
            '**Muhim algoritmlar:**\n'
            '1. **Chiziqli qidiruv (Linear Search)**: Ro\'yxatni boshidan oxirigacha bittalab tekshirish.\n'
            '2. **Ikkilik qidiruv (Binary Search)**: Saralangan ro\'yxatni ikkiga bo\'lib juda tez topish (O(log n)).\n'
            '3. **Saralash (Sorting)**: Elementlarni o\'sish yoki kamayish tartibida joylashtirish.',
        category: AiQueryCategory.python,
        codeLanguage: 'python',
        codeSnippet: '# Ikkilik qidiruv (Binary Search) algoritmi\n'
            'def binary_search(arr, target):\n'
            '    low = 0\n'
            '    high = len(arr) - 1\n'
            '    while low <= high:\n'
            '        mid = (low + high) // 2\n'
            '        if arr[mid] == target:\n'
            '            return mid  # Topildi!\n'
            '        elif arr[mid] < target:\n'
            '            low = mid + 1\n'
            '        else:\n'
            '            high = mid - 1\n'
            '    return -1  # Topilmadi',
        followUpPrompts: [
          'Big-O notation nima?',
          'Python da ro\'yxatlar bilan ishlash qanday?',
        ],
      );
    }

    // 7. Web & Backend (HTML, CSS, JS, SQL, API)
    if (lower.contains('html') ||
        lower.contains('css') ||
        lower.contains('javascript') ||
        lower.contains('backend') ||
        lower.contains('sql') ||
        lower.contains('baza') ||
        lower.contains('database') ||
        lower.contains('api')) {
      return const AiMentorResponse(
        text: '### 🌐 Veb Dasturlash va Ma\'lumotlar Bazasi (SQL)\n\n'
            '1. **Frontend**: Foydalanuvchi ko\'radigan qism (HTML struktura, CSS bezak, JavaScript harakat).\n'
            '2. **Backend**: Serverdagi mantiq, hisob-kitoblar va xavfsizlik (Node.js, Python FastAPI, Go).\n'
            '3. **REST API**: Frontend va Backend o\'rtasidagi JSON formatidagi aloqa ko\'prigi (`GET`, `POST`, `PUT`, `DELETE`).\n'
            '4. **SQL Baza**: Ma\'lumotlarni jadvallarda tartibli saqlash (PostgreSQL, MySQL).',
        category: AiQueryCategory.backend,
        codeLanguage: 'sql',
        codeSnippet: '-- O\'quvchilar jadvalidan faol o\'quvchilarni olish:\n'
            'SELECT student_id, full_name, group_code, monthly_fee\n'
            'FROM students\n'
            'WHERE is_active = TRUE\n'
            'ORDER BY full_name ASC;',
        followUpPrompts: [
          'REST API va GraphQL farqi nima?',
          'SQL va NoSQL farqi qanday?',
        ],
      );
    }

    // 8. Git & GitHub
    if (lower.contains('git') || lower.contains('github') || lower.contains('commit') || lower.contains('push')) {
      return const AiMentorResponse(
        text: '### 🐙 Git va GitHub Buyruqlari Eslatmasi\n\n'
            'Git — bu kodingiz tarixini saqlab boruvchi versiya nazorati tizimi!\n\n'
            '**Har kuni ishlatiladigan buyruqlar:**\n'
            '1. `git status` — O\'zgartirilgan fayllarni ko\'rish.\n'
            '2. `git add .` — Barcha o\'zgarishlarni tayyorlash.\n'
            '3. `git commit -m "izoh"` — O\'zgarishlarni nomlab saqlash.\n'
            '4. `git push origin main` — GitHubga yuklash.\n'
            '5. `git pull origin main` — GitHubdagi eng so\'nggi kodni olish.',
        category: AiQueryCategory.git,
        codeLanguage: 'bash',
        codeSnippet: '# Kodingizni GitHubga yuklash ketma-ketligi:\n'
            'git add .\n'
            'git commit -m "feat: Uy vazifasi 3-modul yakunlandi"\n'
            'git push origin main',
        followUpPrompts: [
          'Git Branch qanday ochiladi?',
          'Merge conflict qanday to\'g\'rilanadi?',
        ],
      );
    }

    // 9. M-IT Academy, Groups, Schedule, Homework & Tuition
    if (lower.contains('markaz') ||
        lower.contains('dars') ||
        lower.contains('guruh') ||
        lower.contains('vazifa') ||
        lower.contains('to\'lov') ||
        lower.contains('tolov') ||
        lower.contains('xona') ||
        lower.contains('ustoz') ||
        lower.contains('mentor') ||
        lower.contains('abbos')) {
      return const AiMentorResponse(
        text: '### 🎓 M-IT O\'quv Markazi va Darslar Ma\'lumoti\n\n'
            '**Sizning kursingiz**: Flutter Mobile Bootcamp (Guruh: `FS-204`)\n'
            '👨‍🏫 **Asosiy mentor**: Abbos Qodirov (Senior Flutter Developer)\n'
            '📅 **Dars kunlari**: Seshanba - Payshanba - Shanba (14:00 - 16:00)\n'
            '🏢 **O\'quv xonasi**: 204-kompyuter laboratoriyasi\n\n'
            '💳 **To\'lov ma\'lumoti**:\n'
            '• Oylik to\'lov miqdori: **500 000 so\'m**\n'
            '• To\'lov holati: **To\'langan** (Joriy oy uchun qabul qilingan)\n'
            '• Keyingi to\'lov muddati: **1-Sentyabr, 2026**\n\n'
            '📝 **Uy vazifalari**: Ilovaning "Uy vazifalari" bo\'limidan GitHub repozitoriy havolangizni yuborishingiz mumkin!',
        category: AiQueryCategory.academy,
        followUpPrompts: [
          'Uy vazifamni qanday topshiraman?',
          'Kompyuter xonasini qanday band qilsam bo\'ladi?',
          'Kurs sertifikati qachon beriladi?',
        ],
      );
    }

    // 10. Greetings & Friendly Teen Encouragement
    if (lower.contains('salom') ||
        lower.contains('assalom') ||
        lower.contains('qalaysiz') ||
        lower.contains('qalesiz') ||
        lower.contains('yordam') ||
        lower.contains('hello') ||
        lower.contains('привет') ||
        lower.contains('rahmat')) {
      return const AiMentorResponse(
        text: 'Assalomu alaykum! Men M-IT O\'quv Markazining sun\'iy intellektli **AI Mentori**man! ⚡\n\n'
            'Sizga quyidagi sohalarda yordam bera olaman:\n'
            '• 📱 **Flutter & Dart**: Vidjetlar, BLoC/Provider, Null Safety, UI xatoliklarini to\'g\'rilash;\n'
            '• 🐍 **Python & Algoritmlar**: Masalalar yechish va mantiqiy fikrlash;\n'
            '• 🛠️ **Kod tekshirish**: Xatoliklarni topish va to\'g\'ri kod variantini ko\'rsatish;\n'
            '• 📚 **M-IT Darslari**: Dars jadvali, vazifalar va mentor tavsiyalari.\n\n'
            'Kodingizni yoki xohlagan dasturlash savolingizni yozing! 🚀',
        category: AiQueryCategory.general,
        followUpPrompts: [
          'BLoC va Provider farqi nima?',
          'RenderFlex overflow xatosini qanday tuzataman?',
          'Bugungi dars jadvalim qanday?',
        ],
      );
    }

    // 11. Intelligent Semantic General Fallback
    return AiMentorResponse(
      text: '### 💡 AI Mentor Tahlili va Maslahati\n\n'
          'Savolingiz: **"$clean"** bo\'yicha tahlil:\n\n'
          'Dasturlashda bu kabi masalalarni yechishda quyidagi 3 qadam tavsiya etiladi:\n'
          '1. **Muammoni kichik qismlarga bo\'ling**: Katta vazifani alohida funksiya va modullarga ajrating.\n'
          '2. **Toza kod (Clean Code) standartlariga rioya qiling**: O\'zgaruvchilarga tushunarli nom bering va qoidalarga amal qiling.\n'
          '3. **Xatolarni konsolda tekshiring**: Debugger yoki `print()` / `debugPrint()` orqali ma\'lumotlar oqimini kuzating.\n\n'
          'Agar aniq kod yozayotgan bo\'lsangiz, kodingizni yoki xatolik matnini shu yerga yuboring, uni birgalikda tahlil qilib to\'g\'rilaymiz! 👨‍💻✨',
      category: AiQueryCategory.general,
      followUpPrompts: [
        'Kodimdagi xatoni qanday topsam bo\'ladi?',
        'Flutterda eng yaxshi arxitektura qaysi?',
        'Uy vazifamni tekshirib bera olasizmi?',
      ],
    );
  }
}

class AiMentorResponse {
  const AiMentorResponse({
    required this.text,
    required this.category,
    this.codeSnippet,
    this.codeLanguage,
    this.followUpPrompts = const [],
  });

  final String text;
  final AiQueryCategory category;
  final String? codeSnippet;
  final String? codeLanguage;
  final List<String> followUpPrompts;
}
