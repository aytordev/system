# Immutability Catalog

Reference card for fixing mutation bugs: `readonly` typing, plus the immutable
alternative to every common array and object mutation. The directive lives in
[keep domain data immutable](../rules/immutability-domain-data.md).

---

## Readonly Typing

Use `readonly` on data structures whose contract is immutable. Local
implementation state may stay mutable when it is encapsulated and clearer.

### Properties and arrays

```typescript
// ✅ Immutable contract
type Scenario = {
  readonly id: string;
  readonly name: string;
  readonly mocks: ReadonlyArray<Mock>;
};

// ⚠️ Mutable — appropriate only when callers are allowed to mutate it
type Scenario = {
  id: string;
  mocks: Mock[];
};
```

`readonly Mock[]` and `ReadonlyArray<Mock>` are equivalent; pick the one the
project already uses.

### Nested readonly

```typescript
type Mock = {
  readonly method: 'GET' | 'POST';
  readonly response: {
    readonly status: number;
    readonly body: readonly unknown[];
  };
};
```

Nested object literals need their own `readonly`: the modifier is shallow.

### Why the modifier earns its place

- The compiler rejects mutation attempts instead of trusting prose.
- It documents intent at the declaration, where callers read it.
- It removes accidental mutation from the list of things to debug.

---

## Immutable Array Operations

```typescript
// ⚠️ MUTATING — avoid when the caller still holds the array
items.push(newItem);      // add to end
items.pop();              // remove last
items.unshift(newItem);   // add to start
items.shift();            // remove first
items.splice(index, 1);   // remove at index
items.reverse();          // reverse order
items.sort();             // sort
items[i] = newValue;      // update at index

// ✅ Immutable alternatives
const withNew = [...items, newItem];
const withoutLast = items.slice(0, -1);
const withFirst = [newItem, ...items];
const withoutFirst = items.slice(1);
const withoutIndex = [...items.slice(0, index), ...items.slice(index + 1)];
const reversed = [...items].reverse();
const sorted = [...items].sort(compare);
const updated = items.map((item, i) => (i === index ? newValue : item));
```

`toSorted()`, `toReversed()`, and `toSpliced()` avoid the copy when the runtime
supports them; check the project's target before using them.

### Common patterns

```typescript
const withoutItem = items.filter((item) => item.id !== targetId);

const replaced = items.map((item) =>
  item.id === targetId ? newItem : item,
);

const inserted = [
  ...items.slice(0, index),
  newItem,
  ...items.slice(index),
];
```

---

## Immutable Object Updates

```typescript
// ⚠️ MUTATING
user.name = 'New';
Object.assign(user, { name: 'New' });

// ✅ Immutable
const updated = { ...user, name: 'New' };
```

`Object.assign(target, source)` mutates `target`. The non-mutating form is
`Object.assign({}, ...sources)` or a spread.

---

## Nested Updates

```typescript
// Nested object inside an array
const updatedCart = {
  ...cart,
  items: cart.items.map((item, i) =>
    i === targetIndex ? { ...item, quantity: newQuantity } : item,
  ),
};

// Nested array inside an object
const updatedOrder = {
  ...order,
  items: [
    ...order.items.slice(0, index),
    updatedItem,
    ...order.items.slice(index + 1),
  ],
};
```

A deep spread does not exist in the language. Copy each level you change, and
consider a structural-sharing helper only when the depth makes the copies
unreadable.

---

## Accidental Mutation Checklist

- `array.sort()` / `reverse()` without a copy — mutates the caller's array.
- `Object.assign(entity, patch)` — mutates `entity`.
- A helper that writes into its argument and also returns it.
- `const copy = { ...value }` where `value.nested` is then mutated — a shallow
  copy shares nested objects.
- Class fields mutated by a method that reads like a query.
- `Map`/`Set` values mutated after being returned to a caller.
