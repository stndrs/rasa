# rasa

Type-safe ETS tables, queues, and counters for Gleam.

[![Package Version](https://img.shields.io/hexpm/v/rasa)](https://hex.pm/packages/rasa)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/rasa/)

## Install

Requires OTP 27 or later.

```sh
gleam add rasa@2
```

## Usage

### Tables

Key-value stores backed by ETS. Configure the table type (`Set` or `OrderedSet`) and access level (`Public`, `Protected`, or `Private`) using the builder pattern.

```gleam
import rasa/table

pub fn main() -> Nil {
  let tabula = table.build()
  |> table.with_kind(table.Set)
  |> table.with_access(table.Private)
  |> table.new

  let assert Ok(Nil) = table.insert(tabula, "nature", 30)
  let assert Ok(Nil) = table.insert(tabula, "nurture", 70)

  // insert_new only inserts if the key doesn't already exist
  let assert Error(Nil) = table.insert_new(tabula, "nature", 0)
  let assert Ok(30) = table.lookup(tabula, "nature")
}
```

### Queues

FIFO queues backed by ordered ETS tables. Each queue requires a counter to generate indices.

```gleam
import rasa/counter
import rasa/queue
import rasa/table

pub fn main() -> Nil {
  let q = queue.new(counter.atomic(), table.Private)

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
import rasa/monotonic

pub fn main() -> Nil {
  // Atomic counter that increments by 1 each call
  let c = counter.atomic()
  let assert 1 = counter.next(c)
  let assert 2 = counter.next(c)

  // Monotonic time counter with nanosecond precision
  let m = counter.monotonic_time(monotonic.Nanosecond)
  let _t = counter.next(m)

  // Monotonic counter with guaranteed unique values
  let u = counter.monotonic()
  let _v = counter.next(u)

  // Custom counter from any function
  let always_99 = counter.new(fn() { 99 })
  let assert 99 = counter.next(always_99)
}
```

Further documentation can be found at <https://hexdocs.pm/rasa>.

## Development

```sh
gleam test  # Run the tests
```
