include: "constants.smk"
include: "utils.smk"


configfile: "config/config.yaml"


pepfile: "config/pep/config.yaml"


if config["dir_run"] and config["dir_run"] is not None:

    workdir: config["dir_run"]


DIR_DATA = config["dir_data"]
DF_SAMPLE = pep.sample_table.set_index("sample_name", drop=False)
SAMPLES = DF_SAMPLE.index

TO_CLEAN_FQ = config["clean_fq"]
TO_RUN_FASTQC = config["run_fastqc"]
TO_RUN_MULTIQC = config["run_multiqc"]
