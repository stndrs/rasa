//// Type-safe key-value tables backed by Erlang's [ETS][1]. Tables are
//// configured using a builder pattern, where you specify the table type
//// (`Set` or `OrderedSet`) and access level (`Public`, `Protected`, or
//// `Private`) before creating the table.
////
//// Requires OTP 27 or later.
////
//// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html

import gleam/erlang/reference.{type Reference}
import gleam/result

/// A `Table` builder. Defaults to `Set` and `Protected`, matching the
/// defaults specified by the [erlang ets module][1].
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#new/2
pub opaque type Builder {
  Builder(kind: Kind, access: Access)
}

/// The type of ETS table. `Set` tables have unordered keys. `OrderedSet`
/// tables maintain keys in sorted order.
pub type Kind {
  Set
  OrderedSet
}

/// The access level of an ETS table. `Public` allows any process to read and
/// write. `Protected` allows any process to read but only the owner to write.
/// `Private` restricts both reads and writes to the owning process.
pub type Access {
  Public
  Protected
  Private
}

/// Creates a new `Builder`. Defaults to `Set` and `Protected`.
pub fn build() -> Builder {
  Builder(kind: Set, access: Protected)
}

/// Sets the table type on the builder.
pub fn with_kind(builder: Builder, kind: Kind) -> Builder {
  Builder(..builder, kind:)
}

/// Sets the access level on the builder.
pub fn with_access(builder: Builder, access: Access) -> Builder {
  Builder(..builder, access:)
}

/// An ETS table for storing key/value pairs
pub opaque type Table(a, b) {
  Table(ref: Reference)
}

/// Creates a new ETS table from a `Builder`.
pub fn table(builder: Builder) -> Table(a, b) {
  ets_new_(builder.kind, builder.access) |> Table
}

/// Inserts a key and value into the table. If the key already exists, its
/// value is replaced with the new one.
pub fn insert(table: Table(a, b), key: a, value: b) -> Result(Nil, Nil) {
  ets_insert_(table.ref, key, value)
}

/// Inserts a key and value into the table only if the key does not already
/// exist. Returns `Error(Nil)` if the key is already present.
pub fn insert_new(table: Table(a, b), key: a, value: b) -> Result(Nil, Nil) {
  ets_insert_new_(table.ref, key, value)
}

/// Returns the value associated with the given key, or `Error(Nil)` if
/// the key does not exist.
pub fn lookup(table: Table(a, b), key: a) -> Result(b, Nil) {
  ets_lookup_(table.ref, key)
}

/// Returns the first key-value pair in the table without removing it from the
/// table. The order is guaranteed only for `OrderedSet` tables. See the
/// [ets docs][1] for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#first/1
pub fn first(table: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_first_lookup_(table.ref)
}

/// Returns the last key-value pair in the table without removing it from the
/// table. The order is guaranteed only for `OrderedSet` tables. See the
/// [ets docs][1] for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#last/1
pub fn last(table: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_last_lookup_(table.ref)
}

/// Returns all entries in the table as a list of key-value tuples.
pub fn to_list(table: Table(a, b)) -> Result(List(#(a, b)), Nil) {
  ets_to_list_(table.ref)
}

/// Determines whether or not the table is empty. Returns `True` if the table
/// does not exist.
pub fn is_empty(table: Table(a, b)) -> Bool {
  first(table)
  |> result.replace(False)
  |> result.unwrap(True)
}

/// Removes a key and its value from the table.
pub fn delete(table: Table(a, b), key: a) -> Result(Nil, Nil) {
  ets_delete_key_(table.ref, key)
}

/// Deletes the table.
pub fn drop(table: Table(a, b)) -> Result(Nil, Nil) {
  ets_delete_(table.ref)
}

/// Returns the size of the table.
pub fn size(table: Table(a, b)) -> Result(Int, Nil) {
  ets_info_(table.ref, Size)
}

/// Returns the table's `Kind` (`Set` or `OrderedSet`).
pub fn kind(table: Table(a, b)) -> Result(Kind, Nil) {
  ets_info_(table.ref, Type)
}

/// Returns the table's `Access` level (`Public`, `Protected`, or `Private`).
pub fn access(table: Table(a, b)) -> Result(Access, Nil) {
  ets_info_(table.ref, Protection)
}

type InfoItem {
  Size
  Type
  Protection
}

@external(erlang, "rasa_ffi", "ets_to_list")
fn ets_to_list_(table: Reference) -> Result(List(#(a, b)), Nil)

@external(erlang, "rasa_ffi", "ets_info")
fn ets_info_(table: Reference, item: InfoItem) -> Result(a, Nil)

@external(erlang, "rasa_ffi", "ets_new")
fn ets_new_(kind: Kind, access: Access) -> Reference

@external(erlang, "rasa_ffi", "ets_insert")
fn ets_insert_(table: Reference, key: a, val: b) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_insert_new")
fn ets_insert_new_(table: Reference, key: a, val: b) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_lookup")
fn ets_lookup_(table: Reference, key: a) -> Result(b, Nil)

@external(erlang, "rasa_ffi", "ets_first_lookup")
fn ets_first_lookup_(table: Reference) -> Result(#(a, b), Nil)

@external(erlang, "rasa_ffi", "ets_last_lookup")
fn ets_last_lookup_(table: Reference) -> Result(#(a, b), Nil)

@external(erlang, "rasa_ffi", "ets_delete")
fn ets_delete_(table: Reference) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_delete")
fn ets_delete_key_(table: Reference, key: a) -> Result(Nil, Nil)
