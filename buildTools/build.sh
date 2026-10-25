# build.sh

# This OS was built entirely using apps on an iPhone 17 Pro

# Testing iSH
echo "hello world!"


# nasm ASM files to BIN files
echo ""
echo "compiling ASM files into Binary."
nasm -f bin -i ../src/kernel ../src/kernel/kernel.asm -o ../build/raw/kernel.bin
nasm -f bin -i ../src/boot ../src/boot/boot.asm -o ../build/raw/boot.bin
nasm -f bin -i ../src/boot ../src/boot/stage2.asm -o ../build/raw/stage2.bin
nasm -f bin -i ../src/boot ../src/boot/stage3.asm -o ../build/raw/stage3.bin
echo ""
echo ../src/boot/boot.asm

# slap the BIN files together into an IMG file
dd if=/dev/zero of=../build/vdrive/LactOS.img bs=512 count=2880 status=noxfer

# stage 1
dd if=../build/raw/boot.bin of=../build/vdrive/LactOS.img bs=512 seek=0 conv=notrunc status=noxfer

# stage 2
dd if=../build/raw/stage2.bin of=../build/vdrive/LactOS.img bs=512 seek=1 conv=notrunc status=noxfer

# stage 3
dd if=../build/raw/stage3.bin of=../build/vdrive/LactOS.img bs=512 seek=9 conv=notrunc status=noxfer

# kernel
dd if=../build/raw/kernel.bin of=../build/vdrive/LactOS.img bs=512 seek=11 conv=notrunc status=noxfer
