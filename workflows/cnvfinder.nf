

include { DOWNLOAD_QC     } from '../subworkflows/local/download_qc/main'
include { BUILD_REFERENCE } from '../subworkflows/local/build_reference/main'
include { MAP_READS       } from '../subworkflows/local/map_reads/main'
include { CALL_CNVS       } from '../subworkflows/local/cnvpytor/main'

workflow CNVFINDER {

    // create main channel from CSV - both columns
    accession_ch = Channel.fromPath(params.accessions)
                       .splitCsv(header: false)
                       .map { row -> [ [id: row[0]], row[1] ] }

    // run download, QC and reference building in parallel
    DOWNLOAD_QC(accession_ch)
    BUILD_REFERENCE(accession_ch)

    // join trimmed reads with assembly_id ready for mapping
    map_input = DOWNLOAD_QC.out.trimmed
                    .join(accession_ch, by: 0)
                    .map { meta, read1, read2, assembly_id ->
                        [ meta, assembly_id, read1, read2 ] }

    // map trimmed reads to reference
    MAP_READS(map_input, BUILD_REFERENCE.out.config)

    // call CNVs using pytor files and config
    CALL_CNVS(MAP_READS.out.pytor, BUILD_REFERENCE.out.config)

    ch_versions = Channel.empty()
        .mix(DOWNLOAD_QC.out.versions)
        .mix(BUILD_REFERENCE.out.versions)
        .mix(MAP_READS.out.versions)
        .mix(CALL_CNVS.out.versions)

    ch_versions.collectFile(
        name: 'software_versions.yml',
        storeDir: "${params.outdir}/pipeline_info"
    )
}
