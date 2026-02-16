import gleam/result

pub opaque type Counter {
  Counter(handle_next: fn() -> Result(Int, Nil))
}

type TimeUnit {
  Nanosecond
}

type AtomicsRef

/// Returns a `Counter` that increases by 1 every time it's passed to `next`
pub fn integer() -> Result(Counter, Nil) {
  use ref <- result.map(counters_new_(1))

  let handle_next = fn() {
    counters_add_(ref, 1, 1)
    |> result.try(fn(_) { counters_get_(ref, 1) })
  }

  Counter(handle_next:)
}

/// Returns a `Counter` tied to erlang's [monotonic_time][1]. This counter
/// will provide monotonically increasing time values, but consecutive calls
/// to `next` can return the same result.
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/0
pub fn monotonic() -> Counter {
  Counter(handle_next: fn() { Ok(monotonic_time_(Nanosecond)) })
}

/// Returns the next integer value for the `Counter`.
pub fn next(counter: Counter) -> Result(Int, Nil) {
  counter.handle_next()
}

@external(erlang, "rasa_ffi", "counters_new")
fn counters_new_(size: Int) -> Result(AtomicsRef, Nil)

@external(erlang, "rasa_ffi", "counters_add")
fn counters_add_(ref: AtomicsRef, idx: Int, num: Int) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "counters_get")
fn counters_get_(ref: AtomicsRef, idx: Int) -> Result(Int, Nil)

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time_(unit: TimeUnit) -> Int
