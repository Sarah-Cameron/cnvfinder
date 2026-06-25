
process MULTIQC {
        tag "Multiqc"
        publishDir params.qc_dir, mode:'copy'
        
        container 'biocontainers/multiqc:1.23--pyhdfd78af_0'
        input:
        path '*'

        output:
        path "multiqc_report.html", emit: report
	path "versions.yml",        emit: versions

	script:
        """
        multiqc . --no-data-dir --flat -o .
	
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    multiqc: \$(multiqc --version | sed 's/multiqc, version //')
	END_VERSIONS
        """
}
