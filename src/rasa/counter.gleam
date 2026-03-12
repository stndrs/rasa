//// Counters for generating sequential integer values. Counters are used by
//// `rasa/queue` to index entries but can also be used on their own. Use
//// `atomic` for a simple incrementing counter, `monotonic` for
//// nanosecond-precision monotonic time values, or `new` to supply a custom
//// function.

import rasa/atomic
import rasa/monotonic

/// A counter that produces integer values.
pub opaque type Counter {
  Counter(handle_next: fn() -> Int)
}

/// Creates a `Counter` from a custom function. The function is called each
/// time the counter is passed to `counter.next`.
pub fn new(handle_next: fn() -> Int) -> Counter {
  Counter(handle_next:)
}

/// Returns an atomic `Counter` that increases by 1 every time it's passed to
/// `next`. Backed by `rasa/atomic`, each call to `next` is a single atomic
/// add-and-get operation with no race conditions.
pub fn atomic() -> Counter {
  let a = atomic.new()

  Counter(handle_next: fn() { atomic.add_get(a, 1) })
}

/// Returns a `Counter` tied to erlang's [monotonic_time][1]. This counter
/// will provide monotonically increasing time values, but consecutive calls
/// to `next` _may_ return the same result.
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/1
pub fn monotonic(unit: monotonic.TimeUnit) -> Counter {
  Counter(handle_next: fn() { monotonic.time(unit) })
}

/// Returns the next value from the `Counter`.
pub fn next(counter: Counter) -> Int {
  counter.handle_next()
}
