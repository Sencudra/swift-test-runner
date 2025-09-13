# 2.0.4

- The WarmUp package has been renamed to TestEnvironment and is now used directly to build exercise solutions.
- A more aggressive caching strategy is applied when source files are copied into the package.

# 2.0.3

- Add WarmUp package to improve exercise build time.
- Exercise package now is copied into docker image.

# 2.0.2

- Fix only one test case being executed.

# 2.0.1

- Update to Swift 6.1.2
- Preformance improvements when using swift-numerics

# 2.0.0

- Updated to Swift 6.1
- Update swift-syntax to 600.0.0
- Use swift-testing instead of XCTest
- Brand new way of handling gathering test results, which is more robust and easier to maintain
- Depricated task_id, user output
- Uses version 2 instead of 3

# 1.1.3

- Fixed an issue making so outputs on multiple lines missed the last line
- Formatted all files using the formatter

# 1.1.2

- Updated test files to follow a more modern design.

# 1.1.1

- Fixed an issue causing help functions to be marked as test cases
- Made the output when writting a compile error shorter

# 1.1.0

- The test runner will run one test at a time, this is to be able to give a better error message when a test fails.
  - This may change in the future.
- Improved message handling for unimplemented tests.
- Improved message handling for non existing functions.
- Fixed so the test runner will give messaging for when test doesn't use `XCTAssertEqual`.
- Fixed so the test runner don't remove incorrect characters from test_code.
  - This was caused when a test runner had an if statement, then would the closing bracket be removed.
- Fixed so the test runner can now handle multiline assert statements (window system exercise).
- Fixed so the test runner will no longer output if an error occurred when running the test. 
- The test code will now be indented.
- Slight changes in formatting of the test runners source code.

# 1.0.1

- Fixed an environment variable with caused so only the first test was run.

# 1.0.0

- Initial release
- Add support for Swift 5.8
- Test code
- Task id
- Fixes and performance improvements
- Added so test will run in parallel
