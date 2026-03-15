# About

Sardine is an ECS library for the Love2D game engine.

The library is in a very early alpha state. You can expect there to be bugs, API breakages, a lack of ergonomics and missing features. We're also attempting to provide LuaLS type information.

Currently we provide:
- `sardine.entity` Slotmap implementation and entity ID allocation
- `sardine.component` Provides component registration, entity-component management and queries
- `sardine.schedule` Provides a linear schedule builder with simple "must happen sometime after" dependancy resolution and rudementry loop/unresolvable schedule detection.

Test coverage currently only covers a subset of even basic usage, functioning currently as a development smoke-test.

# Running Tests

Currently tests are setup to run in the container built by the included Dockerfile. The dockerfile builds a LuaJIT version of the standard buster docker image, since Love2D makes use of LuaJIT/Lua5.1

The `./test.sh` script was written to simplify the process and will build the image if it doesn't already exist and then run the test. It assumes that you're on linux with podman installed.

# Usage

We don't currently publish releases or a package on luarocks. Please just download the repo and copy the `project/sardine` folder where it will be used. Ensure you require the module with dot-syntax and it will be able to load the associated modules using a relative import.

In the future we may provide a single-file release.

# License

This project is provided to you under the MIT License.

```
Copyright 2026 Natalie Baker

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
