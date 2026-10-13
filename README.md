## What is MIPS? 
MIPS (Microprocessor without Interlocked Pipeline Stages) is a Reduced Instruction Set Computer (RISC) microprocessor architecture. 

 Developed in the 1980s by researchers at Stanford University, it is designed around a clean, simple instruction set where commands execute very quickly—typically in a single clock cycle

 ### Core Features of MIPS Architecture 
 1. **RISC Design Philosophy:** It uses a smaller, streamlined set of instructions compared to Complex Instruction Set Computers (CISC) like x86, making hardware decoding faster and more efficient
 2. **Load-Store Architecture:** Arithmetic and logic operations happen strictly inside CPU registers. Main memory is only touched using specialized load and store instructions.
 3.**Fixed Instruction Length:** Every MIPS instruction is strictly 32 bits (4 bytes) wide, which simplifies the process of fetching and decoding instructions.
 4.**General-Purpose Registers:** It features 32 registers (each 32 bits wide), labeled $0 through $31, used for holding temporary and saved data variables.
 5. **Pipelining:** The architecture breaks instruction execution down into 5 distinct pipeline stages (Fetch, Decode, Execute, Memory Access, and Write-Back) so multiple instructions overlap and process simultaneously
 6. **Three-Operand Format:** Most arithmetic instructions use a destination and two source operands (e.g., adding two registers and saving the result in a third).

#### This repository is used to document basic MIPS programs. 
