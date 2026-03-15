import rasa/table

pub fn insert_test() {
  let t = table.build() |> table.table

  let assert Ok(Nil) = table.insert(t, "key", 10)
}

pub fn insert_new_test() {
  let t = table.build() |> table.table

  let assert Ok(Nil) = table.insert_new(t, "key", 10)
}

pub fn insert_new_error_test() {
  let t = table.build() |> table.table

  let assert Ok(Nil) = table.insert_new(t, "key", 10)
  let assert Error(Nil) = table.insert_new(t, "key", 20)
}

pub fn lookup_test() {
  let t = table.build() |> table.table

  let assert Ok(_) = table.insert(t, "key", 10)

  let assert Ok(10) = table.lookup(t, "key")
}

pub fn delete_test() {
  let t = table.build() |> table.table

  let assert Ok(_) = table.insert(t, "key", 10)
  let assert Ok(10) = table.lookup(t, "key")
  let assert Ok(Nil) = table.delete(t, "key")
  let assert Error(Nil) = table.lookup(t, "key")
}

pub fn drop_test() {
  let t = table.build() |> table.table

  let assert Ok(_) = table.insert(t, "key", 10)
  let assert Ok(10) = table.lookup(t, "key")
  let assert Ok(Nil) = table.drop(t)
  let assert Error(Nil) = table.lookup(t, "key")
}

pub fn first_test() {
  let t =
    table.build()
    |> table.with_kind(table.OrderedSet)
    |> table.table

  let assert Ok(Nil) = table.insert(t, "a", 10)
  let assert Ok(Nil) = table.insert(t, "b", 20)

  let assert Ok(#("a", 10)) = table.first(t)
}

pub fn first_empty_test() {
  let t = table.build() |> table.table

  let assert Error(Nil) = table.first(t)
}

pub fn last_test() {
  let t =
    table.build()
    |> table.with_kind(table.OrderedSet)
    |> table.table

  let assert Ok(Nil) = table.insert(t, "a", 10)
  let assert Ok(Nil) = table.insert(t, "b", 20)

  let assert Ok(#("b", 20)) = table.last(t)
}

pub fn last_empty_test() {
  let t = table.build() |> table.table

  let assert Error(Nil) = table.last(t)
}

pub fn to_list_test() {
  let t =
    table.build()
    |> table.with_kind(table.OrderedSet)
    |> table.table

  let assert Ok([]) = table.to_list(t)

  let assert Ok(Nil) = table.insert(t, "a", 10)

  let assert Ok([#("a", 10)]) = table.to_list(t)

  let assert Ok(Nil) = table.insert(t, "b", 20)

  let assert Ok([#("a", 10), #("b", 20)]) = table.to_list(t)
}

pub fn is_empty_test() {
  let t = table.build() |> table.table

  let assert True = table.is_empty(t)

  let assert Ok(Nil) = table.insert(t, "a", 10)

  let assert False = table.is_empty(t)

  let assert Ok(Nil) = table.delete(t, "a")

  let assert True = table.is_empty(t)
}

pub fn dropped_table_is_empty_test() {
  let t = table.build() |> table.table

  let assert True = table.is_empty(t)

  let assert Ok(Nil) = table.drop(t)

  let assert True = table.is_empty(t)
}

pub fn size_test() {
  let t = table.build() |> table.table

  let assert Ok(0) = table.size(t)

  let assert Ok(Nil) = table.insert(t, "a", 10)

  let assert Ok(1) = table.size(t)

  let assert Ok(Nil) = table.insert(t, "b", 10)

  let assert Ok(2) = table.size(t)
}

pub fn private_test() {
  let t =
    table.build()
    |> table.with_access(table.Private)
    |> table.table

  let assert Ok(table.Private) = table.access(t)
}

pub fn protected_test() {
  let t =
    table.build()
    |> table.with_access(table.Protected)
    |> table.table

  let assert Ok(table.Protected) = table.access(t)
}

pub fn public_test() {
  let t =
    table.build()
    |> table.with_access(table.Public)
    |> table.table

  let assert Ok(table.Public) = table.access(t)
}

pub fn set_test() {
  let t =
    table.build()
    |> table.with_kind(table.Set)
    |> table.table

  let assert Ok(table.Set) = table.kind(t)
}

pub fn ordered_set_test() {
  let t =
    table.build()
    |> table.with_kind(table.OrderedSet)
    |> table.table

  let assert Ok(table.OrderedSet) = table.kind(t)
}
