BUILD_DIR := build
SRCS := $(wildcard *.vhdl)
RUN_TARGETS := $(SRCS:%.vhdl=run_%)
WAVE_TARGETS := $(SRCS:%.vhdl=wave_%)

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
	@cd $(BUILD_DIR) && ghdl -e $(@:run_%=%)
	@cd $(BUILD_DIR) && ghdl -r $(@:run_%=%)

.PHONY: $(WAVE_TARGETS)
$(WAVE_TARGETS): build
	@cd $(BUILD_DIR) && ghdl -e $(@:wave_%=%)
	@cd $(BUILD_DIR) && ghdl -r $(@:wave_%=%) --wave=$@.ghw
