#!/bin/bash -l

# ==============================================================================
# SUMMARY
# ==============================================================================


# 07 January 2021

# Extract pichunks from all available models


# =======================================================================
# RUN
# =======================================================================

var="tasmax"
exp="piControl"
state="unmasked" # either "crops" or "forest"

# directories
inDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/lumip/d_a/allpi
mkdir -p /theia/data/brussel/vo/000/bvo00012/vsc10116/lumip/d_a/allpi/wrk
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/lumip/d_a/allpi/wrk
mkdir -p /theia/data/brussel/vo/000/bvo00012/vsc10116/lumip/d_a/allpi/final
finDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/lumip/d_a/allpi/final

# length of series
len=50

cd $inDIR
models_list=()
all_files=($(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}*${exp}*" -printf '%P\n'))
for f in "${all_files[@]}"; do # retrieve model labels
    models_list[${#models_list[@]}]="$(cut -d'_' -f 3 <<<"$f")"
done
models=($(echo "${models_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')) # list of unique model names for analysis

for mod in "${models[@]}"; do

    cd $inDIR
    
    # all pi files for this mod
    mod_files=($(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}*${mod}*${exp}*" -printf '%P\n'))
    member_list=()
    
    # retrieve realisation (member) labels
    for f in "${mod_files[@]}"; do
    
        member_list[${#member_list[@]}]="$(cut -d'_' -f 5 <<<"$f")"
        
    done
    
    unique_member_list=($(echo "${member_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    for m in "${unique_member_list[@]}"; do
        
        # find list of files for realisation m
        cd $inDIR
        mem_files=($(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}*${mod}_${exp}_${m}*" -printf '%P\n' | sort))
        f1="${mem_files[0]}"
        n_f="${#mem_files[@]}"
        f2="${mem_files[$n_f-1]}"
        y1=$(cut -d'_' -f 7 <<<"${f1}" | cut -c 1-4)
        span_y1=$(echo $y1 | sed 's/^0*//')
        y2=$(cut -d'_' -f 7 <<<"${f2}" | cut -d'-' -f 2 | cut -c 1-4)
        span_y2=$(echo $y2 | sed 's/^0*//')
        tstep="$(cut -d'_' -f 2 <<<"${f1}")"
        grid="$(cut -d'_' -f 6 <<<"${f1}")"
        
        # merge files for m
        cdo -O \
            mergetime \
            $(echo "${mem_files[@]}") \
            $wrkDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_${y1}01-${y2}12.nc"
        
        # seasonal and annual selections
        cdo -O \
            yearmax \
            $wrkDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_${y1}01-${y2}12.nc" \
            $wrkDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${y1}01-${y2}12.nc"
        
        cd $wrkDIR

        span=$(($span_y2-$span_y1))
        n_chunks=$(($span/$len))
        
        # get arrays for chunk indexes and chunk starting years
        chunk_ids=($(seq 0 1 $(($n_chunks-1))))
        declare -A chunks
        for i in "${chunk_ids[@]}"; do
            if [ "$i" == 0 ]; then
                chunks[$i]=$span_y1
            elif [ "$i" -gt 0 ]; then
                chunks[$i]=$(( $span_y1+$len*$i ))
            fi
        done
        
        for i in "${chunk_ids[@]}"; do
        
            # chunk years
            y_i=${chunks[$i]}
            y_f=$(( ${chunks[$i]} + $(($len-1)) ))
            
            if [ $len -eq 50 ]; then
            
                # model analysis ranges
                y1_m_a=1915
                y1_m_b=1965
                y2_m_a=$(( $y1_m_a + $(($len-1)) ))
                y2_m_b=$(( $y1_m_b + $(($len-1)) ))
                    
                cdo -O -L \
                    setreftime,${y1_m_b}-01-01,00:00:00,1years \
                    -settaxis,${y1_m_b}-01-01,00:00:00,1years \
                    -seldate,${y_i}-01-01T00:00:00,${y_f}-12-31T00:00:00 \
                    $wrkDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${y1}01-${y2}12.nc" \
                    $finDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${state}_${y1_m_b}01-${y2_m_b}12_chunk${i}.nc" 
                
                
            elif [ $len -eq 100 ]; then
            
                # model analysis ranges
                y1_m=1915
                y2_m=$(( $y1_m + $(($len-1)) ))
            
                # select chunk years; set to model analysis years
                cdo -O -L \
                    setreftime,${y1_m}-01-01,00:00:00,1years \
                    -settaxis,${y1_m}-01-01,00:00:00,1years \
                    -seldate,${y_i}-01-01T00:00:00,${y_f}-12-31T00:00:00 \
                    $wrkDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${y1}01-${y2}12.nc" \
                    $finDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${state}_${y1_m}01-${y2_m}12_chunk${i}.nc" 
                    
            fi
        done
    done
done



