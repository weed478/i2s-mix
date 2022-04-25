BUILD_DIR := build
SRCS := $(wildcard *.vhdl)
RUN_TARGETS := $(SRCS:%.vhdl=%)

.PHONY: all
all: build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: build
build:
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && ghdl -a $(SRCS:%=../%)

.PHONY: $(RUN_TARGETS)
$(RUN_TARGETS): build
	@cd $(BUILD_DIR) && ghdl -e $@
	@cd $(BUILD_DIR) && ghdl -r $@
