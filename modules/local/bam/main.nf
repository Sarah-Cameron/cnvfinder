

process BAM {
    tag "Converting ${meta.id} SAM to BAM and making read depth file"
    publishDir params.pytor_dir, mode: 'copy', pattern: '*.pytor'
    publishDir params.qc_dir, mode: 'copy', pattern: '*.depth'
    publishDir params.qc_dir, mode: 'copy', pattern: '*.txt'
    label 'process_high_memory'
    container 'docker.io/sc3445/samtools-cnvpytor:6.0'

    input:
    tuple val(meta), val(assembly_id), path(sam), path(config)

    output:
    tuple val(meta), val(assembly_id), path("*.depth"), path("*.txt"), path("*.pytor"), emit: results
    path "versions.yml", emit: versions

    script:
    """
    samtools sort ${sam} -n -o ${meta.id}_unsorted.bam
    samtools sort ${meta.id}_unsorted.bam -o ${meta.id}_sorted.bam
    samtools index ${meta.id}_sorted.bam
    samtools depth -a ${meta.id}_sorted.bam -o ${meta.id}_${assembly_id}.depth
    samtools coverage ${meta.id}_sorted.bam -o ${meta.id}_${assembly_id}_coverage.txt
    cnvpytor -conf ${config} \
        -root ${meta.id}_${assembly_id}.pytor \
        -rd ${meta.id}_sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
        cnvpytor: \$(cnvpytor --version 2>&1 | grep "CNVpytor" | sed 's/CNVpytor //')
    END_VERSIONS
    """
}
