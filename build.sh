set -e

echo '[*] Compiling stage1...'
nasm -f bin stage1.asm -o stage1.bin
ls -ls stage1.bin

if [ $(wc -c < stage1.bin) -ne 512 ]; then
    echo "[-] Size of stage1.bin is not 512 bytes!"
    exit 1
fi

echo '[*] Compiling stage2...'
nasm -f bin stage2.asm -o stage2.bin
ls -ls stage2.bin

SIZE=$(wc -c < stage2.bin)
if [ $SIZE -gt 8192 ]; then
    echo "[-] Size of stage2 is too large ($SIZE bytes > 8192)!"
    exit 1
fi

echo "Stage2 size: $SIZE bytes (OK)"

dd if=/dev/zero of=test.img bs=1M count=100
mkfs.ntfs -F test.img
dd if=stage1.bin of=test.img bs=446 count=1 conv=notrunc
dd if=stage2.bin of=test.img bs=512 seek=1 conv=notrunc