# Neuroscience Data Analysis Notebooks

A collection of Jupyter notebooks exploring neuronal waveforms, retinal ganglion cell (RGC) images, dimensionality reduction, clustering, and other neuroscience data-analysis questions.

The notebooks are exploratory workflows with different input datasets and dependencies. Start with a topic below rather than running every notebook in filename order.

## Featured workflows

### Neuronal waveform clustering

- [`04_PCA_clustering_compare_methods.ipynb`](notebooks/04_PCA_clustering_compare_methods.ipynb) standardizes waveform samples, applies PCA, and compares k-means with hierarchical clustering using cluster-quality metrics and plots.
- [`05_cluster_characterization.ipynb`](notebooks/05_cluster_characterization.ipynb) examines exported cluster assignments, waveform features, method agreement, and differences between clusters.

These notebooks expect a cleaned waveform CSV and, for characterization, intermediate CSV outputs under local `data/` and `outputs/` directories. Those required files are not all distributed in this repository. The separate [neuropixels_analysis](https://github.com/mouse577/neuropixels_analysis) repository contains an import-and-cleaning notebook; [MATLAB_neuropixels_clustering](https://github.com/mouse577/MATLAB_neuropixels_clustering) contains a focused MATLAB/Python waveform project with example results.

### Retinal ganglion cell image analysis

- [`01_RGC_import_preview.ipynb`](notebooks/01_RGC_import_preview.ipynb) previews cropped images and creates a contact sheet.
- [`02_RGC_CNN_embeddings_clustering.ipynb`](notebooks/02_RGC_CNN_embeddings_clustering.ipynb) uses a pretrained ResNet18 feature extractor, PCA/UMAP, and unsupervised clustering.
- [`03_RGC_cluster_characterization_revised.ipynb`](notebooks/03_RGC_cluster_characterization_revised.ipynb) reviews cluster structure and morphology-related outputs.

This sequence expects local cropped images and generated files that are not included in the repository.

### Other analyses

Additional notebooks explore CSD and traumatic brain injury, retinal imaging, GluSnFR signals, evoked potentials, and model-based workflows. Treat these as individual analyses; inspect each notebook's stated inputs and assumptions before running it.

## Getting started

Create a Python environment with JupyterLab and the packages imported by your chosen notebook, then launch JupyterLab from the repository root:

```bash
jupyter lab
```

For the waveform clustering notebooks, common dependencies include NumPy, pandas, Matplotlib, SciPy, and scikit-learn. Image and Bayesian notebooks require additional packages. There is no complete root-level dependency specification for every notebook.

## Repository notes

- The root-level `.mat` file is an experimental data artifact; its provenance, sharing permission, and role in a reproducible example should be checked before wider distribution.
- Some notebooks are drafts or alternate versions. The links above identify useful entry points; they do not imply that all notebooks form one end-to-end pipeline.
- Generated outputs and some source datasets are absent, so a fresh clone will not execute every notebook without supplying the corresponding data.
