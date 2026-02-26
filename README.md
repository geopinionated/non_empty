# Non empty

Non empty collections
- NonEmptyVec
- NonEmptySlice
- NonEmptyIterator

### License

Licensed under either of
- [MIT license](https://opensource.org/licenses/MIT)
- [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)


### Examples

non_empty_vec![]

```rust
use non_empty::NonEmptyVec;

let v = non_empty_vec![10, 20, 30, 40, 50];

assert_eq!(v.len(), 5);
assert_eq!(v.first(), &10);
assert_eq!(v.last(), &50);
```

NonEmptyVec::one

```rust
let v = NonEmptyVec::one(10);

assert_eq!(v.len(), 1);
assert_eq!(v.first(), &10);
assert_eq!(v.last(), &10);
assert!(v.init().is_empty());
assert!(v.tail().is_empty());


v.push(20);

assert_eq!(v.init(), &[10]);
assert_eq!(v.tail(), &[20]);

```

NonEmptyVec::try_from

```rust
let vec = vec![10, 20, 30, 40, 50];

let v = vec.try_from().expect("non empty");

assert_eq!(v.first(), &10);
assert_eq!(v.last(), &50);
```

NonEmptySlice

```rust
let s: &NonEmptySlice<i32> = &non_empty_vec![10, 20, 30, 40, 50];

assert_eq!(s.as_slice(), &[10, 20, 30, 40, 50])
assert_eq!(s.split_first(), (&10, &[20, 30, 40, 50][..]));
assert_eq!(s.split_last(), (&[10, 20, 30, 40][..], &50));

let vec = vec![10, 20, 30];
let s = NonEmptySlice::try_from_slice(&vec)?;

assert_eq!(s.first(), &10);
assert_eq!(s.last(), &30);

let s = Box<NonEmptySlice<i32>> = non_empty_vec![10, 20].into_boxed_slice();

```

NonEmptyIterator

```rust
let vec = non_empty_vec![10, 20, 30, 40, 50];

let iter = vec.iter();

assert_eq!(iter.len(), 5);

let result: Vec<i32> = iter.copied().filter(|&v| v > 30).collect();

assert_eq!(result, vec![40, 50]);

let vec = non_empty_vec![10, 20, 30, 40, 50];

let result: NonEmptyVec<_> = vec.iter().map(|v| v * 10).rev().copied().collect_non_empty();

assert_eq!(result, non_empty_vec![500, 400, 300, 200, 100]);
```