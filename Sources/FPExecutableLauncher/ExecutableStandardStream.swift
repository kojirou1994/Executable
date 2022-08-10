import Foundation

// only work for Foundation framework
public enum ExecutableStandardStream {
  case fileHandle(FileHandle)
  case pipe(Pipe)

  var valueForProcess: Any {
    switch self {
    case .fileHandle(let f):
      return f as Any
    case .pipe(let p):
      return p as Any
    }
  }
}
