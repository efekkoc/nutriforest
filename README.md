# 🌿 NutriForest — AI-Powered Gamified Calorie & Nutrition Tracker

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Google%20Gemini%20AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Hive%20DB-FFA000?style=for-the-badge&logo=hive&logoColor=white" alt="Hive" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-brightgreen?style=for-the-badge" alt="Platforms" />
</p>

---

## 🌟 Proje Özeti (Overview)

**NutriForest**, sağlıklı beslenme alışkanlığı kazanmayı eğlenceli ve sürdürülebilir hale getiren, **Google Gemini Yapay Zekası** ile güçlendirilmiş oyunlaştırılmış bir kalori ve besin takip uygulamasıdır. 

Kullanıcılar yedikleri yemeklerin fotoğrafını çekerek veya doğrudan sohbet gibi yazarak saniyeler içinde kalori ve makro besin (Protein, Karbonhidrat, Yağ) analizini alabilir. Günlük hedeflerinize uydukça adanızdaki ağaçlar büyür, ormanınız yeşillenir; hedefler aksatıldığında orman kurur. Sağlıklı yaşam artık sıkıcı bir tablo değil, yaşayan canlı bir ekosistem!

---

## ✨ Temel Özellikler (Key Features)

- 📸 **Gemini AI Fotoğraftan Yemek Tanıma:** Tabağınızın fotoğrafını çekin; Google Gemini Vision API yemeği, porsiyonunu, kalorilerini ve makrolarını anında otomatik analiz etsin.
- 💬 **Yapay Zeka Metin Analizi:** "2 dilim tam buğday ekmeği ve 1 haşlanmış yumurta yedim" yazın, yapay zeka porsiyonu ayrıştırıp doğrudan günlüğünüze eklesin.
- 🏝️ **Canlı Ada & Orman Oyunlaştırması (Living Forest Island):** Beslenme disiplininize göre yeşeren, çiçek açan veya yaprak döken interaktif ada tasarımı.
- 💧 **Akıllı Su Takibi (Hydration Tracker):** Günlük su tüketiminizi tek dokunuşla takip edin, hidrasyon hedefinize ulaştığınızda özel animasyonların tadını çıkarın.
- 📊 **Makro & Mikro Besin Dengesi:** Protein, karbonhidrat ve yağ oranlarınızı şık dinamik göstergelerle takip edin.
- 🏆 **Başarılar ve Rozetler (Achievements):** Hedeflerinize sadık kaldığınız her gün yeni rozetler ve unvanlar kazanın.
- 💾 **Çevrimdışı & Güvenli Depolama (Hive DB):** Verileriniz cihazınızda ultra hızlı NoSQL Hive veritabanında yerel olarak saklanır; internetiniz olmasa bile tüm geçmişinize erişebilirsiniz.
- 🎨 **Modern Glassmorphic Tasarım:** Akıcı animasyonlar, estetik renk paleti ve modern kullanıcı dostu arayüz.

---

## 🛠️ Kullanılan Teknolojiler (Tech Stack)

| Kategori | Teknoloji / Kütüphane | Açıklama |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) | Çapraz platform (iOS, Android, Web, Desktop) mobil geliştirme kiti |
| **Dil** | [Dart](https://dart.dev/) | Modern, güçlü tipli nesne yönelimli dil |
| **Yapay Zeka** | [Google Gemini API](https://ai.google.dev/) (2.0 Flash / 1.5 Flash) | Görsel ve metinsel besin & porsiyon analizi, akıllı diyetisyen tavsiyeleri |
| **State Management** | [Provider](https://pub.dev/packages/provider) | Reaktif ve modüler durum yönetimi |
| **Yerel Veritabanı** | [Hive & Hive Flutter](https://pub.dev/packages/hive) | Ultra hafif, hızlı anahtar-değer NoSQL yerel veritabanı |
| **Kamera & Görsel** | [Image Picker](https://pub.dev/packages/image_picker) | Galeri ve kameradan fotoğraf çekme entegrasyonu |
| **Tipografi & Tasarım** | [Google Fonts](https://pub.dev/packages/google_fonts) | Poppins fontları ve özel cam efektleri (Glassmorphism) |

---

## 🚀 Kurulum ve Çalıştırma (Getting Started)

Projeyi kendi bilgisayarınızda çalıştırmak için:

### Gereksinimler
- Flutter SDK (>= 3.3.0)
- Dart SDK (>= 3.12.0)
- [Google AI Studio](https://aistudio.google.com/)'dan ücretsiz bir Gemini API Anahtarı

### Adım Adım Kurulum

1. **Depoyu Klonlayın:**
   ```bash
   git clone https://github.com/efekkoc/nutriforest.git
   cd nutriforest
   ```

2. **Bağımlılıkları İndirin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı Başlatın:**
   ```bash
   flutter run
   ```

4. **Yapay Zeka API Anahtarını Tanımlama:**
   - Uygulama açıldığında sağ üstteki **Ayarlar (Settings)** simgesine dokunun.
   - [Google AI Studio](https://aistudio.google.com/)'dan aldığınız ücretsiz Gemini API anahtarınızı girip kaydedin. Artık yemek fotoğraflarınızı analiz etmeye hazırsınız!

---

## 👨‍💻 Geliştirici (Author)

**Turgut Efekan Koç**
- GitHub: [@efekkoc](https://github.com/efekkoc)

---

## 📄 Lisans (License)
Bu proje MIT lisansı altında korunmaktadır.
