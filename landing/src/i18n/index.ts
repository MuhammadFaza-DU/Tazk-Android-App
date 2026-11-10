export type Lang = "id" | "en";

export interface NavItem {
  label: string;
  href: string;
}
export interface IconItem {
  title: string;
  body: string;
}
export interface FeatureItem extends IconItem {
  icon: string;
}
export interface FaqItem {
  q: string;
  a: string;
}

export interface Copy {
  metaTitle: string;
  metaDescription: string;
  skip: string;
  nav: NavItem[];
  themeToggle: string;
  langSwitch: string;
  ctaDownload: string;
  ctaSeeFeatures: string;
  hero: {
    eyebrow: string;
    title: string;
    lead: string;
    chips: string[];
    phoneLabel: string;
    phoneSub: string;
  };
  proofs: {
    title: string;
    items: IconItem[];
  };
  features: {
    eyebrow: string;
    title: string;
    lead: string;
    items: FeatureItem[];
  };
  tints: {
    eyebrow: string;
    title: string;
    items: IconItem[];
  };
  steps: {
    eyebrow: string;
    title: string;
    lead: string;
    items: IconItem[];
  };
  faq: {
    eyebrow: string;
    title: string;
    lead: string;
    items: FaqItem[];
  };
  download: {
    title: string;
    lead: string;
    apkNote: string;
    checksumLabel: string;
    cta: string;
  };
  footer: {
    tagline: string;
    links: NavItem[];
    copyright: string;
    madeWith: string;
  };
}

const id: Copy = {
  metaTitle: "Tazk · Selesai lebih tenang",
  metaDescription:
    "Aplikasi tugas, habit, dan sesi fokus untuk Android. Offline penuh, tanpa akun, dan data tersimpan di HP-mu.",
  skip: "Lewati ke konten",
  nav: [
    { label: "Fitur", href: "#fitur" },
    { label: "Cara pakai", href: "#cara-pakai" },
    { label: "FAQ", href: "#faq" },
  ],
  themeToggle: "Ganti tema terang atau gelap",
  langSwitch: "Ganti bahasa",
  ctaDownload: "Unduh APK",
  ctaSeeFeatures: "Lihat fitur",
  hero: {
    eyebrow: "Tazk · v2.0",
    title: "Selesai lebih tenang.",
    lead:
      "Tugas, habit, dan sesi fokus dalam satu tempat. Semua tersimpan di HP-mu: tanpa akun, dan tanpa internet untuk pemakaian harian.",
    chips: ["Gratis", "Offline", "Tanpa akun"],
    phoneLabel: "Tazk",
    phoneSub: "v2.0 · offline",
  },
  proofs: {
    title: "Tiga hal yang bisa kamu pegang",
    items: [
      {
        title: "Offline penuh",
        body:
          "Data tinggal di perangkatmu. Tidak ada akun, dan tidak ada unggahan otomatis ke mana pun.",
      },
      {
        title: "Widget yang bekerja",
        body:
          "Centang tugas dari layar utama, termasuk saat aplikasi sedang tertutup.",
      },
      {
        title: "XP yang jujur",
        body:
          "Batal centang mengurangi XP. Tidak ada poin ganda yang membuat progres terlihat lebih besar.",
      },
    ],
  },
  features: {
    eyebrow: "Fitur",
    title: "Yang benar-benar dipakai tiap hari",
    lead: "Bukan daftar fitur yang mengesankan di atas kertas. Ini yang bekerja saat kamu membuka aplikasi di pagi hari.",
    items: [
      {
        icon: "check",
        title: "Centang dua arah",
        body: "Tandai selesai atau batalkan tanpa dialog. XP ikut menyesuaikan.",
      },
      {
        icon: "list",
        title: "Subtask dan lokasi",
        body: "Pecah tugas jadi langkah kecil, atur urutannya, lalu buka lokasi di Maps.",
      },
      {
        icon: "flame",
        title: "Habit dengan streak",
        body: "Streak dihitung jujur, dan freeze yang tersisa selalu terlihat.",
      },
      {
        icon: "widget",
        title: "Widget yang bekerja",
        body: "Centang dari layar utama, bahkan saat aplikasi tidak sedang dibuka.",
      },
      {
        icon: "chart",
        title: "Statistik dari data nyata",
        body: "Minggu kosong tampil kosong. Tidak ada angka karangan untuk mengisi layar.",
      },
      {
        icon: "archive",
        title: "Cadangan milikmu",
        body: "Ekspor JSON kapan saja, lalu simpan di tempat yang kamu pilih.",
      },
    ],
  },
  tints: {
    eyebrow: "Kenapa terasa beda",
    title: "Tiga prinsip yang menjaga aplikasi ini tenang",
    items: [
      {
        title: "Tenang dulu, produktif kemudian",
        body:
          "Tata letak yang rapi membuat langkah berikutnya jelas. Tidak ada notifikasi berisik yang mengejar.",
      },
      {
        title: "Progres yang terlihat",
        body:
          "XP, streak, dan lencana menunjukkan seberapa jauh kamu melangkah, tanpa mengubah tugas jadi permainan yang melelahkan.",
      },
      {
        title: "Datamu, di tanganmu",
        body:
          "Ekspor dan impor JSON tanpa cloud. Tidak ada data yang tinggal di server kami.",
      },
    ],
  },
  steps: {
    eyebrow: "Cara pakai",
    title: "Terpasang dalam tiga langkah",
    lead: "Tidak ada pendaftaran, tidak ada verifikasi email. Cukup satu file.",
    items: [
      { title: "Unduh APK", body: "Ambil file dari halaman ini." },
      {
        title: "Izinkan instalasi",
        body: "Android akan meminta izin memasang dari sumber ini. Setujui sekali.",
      },
      {
        title: "Mulai dari nol",
        body: "Buat tugas dan habit pertama. Semuanya langsung jalan tanpa internet.",
      },
    ],
  },
  faq: {
    eyebrow: "FAQ",
    title: "Pertanyaan yang sering muncul",
    lead: "Kalau ada yang belum terjawab, ini yang paling sering ditanyakan.",
    items: [
      {
        q: "Apakah Tazk gratis?",
        a: "Ya. Tanpa iklan dan tanpa fitur yang dikunci di balik pembayaran.",
      },
      {
        q: "Apakah data saya dikirim keluar?",
        a: "Tidak. Tidak ada akun dan tidak ada unggahan otomatis. Data tersimpan di perangkatmu.",
      },
      {
        q: "Kenapa tidak ada di Play Store?",
        a: "Tazk dibagikan langsung sebagai APK. Pembaruan diunduh manual dari halaman ini.",
      },
      {
        q: "Bagaimana kalau saya ganti HP?",
        a: "Ekspor file JSON dari HP lama, pindahkan filenya, lalu impor di HP baru.",
      },
      {
        q: "Apakah butuh internet?",
        a: "Tidak untuk pemakaian harian. Hanya pemeriksaan versi baru yang memakai jaringan, dan itu pun kamu yang memicu.",
      },
      {
        q: "Apakah aman memasang APK manual?",
        a: "Unduh hanya dari halaman ini, lalu cocokkan checksum SHA-256 yang ditampilkan sebelum memasang.",
      },
    ],
  },
  download: {
    title: "Unduh Tazk 2.0",
    lead: "Satu file APK, tanpa akun. Setelah terpasang, aplikasi berjalan penuh secara offline.",
    apkNote: "APK sedang disiapkan. Tombol unduh aktif begitu build final tersedia di halaman ini.",
    checksumLabel: "Checksum SHA-256",
    cta: "Unduh APK",
  },
  footer: {
    tagline:
      "Aplikasi tugas, habit, dan fokus untuk Android. Offline, tanpa akun, dan tenang dipakai.",
    links: [
      { label: "Fitur", href: "#fitur" },
      { label: "Cara pakai", href: "#cara-pakai" },
      { label: "FAQ", href: "#faq" },
      { label: "Privasi", href: "/privasi" },
      { label: "Unduh", href: "#unduh" },
    ],
    copyright: "© 2026 Tazk",
    madeWith: "Dibuat dengan Flutter",
  },
};

const en: Copy = {
  metaTitle: "Tazk · Done, calmer",
  metaDescription:
    "Tasks, habits, and focus sessions for Android. Fully offline, no account, and your data stays on your phone.",
  skip: "Skip to content",
  nav: [
    { label: "Features", href: "#fitur" },
    { label: "How it works", href: "#cara-pakai" },
    { label: "FAQ", href: "#faq" },
  ],
  themeToggle: "Switch light or dark theme",
  langSwitch: "Switch language",
  ctaDownload: "Download APK",
  ctaSeeFeatures: "See features",
  hero: {
    eyebrow: "Tazk · v2.0",
    title: "Done, calmer.",
    lead:
      "Tasks, habits, and focus sessions in one place. Everything stays on your phone: no account, and no internet needed for daily use.",
    chips: ["Free", "Offline", "No account"],
    phoneLabel: "Tazk",
    phoneSub: "v2.0 · offline",
  },
  proofs: {
    title: "Three things you can count on",
    items: [
      {
        title: "Fully offline",
        body:
          "Your data stays on your device. No account, and nothing is uploaded anywhere automatically.",
      },
      {
        title: "A widget that works",
        body:
          "Check tasks from the home screen, including while the app is closed.",
      },
      {
        title: "Honest XP",
        body:
          "Unchecking takes XP back. No double points that inflate how far along you look.",
      },
    ],
  },
  features: {
    eyebrow: "Features",
    title: "The parts you actually use every day",
    lead: "Not an impressive list on paper. These are the things that work when you open the app in the morning.",
    items: [
      {
        icon: "check",
        title: "Two-way check",
        body: "Mark done or undo without a dialog. XP adjusts with it.",
      },
      {
        icon: "list",
        title: "Subtasks and places",
        body: "Break a task into small steps, reorder them, then open the place in Maps.",
      },
      {
        icon: "flame",
        title: "Habit streaks",
        body: "Streaks are counted honestly, and the freezes you have left are always visible.",
      },
      {
        icon: "widget",
        title: "A widget that works",
        body: "Check from the home screen, even when the app is not open.",
      },
      {
        icon: "chart",
        title: "Stats from real data",
        body: "An empty week looks empty. No invented numbers to fill the screen.",
      },
      {
        icon: "archive",
        title: "Your own backup",
        body: "Export JSON anytime, then store it wherever you choose.",
      },
    ],
  },
  tints: {
    eyebrow: "Why it feels different",
    title: "Three principles that keep the app calm",
    items: [
      {
        title: "Calm first, productive after",
        body:
          "A tidy layout makes the next step obvious. No noisy notifications chasing you.",
      },
      {
        title: "Progress you can see",
        body:
          "XP, streaks, and badges show how far you have come, without turning your tasks into an exhausting game.",
      },
      {
        title: "Your data, in your hands",
        body:
          "Export and import JSON with no cloud. Nothing of yours stays on our servers.",
      },
    ],
  },
  steps: {
    eyebrow: "How it works",
    title: "Installed in three steps",
    lead: "No sign-up, no email verification. Just one file.",
    items: [
      { title: "Download the APK", body: "Get the file from this page." },
      {
        title: "Allow the install",
        body: "Android will ask permission to install from this source. Approve once.",
      },
      {
        title: "Start from scratch",
        body: "Create your first task and habit. Everything runs offline right away.",
      },
    ],
  },
  faq: {
    eyebrow: "FAQ",
    title: "Questions that come up often",
    lead: "If something is still unclear, these are the most common ones.",
    items: [
      {
        q: "Is Tazk free?",
        a: "Yes. No ads and no features locked behind a payment.",
      },
      {
        q: "Is my data sent anywhere?",
        a: "No. There is no account and no automatic upload. Your data stays on your device.",
      },
      {
        q: "Why is it not on the Play Store?",
        a: "Tazk ships directly as an APK. Updates are downloaded manually from this page.",
      },
      {
        q: "What if I change phones?",
        a: "Export the JSON file from the old phone, move the file, then import it on the new one.",
      },
      {
        q: "Does it need internet?",
        a: "Not for daily use. Only the version check goes online, and you trigger it yourself.",
      },
      {
        q: "Is installing an APK manually safe?",
        a: "Download only from this page, then compare the SHA-256 checksum shown before installing.",
      },
    ],
  },
  download: {
    title: "Download Tazk 2.0",
    lead: "One APK file, no account. Once installed, the app runs fully offline.",
    apkNote: "The APK is being prepared. The download button turns on as soon as the final build is available on this page.",
    checksumLabel: "SHA-256 checksum",
    cta: "Download APK",
  },
  footer: {
    tagline:
      "Tasks, habits, and focus for Android. Offline, no account, and calm to use.",
    links: [
      { label: "Features", href: "#fitur" },
      { label: "How it works", href: "#cara-pakai" },
      { label: "FAQ", href: "#faq" },
      { label: "Privacy", href: "/en/privacy" },
      { label: "Download", href: "#unduh" },
    ],
    copyright: "© 2026 Tazk",
    madeWith: "Built with Flutter",
  },
};

export const dict: Record<Lang, Copy> = { id, en };
export const langs: Lang[] = ["id", "en"];
export function getCopy(lang: Lang): Copy {
  return dict[lang];
}