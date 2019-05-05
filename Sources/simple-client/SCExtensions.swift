extension Sequence {
    /// Returns the number of elements in the sequence that satisfy the given
    /// predicate.
    ///
    /// The sequence must be finite.
    ///
    /// - Parameter predicate: A closure that takes each element of the sequence
    ///   as its argument and returns a Boolean value indicating whether the
    ///   element should be included in the count.
    ///
    /// - Returns: The number of elements in the sequence that satisfy the given
    ///   predicate.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable
    public func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0

        for e in self {
            if try predicate(e) {
                count += 1
            }
        }

        return count
    }
}