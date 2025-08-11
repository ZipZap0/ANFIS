# 🧠 Sistem Kontrol Sudut Yaw Berbasis ANFIS (Adaptive Neuro-Fuzzy Inference System)  
**Intelligent Control for Orientation Stabilization Using Neuro-Fuzzy Learning**

> 📌 *Proyek ini mengimplementasikan sistem kontrol adaptif cerdas berbasis ANFIS untuk mengoreksi sudut yaw (heading) pada sistem dinamis seperti drone, robot otonom, atau kendaraan bergerak. Dengan menggabungkan kekuatan logika fuzzy dan jaringan syaraf tiruan, sistem mampu belajar dari data dan menghasilkan keputusan kontrol yang optimal secara realistis.*

---

## 📌 Ringkasan Proyek

Sistem kontrol orientasi berbasis **ANFIS (Adaptive Neuro-Fuzzy Inference System)** ini dirancang untuk mengatasi permasalahan umum dalam sistem navigasi: **penyimpangan sudut yaw** akibat gangguan eksternal (angin, gesekan, drift sensor). Model fuzzy awal dirancang secara heuristik, kemudian **dilatih menggunakan algoritmo hybrid (least squares + gradient descent)** untuk mengoptimalkan parameter keanggotaan dan output, sehingga menghasilkan sinyal kontrol yang lebih akurat dan stabil.

Program ini mencakup:
- Desain FIS Sugeno 5-rules
- Pelatihan ANFIS dengan data input-output
- Simulasi kontrol loop tertutup (closed-loop)
- Evaluasi performa dan visualisasi hasil

---

## 🔧 Arsitektur Sistem

### 1. **Input: Error Yaw**
- Representasi selisih antara orientasi aktual dan setpoint.
- Rentang: [-30°, +30°]
- Digunakan sebagai input utama ke sistem kontrol.

### 2. **Output: Sinyal Kontrol (Control Signal)**
- Besaran koreksi yang harus diberikan ke aktuator (misalnya: motor, servo).
- Rentang: [-30, +30] (dalam satuan sudut atau PWM ekivalen).
- Digunakan untuk memperbaiki orientasi sistem.

### 3. **Fuzzy Inference System (FIS) – Tipe Sugeno**
- **Metode**: Sugeno (zero-order, output konstan)
- **Jumlah Input**: 1 (`Error`)
- **Jumlah Output**: 1 (`Control`)
- **Jumlah Aturan**: 5
- **T-Norm**: min
- **Implication Method**: min
- **Aggregation**: max
- **Defuzzification**: Weighted Average (untuk output konstan)

#### 🔹 Himpunan Fuzzy Input (`Error`)
| Label             | Fungsi Keanggotaan | Parameter (trimf) |
|-------------------|--------------------|-------------------|
| Negatif Besar     | trimf              | [-30, -15, -5]    |
| Negatif Kecil     | trimf              | [-15, -5, 0]      |
| Nol               | trimf              | [-7, 0, 7]        |
| Positif Kecil     | trimf              | [0, 5, 15]        |
| Positif Besar     | trimf              | [5, 15, 30]       |

#### 🔹 Himpunan Fuzzy Output (`Control`)
| Label     | Jenis     | Parameter (konstanta) |
|----------|-----------|------------------------|
| Out1     | constant  | -15                    |
| Out2     | constant  | -5                     |
| Out3     | constant  | 0                      |
| Out4     | constant  | 5                      |
| Out5     | constant  | 15                     |

#### 🔹 Basis Aturan Fuzzy
| IF Error IS...       | THEN Control = ... |
|----------------------|--------------------|
| Negatif Besar        | -15                |
| Negatif Kecil        | -5                 |
| Nol                  | 0                  |
| Positif Kecil        | 5                  |
| Positif Besar        | 15                 |

> ⚠️ Catatan: Aturan ini bersifat simetris dan intuitif, cocok untuk sistem kontrol stabilisasi.

---

## 🤖 Proses Pelatihan ANFIS

### 🔎 Tujuan Pelatihan
Mengoptimalkan:
- Parameter fungsi keanggotaan input (`trimf`)
- Parameter output (konstanta)
- Agar output model mendekati `control_target` pada setiap `error_yaw`.

### ⚙️ Konfigurasi ANFIS
| Parameter               | Nilai                  |
|-------------------------|------------------------|
| Metode Inisialisasi     | FIS eksis (custom)     |
| Epoch                   | 400                    |
| Algoritma Pembelajaran  | Hybrid (LSE + GD)      |
| Validasi                | Tidak digunakan        |
| Tampilan Error          | Tiap epoch             |

### 📈 Output Pelatihan
- Model terlatih disimpan sebagai: `anfis_trained.fis`
- Plot error pelatihan ditampilkan (opsional)
- RMSE antara prediksi dan target dihitung

---

## 🔄 Simulasi Kontrol Dinamis

Sistem diuji dalam **loop kontrol tertutup (closed-loop)** dengan skenario:

- **Setpoint**: `0°` (orientasi referensi)
- **Posisi Awal (yaw)**: `20°`
- **Kondisi Berhenti**: `|error| < 0.1°` dan `|control| kecil`
- **Maksimum Iterasi**: 30

### 🧮 Update Dinamika Sistem
Setiap iterasi:
```matlab
error = yaw - set_point;
control = evalfis(FIS_trained, error);
yaw = yaw - control;  % Koreksi arah
