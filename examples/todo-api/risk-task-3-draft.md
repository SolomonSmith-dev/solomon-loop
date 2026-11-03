# Risk draft, Task 3: PATCH /items/:id marks an item done

Written before any src or test edit.

## Review Focus items touched

- Cross-owner read: TOUCHED. PATCH returns the updated item in the 200 body, so a PATCH that matched an item by id alone would both mutate and read another owner's item. The store lookup is scoped to the X-Owner value (`updateItem(owner, id, patch)`), so an id owned by someone else is treated as absent. Covered by `PATCH /items/:id > 404 when the id belongs to another owner, and that item is unchanged`.
- Missing or oversize title: NOT TOUCHED. PATCH reads only `done`; the title is never read or written by this route. Any `title` key in the PATCH body is ignored, which `round trip` asserts indirectly by checking the title is unchanged after PATCH. POST validation stays covered by test/post-items.test.js.
- Missing owner header: TOUCHED. PATCH without X-Owner must 401 before any store access. The existing header check in `handle()` runs before routing, so PATCH inherits it. Covered by `PATCH /items/:id > 401 when X-Owner is missing`.

## Security/privacy surfaces touched

- Ownership check on every item route: TOUCHED. The path id selects a candidate, but the X-Owner header still gates which items are visible: the store only updates an item whose `owner` equals the header. Covered by `404 when the id belongs to another owner`.
- Existence leak: TOUCHED. Unknown id and someone else's id both return 404 with the same `{ error: 'not found' }` body, so a caller cannot probe whether an id exists. Covered by `404 for an unknown id` and `404 when the id belongs to another owner` asserting the same status and the same error string.
- Input validation on JSON bodies: TOUCHED. Non-JSON body, non-object body (array, null, string), and `done` that is not a boolean (`"yes"`, `1`, missing) all return 400. Covered by `400 when done is not a boolean` (the `"yes"` case named in the plan's Fails-when), `400 when done is missing`, and `400 when the body is not JSON`. Body size is already capped by `readBody` (64 KiB) from Task 1.

## Other risks

- Shared module-level store across the test process: owner names in this file carry a `-patch` suffix so POST and GET tests cannot collide.
- Route matching: `/items/:id` must not match `/items` (handled by Task 1 and 2 routes) or `/items/a/b`. The route uses a single-segment match on the pathname.
- Store signature: the plan writes `updateItem(id, patch)`; the implementation takes `(owner, id, patch)` to keep ownership inside the store like `createItem` and `listItems`. Deviation reported.
