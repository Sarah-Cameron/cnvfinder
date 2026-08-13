
process GCFILE {
    tag "Making the GC File for ${meta.id}"
    publishDir params.gc_dir, mode: params.publish_dir_mode, pattern: '*.pytor'
    maxForks 10
    container 'quay.io/biocontainers/cnvpytor:1.3.1--pyhdfd78af_0'

    input:
    tuple val(meta), val(assembly_id), path(assembly_fasta)

    output:
    tuple val(meta), val(assembly_id), path(assembly_fasta), path("*.pytor"), emit: gcfile
    path "versions.yml", emit: versions

    script:
    """
    cnvpytor -root ${meta.id}_${assembly_id}_gc_file.pytor \
        -gc ${assembly_fasta} \
        -make_gc_file

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvpytor: \$(cnvpytor --version 2>&1 | grep "CNVpytor" | sed 's/CNVpytor //')
    END_VERSIONS
    """
}
