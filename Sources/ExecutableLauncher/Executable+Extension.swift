public extension Executable {
  func validate() throws {
    _ = try ExecutablePath.lookup(self).get()
  }

  static func validate() throws {
    _ = try ExecutablePath.lookup(type: Self.self).get()
  }
}
