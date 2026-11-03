# Risk draft, Task 2: GET /items scoped to X-Owner

Written before any src or test edit.

## Review Focus items touched

- Cross-owner read: TOUCHED. This is the core of the task. `listItems(owner)` filters by exact owner string; GET /items passes only the header value. Covered by `GET /items > owner A never sees owner B's items` (alice2 posts, bob2 lists and sees none; alice2 lists and sees only hers).
- Missing or oversize title: NOT TOUCHED. GET has no body and no title; POST validation is unchanged from Task 1 and stays covered by test/post-items.test.js.
- Missing owner header: TOUCHED. GET /items without X-Owner must 401 before store access. The existing header check in `handle()` runs before routing, so GET inherits it. Covered by `GET /items > 401 when X-Owner is missing`.

## Security/privacy surfaces touched

- Ownership check on every item route: TOUCHED. GET /items selects items by the X-Owner header only; no query string, body field or path segment selects items. Covered by `owner A never sees owner B's items` and `ignores owner query param` (a `?owner=` on the URL must not change the result).
- Existence leak: NOT TOUCHED. GET /items is a list, not a by-id lookup; it returns an array (possibly empty) and never reveals whether another owner's item exists. PATCH is Task 3.
- Input validation on JSON bodies: NOT TOUCHED. GET /items reads no body.

## Other risks

- Shared module-level store across the test process: tests use owner names unique to this file (suffix `-get`) so POST tests in the other file cannot pollute counts.
- Insertion order: spec says newest last; `listItems` must return in push order, covered by `items appear after POST` asserting order of two posts.
