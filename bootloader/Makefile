all: stage1 stage2

stage1:
	@(cd stage1 && $(MAKE))

stage2:
	@(cd stage2 && $(MAKE))

clean:
	@(cd stage1 && $(MAKE) clean)
	@(cd stage2 && $(MAKE) clean)
