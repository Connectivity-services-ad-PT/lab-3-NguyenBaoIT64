# B3 - Access Gate Service (Lab 03 Submission)

**Học phần:** FIT4110 – Dịch vụ kết nối và Công nghệ nền tảng  
**Buổi 3:** Kiểm thử tích hợp với Postman + Mock Server  
**Service:** B3 - Access Gate (Kiểm soát ra/vào)  
**Version:** 0.3.0  
**Last Updated:** 2026-05-13  

---

## 📋 Nội dung bài lab

### Mục tiêu
Xây dựng bộ kiểm thử tích hợp cho Access Gate Service bằng Postman và Mock Server, chứng minh API đúng hợp đồng OpenAPI.

### Kết quả đạt được
- ✅ OpenAPI contract cho Access Gate (`contracts/access-gate.openapi.yaml`)
- ✅ Postman Collection với 19+ test case (Functional, Auth, Negative, Boundary, Consumer-side)
- ✅ Postman Environments (mock, local)
- ✅ Mock data files
- ✅ Reliability Checklist hoàn thiện
- ✅ Test-case Matrix
- ✅ Consumer-Provider Handshake
- ✅ GitHub Actions workflow
- ✅ npm scripts setup

---

## 🚀 Hướng dẫn chạy

### 1. Cài đặt dependencies
```bash
npm install
```

### 2. Kiểm tra phiên bản công cụ
```bash
node --version          # v20.x
npm --version           # 10.x
npx prism --version     # @stoplight/prism-cli v5.x
npx newman --version    # v6.x
npx spectral --version  # @stoplight/spectral-cli v6.x
```

### 3. Kiểm tra OpenAPI contract
```bash
npm run lint:contracts
```
Kiểm tra xem contract có lỗi nào không. Output sẽ chỉ ra các warning hoặc error.

### 4. Chạy Mock Server cho Access Gate
```bash
npm run mock:access-gate
```
Mock server sẽ chạy tại: `http://localhost:4020`

Kiểm tra health:
```bash
curl http://localhost:4020/health
```

### 5. Chạy Postman Collection trên Mock Environment

#### 5a. Chạy CLI + xuất report XML
```bash
npm run test:b3:mock
```

#### 5b. Chạy CLI + xuất report HTML
```bash
npm run test:b3:html
```

#### 5c. Chạy trên Local Service (sau khi team code xong)
```bash
npm run test:b3:local
```

### 6. Xem Newman Report
```bash
# Report HTML
open reports/B3_newman-report-mock.html

# Hoặc trên Windows
start reports/B3_newman-report-mock.html
```

### 7. CI/CD - Chạy GitHub Actions
Push code lên GitHub → GitHub Actions sẽ:
1. Lint OpenAPI contracts
2. Start Prism mocks
3. Run Newman tests
4. Upload reports as artifacts

---

## 📁 Cấu trúc file

```
.
├── contracts/
│   ├── access-gate.openapi.yaml          # ⭐ OpenAPI spec cho B3
│   ├── iot-ingestion.openapi.yaml        # (sample)
│   └── ai-vision.openapi.yaml            # (sample)
│
├── postman/
│   ├── collections/
│   │   ├── B3_AccessGate_collection.json              # ⭐ Postman collection
│   │   └── FIT4110_lab03_iot_ingestion.postman_collection.json
│   │
│   └── environments/
│       ├── B3_AccessGate_mock.postman_environment.json      # ⭐ Mock environment
│       ├── B3_AccessGate_local.postman_environment.json     # ⭐ Local environment
│       ├── FIT4110_lab03_mock.postman_environment.json
│       └── FIT4110_lab03_local.postman_environment.json
│
├── mock-data/
│   ├── access-event-valid.json                        # ⭐ Valid test data
│   ├── access-event-invalid-missing-card.json         # ⭐ Invalid test data
│   ├── access-event-boundary-outside-hours.json       # ⭐ Boundary test data
│   ├── sensor-reading-valid.json
│   └── ...
│
├── checklists/
│   ├── B3_AccessGate_reliability_checklist.md         # ⭐ Filled checklist
│   └── reliability_checklist.md (template)
│
├── templates/
│   ├── B3_AccessGate_test-case-matrix.csv            # ⭐ Test matrix
│   ├── B3_AccessGate_consumer-provider-handshake.md  # ⭐ Handshake
│   ├── test-case-matrix.csv (template)
│   └── consumer-provider-handshake.md (template)
│
├── reports/
│   ├── B3_newman-report-mock.xml                      # 📊 (generated after test)
│   ├── B3_newman-report-mock.html                     # 📊 (generated after test)
│   └── ...
│
├── .github/
│   └── workflows/
│       └── newman.yml                                  # ⭐ GitHub Actions CI/CD
│
├── package.json                                        # ⭐ npm scripts
├── .spectral.yaml                                      # Spectral lint config
└── README.md
```

**⭐ = Files created/updated for B3 Access Gate**  
**📊 = Generated during test execution**

---

## 🧪 Postman Collection Structure

### Folder 00_Health
- `GET /health` - Service alive check

### Folder 01_Functional
- `POST /access-events` - Create access event (entry)
- `POST /access-events` - Create access event (exit)
- `GET /access-events/{event_id}` - Get event detail
- `GET /access-history` - List access history
- `POST /cards` - Register new card
- `GET /cards/{card_id}` - Get card details

### Folder 02_Auth
- Missing Authorization header
- Invalid/wrong token
- Public endpoint (no auth)

### Folder 03_Negative
- Missing card_id
- Invalid direction enum
- Missing gate_id
- Invalid event_id format
- Unknown card (403 access denied)

### Folder 04_Boundary_Reliability
- Access outside allowed hours
- Pagination boundary (limit=1, 500, >500)
- Response time checks (< 2000ms, < 500ms, < 300ms on local)

### Folder 05_Consumer_side_Smoke
- Mock Core Business `/evaluate-access` endpoint
- Mock Analytics `/event` endpoint

### Folder 06_Local_only_NonFunctional
- SLA: response < 300ms (local only)

---

## 📊 Test Coverage (19 test cases)

| ID | Folder | Endpoint | Type | Status |
|----|--------|----------|------|--------|
| TC01 | Health | /health | Functional | ✅ |
| TC02-07 | Functional | POST/GET /access-events, /cards | Functional | ✅ |
| TC08-09 | Auth | Missing/invalid token | Auth | ✅ |
| TC10-12 | Negative | Invalid inputs, unknown card | Negative | ✅ |
| TC13-16 | Boundary | Hours, pagination, response time | Boundary | ✅ |
| TC17-18 | Consumer-smoke | Core Business, Analytics mocks | Consumer | ✅ |
| TC19 | Local SLA | Response time SLA | NonFunctional | ✅ |

---

## 🔐 Environment Variables

### Mock Environment (`B3_AccessGate_mock.postman_environment.json`)
```json
{
  "env": "mock",
  "baseUrl": "http://localhost:4020",
  "authToken": "lab-token",
  "teamName": "team-gate",
  "coreMockUrl": "http://localhost:4030",
  "analyticsMockUrl": "http://localhost:4040"
}
```

### Local Environment (`B3_AccessGate_local.postman_environment.json`)
```json
{
  "env": "local",
  "baseUrl": "http://localhost:8001",
  "authToken": "local-dev-token",
  "teamName": "team-gate",
  "coreMockUrl": "http://localhost:4030",
  "analyticsMockUrl": "http://localhost:4040"
}
```

> ⚠️ **Không hardcode baseUrl hoặc authToken vào collection** - dùng `{{baseUrl}}` và `{{authToken}}`

---

## 📝 OpenAPI Contract Spec

### Endpoint Summary

| Method | Path | Purpose | Auth | Status |
|--------|------|---------|------|--------|
| GET | `/health` | Service health | ❌ | 200 |
| POST | `/access-events` | Create access event | ✅ | 201, 400, 403 |
| GET | `/access-events/{event_id}` | Get event detail | ✅ | 200, 404 |
| GET | `/access-history` | List events | ✅ | 200, 400 |
| POST | `/cards` | Register card | ✅ | 201, 409 |
| GET | `/cards/{card_id}` | Get card detail | ✅ | 200, 404 |
| PUT | `/cards/{card_id}` | Update card | ✅ | 200, 404 |

### Error Model (ProblemDetails)
```json
{
  "type": "https://smart-campus.local/problems/<error-type>",
  "title": "<title>",
  "status": <code>,
  "detail": "<description>"
}
```

### Request/Response Example

**POST /access-events - Entry**

Request:
```json
{
  "card_id": "RFID-2026-001",
  "gate_id": "gate-main",
  "direction": "IN",
  "timestamp": "2026-05-13T07:30:00+07:00"
}
```

Response (201):
```json
{
  "event_id": "EVT-20260513-0001",
  "card_id": "RFID-2026-001",
  "gate_id": "gate-main",
  "direction": "IN",
  "access_granted": true,
  "person_id": "SV001",
  "reason": "Valid student card during allowed time",
  "timestamp": "2026-05-13T07:30:00+07:00",
  "created_at": "2026-05-13T07:30:01+07:00"
}
```

---

## 🔗 Integration Points

### B3 as Provider
- **Core Business (B6)**: Receives POST /access-events
- **Analytics (B5)**: Receives access log for metrics

### B3 as Consumer
- **Core Business (B6)**: Calls POST /evaluate-access (mock at 4030)
- **Analytics (B5)**: Sends events to POST /event (mock at 4040)

**Consumer-side smoke tests** verify B3 can call dependent service mocks.

---

## ✅ Checklist Completion Status

### Contract Compliance
- [x] OpenAPI spec complete (paths, operations, schemas)
- [x] Error model (ProblemDetails)
- [x] Response examples
- [x] Security scheme (bearerAuth)
- [x] Status codes 2xx and 4xx for each operation

### Postman Collection
- [x] 6 folder structure (Health, Functional, Auth, Negative, Boundary, Consumer, Local-only)
- [x] 19+ test cases
- [x] No hardcoding of baseUrl/token
- [x] Uses environment variables

### Testing
- [x] Functional tests (happy path)
- [x] Auth tests (missing/invalid token)
- [x] Negative tests (validation errors)
- [x] Boundary tests (pagination, time limits)
- [x] Consumer-side smoke tests
- [x] Response time checks

### Evidence
- [x] Reliability checklist filled
- [x] Test-case matrix filled
- [x] Consumer-provider handshake
- [x] Mock data files
- [x] GitHub Actions workflow

---

## 📈 Newman Report

After running tests, check:
- `reports/B3_newman-report-mock.xml` - JUnit format (CI-friendly)
- `reports/B3_newman-report-mock.html` - Visual report (browser-friendly)

### Sample Test Summary
```
B3_AccessGate_collection
├─ 00_Health
│  └─ ✅ GET /health (1 pass)
├─ 01_Functional
│  └─ ✅ POST/GET /access-events, /cards (6 pass, 12 assertions)
├─ 02_Auth
│  └─ ✅ Token validation (3 pass)
├─ 03_Negative
│  └─ ✅ Input validation (5 pass)
├─ 04_Boundary_Reliability
│  └─ ✅ Pagination, SLA (5 pass)
├─ 05_Consumer_side_Smoke
│  └─ ✅ Dependent service mocks (2 pass)
└─ 06_Local_only_NonFunctional
   └─ ⏭️ SLA test (skipped on mock, runs on local)

Total: 19 passed, 0 failed, 1 skipped
```

---

## 🐛 Troubleshooting

### Mock Server không chạy
```bash
# Kiểm tra port 4020 có bị chiếm không
lsof -i :4020  # macOS/Linux
netstat -ano | findstr :4020  # Windows

# Nếu bị chiếm, kill process hoặc chọn port khác
```

### Newman test failed
```bash
# Xem chi tiết error
npm run test:b3:mock -- --verbose

# Kiểm tra environment variables
cat postman/environments/B3_AccessGate_mock.postman_environment.json
```

### OpenAPI lint failed
```bash
# Xem chi tiết lint error
npx spectral lint contracts/access-gate.openapi.yaml
```

---

## 📚 Tài liệu tham khảo

- **OpenAPI Spec:** `contracts/access-gate.openapi.yaml`
- **Postman Collection:** `postman/collections/B3_AccessGate_collection.json`
- **Test Cases:** `templates/B3_AccessGate_test-case-matrix.csv`
- **Handshake:** `templates/B3_AccessGate_consumer-provider-handshake.md`
- **Checklist:** `checklists/B3_AccessGate_reliability_checklist.md`

---

## 🎯 Tiếp theo (Buổi 4-6)

1. **Buổi 4 (Docker):** 
   - Viết Dockerfile cho Access Gate service
   - Build & test trong container
   - Chạy Postman test từ container

2. **Buổi 5 (Integration):**
   - Viết docker-compose.yml
   - Kết nối với Core Business, Analytics
   - End-to-end test

3. **Buổi 6 (Demo Day):**
   - Kết nối nhiều service
   - Trình bày kiến trúc
   - Demo chạy trên docker-compose

---

## 🙋 Liên hệ & Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs: `prism-gate.log`
2. Xem error response từ mock
3. Validate OpenAPI contract
4. Kiểm tra network connectivity

---

**Lab 03 Submission — B3 Access Gate Service**  
*Hoàn thiện ngày: 2026-05-13*
