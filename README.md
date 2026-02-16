# rasa

Type-safe ETS tables, queues, and counters for Gleam.

[![Package Version](https://img.shields.io/hexpm/v/rasa)](https://hex.pm/packages/rasa)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/rasa/)

## Install

```sh
gleam add rasa@1
```

## Usage

### Tables

Key-value stores backed by ETS. Configure the table type (`Set` or `OrderedSet`) and access level (`Public`, `Protected`, or `Private`) using the builder pattern.

```gleam
import rasa

pub fn main() -> Nil {
  let tabula = rasa.build("blank_slate")
  |> rasa.with_kind(rasa.Set)
  |> rasa.with_access(rasa.Private)
  |> rasa.table

  let assert Ok(Nil) = rasa.insert(tabula, "nature", 30)
  let assert Ok(Nil) = rasa.insert(tabula, "nurture", 70)

  // insert_new only inserts if the key doesn't already exist
  let assert Error(Nil) = rasa.insert_new(tabula, "nature", 0)
  let assert Ok(30) = rasa.lookup(tabula, "nature")
}
```

### Queues

FIFO queues backed by ordered ETS tables. Each queue requires a counter to generate indices.

```gleam
import rasa
import rasa/counter
import rasa/queue

pub fn main() -> Nil {
  let q = queue.build("tasks")
  |> queue.with_access(rasa.Private)
  |> queue.new(counter.atomic())

  let assert Ok(1) = queue.push(q, "first")
  let assert Ok(2) = queue.push(q, "second")

  // Remove an item by index without popping
  let assert Ok(Nil) = queue.delete(q, 1)

  let assert Ok("second") = queue.pop(q)
}
```

### Counters

Atomic counters for generating sequential or time-based indices.

```gleam
import rasa/counter

pub fn main() -> Nil {
  // Atomic counter that increments by 1 each call
  let c = counter.atomic()
  let assert Ok(1) = counter.next(c)
  let assert Ok(2) = counter.next(c)

  // Monotonic time counter with nanosecond precision
  let m = counter.monotonic(counter.Nanosecond)
  let assert Ok(_t) = counter.next(m)

  // Custom counter from any function
  let always_99 = counter.new(fn() { Ok(99) })
  let assert Ok(99) = counter.next(always_99)
}
```

Further documentation can be found at <https://hexdocs.pm/rasa>.

## Development

```sh
gleam test  # Run the tests
```
