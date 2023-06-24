you need nasm and visual studio build tools installed

# how to run

```sh
make build FILE=(the file you want)
```

if you dont pass FILE then it will be defaulted to main

example:

```sh
make build FILE=addx
```

will build addx.obj and then link msvcrt.lib to the obj and create an addx.exe
then run by doing ./addx
