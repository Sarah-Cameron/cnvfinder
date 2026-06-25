
process BWA {
    tag "Indexing and mapping ${meta.id}"
    publishDir params.sam_dir, mode: 'copy', pattern: '*.sam'
    maxForks 1
    label 'process_high'
    container 'quay.io/biocontainers/bwa-mem2:2.2.1--hd03093a_4'

    input:
    tuple val(meta), val(assembly_id), path(read1), path(read2)

    output:
    tuple val(meta), val(assembly_id), path("*.sam"), emit: sam
    path "versions.yml", emit: versions

    script:
    """
    bwa-mem2 index ${params.assemblies}/${assembly_id}.${params.fasta}
    bwa-mem2 mem -t 24 \
        ${params.assemblies}/${assembly_id}.${params.fasta} \
        ${read1} ${read2} \
        > ${meta.id}_${assembly_id}.sam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwamem2: \$(bwa-mem2 version 2>&1 | tail -n 1)
    END_VERSIONS
    """
}
