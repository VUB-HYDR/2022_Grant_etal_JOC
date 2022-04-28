#!/bin/bash -l


# ==============================================================================
# SUMMARY
# ==============================================================================


# 31 May 2021

# decomposition of hist and hist-nolu into hist-nolu + lu


# =======================================================================
# RUN FACTORS
# =======================================================================


# directories
inDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod
mkdir -p /nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/decomp
dcmpDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/decomp
mkdir -p /nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/final
finDIR=/nec/vol1/site_scratch/leuven/projects/lt1_2020_es_pilot/VUB/lgrant/d_a/mod/final

# variable
var="tasmax"

# decomp factors
factor="2-factor"

if [[ "$factor" == "2-factor" ]]; then
    exp_a="historical"
    exp_b="hist-noLu"
    exp_list=("${exp_a}" "${exp_b}")
elif [[ "$factor" == "3-factor" ]]; then
    true
fi


# =======================================================================
# RUN
# =======================================================================


# list of available files
cd $inDIR
file_list=($(find ./ -maxdepth 1 -mindepth 1 -type f))

# all models
models=()
for file in "${file_list[@]}"; do
    models[${#models[@]}]="$(cut -d'_' -f 3 <<<"$file")"
done

# unique models
unique_models=($(echo "${models[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# for each model, get member list (r...)
    # for each member list, run subtraction + copy of hist-nolu to outputdir
        # in output dir, compute winter and summer seasons, annual mean
for mod in "${unique_models[@]}"; do

    mod_files=($(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_"\*"${mod}"\* -printf '%P\n'))
    echo "${mod_files[@]}"
    member_list=()
    
    for f in "${mod_files[@]}"; do
        member_list[${#member_list[@]}]="$(cut -d'_' -f 5 <<<"$f")"
    done
    
    unique_member_list=($(echo "${member_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    if [[ "${mod}" != "CanESM5" ]]; then
    
        for m in "${unique_member_list[@]}"; do 
        
            f1=$(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_"\*"${mod}_${exp_a}_${m}"\*".nc" -printf '%P\n')
            f2=$(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_"\*"${mod}_${exp_b}_${m}"\*".nc" -printf '%P\n')
            f_list=("${f1}" "${f2}")
            tstep="$(cut -d'_' -f 2 <<<"${f1}")"
            grid="$(cut -d'_' -f 6 <<<"${f1}")"
            time="$(cut -d'_' -f 7 <<<"${f1}")"
            
            for exp in "${exp_list[@]}"; do
                
                for i in "${f_list[@]}"; do
                
                    if [[ "$i" == *"$exp"* ]]; then
                        
                        f="${i}"
                    
                        cdo -O \
                            yearmax \
                            ${f} \
                            $dcmpDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${time}" \
                            
                    fi
                done
            done
            
            cdo -O \
                sub \
                $dcmpDIR/"${var}_${tstep}_${mod}_${exp_a}_${m}_${grid}_max_${time}" \
                $dcmpDIR/"${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_max_${time}" \
                $finDIR/"${var}_${tstep}_${mod}_lu_${m}_${grid}_max_${time}"
            
            cp $dcmpDIR/"${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_max_${time}" $finDIR
            cp $dcmpDIR/"${var}_${tstep}_${mod}_${exp_a}_${m}_${grid}_max_${time}" $finDIR
            
        done
        
    elif [[ "${mod}" == "CanESM5" ]]; then
    
        for m in "${unique_member_list[@]}"; do 
        
            f1=$(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_"\*"${mod}_${exp_a}_${m}"\*".nc" -printf '%P\n')
            f2=$(find ./ -maxdepth 1 -mindepth 1 -type f -name "${var}_"\*"${mod}_${exp_b}_${m}"\*"202012.nc" -printf '%P\n')
            tstep="$(cut -d'_' -f 2 <<<"${f1}")"
            grid="$(cut -d'_' -f 6 <<<"${f1}")"
            time="185001-201412"

            cdo -O \
                selyear,1850/2014 \
                "${f2}" \
                "${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_185001-201412.nc"
                
            f2="${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_185001-201412.nc"
            f_list=("${f1}" "${f2}")
            
            # new code
            for exp in "${exp_list[@]}"; do
                
                for i in "${f_list[@]}"; do
                
                    if [[ "$i" == *"$exp"* ]]; then
                        
                        f="${i}"
                    
                        cdo -O \
                            yearmax \
                            ${f} \
                            $dcmpDIR/"${var}_${tstep}_${mod}_${exp}_${m}_${grid}_max_${time}.nc" \
                            
                    fi
                done
            done
            
            cdo -O \
                sub \
                $dcmpDIR/"${var}_${tstep}_${mod}_${exp_a}_${m}_${grid}_max_${time}.nc" \
                $dcmpDIR/"${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_max_${time}.nc" \
                $finDIR/"${var}_${tstep}_${mod}_lu_${m}_${grid}_max_${time}.nc"
            
            cp $dcmpDIR/"${var}_${tstep}_${mod}_${exp_b}_${m}_${grid}_max_${time}.nc" $finDIR
            cp $dcmpDIR/"${var}_${tstep}_${mod}_${exp_a}_${m}_${grid}_max_${time}.nc" $finDIR
            
            
        done
    fi
done
        
        
        












