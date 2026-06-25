

process CONFIG {
    tag "Making config file for ${meta.id}"
    publishDir params.configs_dir, mode: 'copy', pattern: '*.py'
    container 'quay.io/biocontainers/cnvpytor:1.3.1--pyhdfd78af_0'

    input:
    tuple val(meta), val(assembly_id), path(gc_file)

    output:
    tuple val(meta), val(assembly_id), path("*.py"), emit: config
    path "versions.yml", emit: versions

    script:
    """
    python $projectDir/bin/config_file.py \
        ${params.assemblies}/${assembly_id}.${params.fasta} \
        ${assembly_id} \
        "${params.species}" \
        "${params.gc_dir}/${gc_file}" \
        > ${assembly_id}.py

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvpytor: \$(cnvpytor --version 2>&1 | grep "CNVpytor" | sed 's/CNVpytor //')
        python: \$(python --version 2>&1 | sed 's/Python //')
    END_VERSIONS
    """
}
