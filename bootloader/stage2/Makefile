OUTFILE := bin/stage2.bin
SOURCES := src/main.s

all:
	@echo "Linking Stage2"
	@nasm -f bin -o $(OUTFILE) $(SOURCES)

clean:
	@echo "Cleaning Stage2"
	@rm -f $(OUTFILE)
