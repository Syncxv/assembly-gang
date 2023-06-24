FILE ?= main

FILES := $(wildcard *.asm)
OBJS := $(patsubst %.asm, %.obj, $(FILES))
EXES := $(patsubst %.asm, %.exe, $(FILES))

build:
	nasm -f win32 $(FILE).asm -o $(FILE).obj
	vcvars32.bat
	link /entry:main $(FILE).obj ../libs/msvcrt.lib

clean:
	rm -f $(OBJS)
	rm -f $(EXES)

run:
	./main.exe
