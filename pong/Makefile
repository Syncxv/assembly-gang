FILE ?= main
ARGS ?= 

FILES := $(wildcard *.asm)
OBJS := $(patsubst %.asm, %.obj, $(FILES))
EXES := $(patsubst %.asm, %.exe, $(FILES))


ASM := nasm
ASM_FLAGS := -f win32
ASM_DEBUG_FLAGS := $(ASM_FLAGS) -gcv8

LINKER := link
LIBS := lib/kernel32.lib
LIB_PATH := lib
LINKER_FLAGS := /subsystem:console /entry:main /libpath:$(LIB_PATH) /MACHINE:X86
LINKER_DEBUG_FLAGS := /debug $(LINKER_FLAGS)

build:
	$(ASM) $(ASM_FLAGS) $(FILE).asm -o $(FILE).obj
	vcvars32.bat
	$(LINKER) $(LINKER_FLAGS) $(ARGS) $(FILE).obj $(LIBS)

debug:
	@echo "welp doesnt work in the make file :| WHY? paste this in the termnial"
	@echo "$(ASM) $(ASM_DEBUG_FLAGS) $(FILE).asm -o $(FILE).obj"
	@echo "vcvars32.bat"
	@echo "$(LINKER) $(LINKER_DEBUG_FLAGS) $(ARGS) $(FILE).obj $(LIBS)"

clean:
	rm -f $(OBJS)
	rm -f $(EXES)

run:
	./main.exe
