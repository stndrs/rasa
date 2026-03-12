/// The time unit for a `monotonic` counter. This is passed directly to
/// Erlang's [monotonic_time][1].
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/1
pub type TimeUnit {
  /// Monotonic time in seconds.
  Second
  /// Monotonic time in milliseconds.
  Millisecond
  /// Monotonic time in microseconds.
  Microsecond
  /// Monotonic time in nanoseconds.
  Nanosecond
  /// Native time unit used by the erlang runtime system.
  Native
}

/// Returns the next value from the `Counter`.
pub fn time(unit: TimeUnit) -> Int {
  monotonic_time_(unit)
}

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time_(unit: TimeUnit) -> Int
