# Google Play Market (Play Console) ga Chiqarish Bo'yicha To'liq Qo'llanma

Bu qo'llanma **M-IT Student Platform (M-IT ERP)** ilovasini Google Play Console orqali Play Marketga muvaffaqiyatli chiqarish uchun qadam-baqadam ko'rsatmalarni o'z ichiga oladi.

---

## 1. Ilova Asosiy Ma'lumotlari

- **Ilova Nomi (App Name):** M-IT ERP *(yoki M-IT Student Platform)*
- **Paket Nomi (Application ID):** `uz.mit.student`
- **Versiya:** `1.0.0` (Build: `1`)
- **Format:** Android App Bundle (`.aab`)

---

## 2. Imzo Kaliti (Upload Keystore) Yaratish

Google Play Console'ga yuklanadigan barcha ilovalar raqamli kalit bilan imzolanishi shart.

### 1-usul: Avtomatik skript orqali (Tavsiya etiladi)
Loyiha papkasidagi [`scripts/generate_keystore.bat`](file:///d:/M-IT/m_it_student_platform/scripts/generate_keystore.bat) faylini sichqoncha bilan 2 marta bosing va parollarni kiriting.

### 2-usul: Terminal (CMD / PowerShell) orqali
```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Sizdan parol va ism-sharifingiz so'raladi. Ushbu parollarni eslab qoling.*

---

## 3. `android/key.properties` Faylini Yaratish

`android/` papkasida **`key.properties`** faylini yarating va unga quyidagilarni yozing:

```properties
keyAlias=upload
keyPassword=SIZ_KIRITGAN_PAROL
storeFile=upload-keystore.jks
storePassword=SIZ_KIRITGAN_PAROL
```

> [!IMPORTANT]
> `upload-keystore.jks` va `key.properties` fayllari `.gitignore` ga kiritilgan. Bu fayllarni yo'qotib qo'ymang va zaxira nusxasini xavfsiz joyda saqlang (kelgusida ilovani yangilashda ushbu kalit kerak bo'ladi).

---

## 4. Release AppBundle (.aab) Faylini Yig'ish (Build)

Ilovani Google Play talab qiladigan eng so'nggi `.aab` formatida yig'ish uchun:

### 1-usul: Skript orqali
[`scripts/build_release_aab.bat`](file:///d:/M-IT/m_it_student_platform/scripts/build_release_aab.bat) faylini ishga tushiring.

### 2-usul: Terminal orqali
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Tayyor `.aab` fayli quyidagi manzilda hosil bo'ladi:
📁 `build/app/outputs/bundle/release/app-release.aab`

---

## 5. Google Play Console'da Dasturni Sozlash

1. [Google Play Console](https://play.google.com/console/) sahifasiga kiring.
2. **"Create app"** (Ilova yaratish) tugmasini bosing:
   - **App name:** `M-IT ERP`
   - **Default language:** `Uzbek` (yoki `English`)
   - **App or game:** `App`
   - **Free or paid:** `Free`
   - Deklaratsiyalarni belgilab, **Create app** ni bosing.

---

## 6. Do'kon Sahifasi (Store Listing) Ma'lumotlari

### Matnlar:
- **Short description (Qisqa tavsif - 80 belgi):**
  > M-IT o'quv markazi talabalari uchun darslar, davomat, to'lovlar va reyting tizimi.
- **Full description (To'liq tavsif):**
  > M-IT ERP — M-IT o'quv markazi talabalari va o'quvchilari uchun maxsus ishlab chiqilgan rasmiy mobil platforma.
  > 
  > Ilovaning asosiy imkoniyatlari:
  > - Darslar jadvali va xonalar ma'lumotlari
  > - Darslarga QR kod orqali davomat qilish
  > - Oylik to'lovlar holati va kvitansiyalar
  > - Uyga vazifalar va baholar monitoringi
  > - Guruh chatlari va e'lonlar
  > - Leaderboard va o'quvchilar reytingi

### Grafikalar:
- **App icon:** 512 x 512 px (32-bit PNG)
- **Feature graphic:** 1024 x 500 px (JPEG yoki 24-bit PNG)
- **Phone screenshots:** Kamida 2 ta (tavsiya: 4-6 ta) ekran rasmlari (1080 x 2400 px)

---

## 7. Ilova Xavfsizligi va Maxfiylik (App Content & Data Safety)

Play Console menyusidagi **"App content"** bo'limida quyidagilarni to'ldiring:

1. **Privacy Policy (Maxfiylik siyosati):**
   - Veb-sayt yoki GitHub Pages dagi maxfiylik siyosati havolasini kiriting (Masalan: `https://m-it.uz/privacy-policy` yoki `https://hojimurod0.github.io/privacy-policy`).
2. **App Access (Ilovaga kirish):**
   - *"All or some functionality is restricted"* ni tanlang va tekshiruvchilar (Google Reviewers) kirib ko'rishi uchun test hisob ma'lumotlarini taqdim eting (Masalan: Telefon: `+998901234567`, Parol: `123456`).
3. **Ads (Reklama):**
   - *"No, my app does not contain ads"*.
4. **Target Audience (Auditoriya):**
   - 13-15, 16-17, 18+ yosh toifalari.
5. **Data Safety (Ma'lumotlar xavfsizligi):**
   - **Personal info:** Name, Phone number (Hisobni identifikatsiya qilish va SMS kod uchun).
   - **Financial info:** User payment history (To'lovlar monitoringi uchun).
   - **Photos/Files:** Faqat foydalanuvchi vazifa yoki profil rasmini yuklaganda.
   - Barcha ma'lumotlar HTTPS orqali shifrlangan holda uzatiladi (*"Data is encrypted in transit"*).

---

## 8. Relizni Yuklash va Tekshiruvga Yuborish

1. Chap menyudan **"Production"** (yoki avval **"Internal testing"**) bo'limiga o'ting.
2. **"Create new release"** tugmasini bosing.
3. `build/app/outputs/bundle/release/app-release.aab` faylini yuklang.
4. **Release notes** ga yangiliklarni yozing (masalan: *"Dastlabki versiya: Darslar jadvali, to'lovlar va profil boshqaruvi"*).
5. **"Save"** va **"Review release"** tugmasini bosing.
6. **"Start rollout to Production"** tugmasi orqali Google tekshiruviga yuboring!

---
*M-IT Platform jamoasi tomonidan tayyorlandi.*
