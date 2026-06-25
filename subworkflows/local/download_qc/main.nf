
include { READS   } from '../../../modules/local/iseq/main'
include { FASTP   } from '../../../modules/local/fastp/main'
include { FASTQC  } from '../../../modules/local/fastqc/main'
include { MULTIQC } from '../../../modules/local/multiqc/main'

workflow DOWNLOAD_QC {

    take:
    accession_ch 

    main:

    if ( !params.skip_download ) {
        reads_ch = READS(accession_ch)
        ch_versions = Channel.empty().mix(READS.out.versions)
        reads_ch    = READS.out.reads.map { meta, reads, metadata -> [ meta, reads ] }
    } else {
        reads_ch = accession_ch.map { meta, assembly_id ->
            [ meta, [
                file("${params.reads_dir}/${meta.id}_1.fastq.gz"),
                file("${params.reads_dir}/${meta.id}_2.fastq.gz")
            ]]
        }
	ch_versions = Channel.empty()
    }

    FASTP(reads_ch)
    FASTQC(FASTP.out.reads.map { meta, read1, read2 -> [ meta, read1, read2 ] })
    MULTIQC(FASTQC.out.logs.collect())

    emit:
    trimmed = FASTP.out.reads
    versions = ch_versions
     .mix(FASTP.out.versions)
     .mix(FASTQC.out.versions)
     .mix(MULTIQC.out.versions)
}
