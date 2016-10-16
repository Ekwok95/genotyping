
params.infile = "./demodata.csv"


params.species = "mouse"
params.algo = "bwa"
inputChannel =  Channel.fromPath(params.infile)

log.info("")
log.info("H E A L T H   H A C K")
log.info("")
log.info("G E N O T Y P I N G   P I P E L I N E")
log.info("=====================================")
log.info("Reference species: ${params.species}")
log.info("Mapping algorithm: ${params.algo}")
log.info("")

inputChannel
.map{ it.text.split(",") }
.flatten()
.set { foo }

process readQC {

	input:
	val inputVal from foo

	output:
	stdout into intermediateChannel

	script:
	"""
	#!/usr/bin/python

	inputVal2 = $inputVal

	outputVal = inputVal2 + 1;

	print outputVal
	"""

}

chanForTimes2 = intermediateChannel.tap { foo }


if (params.algo == "bwa") {
	process readMappingWithBWA {
		input:
		val inputValueTimes from chanForTimes2

		output:
		stdout into outputChannel

		script:
		"""
		#!/usr/bin/python

		inputValue = $inputValueTimes

		outputValueTimes = inputValue * 2;

		print outputValueTimes
		"""
	}
} else {
	process readMappingWithBowties {
		input:
		val inputValueTimes from chanForTimes2

		output:
		stdout into outputChannel

		script:
		"""
		#!/usr/bin/python

		inputValue = $inputValueTimes

		outputValueTimes = inputValue * 4;

		print outputValueTimes
		"""
	}
}

foo.subscribe { print("Filtered reads: "); print(it)}


outputChannel
.collectFile(name: "./final.txt", newLine: false)
.subscribe { print("/nFINISHED.\nFinal output saved to 'final.txt'\n")}
