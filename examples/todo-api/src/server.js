import http from 'node:http';
import { createItem, listItems, updateItem } from './store.js';

const MAX_TITLE = 120;
const MAX_BODY_BYTES = 64 * 1024;

function send(res, status, payload) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    let size = 0;
    req.setEncoding('utf8');
    req.on('data', (chunk) => {
      size += Buffer.byteLength(chunk);
      if (size > MAX_BODY_BYTES) {
        reject(new Error('body too large'));
        req.destroy();
        return;
      }
      body += chunk;
    });
    req.on('end', () => resolve(body));
    req.on('error', reject);
  });
}

// Returns { body } when the request body is a JSON object, else { error }.
async function parseJsonObject(req) {
  let body;
  try {
    body = JSON.parse(await readBody(req));
  } catch {
    return { error: 'body must be valid JSON' };
  }
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    return { error: 'body must be a JSON object' };
  }
  return { body };
}

// Returns { title } on success or { error } on failure.
function validateTitle(input) {
  if (typeof input !== 'string') return { error: 'title must be a string' };
  const title = input.trim();
  if (title.length < 1) return { error: 'title must not be empty' };
  if (title.length > MAX_TITLE) return { error: `title must be at most ${MAX_TITLE} characters` };
  return { title };
}

async function handle(req, res) {
  const owner = req.headers['x-owner'];
  if (typeof owner !== 'string' || owner.trim() === '') {
    return send(res, 401, { error: 'X-Owner header required' });
  }

  const url = new URL(req.url, 'http://localhost');

  if (req.method === 'GET' && url.pathname === '/items') {
    return send(res, 200, listItems(owner));
  }

  if (req.method === 'POST' && url.pathname === '/items') {
    const parsed = await parseJsonObject(req);
    if (parsed.error) return send(res, 400, { error: parsed.error });
    const result = validateTitle(parsed.body.title);
    if (result.error) return send(res, 400, { error: result.error });
    return send(res, 201, createItem(owner, result.title));
  }

  const itemMatch = /^\/items\/([^/]+)$/.exec(url.pathname);
  if (req.method === 'PATCH' && itemMatch) {
    const parsed = await parseJsonObject(req);
    if (parsed.error) return send(res, 400, { error: parsed.error });
    if (typeof parsed.body.done !== 'boolean') {
      return send(res, 400, { error: 'done must be a boolean' });
    }
    const item = updateItem(owner, itemMatch[1], { done: parsed.body.done });
    if (!item) return send(res, 404, { error: 'not found' });
    return send(res, 200, item);
  }

  return send(res, 404, { error: 'not found' });
}

export function createServer() {
  return http.createServer((req, res) => {
    handle(req, res).catch(() => send(res, 500, { error: 'internal error' }));
  });
}
