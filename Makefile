EMACS ?= emacs
BATCH = $(EMACS) --batch -Q

PACKAGE_NAME = semaphoreci-debug
PACKAGE_VERSION = 0.1.0
PACKAGE_REQUIRES = "((emacs \"29\"))"

ELS = $(PACKAGE_NAME).el
ELCS = $(ELS:.el=.elc)

.PHONY: all clean

all: $(ELCS)

clean:
	rm -f $(ELCS)
	rm -rf .elpa

%.elc: %.el
	$(BATCH) --eval "(setq byte-compile-error-on-warn t)" \
		-f batch-byte-compile $<
