#!/bin/bash

source activate aienv
nohup jupyter notebook --ip=0.0.0.0 --port=8080 --allow-root --NotebookApp.token='' --NotebookApp.password='' &
conda deactivate
