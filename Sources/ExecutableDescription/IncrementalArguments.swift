public protocol IncrementalArguments {
  func writeArguments(to builder: inout ArgumentsBuilder)
}

extension IncrementalArguments where Self: Executable {
  var arguments: [String] {
    var builder = ArgumentsBuilder()
    self.writeArguments(to: &builder)
    return builder.arguments
  }
}

public struct ArgumentsBuilder {
  @inlinable
  public init() {
    arguments = .init()
  }

  @_alwaysEmitIntoClient
  public internal(set) var arguments: [String]

  @inlinable
  public mutating func append<S>(arguments other: S) where S: Sequence, S.Element == String {
    arguments.append(contentsOf: other)
  }

  /// add [flag, value!] to arguments if value is not nil
  @inlinable
  public mutating func add(flag: String, value: String?) {
    if let v = value {
      arguments.append(flag)
      arguments.append(v)
    }
  }

  @inlinable
  @available(*, unavailable)
  public mutating func add<T: IncrementalArguments & CustomStringConvertible>(flag: String, value: T?) {
    if let v = value {
      arguments.append(flag)
      v.writeArguments(to: &self)
    }
  }

  @inlinable
  public mutating func add<T: IncrementalArguments>(flag: String, value: T?) {
    if let v = value {
      arguments.append(flag)
      v.writeArguments(to: &self)
    }
  }

  @inlinable
  public mutating func add<T: CustomStringConvertible>(flag: String, value: T?) {
    add(flag: flag, value: value?.description)
  }

  @inlinable
  public mutating func add(flag: String, when enabled: Bool = true) {
    if enabled {
      arguments.append(flag)
    }
  }
}
