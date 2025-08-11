import GEOparse
import pandas as pd
import requests
import argparse
import re
import os

def get_metadata(asc_id: str,
    gse):
    metadata = pd.DataFrame()
    for gsm_name, gsm in gse.gsms.items():
        for key, value in gsm.metadata.items():
            metadata.loc[gsm_name, key] = ''.join(value)
    metadata.to_csv(f"{asc_id}/metadata.tsv", sep="\t", header = True)

def get_suppl_file(asc_id: str,
    suppl_data_link: str,
    gse):
    response = requests.get(f"{suppl_data_link}")
    html = response.text
    
    link_elements = re.search(r'<pre>(.*?)</pre>', html, re.DOTALL)
    print(html)
    pre_content = link_elements.group(1)
    links = re.findall(r'<a href="([^"]+)">', pre_content)
    full_links = [f"{suppl_data_link}" + link for link in links 
        if not link.startswith("..") and "/geo/series/" not in link]

    for link in full_links:
        filename = f"{asc_id}/" + link.split('/')[-1]
        r = requests.get(link, stream = True)
        with open(filename, "wb") as file:
            for chunk in r.iter_content(chunk_size=8192):
                file.write(chunk)


def get_data(asc_id: str, 
    suppl_data_link: str
):
    os.makedirs(
        f"{asc_id}", 
        exist_ok=True
    )

    gse = GEOparse.get_GEO(geo=f"{asc_id}", destdir="./")

    print(gse)

    get_suppl_file(
        asc_id, 
        suppl_data_link,
        gse
    )


    get_metadata(
        asc_id,
        gse
    )


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument("--asc_id")
    parser.add_argument("--suppl_data_link")

    args = parser.parse_args()

    get_data(
        args.asc_id,
        args.suppl_data_link
    )