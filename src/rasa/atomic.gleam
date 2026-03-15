//// Atomic integers backed by Erlang's [atomics][1]. Each `Atomic` is a
//// single signed 64-bit integer that supports lock-free atomic operations.
//// All operations use hardware atomic instructions with no software locking.
////
//// [1]: https://www.erlang.org/doc/apps/erts/atomics.html

import gleam/erlang/reference.{type Reference}

/// A single atomic integer.
pub opaque type Atomic {
  Atomic(ref: Reference)
}

/// Creates a new `Atomic` initialized to 0.
pub fn new() -> Atomic {
  Atomic(ref: atomics_new_())
}

/// Returns the current value of the atomic.
pub fn get(atomic: Atomic) -> Int {
  atomics_get_(atomic.ref)
}

/// Sets the atomic to the given value.
pub fn put(atomic: Atomic, value: Int) -> Nil {
  atomics_put_(atomic.ref, value)
}

/// Adds the given value to the atomic.
pub fn add(atomic: Atomic, value: Int) -> Nil {
  atomics_add_(atomic.ref, value)
}

/// Atomically adds the given value to the atomic and returns the result.
pub fn add_get(atomic: Atomic, value: Int) -> Int {
  atomics_add_get_(atomic.ref, value)
}

/// Subtracts the given value from the atomic.
pub fn sub(atomic: Atomic, value: Int) -> Nil {
  atomics_sub_(atomic.ref, value)
}

/// Atomically subtracts the given value from the atomic and returns the
/// result.
pub fn sub_get(atomic: Atomic, value: Int) -> Int {
  atomics_sub_get_(atomic.ref, value)
}

/// Atomically replaces the value of the atomic with the given value and
/// returns the previous value.
pub fn exchange(atomic: Atomic, value: Int) -> Int {
  atomics_exchange_(atomic.ref, value)
}

/// Atomically compares the atomic with `expected`, and if equal, sets it to
/// `desired`. Returns `Ok(Nil)` if the swap succeeded, or `Error(actual)`
/// with the actual value if it did not match `expected`.
pub fn compare_exchange(
  atomic: Atomic,
  expected: Int,
  desired: Int,
) -> Result(Nil, Int) {
  atomics_compare_exchange_(atomic.ref, expected, desired)
}

@external(erlang, "rasa_ffi", "atomics_new")
fn atomics_new_() -> Reference

@external(erlang, "rasa_ffi", "atomics_get")
fn atomics_get_(ref: Reference) -> Int

@external(erlang, "rasa_ffi", "atomics_put")
fn atomics_put_(ref: Reference, value: Int) -> Nil

@external(erlang, "rasa_ffi", "atomics_add")
fn atomics_add_(ref: Reference, value: Int) -> Nil

@external(erlang, "rasa_ffi", "atomics_add_get")
fn atomics_add_get_(ref: Reference, value: Int) -> Int

@external(erlang, "rasa_ffi", "atomics_sub")
fn atomics_sub_(ref: Reference, value: Int) -> Nil

@external(erlang, "rasa_ffi", "atomics_sub_get")
fn atomics_sub_get_(ref: Reference, value: Int) -> Int

@external(erlang, "rasa_ffi", "atomics_exchange")
fn atomics_exchange_(ref: Reference, value: Int) -> Int

@external(erlang, "rasa_ffi", "atomics_compare_exchange")
fn atomics_compare_exchange_(
  ref: Reference,
  expected: Int,
  desired: Int,
) -> Result(Nil, Int)
