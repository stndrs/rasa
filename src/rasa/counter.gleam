//// Atomic counters for generating sequential integer values. Counters are
//// used by `rasa/queue` to index entries but can also be used on their own.
//// Use `atomic` for a simple incrementing counter, `monotonic` for
//// nanosecond-precision monotonic time values, or `new` to supply a custom
//// function.

import gleam/result

/// A counter that produces integer values.
pub opaque type Counter {
  Counter(handle_next: fn() -> Result(Int, Nil))
}

/// Creates a `Counter` from a custom function. The function is called each
/// time `next` is invoked and should return the next integer value.
pub fn new(handle_next: fn() -> Result(Int, Nil)) -> Counter {
  Counter(handle_next:)
}

type TimeUnit {
  Nanosecond
}

type AtomicsRef

/// Returns an atomic `Counter` that increases by 1 every time it's passed to
/// `next`.
pub fn atomic() -> Counter {
  let ref = counters_new_(1)

  let handle_next = fn() {
    counters_add_(ref, 1, 1)
    |> result.try(fn(_) { counters_get_(ref, 1) })
  }

  Counter(handle_next:)
}

/// Returns a `Counter` tied to erlang's [monotonic_time][1]. This counter
/// will provide monotonically increasing time values, but consecutive calls
/// to `next` _may_ return the same result.
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/0
pub fn monotonic() -> Counter {
  Counter(handle_next: fn() { Ok(monotonic_time_(Nanosecond)) })
}

/// Returns the next value from the `Counter`.
pub fn next(counter: Counter) -> Result(Int, Nil) {
  counter.handle_next()
}

@external(erlang, "rasa_ffi", "counters_new")
fn counters_new_(size: Int) -> AtomicsRef

@external(erlang, "rasa_ffi", "counters_add")
fn counters_add_(ref: AtomicsRef, idx: Int, num: Int) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "counters_get")
fn counters_get_(ref: AtomicsRef, idx: Int) -> Result(Int, Nil)

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time_(unit: TimeUnit) -> Int
