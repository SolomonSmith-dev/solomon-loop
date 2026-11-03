# Todo API spec

A single-process HTTP API, no dependencies beyond node:http, in-memory storage.
Items have three fields: owner (string), title (string), done (boolean, default false). The server assigns an id.
The caller identifies itself with the X-Owner request header. A request with no X-Owner header is rejected with 401.
POST /items creates an item for the calling owner from a JSON body {"title": "..."}. Returns 201 with the item.
Title must be a string of 1 to 120 characters after trimming. Anything else is rejected with 400 and a JSON error.
GET /items returns 200 with only the calling owner's items, newest last. Another owner's items never appear.
PATCH /items/:id sets done from the JSON body {"done": true|false}. Only the item's owner may change it.
An item that does not exist, or belongs to another owner, returns 404 from PATCH (no existence leak).
Bodies that are not valid JSON return 400. Unknown routes return 404.
Tests use node:test and run with `node --test test/`, starting the server on an ephemeral port.
