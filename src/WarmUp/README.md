# Swift build cache warm-up for faster builds inside docker
## Overview

Cold swift builds are slow. We need fast feedback — to respond quickly when someone runs an exercise and not hit Docker timeouts. This package is used to build warm-up: it prebuilds the .build folder during docker image creation and is used as an environment for building and testing exercises.

## Why cold builds are slow?

When Swift compiles from a clean state, it spends a huge amount of time on resolving dependencies. Imports like Foundation, Numerics, Dispatch, etc. pull in a ton of underlying clang and swift modules like SwiftShims, SwiftGlibc, _Builtin_stddef, etc.

Even if you don’t import them directly, Swift still needs to find, parse, and compile some of them into .build and specifically ModuleCache directory.

## What does this package do?

It simply imports all the common libraries that exercises usually rely on:

```swift
import Foundation
import Numerics
import Testing
@testable import ModuleName
```

Then it gets built during Docker image creation. When a student runs their solution later the code for a particular exercise is copied into WarmUp package and the package itself is rebuilt with minor difference, like you've just replace code in files and rebuilt the same package.

Then it is built during Docker image creation. Later, when a student runs their solution, the code for a particular exercise is copied into the WarmUp package. Theb, the package itself is rebuilt with minor changes, such as replacing code in Source and Tests files. See `bin/run.sh` for more details on which parts of an exercise are copied into docker image.