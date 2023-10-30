NASM = nasm

all: build run

build:
	nasm -f win32 main.asm
	vcvars32.bat
	link /entry:main main.obj ../../libs/msvcrt.lib ../lib/kernel32.lib ../main.lib

# doesnt work :|
run:
	./main.exe