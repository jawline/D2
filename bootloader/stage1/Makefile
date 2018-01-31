OUTFILE := bin/stage1.bin
SOURCES := src/main.s

all:
	@echo "Linking Stage1"
	@nasm -f bin -o $(OUTFILE) $(SOURCES)

clean:
	@echo "Cleaning Stage1"
	@rm -f $(OUTFILE)
