% Subdirectories of the participants
subdir_list={%'VPpaa_15_03_04'    
    'VPpab_15_03_06'    
    %'VPpac_15_03_09'
    'VPpad_15_03_10'
    'VPpae_15_03_11'
    'VPpaf_15_03_11'
    'VPpag_15_03_12'
    'VPpah_15_03_12'
    'VPpai_15_03_13'
    'VPpaj_15_03_16'     
    'VPpak_15_03_16'
    'VPpal_15_03_17' 
    'VPpam_15_03_19'
    %'VPpan_15_03_20' % Missing eye tracking file (one block)
    %'VPpao_15_03_20' % Empty eeg marker file (one block)
    'VPpap_15_03_23'
    'VPpaq_15_03_27'
    'VPpar_15_03_30'
    'VPpas_15_03_31'
    'VPpat_15_04_24'
    'VPpau_15_04_27'
    };

% TEST WITH THREE SUBJECTS
%subdir_list=subdir_list(1:3,:);

% Experimental conditions 
% (hf= high focus, lf=low focus; cr=cross, sq=square, st=star, es=eye shaped, do =dotted, tr=triangle)
tags={'hf_sq' 'lf_do' 'hf_st' 'lf_tr' 'hf_es' 'lf_cr'
    'hf_do' 'lf_es' 'hf_tr' 'lf_st' 'hf_cr' 'lf_sq'};
