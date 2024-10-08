# -----------------------------------------------------------------------------

megabuild		= 1
attachdebugger	= 0

# -----------------------------------------------------------------------------

MAKE			= make
CP				= cp
MV				= mv
RM				= rm -f
CAT				= cat

SRC_DIR			= ./src
UI_SRC_DIR		= ./src/ui
UIELT_SRC_DIR	= ./src/ui/uielements
DRVRS_SRC_DIR	= ./src/drivers
EXE_DIR			= ./exe
BIN_DIR			= ./bin

# mega65 fork of ca65: https://github.com/dillof/cc65
AS				= ca65mega
ASFLAGS			= -g -D megabuild=$(megabuild) --cpu 45GS02 -U --feature force_range -I ./exe
LD				= ld65
C1541			= c1541
CC1541			= cc1541
SED				= sed
PU				= pucrunch
BBMEGA			= b2mega
LC				= crush 6
GCC				= gcc
MC				= MegaConvert
MEGAADDRESS		= megatool -a
MEGACRUNCH		= megatool -c
MEGAIFFL		= megatool -i
MEGAMOD			= MegaMod
EL				= etherload
XMEGA65			= D:\xemu\xmega65.exe
MEGAFTP			= mega65_ftp -e

CONVERTBREAK	= 's/al [0-9A-F]* \.br_\([a-z]*\)/\0\nbreak \.br_\1/'
CONVERTWATCH	= 's/al [0-9A-F]* \.wh_\([a-z]*\)/\0\nwatch store \.wh_\1/'

CONVERTVICEMAP	= 's/al //'

.SUFFIXES: .o .s .out .bin .pu .b2 .a

default: all

OBJS = $(EXE_DIR)/boot.o $(EXE_DIR)/main.o

BINFILES  = $(BIN_DIR)/jugler_chars0.bin
BINFILES += $(BIN_DIR)/jugler_screen0.bin
BINFILES += $(BIN_DIR)/jugler_pal0.bin
BINFILES += $(BIN_DIR)/ping.raw

BINFILESMC  = $(BIN_DIR)/jugler_chars0.bin.addr.mc
BINFILESMC += $(BIN_DIR)/jugler_screen0.bin.addr.mc
BINFILESMC += $(BIN_DIR)/jugler_pal0.bin.addr.mc
BINFILESMC += $(BIN_DIR)/ping.raw.addr.mc

# -----------------------------------------------------------------------------

$(BIN_DIR)/jugler_chars0.bin: $(BIN_DIR)/jugler.bin
	$(MC) $< cm1:1 d1:3 cl1:10000 rc1:1

$(EXE_DIR)/boot.o:	$(SRC_DIR)/boot.s \
					$(SRC_DIR)/main.s \
					$(SRC_DIR)/irqload.s \
					$(SRC_DIR)/decruncher.s \
					$(SRC_DIR)/macros.s \
					$(SRC_DIR)/sampleplay.s \
					Makefile Linkfile
	$(AS) $(ASFLAGS) -o $@ $<

$(BIN_DIR)/alldata.bin: $(BINFILES)
	$(MEGAADDRESS) $(BIN_DIR)/jugler_chars0.bin      00010000
	$(MEGAADDRESS) $(BIN_DIR)/jugler_screen0.bin     00003000
	$(MEGAADDRESS) $(BIN_DIR)/jugler_pal0.bin        00000400
	$(MEGAADDRESS) $(BIN_DIR)/ping.raw               0005d000
	$(MEGACRUNCH) $(BIN_DIR)/jugler_chars0.bin.addr
	$(MEGACRUNCH) $(BIN_DIR)/jugler_screen0.bin.addr
	$(MEGACRUNCH) $(BIN_DIR)/jugler_pal0.bin.addr
	$(MEGACRUNCH) $(BIN_DIR)/ping.raw.addr
	$(MEGAIFFL) $(BINFILESMC) $(BIN_DIR)/alldata.bin

$(EXE_DIR)/boot.prg.addr.mc: $(BINFILES) $(EXE_DIR)/boot.o Linkfile
	$(LD) -Ln $(EXE_DIR)/boot.maptemp --dbgfile $(EXE_DIR)/boot.dbg -C Linkfile -o $(EXE_DIR)/boot.prg $(EXE_DIR)/boot.o
	$(MEGAADDRESS) $(EXE_DIR)/boot.prg 00000800
	$(MEGACRUNCH) -e 00000800 $(EXE_DIR)/boot.prg.addr

$(EXE_DIR)/megajglr.d81: $(EXE_DIR)/boot.prg.addr.mc $(BIN_DIR)/alldata.bin
	$(RM) $@
	$(CC1541) -n "megajugler" -i " 2023" -d 19 -v\
	 \
	 -f "megajglr" -w $(EXE_DIR)/boot.prg.addr.mc \
	 -f "megajgl.ifflcrch" -w $(BIN_DIR)/alldata.bin \
	$@

# -----------------------------------------------------------------------------

run: $(EXE_DIR)/megajglr.d81

ifeq ($(megabuild), 1)
	$(MEGAFTP) -c "put D:\Mega\MegaJglr\exe\megajglr.d81 megajglr.d81" -c "quit"
	$(EL) -m MEGAJGLR.D81 -r $(EXE_DIR)/boot.prg.addr.mc
ifeq ($(attachdebugger), 1)
	m65dbg --device /dev/ttyS2
endif
else
	cmd.exe /c $(XMEGA65) -autoload -8 $(EXE_DIR)/megajglr.d81
endif

clean:
	$(RM) $(EXE_DIR)/*.*
	$(RM) $(EXE_DIR)/*
