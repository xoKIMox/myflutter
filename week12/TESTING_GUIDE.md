# 🧪 คู่มือการทดสอบโปรเจกต์สัปดาห์ที่ 12 (Week 12 Testing Guide)

เอกสารนี้รวบรวมขั้นตอนการรันและทดสอบระบบทั้งหมด 4 ส่วน ได้แก่ `backend1`, `backend2`, `frontend1` และ `frontend2`

---

## 📋 ข้อมูลบัญชีผู้ใช้สำหรับทดสอบ (Test Accounts)

| Username | Password | สิทธิ์ (Role) | การใช้งาน |
| :--- | :--- | :--- | :--- |
| **`student01`** | `test1234` | Staff User (`is_staff = True`) | บัญชีนักศึกษาสำหรับทดสอบล็อกอิน JWT & OIDC |
| **`admin`** | `admin1234` | Superuser | บัญชีผู้ดูแลระบบ |

---

## 🛠️ ส่วนที่ 1: การทดสอบ JWT Authentication (`backend1` + `frontend1`)

### Step 1: เปิดใช้งาน Backend 1 (DRF + Simple JWT)
เปิด **Terminal 1** แล้วรันคำสั่ง:
```bash
cd week12/backend1
uv run manage.py runserver 8000
```
> **พอร์ตใช้งาน:** `http://localhost:8000`

### Step 2: เปิดใช้งาน Frontend 1 (Flutter JWT App)
เปิด **Terminal 2** แล้วรันคำสั่ง:
```bash
cd week12/frontend1
flutter run -d chrome
```

### Step 3: ขั้นตอนการทดสอบผ่านหน้าแอป Frontend 1
1. **ตรวจสอบ Backend URL**: ระบุเป็น `http://localhost:8000`
2. **ปุ่ม `1. Get Token (/api/token/)`**:
   - กรอก `student01` / `test1234` แล้วกดปุ่ม
   - **ผลลัพธ์ที่คาดหวัง**: ได้รับ **Access Token** และ **Refresh Token** แสดงในช่อง Log สีเขียว
3. **ปุ่ม `3. Call Protected API`**:
   - กดปุ่มเพื่อเรียกดูข้อมูลที่มีการคุ้มครองสิทธิ์ (`/api/protected/`)
   - **ผลลัพธ์ที่คาดหวัง**: ได้รับ JSON Response `Status: 200 OK` พร้อมข้อความต้อนรับ
4. **ปุ่ม `2. Refresh Token (/api/token/refresh/)`**:
   - กดปุ่มเพื่อทดสอบส่ง Refresh Token ไปขอ Access Token ชุดใหม่

### 💡 การทดสอบ backend1 ผ่าน Terminal (HTTPie / cURL)
```bash
# ขอรับคู่ Token
uv tool run httpie POST http://localhost:8000/api/token/ username=student01 password=test1234

# เรียก Protected API ด้วย Bearer Token
uv tool run httpie GET http://localhost:8000/api/protected/ "Authorization: Bearer <ใส่อิสระ_access_token>"
```

---

## 🔐 ส่วนที่ 2: การทดสอบ OpenID Connect (`backend2` + `frontend2`)

### Step 1: เปิดใช้งาน Backend 2 (Django OIDC Server)
เปิด **Terminal 1** (หรือแท็บใหม่) แล้วรันคำสั่ง:
```bash
cd week12/backend2
uv run manage.py runserver 8001
```
> **พอร์ตใช้งาน:** `http://localhost:8001` (รันพอร์ต 8001 เพื่อไม่ให้ชนกับ backend1)

### Step 2: เปิดใช้งาน Frontend 2 (Flutter Web OIDC App)
เปิด **Terminal 2** แล้วรันคำสั่ง (*จำเป็นต้องตั้งค่า `--web-port 50000`*):
```bash
cd week12/frontend2
flutter run -d chrome --web-port 50000
```

### Step 3: ขั้นตอนการทดสอบผ่านหน้าแอป Frontend 2
1. **ตรวจสอบ OIDC Issuer URL**: ระบุเป็น `http://localhost:8001`
2. **กดปุ่ม `Sign in with OpenID Connect`**:
   - แอปจะ Redirect พาไปยังหน้าล็อกอินของ Django (`http://localhost:8001/admin/login/`)
3. **ล็อกอินเข้าสู่ระบบ**:
   - กรอก **Username**: `student01` / **Password**: `test1234`
4. **ผลลัพธ์ที่คาดหวัง**:
   - เมื่อล็อกอินสำเร็จ ระบบจะ Redirect กลับมาที่หน้าแอป Flutter Web บนพอร์ต `50000`
   - หน้าจอจะแสดงผลข้อมูลโปรไฟล์ผู้ใช้สำเร็จ:
     - **Name**: `student01`
     - **Email**: `student01@example.com`
     - **Subject (sub)**: `1` (User ID)

### 💡 การทดสอบ backend2 ผ่าน Terminal (OIDC Endpoints)
```bash
# ตรวจสอบ OIDC Discovery Metadata
uv tool run httpie GET http://localhost:8001/.well-known/openid-configuration

# ตรวจสอบ Public RS256 Keys (JWKS)
uv tool run httpie GET http://localhost:8001/jwks/
```

---

## 🔧 คู่มือแก้ไขปัญหาที่พบบ่อย (Troubleshooting & FAQs)

| ปัญหาที่พบ | สาเหตุ | วิธีแก้ไข |
| :--- | :--- | :--- |
| **`SyntaxError: Unexpected token '<'`** | รัน Backend ผิดตัว หรือไม่ได้เปิดเซิร์ฟเวอร์ | ตรวจสอบว่า `backend1` รันอยู่บนพอร์ต 8000 เมื่อทดสอบ `frontend1` |
| **`Redirect URI Error`** | Port หรือ URL Redirect ไม่ตรงกับที่ลงทะเบียน | ให้รัน `frontend2` ด้วยคำสั่ง `--web-port 50000` เสมอ |
| **`Please enter a correct staff account`** | บัญชีผู้ใช้ไม่มีสิทธิ์ `is_staff` | ใช้บัญชี `student01` / `test1234` หรือ `admin` / `admin1234` ซึ่งถูกเปิดสิทธิ์ `is_staff = True` ไว้แล้ว |
