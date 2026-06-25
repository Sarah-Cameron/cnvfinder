
process FASTP {
    tag "Trimming ${meta.id}"
    publishDir params.trimmed_dir, mode: 'copy', pattern: '*_trim.fastq.gz'
    container 'quay.io/biocontainers/fastp:0.24.0--h125f33a_0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_1_trim.fastq.gz"), path("${meta.id}_2_trim.fastq.gz"), emit: reads
    path "versions.yml", emit: versions


    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \
        -o ${meta.id}_1_trim.fastq.gz \
        -O ${meta.id}_2_trim.fastq.gz \
        --cut_front --cut_tail -W 2 -f 5 -F 5 -t 5 -T 5

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed 's/fastp //')
    END_VERSIONS
    """
}
