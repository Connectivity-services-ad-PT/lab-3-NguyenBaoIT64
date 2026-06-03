# Consumer-Provider Handshake — B3 Access Gate Service

**Service Provider:** Team B3 - Access Gate  
**Service Version:** 0.3.0  
**Last Updated:** 2026-05-13  

---

## 1. Service Overview

### Provider: B3 - Access Gate Service
- **Base URL (Mock):** `http://localhost:4020`
- **Base URL (Local):** `http://localhost:8001`
- **OpenAPI Spec:** `contracts/access-gate.openapi.yaml`

### Responsibility
- Receive and log access events (card swipe, QR scan, code entry).
- Validate card authenticity and status.
- Make access decision based on policy (time, card type, gate).
- Send access decision and event to downstream services.

---

## 2. Consumer Services & Dependencies

### B3 acts as **Provider** to:

| Consumer | Endpoint Called | Purpose | Status |
|----------|-----------------|---------|--------|
| B6 - Core Business | POST /access-events | Send access event for policy evaluation | Not yet implemented |
| B5 - Analytics | POST /event | Send access event for metrics | Not yet implemented |

### B3 acts as **Consumer** of:

| Provider | Endpoint Used | Purpose | Status |
|----------|---------------|---------|--------|
| B6 - Core Business | POST /evaluate-access (mock at 4030) | Evaluate access policy | To test with mock |
| B5 - Analytics | POST /event (mock at 4040) | Stream access events | To test with mock |

---

## 3. API Contract Handshake

### Provided Endpoints

#### 3.1 POST /access-events — Create access event

**Producer:** B3 - Access Gate  
**Consumer:** B6 Core Business, B5 Analytics  

**Request:**
```json
{
  "card_id": "RFID-2026-001",
  "gate_id": "gate-main",
  "direction": "IN",
  "timestamp": "2026-05-13T07:30:00+07:00",
  "device_id": "READER-001" (optional)
}
```

**Response (201):**
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

**Response (403) - Access Denied:**
```json
{
  "type": "https://smart-campus.local/problems/access-denied",
  "title": "Access denied",
  "status": 403,
  "detail": "Card not registered in system or access outside allowed time"
}
```

**Notes:**
- `direction` must be **IN** or **OUT**.
- `access_granted` indicates whether gate should open.
- `reason` explains why access was granted or denied.
- Service must respond within **< 2000ms** (ideally **< 500ms** for gate hardware).

---

#### 3.2 GET /access-history — Retrieve access log

**Producer:** B3 - Access Gate  
**Consumer:** B5 Analytics, B6 Core Business (for audit)  

**Query Parameters:**
```
GET /access-history?card_id=RFID-2026-001&gate_id=gate-main&direction=IN&limit=50&offset=0
```

**Response (200):**
```json
{
  "total": 127,
  "limit": 50,
  "offset": 0,
  "events": [
    {
      "event_id": "EVT-20260513-0001",
      "card_id": "RFID-2026-001",
      "gate_id": "gate-main",
      "direction": "IN",
      "access_granted": true,
      "person_id": "SV001",
      "reason": "Valid student card",
      "timestamp": "2026-05-13T07:30:00+07:00",
      "created_at": "2026-05-13T07:30:01+07:00"
    },
    ...
  ]
}
```

**Notes:**
- `limit` max 500 (default 50).
- Used for dashboards and analytics queries.
- Must support filtering by card_id, gate_id, direction.

---

#### 3.3 POST /cards — Register card

**Producer:** B3 - Access Gate  
**Consumer:** B7 Notification (for card issue/expiry alerts), potentially B6 Core  

**Request:**
```json
{
  "card_id": "RFID-2026-002",
  "person_id": "SV002",
  "card_type": "student",
  "status": "active",
  "valid_from": "2026-01-01",
  "valid_until": "2026-12-31"
}
```

**Response (201):**
```json
{
  "card_id": "RFID-2026-002",
  "person_id": "SV002",
  "card_type": "student",
  "status": "active",
  "valid_from": "2026-01-01",
  "valid_until": "2026-12-31",
  "created_at": "2026-05-13T08:00:00+07:00",
  "updated_at": "2026-05-13T08:00:00+07:00"
}
```

**Error (409) - Card already exists:**
```json
{
  "type": "https://smart-campus.local/problems/conflict",
  "title": "Conflict",
  "status": 409,
  "detail": "Card RFID-2026-002 already registered"
}
```

---

### Consumed Endpoints (Mocks for Testing)

#### 3.4 POST /evaluate-access (Core Business Mock)

**Provider:** B6 Core Business  
**Consumer:** B3 Access Gate  
**Mock URL:** `http://localhost:4030/evaluate-access`  

B3 sends access event to Core for policy decision.

**Request from B3:**
```json
{
  "event_id": "EVT-20260513-0001",
  "card_id": "RFID-2026-001",
  "gate_id": "gate-main",
  "direction": "IN",
  "timestamp": "2026-05-13T07:30:00+07:00"
}
```

**Expected Response (200/201):**
```json
{
  "event_id": "EVT-20260513-0001",
  "decision": "allow",
  "policy": "student_during_hours",
  "alert_if_triggered": false
}
```

**Status:** Not yet started (will integrate after B6 provides mock).

---

#### 3.5 POST /event (Analytics Mock)

**Provider:** B5 Analytics  
**Consumer:** B3 Access Gate  
**Mock URL:** `http://localhost:4040/event`  

B3 streams access events for aggregation.

**Request from B3:**
```json
{
  "event_type": "access",
  "source_service": "access-gate",
  "card_id": "RFID-2026-001",
  "gate_id": "gate-main",
  "direction": "IN",
  "timestamp": "2026-05-13T07:30:00+07:00"
}
```

**Expected Response (200/201):**
```json
{
  "status": "ingested",
  "event_id": "EVT-20260513-0001"
}
```

**Status:** Not yet started (will integrate after B5 provides mock).

---

## 4. Authentication & Authorization

### Bearer Token
- All endpoints require `Authorization: Bearer <token>`.
- Mock environment token: `lab-token`.
- Local environment token: `local-dev-token`.
- Public endpoint: `/health` (no auth required).

### Token Format
- Expected format: JWT or opaque token.
- Validation: Service verifies token validity.
- If token invalid → return `401 Unauthorized`.
- If token missing → return `401 Unauthorized`.

---

## 5. Error Handling & Codes

All errors follow **ProblemDetails** format (RFC 7807):

```json
{
  "type": "https://smart-campus.local/problems/<error-type>",
  "title": "<title>",
  "status": <code>,
  "detail": "<description>"
}
```

| Status | Scenario |
|--------|----------|
| **200** | GET successful (health, card, history) |
| **201** | POST successful (access event created, card registered) |
| **400** | Validation error (missing field, wrong enum, invalid format) |
| **401** | Unauthorized (missing/invalid token) |
| **403** | Forbidden (access denied, card not found, outside hours) |
| **404** | Not found (event_id, card_id) |
| **409** | Conflict (card already registered) |
| **429** | Too many requests (rate limit hit) |
| **500** | Server error |

---

## 6. Data & Boundary Constraints

### Card ID
- Format: `RFID-YYYY-XXX` or custom identifier.
- Validation: Required, non-empty.
- Example: `RFID-2026-001`.

### Gate ID
- Format: Any string identifier.
- Examples: `gate-main`, `gate-side`, `gate-lab-a`.
- Validation: Required.

### Direction
- Allowed values: **IN** or **OUT**.
- Validation: Enum check.

### Timestamp
- Format: ISO 8601 (RFC 3339).
- Example: `2026-05-13T07:30:00+07:00`.
- Validation: Required, valid datetime.

### Response Time SLA
- **Access event creation:** < 2000ms (general), **< 500ms preferred** for real-time gate control.
- **History query:** < 3000ms for up to 500 records.
- Local service SLA: **< 300ms** for access event.

### Pagination
- `limit`: 1-500 (default 50).
- `offset`: >= 0 (default 0).
- Response includes `total`, `limit`, `offset`, `events[]`.

---

## 7. Rate Limiting & Reliability

### Rate Limit (if implemented)
- Service may implement rate limiting.
- Response: **429 Too Many Requests** with ProblemDetails.
- Header: `Retry-After: <seconds>`.

### Idempotency
- POST /access-events should be idempotent.
- Multiple identical requests within short time should not create duplicate events.
- Recommended: Use `request-id` header or event deduplication logic.

### Retry Strategy
- Consumer should retry on 5xx, 429.
- Backoff: exponential backoff (1s, 2s, 4s, ...) up to 30s max.

---

## 8. Integration Checklist

### B3 Must Provide
- [x] OpenAPI spec (access-gate.openapi.yaml).
- [ ] Dockerfile & docker-compose.yml.
- [ ] Postman Collection with tests.
- [ ] Environment files (mock, local).
- [ ] RUN_LOCAL.md instructions.
- [ ] Evidence: test report, screenshots, logs.

### B3 Must Consume (Mocks available at)
- [ ] Core Business mock: `http://localhost:4030`.
- [ ] Analytics mock: `http://localhost:4040`.
- [ ] Integration test in Postman (05_Consumer_side_Smoke folder).

### Dependent Teams Must Provide
- **B6 Core Business**: Mock at `http://localhost:4030/evaluate-access` by Demo Day.
- **B5 Analytics**: Mock at `http://localhost:4040/event` by Demo Day.

---

## 9. Known Issues & Notes

### Issue 1: Time Zone Handling
- Timestamps use UTC+7 (Vietnam time).
- All services should align on timezone or use UTC explicitly.

### Issue 2: Card Status Transitions
- Card lifecycle: `active` → `suspended` → `active` or `inactive`.
- Suspended cards should be rejected at gate immediately.

### Issue 3: Access Policy Not Yet Defined
- "Allowed hours" and policy details TBD with B6 Core Business.
- For now, mock accepts all valid cards; rejection based on card status only.

---

## 10. Sign-Off

### B3 - Access Gate (Provider)
- **Team:** Team B3
- **Signature/Confirmation:** _________________________ (Date: ________)

### Consumers - B6 Core Business
- **Confirmation:** _________________________ (Date: ________)

### Consumers - B5 Analytics
- **Confirmation:** _________________________ (Date: ________)

---

## 11. Appendix: Postman Collection Structure

```
B3_AccessGate_collection.json
├── 00_Health
│   └── GET /health
├── 01_Functional
│   ├── POST /access-events (entry)
│   ├── POST /access-events (exit)
│   ├── GET /access-events/{event_id}
│   ├── GET /access-history
│   ├── POST /cards
│   └── GET /cards/{card_id}
├── 02_Auth
│   ├── Missing token
│   ├── Invalid token
│   └── Public endpoint
├── 03_Negative
│   ├── Missing card_id
│   ├── Invalid direction
│   ├── Missing gate_id
│   ├── Invalid event_id format
│   └── Unknown card (403)
├── 04_Boundary_Reliability
│   ├── Access outside hours
│   ├── Pagination limit=1
│   ├── Pagination limit=500
│   ├── Invalid limit >500
│   └── Response time check
├── 05_Consumer_side_Smoke
│   ├── POST to Core Business mock
│   └── POST to Analytics mock
└── 06_Local_only_NonFunctional
    └── SLA: response < 300ms
```

---

**End of Handshake Document**
