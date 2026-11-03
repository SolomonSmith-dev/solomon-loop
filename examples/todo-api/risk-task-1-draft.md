# Risk: Task 1 (POST /items with validation)

Written before any src/ or test/ file exists.

## Review Focus items touched

- Cross-owner read: NOT touched. Task 1 has no GET route; no read path exists yet. Task 2 owns it.
- Missing or oversize title: TOUCHED. Tests in test/post-items.test.js:
  - "400 when title is missing"
  - "400 when title is empty"
  - "400 when title is whitespace only"
  - "400 when title is not a string"
  - "400 when title is 121 characters"
  - "201 when title is 120 characters" (boundary, proves 120 is still accepted)
- Missing owner header: TOUCHED. Test "401 when X-Owner is missing" posts a valid body without the header and asserts 401; the handler checks the header before parsing the body or touching the store.

## Security/privacy surfaces touched

- Ownership check on every item route: TOUCHED for POST only. The item owner is taken from X-Owner and nothing else (body "owner" field is ignored). Test "201 happy path" asserts the returned owner equals the header value; test "ignores owner field in body" asserts a body owner is not honored.
- Existence leak: NOT touched. No lookup by id in Task 1 (PATCH is a later task).
- Input validation on JSON bodies: TOUCHED. Tests "400 when body is not JSON" and "400 when title is not a string"; oversize covered by the 121-char test.

## Mocks

None planned. Tests start the real node:http server on port 0 and use global fetch.
