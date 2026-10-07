rule fastp:
    input:
        fq1=f"{DIR_DATA}/{{sample}}_R1.fq.gz",
        fq2=f"{DIR_DATA}/{{sample}}_R2.fq.gz",
    output:
        fq1=f"fastp/{{sample}}/{{sample}}_R1.fq.gz",
        fq2=f"fastp/{{sample}}/{{sample}}_R2.fq.gz",
        fq1_unpaired="fastp/{sample}/{sample}.unpaired_R1.fq.gz",
        fq2_unpaired="fastp/{sample}/{sample}.unpaired_R2.fq.gz",
        fq_failed="fastp/{sample}/{sample}.failed.fq.gz",
        json="fastp/{sample}/{sample}.json",
        html="fastp/{sample}/{sample}.html",
    log:
        "logs/{sample}/fastp.log",
    threads: 1
    params:
        args=get_extra_arguments("fastp"),
    shell:
        """
        fastp \\
            {params.args} \\
            --thread {threads} \\
            --detect_adapter_for_pe \\
            --in1 {input.fq1} --in2 {input.fq2} \\
            --out1 {output.fq1} --out2 {output.fq2} \\
            --unpaired1 {output.fq1_unpaired} --unpaired2 {output.fq2_unpaired} \\
            --failed_out {output.fq_failed} \\
            --json {output.json} \\
            --html {output.html} \\
            1>{log} 2>&1
        """
