TARGET:=tangnano9k # The board to flash. available targets are in the targets folder.
TOP:=top           # The top module to use.

SV2V_CMD=docker run --rm -v $(PWD):/app --workdir=/app davidsiaw/ocs sv2v
SYSTEM_VERILOG_FILES=$(shell find src -type f -name '*.sv')
VERILOG_FILES=$(shell find src -type f -name '*.v') $(patsubst src/%.sv,obj/sv2ved/%.v,$(SYSTEM_VERILOG_FILES))

TARGET_DIR=obj/args

# produce defines for verilog from target
obj/defines: $(TARGET_DIR)/defines
	mkdir -p $@
	for i in $(shell cat $<); \
	do  \
	  echo "" > "$@/$$i"; \
	done

obj/sv2ved/%.v.gen.sh: src/%.sv
	mkdir -p $(shell dirname "$@")
	echo "#!/bin/sh" > $@
	echo "$(SV2V_CMD) \\" >> $@
	echo $< >> $@

# pre-process systemverilog down to verilog
obj/sv2ved/%.v: obj/sv2ved/%.v.gen.sh
	echo "// Generated by Makefile using sv2v" > $@
	sh $< >> $@

.INTERMEDIATE: obj/sv2ved/%.v

$(TARGET_DIR)/%: targets/$(TARGET)
	mkdir -p $(TARGET_DIR)
	cat targets/$(TARGET) | while read line; \
	do \
	  IFS='=' read -ra toks <<< "$$line"; \
	  echo "$${toks[1]}" > "$(TARGET_DIR)/$${toks[0]}"; \
	done

all: apicula gowin

clean:
	rm -rf obj

.PHONY: clean all unpack_target

include mklib/*.mk
