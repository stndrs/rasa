# rasa

- ETS tables
- ETS backed queues

[![Package Version](https://img.shields.io/hexpm/v/rasa)](https://hex.pm/packages/rasa)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/rasa/)

```sh
gleam add rasa@1
```
```gleam
import rasa

pub fn main() -> Nil {
  let tabula = rasa.build("blank_slate")
  |> rasa.set
  |> rasa.private
  |> rasa.table

  let assert Ok(Nil) = rasa.insert(tabula, "nature", 30)
  let assert Ok(Nil) = rasa.insert(tabula, "nurture", 70)

  let assert Ok(30) = rasa.lookup(tabula, "nature")
  let assert Ok(70) = rasa.lookup(tabula, "nuture")
}
```

Further documentation can be found at <https://hexdocs.pm/rasa>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
