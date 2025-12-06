public extension Executable {
  func validate() throws(ExecutableError) {
    _ = try ExecutablePath.lookup(self).get()
  }

  static func validate() throws(ExecutableError) {
    _ = try ExecutablePath.lookup(type: Self.self).get()
  }
}
