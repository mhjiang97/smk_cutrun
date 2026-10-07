def get_input_bedgraph(wildcards):
    sample = wildcards.sample
    if config["mode_normalization"] in ["CPM", "BPM"]:
        return f"deeptools/{sample}/{sample}.bedgraph"
    elif config["mode_normalization"] in ["none", "spike-in"]:
        return f"bedtools/{sample}/{sample}.bedgraph"
    else:
        raise ValueError(
            f"Invalid mode_normalization: {config['mode_normalization']}"
        )


rule seacr:
    input:
        bedgraph=get_input_bedgraph,
    output:
        peaks="seacr/{sample}/{sample}.stringent.bed",
    log:
        "logs/{sample}/seacr.log",
    shadow:
        "minimal"
    conda:
        "../../envs/seacr.yaml"
    params:
        threshold=0.01,
        normalization="non",
        stringency="stringent",
        prefix="seacr/{sample}/{sample}",
    shell:
        """
        SEACR_1.3.sh \\
            {input.bedgraph} \\
            {params.threshold} \\
            {params.normalization} \\
            {params.stringency} \\
            {params.prefix} \\
            1>{log} 2>&1
        """
