import gleam/erlang/atom.{type Atom}
import gleam/int
import gleam/result
import gleam/string

/// A `Table` builder. Defaults to `Set` and `Protected`, matching the
/// defaults specified by the [erlang ets module][1].
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#new/2
pub opaque type Builder {
  Builder(name: String, kind: Kind, access: Access)
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

/// Creates a new `Builder` with the given name. Defaults to `Set` and
/// `Protected`.
pub fn build(name: String) -> Builder {
  Builder(name:, kind: Set, access: Protected)
}

/// Configures the builder to create a `set` table.
pub fn set(builder: Builder) -> Builder {
  Builder(..builder, kind: Set)
}

/// Configures the builder to create an `ordered_set` table.
pub fn ordered_set(builder: Builder) -> Builder {
  Builder(..builder, kind: OrderedSet)
}

/// Configures the builder to create a `public` table.
pub fn public(builder: Builder) -> Builder {
  Builder(..builder, access: Public)
}

/// Configures the builder to create a `protected` table.
pub fn protected(builder: Builder) -> Builder {
  Builder(..builder, access: Protected)
}

/// Configures the builder to create a `private` table.
pub fn private(builder: Builder) -> Builder {
  Builder(..builder, access: Private)
}

/// An ETS table for storing key/value pairs
pub opaque type Table(a, b) {
  Table(name: Atom)
}

/// Creates a new ETS table from a `Builder`. The table name is suffixed with
/// a unique integer to avoid name collisions. The table name is converted to
/// an atom which is used as the table identifier.
pub fn table(builder: Builder) -> Table(a, b) {
  let name =
    builder.name
    |> string.append(int.to_string(unique_int_()))
    |> atom.create
    |> ets_new_(builder.kind, builder.access)

  Table(name:)
}

/// Inserts a key and value into the table. If the key already exists, its
/// value is replaced with the new one.
pub fn insert(table: Table(a, b), key: a, value: b) -> Result(Nil, Nil) {
  ets_insert_(table.name, key, value)
}

pub fn insert_new(table: Table(a, b), key: a, value: b) -> Result(Nil, Nil) {
  ets_insert_new_(table.name, key, value)
}

/// Returns the value associated with the given key, or `Error(Nil)` if
/// the key does not exist.
pub fn lookup(table: Table(a, b), key: a) -> Result(b, Nil) {
  ets_lookup_(table.name, key)
}

/// Returns the first key-value pair in the table without removing it from the
/// table. The order is guaranteed only for `OrderedSet` tables. See the
/// [ets docs][1] for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#first/1
pub fn first(rasa: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_first_lookup_(rasa.name)
}

/// Returns the last key-value pair in the table without removing it from the
/// table. The order is guaranteed only for `OrderedSet` tables. See the
/// [ets docs][1] for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#last/1
pub fn last(rasa: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_last_lookup_(rasa.name)
}

/// Returns all entries in the table as a list of key-value tuples.
pub fn to_list(rasa: Table(a, b)) -> Result(List(#(a, b)), Nil) {
  ets_to_list_(rasa.name)
}

/// Determines whether or not the table is empty. Returns True if the table
/// does not exist.
pub fn is_empty(rasa: Table(a, b)) -> Bool {
  first(rasa)
  |> result.replace(False)
  |> result.unwrap(True)
}

/// Removes a key and its value from the table.
pub fn delete(table: Table(a, b), key: a) -> Result(Nil, Nil) {
  ets_delete_key_(table.name, key)
}

/// Deletes the table.
pub fn drop(table: Table(a, b)) -> Result(Nil, Nil) {
  ets_delete_(table.name)
}

/// Returns the size of the table.
pub fn size(rasa: Table(a, b)) -> Result(Int, Nil) {
  ets_info_(rasa.name, Size)
}

/// Returns the table's `Kind` (`Set` or `OrderedSet`).
pub fn kind(rasa: Table(a, b)) -> Result(Kind, Nil) {
  ets_info_(rasa.name, Type)
}

/// Returns the table's `Access` level (`Public`, `Protected`, or `Private`).
pub fn access(rasa: Table(a, b)) -> Result(Access, Nil) {
  ets_info_(rasa.name, Protection)
}

type InfoItem {
  Size
  Type
  Protection
}

@external(erlang, "rasa_ffi", "ets_to_list")
fn ets_to_list_(name: Atom) -> Result(List(#(a, b)), Nil)

@external(erlang, "rasa_ffi", "ets_info")
fn ets_info_(name: Atom, item: InfoItem) -> Result(a, Nil)

@external(erlang, "rasa_ffi", "ets_new")
fn ets_new_(name: Atom, kind: Kind, access: Access) -> Atom

@external(erlang, "rasa_ffi", "ets_insert")
fn ets_insert_(name: Atom, key: a, val: b) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_insert_new")
fn ets_insert_new_(name: Atom, key: a, val: b) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_lookup")
fn ets_lookup_(name: Atom, key: a) -> Result(b, Nil)

@external(erlang, "rasa_ffi", "ets_first_lookup")
fn ets_first_lookup_(name: Atom) -> Result(#(a, b), Nil)

@external(erlang, "rasa_ffi", "ets_last_lookup")
fn ets_last_lookup_(name: Atom) -> Result(#(a, b), Nil)

@external(erlang, "rasa_ffi", "ets_delete")
fn ets_delete_(name: Atom) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "ets_delete")
fn ets_delete_key_(name: Atom, key: a) -> Result(Nil, Nil)

@external(erlang, "rasa_ffi", "unique_int")
fn unique_int_() -> Int
