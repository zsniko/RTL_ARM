GHDL=/usr/bin/ghdl-gcc
GHDL_OP = -v
C_MOD_DIR = ../C_model/
all : main_tb

ram.o : ram.vhdl
	${GHDL} -a ${GHDL_OP} ram.vhdl

icache.o : icache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} icache.vhdl

dcache.o : dcache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} dcache.vhdl

main_tb.o : main_tb.vhdl icache.o dcache.o ram.o 
	${GHDL} -a ${GHDL_OP} main_tb.vhdl

arm_core.o : ../CORE/arm_core.vhdl ifetch.o decod.o exec.o mem.o
	${GHDL} -a ${GHDL_OP} ../CORE/arm_core.vhdl
	
ifetch.o : ../IFETCH/ifetch.vhdl fifo.o
	${GHDL} -a ${GHDL_OP} ../IFETCH/ifetch.vhdl

decod.o : ../DECOD/decod.vhdl fifo.o reg.o
	${GHDL} -a ${GHDL_OP} ../DECOD/decod.vhdl

reg.o : ../DECOD/reg.vhdl 
	${GHDL} -a ${GHDL_OP} ../DECOD/reg.vhdl

exec.o : ../EXEC/exec.vhdl fifo.o alu.o shifter.o
	${GHDL} -a ${GHDL_OP} ../EXEC/exec.vhdl

fifo.o : ../FIFO/fifo.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo.vhdl

alu.o : ../EXEC/alu.vhdl add32.o
	${GHDL} -a ${GHDL_OP} ../EXEC/alu.vhdl

add1.o : ../EXEC/add_1b.vhdl
	${GHDL} -a ${GHDL_OP} ../EXEC/add_1b.vhdl

add4.o : ../EXEC/adder_4b.vhdl add1.o
	${GHDL} -a ${GHDL_OP} ../EXEC/adder_4b.vhdl

add32.o : ../EXEC/adder_32b.vhdl add4.o
	${GHDL} -a ${GHDL_OP} ../EXEC/adder_32b.vhdl

shifter.o : ../EXEC/shifter.vhdl
	${GHDL} -a ${GHDL_OP} ../EXEC/shifter.vhdl

mem.o : ../MEM/mem.vhdl
	${GHDL} -a ${GHDL_OP} ../MEM/mem.vhdl

main_tb : main_tb.o ram.o icache.o dcache.o arm_core.o ${C_MOD_DIR}/lib/arm_ghdl.o
	${GHDL} -e ${GHDL_OP} -Wl,${C_MOD_DIR}/lib/mem.o -Wl,${C_MOD_DIR}/lib/arm_ghdl.o -Wl,${C_MOD_DIR}/ReadElf/lib/ElfObj.o main_tb

clean :
	rm *.o main_tb work-obj93.cf *.vcd
