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

/// Returns the current monotonic time in the given `TimeUnit`.
pub fn time(unit: TimeUnit) -> Int {
  monotonic_time_(unit)
}

/// Returns a unique integer that is monotonically ordered. Consecutive calls
/// are guaranteed to produce strictly increasing values, unlike `time` which
/// may return the same value from consecutive calls. Backed by erlang's
/// [unique_integer/1][1]. These are [strictly monotonically increasing][2]
/// integers which are expensive to generate.
///
/// [1]: https://www.erlang.org/doc/apps/erts/erlang#unique_integer/1
/// [2]: https://www.erlang.org/docs/24/apps/erts/time_correction#Strictly_Monotonically_Increasing
pub fn unique() -> Int {
  monotonic_unique_int_()
}

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time_(unit: TimeUnit) -> Int

@external(erlang, "rasa_ffi", "monotonic_unique_int")
fn monotonic_unique_int_() -> Int
