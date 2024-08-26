namespace Emulator {
	class RVI32System {
		rom = new ROMDevice()
		ram = new RAMDevice()

		bus = new SystemInterface(this.rom, this.ram)
	}

	interface MMIO {
		read(address: number): number
		write(address: number, value: number): void
	}

	enum MemoryMap {
		ROM_START = 0x10000000, // 256 MB
		ROM_END = 0x1fffffff,   // 512 MB

		RAM_START = 0x20000000, // 512 MB
		RAM_END = 0x2fffffff,   // 769 MB
	}

	class SystemInterface implements MMIO {
		private romDevice: ROMDevice
		private ramDevice: RAMDevice

		constructor(romDevice: ROMDevice, ramDevice: RAMDevice) {
			this.romDevice = romDevice
			this.ramDevice = ramDevice
		}

		read(address: number): number {
			// Verify that the address is 4 byte aligned.
			if ((address & 0b11) != 0)
				throw new Error(`Unaligned read from address 0x${numberToHexString(address)}`)

			if ((address & MemoryMap.ROM_START) == MemoryMap.ROM_START)
				return this.romDevice.read((address & 0x0fffffff) >> 2) // TODO : Understand why he did >> 2.

			if ((address & MemoryMap.RAM_START) == MemoryMap.RAM_START)
				return this.ramDevice.read((address & 0x0fffffff) >> 2)

			return 0
		}

		write(address: number, value: number): void {
			// Verify that the address is 4 byte aligned.
			if ((address & 0b11) != 0)
				throw new Error(`Unaligned write to address 0x${numberToHexString(address)}`)

			if ((address & MemoryMap.RAM_START) == MemoryMap.RAM_START)
				return this.ramDevice.write((address & 0x0fffffff) >> 2, value)
		}
	}

	const ROM_SIZE = 1024 * 1024 // 1 MB.

	class ROMDevice implements MMIO {
		private rom = new Uint32Array(ROM_SIZE / 4)

		read(address: number): number {
			// In case the address is out of bounds, we'll use a mask to bring the address within the
			// ROM size.
			const mask = ((ROM_SIZE / 4) - 1)
			address = address & mask

			return this.rom[address]
		}

		// We cannot write to ROM.
		write(address: number, value: number): void { }

		load(data: Uint32Array) {
			for (let i = 0; i < (ROM_SIZE / 4); i++) {
				if (i >= data.length)
					this.rom[i] = 0xffffffff;

				else this.rom[i] = data[i];
			}
		}
	}

	const RAM_SIZE = 1024 * 1024 * 4 // 4 MB.

	class RAMDevice implements MMIO {
		private ram = new Uint32Array(RAM_SIZE / 4)

		read(address: number): number {
			// In case the address is out of bounds, we'll use a mask to bring the address within the
			// RAM size.
			const mask = ((RAM_SIZE / 4) - 1)
			address = address & mask

			return this.ram[address]
		}

		write(address: number, value: number): void { }
	}

	class Register {
		private _value: number

		constructor(value = 0) {
			this._value = value
		}

		get value() {
			return this._value
		}

		set value(v: number) {
			if (v < 0)
				this._value = (~(-v) + 1) & 0xffffffff

			else this._value = v
		}
	}

	namespace Pipeline {
		export abstract class PipelineStage {
			abstract readyToSend(): boolean
			abstract readyToReceive(): boolean

			abstract compute(): void
			abstract latchNext(): void
		}

		class InstructionFetch extends PipelineStage {
			private instruction = new Register(0)
			private instructionNext = new Register(0)

			readyToSend = (): boolean => true

			readyToReceive = (): boolean => true

			compute(): void {

			}

			latchNext(): void {

			}
		}
	}

	const numberToHexString =
		(n: number, padStart = 8) => n.toString(16).padStart(padStart, '0')

	const numberToBinaryString =
		(n: number, padStart = 32) => n.toString(2).padStart(padStart, '0');

	(function main() {
		const rvi32System = new RVI32System()

		rvi32System.rom.load(new Uint32Array([
			0xdeadbeef,
			0xdeafcafe
		]))

		console.log(numberToHexString(rvi32System.bus.read(0x10000000)))
		console.log(numberToHexString(rvi32System.bus.read(0x10000004)))
		console.log(numberToHexString(rvi32System.bus.read(0x10000005)))
	})()
}
