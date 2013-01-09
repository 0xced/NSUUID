## About

#### The problem

You want to use the [NSUUID](http://developer.apple.com/library/ios/documentation/Foundation/Reference/NSUUID_Class/Reference/Reference.html) class, but you are targeting a platform where it's not available, i.e. iOS < 6 or OS X < 10.8.

#### The solution

Just compile the `NSUUID.m` file ([without ARC](http://stackoverflow.com/a/6658549/21698)) in your project. The `NSUUID` class will then be automatically available, even on platforms where it is normally not available.

## Known Issues

Subclassing `NSUUID` does not work on iOS < 6 and OS X < 10.8.

## Contact

Cédric Luthi

- http://github.com/0xced
- http://twitter.com/0xced
- cedric.luthi@gmail.com

## License

The MIT License (MIT)  
Copyright (c) 2013 Cédric Luthi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
