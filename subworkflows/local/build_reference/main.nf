

include { GCFILE  } from '../../../modules/local/gcfile/main'
include { CONFIG  } from '../../../modules/local/config/main'

workflow BUILD_REFERENCE {

    take:
    accession_ch    // channel: [ val(meta), val(assembly_id) ]

    main:
    GCFILE(accession_ch)
    CONFIG(GCFILE.out.gcfile)

    emit:
    config = CONFIG.out.config
    versions = Channel.empty()
          .mix(GCFILE.out.versions)
          .mix(CONFIG.out.versions)    // passes config files to next subworkflow
}
