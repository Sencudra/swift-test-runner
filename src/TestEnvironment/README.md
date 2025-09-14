# Swift build cache warm-up for faster builds inside docker

## Overview

This package is used in a production environment as a container for building and testing students’ solutions.
It is built and included in a Docker image with a pre-built .build directory, which minimizes changes in the build graph when applying different exercise solutions.
Exercise resources are copied into the TestEnvironment package as if they had always been part of it.

## The problem with slow build times

Cold swift builds are slow.
We need fast feedback — to respond quickly when someone runs an exercise and not hit Docker timeouts.
This package is used to build warm-up: it prebuilds the .build folder during docker image creation and is used as an environment for building and testing exercises.

## Why cold builds are slow?

When Swift compiles from a clean state, it spends a huge amount of time on resolving dependencies.
Imports like Foundation, Numerics, Dispatch, etc. pull in a ton of underlying clang and swift modules like SwiftShims, SwiftGlibc, _Builtin_stddef, etc.

Even if you don’t import them directly, Swift still needs to find, parse, and compile some of them into .build and specifically ModuleCache directory.

## What does this package do?

It simply imports all the common libraries that exercises usually rely on:

```swift
import Foundation
import Numerics
import Testing
@testable import ModuleName
```

Then it is built during Docker image creation.
When a student runs their solution, the code for a particular exercise is copied into the TestEnvironment package.
Then, the package itself is rebuilt with minor changes, such as replacing code in Source and Tests files.
See `bin/run.sh` for more details on which parts of an exercise are copied into docker image.