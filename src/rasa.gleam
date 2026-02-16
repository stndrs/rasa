import gleam/erlang/atom.{type Atom}
import gleam/int
import gleam/result
import gleam/string

/// A `Table` builder. Defaults to `set` and `protected` matching the
/// default options specified by the [erlang ets module]. [1]
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#new/2
pub opaque type Builder {
  Builder(name: String, kind: Kind, access: Access)
}

pub type Kind {
  Set
  OrderedSet
}

pub type Access {
  Public
  Protected
  Private
}

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

/// An ETS table
pub opaque type Table(a, b) {
  Table(name: Atom)
}

/// Returns a new `Table` table
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
pub fn insert(store: Table(a, b), key: a, value: b) -> Result(Nil, Nil) {
  ets_insert_(store.name, key, value)
}

/// Returns the value associated with the provided key.
pub fn lookup(store: Table(a, b), key: a) -> Result(b, Nil) {
  ets_lookup_(store.name, key)
}

/// Returns the first item in the table without removing it from the table.
/// The order is guaranteed only for `OrderedSet` tables. See the [ets docs][1]
/// for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#first/1
pub fn first(rasa: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_first_lookup_(rasa.name)
}

/// Returns the last item in the table without removing it from the table.
/// The order is guaranteed only for `OrderedSet` tables. See the [ets docs][1]
/// for more details.
///
/// [1]: https://www.erlang.org/doc/apps/stdlib/ets.html#first/1
pub fn last(rasa: Table(a, b)) -> Result(#(a, b), Nil) {
  ets_last_lookup_(rasa.name)
}

/// Returns the table as a list of keys and values
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
pub fn delete(store: Table(a, b), key: a) -> Result(Nil, Nil) {
  ets_delete_key_(store.name, key)
}

/// Deletes the table.
pub fn drop(store: Table(a, b)) -> Result(Nil, Nil) {
  ets_delete_(store.name)
}

/// Returns the size of the table.
pub fn size(rasa: Table(a, b)) -> Result(Int, Nil) {
  ets_info_(rasa.name, Size)
}

pub fn kind(rasa: Table(a, b)) -> Result(Kind, Nil) {
  ets_info_(rasa.name, Type)
}

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
