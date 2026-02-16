import gleeunit
import rasa

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn insert_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.table

  let assert Ok(Nil) = rasa.insert(table, "key", 10)
}

pub fn lookup_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(_) = rasa.insert(table, "key", 10)

  let assert Ok(10) = rasa.lookup(table, "key")
}

pub fn delete_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(_) = rasa.insert(table, "key", 10)

  let assert Ok(10) = rasa.lookup(table, "key")

  let assert Ok(Nil) = rasa.delete(table, "key")

  let assert Error(Nil) = rasa.lookup(table, "key")
}

pub fn drop_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(_) = rasa.insert(table, "key", 10)

  let assert Ok(10) = rasa.lookup(table, "key")

  let assert Ok(Nil) = rasa.drop(table)

  let assert Error(Nil) = rasa.lookup(table, "key")
}

pub fn first_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(Nil) = rasa.insert(table, "a", 10)
  let assert Ok(Nil) = rasa.insert(table, "b", 20)

  let assert Ok(#("b", 20)) = rasa.first(table)
}

pub fn ordered_set_first_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.ordered_set
    |> rasa.table

  let assert Ok(Nil) = rasa.insert(table, "a", 10)
  let assert Ok(Nil) = rasa.insert(table, "b", 20)

  let assert Ok(#("a", 10)) = rasa.first(table)
}

pub fn first_empty_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Error(Nil) = rasa.first(table)
}

pub fn last_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(Nil) = rasa.insert(table, "a", 10)
  let assert Ok(Nil) = rasa.insert(table, "b", 20)

  let assert Ok(#("b", 20)) = rasa.last(table)
}

pub fn last_empty_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Error(Nil) = rasa.last(table)
}

pub fn ordered_set_last_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.ordered_set
    |> rasa.table

  let assert Ok(Nil) = rasa.insert(table, "a", 10)
  let assert Ok(Nil) = rasa.insert(table, "b", 20)

  let assert Ok(#("b", 20)) = rasa.last(table)
}

pub fn to_list_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok([]) = rasa.to_list(table)

  let assert Ok(Nil) = rasa.insert(table, "a", 10)

  let assert Ok([#("a", 10)]) = rasa.to_list(table)

  let assert Ok(Nil) = rasa.insert(table, "b", 20)

  let assert Ok([#("a", 10), #("b", 20)]) = rasa.to_list(table)
}

pub fn is_empty_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert True = rasa.is_empty(table)

  let assert Ok(Nil) = rasa.insert(table, "a", 10)

  let assert False = rasa.is_empty(table)

  let assert Ok(Nil) = rasa.delete(table, "a")

  let assert True = rasa.is_empty(table)
}

pub fn dropped_table_is_empty_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert True = rasa.is_empty(table)

  let assert Ok(Nil) = rasa.drop(table)

  let assert True = rasa.is_empty(table)
}

pub fn size_test() {
  let table = rasa.build("rasa_test") |> rasa.table

  let assert Ok(0) = rasa.size(table)

  let assert Ok(Nil) = rasa.insert(table, "a", 10)

  let assert Ok(1) = rasa.size(table)

  let assert Ok(Nil) = rasa.insert(table, "b", 10)

  let assert Ok(2) = rasa.size(table)
}

pub fn private_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.private
    |> rasa.table

  let assert Ok(rasa.Private) = rasa.access(table)
}

pub fn protected_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.protected
    |> rasa.table

  let assert Ok(rasa.Protected) = rasa.access(table)
}

pub fn public_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.public
    |> rasa.table

  let assert Ok(rasa.Public) = rasa.access(table)
}

pub fn set_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.set
    |> rasa.table

  let assert Ok(rasa.Set) = rasa.kind(table)
}

pub fn ordered_set_test() {
  let table =
    rasa.build("rasa_test")
    |> rasa.ordered_set
    |> rasa.table

  let assert Ok(rasa.OrderedSet) = rasa.kind(table)
}
