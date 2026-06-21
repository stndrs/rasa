//// Counters for generating sequential integer values. Counters are used by
//// `rasa/queue` to index entries but can also be used on their own. Use
//// `atomic` for a simple incrementing counter, `from_atomic` for a custom
//// atomic counter, `monotonic` for guaranteed unique monotonic values,
//// `monotonic_time` for time-based monotonic values, or `new` to supply a
//// custom function.

import rasa/atomic.{type Atomic}
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
  from_atomic(atomic.new(), atomic.add_get(_, 1))
}

/// Creates a `Counter` from an existing `Atomic` and a function describing how
/// to produce the next value from it. The `handle_next` function receives the
/// `Atomic` and is called each time the counter is passed to `next`.
///
/// Useful for custom step sizes or starting values, or when you need to retain
/// a reference to the underlying `Atomic` (e.g. to read or reset it):
///
/// ```gleam
/// let a = atomic.new()
/// let c = counter.from_atomic(a, atomic.add_get(_, 2))
/// ```
pub fn from_atomic(atomic: Atomic, handle_next: fn(Atomic) -> Int) -> Counter {
  Counter(handle_next: fn() { handle_next(atomic) })
}

/// Returns a `Counter` tied to erlang's [monotonic_time][1]. This counter
/// will provide monotonically increasing time values, but consecutive calls
/// to `next` _may_ return the same result.
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang.html#monotonic_time/1
pub fn monotonic_time(unit: monotonic.TimeUnit) -> Counter {
  Counter(handle_next: fn() { monotonic.time(unit) })
}

/// Returns a `Counter` backed by [strictly monotonically increasing][1] unique
/// integers. Unlike `monotonic_time`, consecutive calls to `next` are
/// **guaranteed** to produce strictly increasing values. Backed by erlang's
/// [unique_integer/1][2], these are more expensive to call than `monotonic_time`.
///
/// [1]: https://www.erlang.org/doc/apps/erts/time_correction.html#strictly-monotonically-increasing
/// [2]: https://www.erlang.org/doc/apps/erts/erlang.html#unique_integer/1
pub fn monotonic() -> Counter {
  Counter(handle_next: fn() { monotonic.unique() })
}

/// Returns the next value from the `Counter`.
pub fn next(counter: Counter) -> Int {
  counter.handle_next()
}
