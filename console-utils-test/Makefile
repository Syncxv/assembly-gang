NASM = nasm

all: build run

build:
	nasm -f win32 main.asm
	vcvars32.bat
	link /entry:main main.obj ../libs/msvcrt.lib ../libs/kernel32.lib

# doesnt work :|
run:
	./main.exe