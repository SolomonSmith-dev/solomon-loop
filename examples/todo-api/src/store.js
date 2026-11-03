import { randomUUID } from 'node:crypto';

const items = [];

export function createItem(owner, title) {
  const item = { id: randomUUID(), owner, title, done: false };
  items.push(item);
  return item;
}

// Only the given owner's items, in insertion order (newest last).
export function listItems(owner) {
  return items.filter((item) => item.owner === owner);
}

// Applies `patch` to the item with this id if it belongs to `owner`.
// Returns the updated item, or null when no item of this owner has that id
// (an unknown id and another owner's id look the same to the caller).
export function updateItem(owner, id, patch) {
  const item = items.find((i) => i.id === id && i.owner === owner);
  if (!item) return null;
  Object.assign(item, patch);
  return item;
}
