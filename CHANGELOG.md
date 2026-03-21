# Changelog

## v2.0.0

### Breaking changes

- The `rasa` module has been removed. All table functions have moved to
  `rasa/table`.
- Tables are now unnamed and identified by reference instead of by name.
- `table.new` now returns a `table.Builder` and `table.build` returns a table
- `queue.new` now returns a `queue.Builder` and `queue.build` returns a queue
- The `rasa/counter` module has been redesigned:
  - `counter.next` now returns `Int` instead of `Result(Int, Nil)`.
  - `counter.new` accepts `fn() -> Int` instead of `fn() -> Result(Int, Nil)`.
  - `counter.monotonic` has been renamed to `counter.monotonic_time` and its
    `TimeUnit` type has moved to the new `rasa/monotonic` module.
  - Counters are now backed by `rasa/atomic` (hardware atomics) instead of
    erlang `counters`.

### New modules

- `rasa/atomic` -- Atomic integers backed by Erlang's `atomics`.
  Supports `get`, `put`, `add`, `sub`, `add_get`, `sub_get`, `exchange`, and
  `compare_exchange`.
- `rasa/monotonic` -- Monotonic time and unique integer generation backed by
  Erlang's `monotonic_time/1` and `unique_integer/1`.

### New features

- `table.first` and `table.last` now use `ets:first_lookup/1` and
  `ets:last_lookup/1`.
- `counter.monotonic` returns a counter backed by strictly monotonically
  increasing unique integers, guaranteed to produce unique values on every
  call.
- `table.insert_new` inserts only if the key does not already exist.

## v1.0.0

- Initial release.
