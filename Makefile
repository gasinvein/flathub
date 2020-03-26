MULTILIB_SRC := $(wildcard modules/*.yml)
MULTILIB_MFS := $(patsubst modules/%.yml,modules/generated-%.json,$(MULTILIB_SRC))
.PHONY: all clean
.DEFAULT_GOAL := all

modules/generated-%.json: modules/%.yml modules/.compat32-module.yml multilibify.py
	python3 multilibify.py $< $@

all: $(MULTILIB_MFS)

clean:
	rm modules/*generated*
