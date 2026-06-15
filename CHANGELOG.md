# Changelog

## v3.0.0

### Breaking changes

- **`queue.with_counter` signature change**: The `counter` argument now expects a `fn() -> Counter` instead of a `Counter` value. This defers counter creation until `queue.build` is called.

### Fixed

- **`ets_delete_first` stack growth**: Restructured the internal Erlang FFI retry loop to be a proper tail call. This prevents unbounded stack growth under heavy contention on `Public` tables when another process deletes the first entry between lookup and removal.

### Changed

- Updated `gleam_stdlib` minimum version to 1.0.0

### New features

- **`table.delete_last` / `queue.pop_last`**: Remove and return the last entry of a table or queue. Combined with `delete_first`/`pop`, queues can now be used as double-ended queues. Like `delete_first`, the operation retries on `Public` tables if another process removes the last entry mid-operation.
- **`table.delete_first` is now public**: Previously internal, it removes and returns the first entry of a table directly (the same operation `queue.pop` uses). Pairs with the new `table.delete_last`.
- **`counter.atomic_with(start:, step:)`**: Create an atomic counter with a custom starting value and increment. `counter.atomic()` is equivalent to `counter.atomic_with(start: 1, step: 1)`.
- **`table.member`**: Check whether a key exists without copying its value out of the table. Returns `Ok(True)`/`Ok(False)`, or `Error(Nil)` if the table no longer exists.

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
