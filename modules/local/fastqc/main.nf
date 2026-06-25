

process FASTQC {
        tag "Fastqc on ${meta.id}"
        publishDir params.qc_dir, mode:'copy'
        
        container 'biocontainers/fastqc:0.12.1--hdfd78af_0'
        input:
        tuple val(meta), path(read1), path(read2)

        output:
        path "fastqc_${meta.id}_logs", emit: logs
	path "versions.yml",           emit: versions

        
	script:
	"""
        mkdir fastqc_${meta.id}_logs
        fastqc -o fastqc_${meta.id}_logs -q ${read1} ${read2}

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    fastqc: \$(fastqc --version | sed 's/FastQC v//')
	END_VERSIONS
        """
}
