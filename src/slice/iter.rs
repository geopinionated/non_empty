use std::{iter::Map, ops::Deref, slice::Iter};

use crate::NonEmptyVec;

pub trait NonEmptyIterator: Iterator {
    fn is_empty(&self) -> bool {
        false
    }
    fn collect_non_empty(self) -> NonEmptyVec<Self::Item>
    where
        Self: Sized,
    {
        NonEmptyVec::try_from(self.collect::<Vec<_>>()).unwrap()
    }
}

#[derive(Clone)]
pub struct NonEmptyIter<'a, T>(Iter<'a, T>);

impl<'a, T> NonEmptyIter<'a, T> {
    pub(crate) fn new_unchecked(iter: Iter<'a, T>) -> Self {
        debug_assert!(iter.len() >= 1, "non empty iter is greater than 0 len");
        NonEmptyIter(iter)
    }
}

impl<'a, T> Iterator for NonEmptyIter<'a, T> {
    type Item = &'a T;

    fn next(&mut self) -> Option<Self::Item> {
        self.0.next()
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        (self.0.len(), Some(self.0.len()))
    }
}

impl<'a, T> DoubleEndedIterator for NonEmptyIter<'a, T> {
    fn next_back(&mut self) -> Option<<Self as Iterator>::Item> {
        self.0.next_back()
    }
}

impl<'a, T> ExactSizeIterator for NonEmptyIter<'a, T> {
    fn len(&self) -> usize {
        self.0.len()
    }
}

impl<'a, T> NonEmptyIterator for NonEmptyIter<'a, T> {}

impl<B, I: NonEmptyIterator, F> NonEmptyIterator for Map<I, F> where F: FnMut(I::Item) -> B {}

impl<'a, T> Deref for NonEmptyIter<'a, T> {
    type Target = Iter<'a, T>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[cfg(test)]
mod tests {

    use crate::{non_empty_vec, slice::iter::NonEmptyIterator, NonEmptyVec};

    #[test]
    fn deref() {
        let vec = non_empty_vec![10, 20, 30, 40, 50];

        let iter = vec.iter();

        assert_eq!(iter.len(), 5);

        let result: Vec<i32> = iter.map(|&v| v).filter(|&v| v > 30).collect();

        assert_eq!(result, vec![40, 50]);
    }

    #[test]
    fn non_empty_collect() {
        let vec = non_empty_vec![10, 20, 30, 40, 50];

        let result: NonEmptyVec<_> = vec.iter().map(|v| v * 10).collect_non_empty();

        assert_eq!(result, non_empty_vec![100, 200, 300, 400, 500]);

        let result: Vec<_> = vec.iter().map(|v| v * 10).filter(|&v| v > 300).collect();

        assert_eq!(result, vec![400, 500]);
    }

    #[test]
    fn non_empty_collect_size() {
        let vec = non_empty_vec![10, 20, 30, 40, 50];

        let result: Vec<_> = vec.iter().enumerate().map(|(v, _)| v * 10).collect();

        assert_eq!(result.capacity(), result.len());
    }

    #[test]
    fn non_empty_rev() {
        let vec = non_empty_vec![10, 20, 30, 40, 50];

        let result: Vec<_> = vec.iter().enumerate().map(|(_, v)| *v).rev().collect();

        assert_eq!(result, vec![50, 40, 30, 20, 10]);
    }
}
