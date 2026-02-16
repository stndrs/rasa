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

Key-value stores backed by ETS. Configure the table type (`set` or `ordered_set`) and access level (`public`, `protected`, or `private`) using the builder pattern.

```gleam
import rasa

pub fn main() -> Nil {
  let tabula = rasa.build("blank_slate")
  |> rasa.set
  |> rasa.private
  |> rasa.table

  let assert Ok(Nil) = rasa.insert(tabula, "nature", 30)
  let assert Ok(Nil) = rasa.insert(tabula, "nurture", 70)

  let assert Ok(30) = rasa.lookup(tabula, "nature")
  let assert Ok(70) = rasa.lookup(tabula, "nurture")
}
```

### Queues

FIFO queues backed by ordered ETS tables. Each queue requires a counter to generate indices.

```gleam
import rasa
import rasa/counter
import rasa/queue

pub fn main() -> Nil {
  let q = rasa.build("tasks")
  |> rasa.private
  |> queue.new(counter.integer())

  let assert Ok(_) = queue.push(q, "first")
  let assert Ok(_) = queue.push(q, "second")

  let assert Ok("first") = queue.pop(q)
  let assert Ok("second") = queue.pop(q)
}
```

### Counters

Atomic counters for generating sequential or time-based indices.

```gleam
import rasa/counter

pub fn main() -> Nil {
  // Incrementing integer counter
  let c = counter.integer()
  let assert Ok(1) = counter.next(c)
  let assert Ok(2) = counter.next(c)

  // Monotonic time counter with nanosecond precision
  let m = counter.monotonic()
  let assert Ok(_timestamp) = counter.next(m)
}
```

Further documentation can be found at <https://hexdocs.pm/rasa>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
