             
process READS {
	tag "Downloading ${meta.id}"
	publishDir params.reads_dir, mode:'copy', pattern: '*.fastq.gz' 
	publishDir params.metadata_dir, mode: 'copy', pattern: '*.metadata.tsv'
	maxForks 2
	afterScript 'sleep 10'

	container 'biocontainers/iseq:1.0.0--hdfd78af_0'
	input:
	tuple val(meta), val(read_id)

	output:
	tuple val(meta), path("*.fastq.gz"), path("${meta.id}.metadata.tsv"), emit: reads
	path "versions.yml", emit: versions

	script:
	"""
	iseq -i ${meta.id} -g

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	iseq: \$(iseq --version 2>&1 | sed 's/iseq //')
	END_VERSIONS
	"""
}

