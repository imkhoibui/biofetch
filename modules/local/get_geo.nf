#!/usr/bin/env nextflow
process GET_GEO {
    tag "${asc_id}"

    container "community.wave.seqera.io/library/pip_geoparse_pandas:24e5b15a83985023"

    input:
    tuple val(meta), val(asc_id)

    output:
    // path("${asc_id}/data_urls.txt")                                 , emit: geo_data
    tuple val(meta), val(asc_id), path("${asc_id}/*")                , emit: geo_folder   

    script:
    def base_data_link      = task.ext.geo_link ?: "https://ftp.ncbi.nlm.nih.gov/geo/series"
    def bucket              = "${asc_id}"[0..-4]
    def suppl_data_link     = "${base_data_link}/${bucket}nnn/${asc_id}/suppl/"
    def outdir              = params.outdir ?: "./"
    """
    #!/usr/bin/env python3

    import GEOparse
    import pandas as pd
    import requests
    import re
    import os

    os.makedirs(
        "./${asc_id}", 
        exist_ok=True
    )

    gse = GEOparse.get_GEO(
        geo="${asc_id}",
        destdir="./"
    )

    response = requests.get("${suppl_data_link}")
    html = response.text
    
    link_elements = re.search(r'<pre>(.*?)</pre>', html, re.DOTALL)
    pre_content = link_elements.group(1)
    links = re.findall(r'<a href="([^"]+)">', pre_content)
    full_links = ["${suppl_data_link}" + link for link in links if not link.startswith("..") and "/geo/series/" not in link]

    for link in full_links:
        filename = "${asc_id}/" + link.split('/')[-1]
        r = requests.get(link, stream = True)
        with open(filename, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)

    metadata = pd.DataFrame()
    for gsm_name, gsm in gse.gsms.items():
        for key, value in gsm.metadata.items():
            metadata.loc[gsm_name, key] = ''.join(value)
    metadata.to_csv("${asc_id}/metadata.tsv", sep="\t", header = True)
        
    """

}