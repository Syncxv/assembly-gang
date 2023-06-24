build:
	nasm -f win32 main.asm
	vcvars32.bat
	link /entry:main main.obj ../libs/msvcrt.lib

# doesnt work :|
run:
	./main.exe