# Reliability Checklist — B3 Access Gate Service

Điền checklist này trước khi nộp Lab 03.

## 1. Functional tests

- [x] Có test cho endpoint health.
- [x] Có test happy path cho endpoint chính (POST /access-events).
- [x] Có kiểm tra status code 2xx.
- [x] Có kiểm tra field quan trọng trong response (event_id, card_id, access_granted).
- [x] Có ít nhất 1 test đọc dữ liệu danh sách (GET /access-history) và chi tiết (GET /access-events/{id}).
- [x] Có test endpoint card management (POST /cards, GET /cards).

## 2. Auth tests

- [x] Có test thiếu token (POST /access-events without Authorization header).
- [x] Có test sai token (Bearer invalid-token).
- [x] Endpoint public /health được khai báo rõ và không cần auth.
- [x] Test thể hiện đúng expected status 401/403.

## 3. Negative tests

- [x] Có test thiếu field bắt buộc (missing card_id, gate_id).
- [x] Có test sai kiểu dữ liệu (direction: INVALID thay vì IN/OUT).
- [x] Có test sai enum hoặc giá trị ngoài miền (invalid direction).
- [x] Lỗi trả về theo cùng một error model (ProblemDetails).
- [x] Có test card không có trong hệ thống (card_id unknown → 403).
- [x] Có test invalid event_id format.

## 4. Boundary tests

- [x] Có test access ngoài giờ hành chính (thời gian biên).
- [x] Có test pagination boundary (limit=1, limit=500, limit>500).
- [x] Có test offset pagination.
- [x] Có ghi chú kỳ vọng xử lý: service có thể accept hoặc reject access outside hours, nhưng hành động phải rõ ràng.

## 5. Reliability tests cơ bản

- [x] Có kiểm tra response time (< 2000ms general, < 500ms for access event on local).
- [x] Có mô tả SLA: access event endpoint phải nhanh vì là real-time control.
- [x] Consumer-side smoke test: Access Gate có thể gọi mock Core Business và Analytics.
- [x] Local-only test: SLA test chỉ chạy trên local service thật (pm.environment.get('env') === 'local').

## 6. Evidence

- [x] Collection export JSON (B3_AccessGate_collection.json).
- [x] Environment mock export JSON (B3_AccessGate_mock.postman_environment.json).
- [x] Environment local export JSON (B3_AccessGate_local.postman_environment.json).
- [ ] Newman report XML/HTML (sẽ generate sau khi chạy).
- [x] Test-case matrix đã điền (TC01-TC15).
- [x] Biên bản handshake đã điền (với Core Business, Analytics).

## 7. Contract Compliance

- [x] openapi.yaml có đầy đủ: paths, operations, request/response schema, examples.
- [x] Có error model (ProblemDetails) với status 400-599.
- [x] Có ít nhất một 2xx response và một 4xx response cho mỗi operation.
- [x] Có description, example cho mỗi parameter, path, query.
- [x] Security scheme (bearerAuth) được khai báo.
- [x] Mock data files có sẵn (access-event-valid.json, access-event-invalid-*.json).

## 8. Integration Readiness

- [ ] Access Gate repository có Dockerfile.
- [ ] Có .env.example với các biến cần thiết.
- [ ] Có RUN_LOCAL.md hướng dẫn chạy service trên máy.
- [ ] Có docker-compose.yml nếu service cần database.
- [x] Collection không hardcode baseUrl hoặc authToken - dùng {{baseUrl}}, {{authToken}}.
- [ ] Service có thể gọi được Core Business endpoint (kết nối downstream).

## 9. Notes

### Boundary behavior
- Access control service phải kiểm tra thời gian hoặc policy. Nếu quẹt thẻ ngoài giờ:
  - Option 1: Accept nhưng có warning trong reason.
  - Option 2: Reject với status 403 và detail "outside allowed hours".
- Nhóm cần quyết định và ghi rõ.

### Consumer-side assumption
- Core Business mock chạy tại `http://localhost:4030`.
- Analytics mock chạy tại `http://localhost:4040`.
- Nếu port khác, cập nhật postman environment.

### Rate limiting
- OpenAPI có response 429 cho rate limit.
- Nếu implement rate limiting, viết test kiểm tra hành vi đó.
- Nếu chưa implement, ghi chú trong changelog.

### Card registration
- POST /cards endpoint để admin đăng ký thẻ mới.
- PUT /cards/{card_id} để update status (suspend, reactive).
- Test cả happy path lẫn error case (409 if card already exists).
