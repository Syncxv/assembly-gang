FILE ?= main
ARGS ?= 

FILES := $(wildcard *.asm)
OBJS := $(patsubst %.asm, %.obj, $(FILES))
EXES := $(patsubst %.asm, %.exe, $(FILES))
ILKS := $(patsubst %.asm, %.ilk, $(FILES))
PDBS := $(patsubst %.asm, %.pdb, $(FILES))


ASM := nasm
ASM_FLAGS := -f win32
ASM_DEBUG_FLAGS := $(ASM_FLAGS) -gcv8

LIB := lib
LIBS := ./lib/kernel32.lib ../libs/msvcrt.lib
LIB_FLAGS := /OUT:$(FILE).lib $(FILE).obj
LIB_DEBUG_FLAGS := /debug $(LIB_FLAGS)


all: build

build:
	$(ASM) $(ASM_FLAGS) $(FILE).asm -o $(FILE).obj
	vcvars32.bat
	$(LIB) /OUT:$(FILE).lib $(ARGS) $(FILE).obj

debug:
	$(ASM) $(ASM_DEBUG_FLAGS) $(FILE).asm -o $(FILE).obj
	vcvars32.bat
	$(LIB) $(LIB_DEBUG_FLAGS) $(ARGS) $(FILE).obj

clean:
	rm -f $(OBJS)
	rm -f $(EXES)
	rm -f $(ILKS)
	rm -f $(PDBS)

run:
	./main.exe
