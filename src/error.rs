use std::error::Error;
use std::fmt;

#[derive(Debug)]
pub struct Empty;

impl fmt::Display for Empty {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "cannot create non empty collection from empty datastructure"
        )
    }
}

impl Error for Empty {}
