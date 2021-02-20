# JSON support for Starlark

## Status
Working json recognizer.  
Outputs the indices in the input string where it managed to recognize valid json.

## TODO
1. JSON parser
1. JSON marhsaler/encoder
1. Optimizations to improve performance

## Prerequisites
1. Starlark interpreter with recursion and set support. (The Go version has support for this. https://github.com/google/starlark-go/#getting-started)
1. make (Optional)

## Usage
`make`  
Or if you don't have make installed:  
`starlark -recursion -set main.star`
