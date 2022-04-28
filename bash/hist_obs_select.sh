#!/bin/bash -l


# ==============================================================================
# SUMMARY
# ==============================================================================


# 17 May 2021

# make year selections from decomp'd historical data 


# =======================================================================
# RUN FACTORS
# =======================================================================


exp_list=("historical" "hist-noLu" "lu")
models=("CanESM5" "CNRM-ESM2-1" "IPSL-CM6A-LR" "UKESM1-0-LL")
var="tasmax"
state="unmasked"
len=50

# directories
m_inDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/final
mkdir -p /nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/final/select/${state}
m_finDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/final/select/${state}

o_inDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/obs/final
mkdir -p /nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/obs/final/select/${state}
o_finDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/obs/final/select/${state}


# =======================================================================
# RUN
# =======================================================================


# select and mask model and obs data
cd $m_inDIR
for mod in "${models[@]}"; do

    cd $m_inDIR
    mod_files=($(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_*${mod}*max*" -printf '%P\n'))
    
    # select years, set time and mask model data (hist_decomp.sh already decomposes and takes season)
    for f in "${mod_files[@]}"; do
    
        # two sets if 50 year length chosen
        if [[ $len -eq 50 ]]; then
        
            y1_m_a=1915
            y1_m_b=1965
            y2_m_a=$(( $y1_m_a + $(($len-1)) ))
            y2_m_b=$(( $y1_m_b + $(($len-1)) ))
        
            cdo -O -L \
                setreftime,${y1_m_a}-01-01,00:00:00,1years \
                -settaxis,${y1_m_a}-01-01,00:00:00,1years \
                -seldate,${y1_m_a}-01-01T00:00:00,${y2_m_a}-12-31T00:00:00 \
                $m_inDIR/${f} \
                $m_finDIR/"${f/185001-201412/${state}_${y1_m_a}01-${y2_m_a}12}"
                
            cdo -O -L \
                setreftime,${y1_m_b}-01-01,00:00:00,1years \
                -settaxis,${y1_m_b}-01-01,00:00:00,1years \
                -seldate,${y1_m_b}-01-01T00:00:00,${y2_m_b}-12-31T00:00:00 \
                $m_inDIR/${f} \
                $m_finDIR/"${f/185001-201412/${state}_${y1_m_b}01-${y2_m_b}12}"

        # one set if 100 year length chosen
        elif [[ $len -eq 100 ]]; then
        
            y1_m=1915
            y2_m=$(( $y1_m + $(($len-1)) ))
                
            cdo -O -L \
                setreftime,${y1_m}-01-01,00:00:00,1years \
                -settaxis,${y1_m}-01-01,00:00:00,1years \
                -seldate,${y1_m}-01-01T00:00:00,${y2_m}-12-31T00:00:00 \
                $m_inDIR/${f} \
                $m_finDIR/"${f/185001-201412/${state}_${y1_m}01-${y2_m}12}"
        fi
    done
    
    # select years, tres, set time and select tasmax from obs data
    cd $o_inDIR
    f="tasmax_obs_${mod}-res_190101-201412.nc" # premade with remap on command line
    
    if [[ $len -eq 50 ]]; then
            
        cdo -O -L \
            selname,${var} \
            -setreftime,${y1_m_a}-01-01,00:00:00,1years \
            -settaxis,${y1_m_a}-01-01,00:00:00,1years \
            -yearmax \
            -seldate,${y1_m_a}-01-01T00:00:00,${y2_m_a}-12-31T00:00:00 \
            $o_inDIR/${f} \
            $o_finDIR/"${f/_190101-201412/_max_${state}_${y1_m_a}01-${y2_m_a}12}"
            
        cdo -O -L \
            selname,${var} \
            -setreftime,${y1_m_b}-01-01,00:00:00,1years \
            -settaxis,${y1_m_b}-01-01,00:00:00,1years \
            -yearmax \
            -seldate,${y1_m_b}-01-01T00:00:00,${y2_m_b}-12-31T00:00:00 \
            $o_inDIR/${f} \
            $o_finDIR/"${f/_190101-201412/_max_${state}_${y1_m_b}01-${y2_m_b}12}"

    elif [[ $len -eq 100 ]]; then
    
        cdo -O -L \
            selname,${var} \
            -setreftime,${y1_m}-01-01,00:00:00,1years \
            -settaxis,${y1_m}-01-01,00:00:00,1years \
            -yearmax \
            -seldate,${y1_m}-01-01T00:00:00,${y2_m}-12-31T00:00:00 \
            $o_inDIR/${f} \
            $o_finDIR/"${f/_190101-201412/_max_${state}_${y1_m}01-${y2_m}12}"
                    
    fi
done
        
        







