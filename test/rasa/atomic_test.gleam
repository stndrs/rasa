import rasa/atomic

pub fn new_test() {
  let a = atomic.new()

  let assert 0 = atomic.get(a)
}

pub fn put_test() {
  let a = atomic.new()

  atomic.put(a, 42)

  let assert 42 = atomic.get(a)
}

pub fn add_test() {
  let a = atomic.new()

  atomic.add(a, 5)

  let assert 5 = atomic.get(a)
}

pub fn add_get_test() {
  let a = atomic.new()

  let assert 5 = atomic.add_get(a, 5)
  let assert 8 = atomic.add_get(a, 3)
}

pub fn sub_test() {
  let a = atomic.new()

  atomic.put(a, 10)
  atomic.sub(a, 3)

  let assert 7 = atomic.get(a)
}

pub fn sub_get_test() {
  let a = atomic.new()

  atomic.put(a, 10)

  let assert 7 = atomic.sub_get(a, 3)
}

pub fn exchange_test() {
  let a = atomic.new()

  atomic.put(a, 10)

  let assert 10 = atomic.exchange(a, 20)
  let assert 20 = atomic.get(a)
}

pub fn compare_exchange_ok_test() {
  let a = atomic.new()

  atomic.put(a, 10)

  let assert Ok(Nil) = atomic.compare_exchange(a, 10, 20)
  let assert 20 = atomic.get(a)
}

pub fn compare_exchange_error_test() {
  let a = atomic.new()

  atomic.put(a, 10)

  let assert Error(10) = atomic.compare_exchange(a, 5, 20)
  let assert 10 = atomic.get(a)
}

pub fn independent_test() {
  let a1 = atomic.new()
  let a2 = atomic.new()

  atomic.put(a1, 100)
  atomic.put(a2, 200)

  let assert 100 = atomic.get(a1)
  let assert 200 = atomic.get(a2)

  atomic.add(a1, 1)

  let assert 101 = atomic.get(a1)
  let assert 200 = atomic.get(a2)
}
