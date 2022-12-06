#!/bin/bash
cd $HOME

VIRTUAL_ENV=$1
USERNAME=$2
CONDA_EXEC=$HOME/anaconda3/bin/conda
QUANTDG_LOCAL_REPO=/nfs/quantdg

# Anaconda3
if [ -f $CONDA_EXEC ] 
then
    echo "Anaconda3 installed."
else
    echo "Anaconda3 not installed. Start installation now..."
    wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh
    bash Anaconda3-2022.05-Linux-x86_64.sh -b -p $HOME/anaconda3
fi
eval "$($HOME/anaconda3/bin/conda shell.bash hook)"
conda init

# create virtual environment if not exists
if ! { conda env list | grep $VIRTUAL_ENV; } >/dev/null 2>&1
then
    echo "Conda environment $VIRTUAL_ENV not installed."
    conda create -y --name $VIRTUAL_ENV python=3.9
else
    echo "Conda environment $VIRTUAL_ENV installed."
fi
source $HOME/anaconda3/etc/profile.d/conda.sh
conda activate $VIRTUAL_ENV

# If already cloned
if ! [ -d $QUANTDG_LOCAL_REPO ]
then
    echo "git clone from remote repo..."
    git clone https://github.com/harini9804/quant-dg-experiment.git $QUANTDG_LOCAL_REPO
else
    echo "$QUANTDG_LOCAL_REPO exists! Skip git clone..."
fi


cd $QUANTDG_LOCAL_REPO
pip install torch numpy pandas matplotlib scikit-learn tensorboard tqdm