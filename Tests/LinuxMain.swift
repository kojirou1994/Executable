import XCTest

import ExecutableTests

var tests = [XCTestCaseEntry]()
tests += ExecutableTests.allTests()
XCTMain(tests)
