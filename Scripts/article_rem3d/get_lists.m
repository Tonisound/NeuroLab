function L = get_lists(rec_list,reg_group)
% generate list_files and list_regions based on recording list and region group

if strcmp(rec_list,'CORONAL')
    list_files = {'20190225_SD025_P202_R_nlab';'20190226_SD025_P101_R_nlab';'20190226_SD025_P201_R_nlab';'20190226_SD025_P301_R_nlab';'20190226_SD025_P302_R_nlab';
        '20190226_SD025_P401_R_nlab';'20190227_SD025_P102_R_nlab';'20190227_SD025_P201_R_nlab';'20190227_SD025_P202_R_nlab';'20190227_SD025_P501_R_nlab';
        '20190306_SD025_P301_R_nlab';'20190306_SD025_P401_R_nlab';'20190415_SD032_P201_R_nlab';'20190415_SD032_P202_R_nlab';'20190415_SD032_P301_R_nlab';
        '20190415_SD032_P302_R_nlab';'20190416_SD032_P102_R_nlab';'20190416_SD032_P201_R_nlab';'20190416_SD032_P202_R_nlab';'20190416_SD032_P203_R_nlab';
        '20190416_SD032_P301_R_nlab';'20190416_SD032_P302_R_nlab';'20190416_SD032_P303_R_nlab';'20190416_SD032_P402_R_nlab';'20190417_SD032_P102_R_nlab';
        '20190417_SD032_P103_R_nlab';'20190417_SD032_P202_R_nlab';'20190417_SD032_P203_R_nlab';'20190417_SD032_P301_R_nlab';'20190417_SD032_P302_R_nlab';
        '20190417_SD032_P303_R_nlab';'20190417_SD032_P401_R_nlab';'20190417_SD032_P402_R_nlab';'20190417_SD032_P403_R_nlab';'20190418_SD032_P102_R_nlab';
        '20190418_SD032_P103_R_nlab';'20190418_SD032_P201_R_nlab';'20190418_SD032_P202_R_nlab';'20190418_SD032_P203_R_nlab';'20190710_SD041_P201_R_nlab';
        '20190710_SD041_P301_R_nlab';'20190710_SD041_P401_R_nlab';'20190710_SD041_P402_R_nlab';'20190710_SD041_P501_R_nlab';'20190711_SD041_P103_R_nlab';
        '20190711_SD041_P401_R_nlab';'20190711_SD041_P402_R_nlab';'20190716_SD041_P201_R_nlab';'20190716_SD041_P203_R_nlab';'20190716_SD041_P301_R_nlab';
        '20190716_SD041_P302_R_nlab';'20190717_SD041_P103_R_nlab';'20190717_SD041_P104_R_nlab';'20190717_SD041_P201_R_nlab';'20190717_SD041_P401_R_nlab';
        '20190718_SD041_P201_R_nlab';'20190718_SD041_P202_R_nlab';'20190718_SD041_P302_R_nlab'};

elseif strcmp(rec_list,'SAGITTAL')
    list_files = {'20190228_SD025_P301_R_nlab';'20190228_SD025_P302_R_nlab';'20190301_SD025_P401_R_nlab';'20190301_SD025_P402_R_nlab';'20190418_SD032_P301_R_nlab';
        '20190418_SD032_P302_R_nlab';'20190418_SD032_P303_R_nlab';'20190418_SD032_P401_R_nlab';'20190419_SD032_P201_R_nlab';'20190419_SD032_P202_R_nlab';
        '20190419_SD032_P301_R_nlab';'20190419_SD032_P302_R_nlab';'20190419_SD032_P401_R_nlab';'20190419_SD032_P402_R_nlab'};
    
elseif strcmp(rec_list,'ALL')
    list_files = {'20190225_SD025_P202_R_nlab';'20190226_SD025_P101_R_nlab';'20190226_SD025_P201_R_nlab';'20190226_SD025_P301_R_nlab';'20190226_SD025_P302_R_nlab';
        '20190226_SD025_P401_R_nlab';'20190227_SD025_P102_R_nlab';'20190227_SD025_P201_R_nlab';'20190227_SD025_P202_R_nlab';'20190227_SD025_P501_R_nlab';
        '20190228_SD025_P301_R_nlab';'20190228_SD025_P302_R_nlab';'20190301_SD025_P401_R_nlab';'20190301_SD025_P402_R_nlab';'20190306_SD025_P301_R_nlab';
        '20190306_SD025_P401_R_nlab';'20190415_SD032_P201_R_nlab';'20190415_SD032_P202_R_nlab';'20190415_SD032_P301_R_nlab';'20190415_SD032_P302_R_nlab';
        '20190416_SD032_P102_R_nlab';'20190416_SD032_P201_R_nlab';'20190416_SD032_P202_R_nlab';'20190416_SD032_P203_R_nlab';'20190416_SD032_P301_R_nlab';
        '20190416_SD032_P302_R_nlab';'20190416_SD032_P303_R_nlab';'20190416_SD032_P402_R_nlab';'20190417_SD032_P102_R_nlab';'20190417_SD032_P103_R_nlab';
        '20190417_SD032_P202_R_nlab';'20190417_SD032_P203_R_nlab';'20190417_SD032_P301_R_nlab';'20190417_SD032_P302_R_nlab';'20190417_SD032_P303_R_nlab';
        '20190417_SD032_P401_R_nlab';'20190417_SD032_P402_R_nlab';'20190417_SD032_P403_R_nlab';'20190418_SD032_P102_R_nlab';'20190418_SD032_P103_R_nlab';
        '20190418_SD032_P201_R_nlab';'20190418_SD032_P202_R_nlab';'20190418_SD032_P203_R_nlab';'20190418_SD032_P301_R_nlab';'20190418_SD032_P302_R_nlab';
        '20190418_SD032_P303_R_nlab';'20190418_SD032_P401_R_nlab';'20190419_SD032_P201_R_nlab';'20190419_SD032_P202_R_nlab';'20190419_SD032_P301_R_nlab';
        '20190419_SD032_P302_R_nlab';'20190419_SD032_P401_R_nlab';'20190419_SD032_P402_R_nlab';'20190710_SD041_P201_R_nlab';'20190710_SD041_P301_R_nlab';
        '20190710_SD041_P401_R_nlab';'20190710_SD041_P402_R_nlab';'20190710_SD041_P501_R_nlab';'20190711_SD041_P103_R_nlab';'20190711_SD041_P401_R_nlab';
        '20190711_SD041_P402_R_nlab';'20190716_SD041_P201_R_nlab';'20190716_SD041_P203_R_nlab';'20190716_SD041_P301_R_nlab';'20190716_SD041_P302_R_nlab';
        '20190717_SD041_P103_R_nlab';'20190717_SD041_P104_R_nlab';'20190717_SD041_P201_R_nlab';'20190717_SD041_P401_R_nlab';'20190718_SD041_P201_R_nlab';
        '20190718_SD041_P202_R_nlab';'20190718_SD041_P302_R_nlab'};
else
    list_files = [];
end
L.list_files = list_files;

% list_regions
if strcmp(reg_group,'AREAS')

    list_regions = {'[SR]AnteriorCortex';'[SR]PosteriorCortex';'[SR]HippocampalFormation';'[SR]Midbrain';'[SR]Thalamus';'[SR]Amygdala';'[SR]Hypothalamus';'[SR]Other'};
    label_regions = {'ACx';'PCx';'HF';'MB';'Th';'Am';'HyTh';'Oth'};
    
elseif strcmp(reg_group,'AREAS-L')

    list_regions = {'[SR]AnteriorCortex-L';'[SR]PosteriorCortex-L';'[SR]HippocampalFormation-L';'[SR]Midbrain-L';'[SR]Thalamus-L';'[SR]Amygdala-L';'[SR]Hypothalamus-L';'[SR]Other-L'};
    label_regions = {'ACx-L';'PCx-L';'HF-L';'MB-L';'Th-L';'Am-L';'HyTh-L';'Oth-L'};
    
elseif strcmp(reg_group,'AREAS-R')
    
    list_regions = {'[SR]AnteriorCortex-R';'[SR]PosteriorCortex-R';'[SR]HippocampalFormation-R';'[SR]Midbrain-R';'[SR]Thalamus-R';'[SR]Amygdala-R';'[SR]Hypothalamus-R';'[SR]Other-R'};
    label_regions = {'ACx-R';'PCx-R';'HF-R';'MB-R';'Th-R';'Am-R';'HyTh-R';'Oth-R'};
    
elseif strcmp(reg_group,'GROUPS')
    
    list_regions = {'OrbitalCortex';'LimbicCortex';'CingulateCortex';'InsularCortex';'MotorCortex';'SomatosensoryCortex';...
        'PiriformCortex';'RetrosplenialCortex';'ParietalCortex';'EntorhinalCortex';'VisualCortex';'AuditoryCortex';'RhinalCortex';
        'DentateGyrus';'CA1Region';'CA2Region';'CA3Region';'ResidualHippocampus';'Subiculum';'Fimbria';
        'Striatum';'BasalForebrain';'SubstantiaNigra';'Septum';
        'StriataTerminalis';'SuperiorColliculus';'InferiorColliculus';'DPAG';'VPAG';'DThalamus';'VThalamus';'Habenulla';'ZonaIncerta';'PretectalNuclei';'GeniculateNuclei';'ReticularFormation';
        'BasalAmygdala';'LateralAmygdala';'CentromedialAmygdala';'CorticalAmygdala';'ResidualAmygdala';
        'DHypothalamus';'LHypothalamus';'VHypothalamus';'VTegmentalArea';'PreopticArea';'MammillaryNuclei';'OlfactoryNuclei';
        'Cerebellum';'BrainStem';'PinealGland';'OptChiasm';'Claustrum';'CCallosum';'Ventricles'};
    label_regions = {'OrCx';'LiCx';'CCx';'ICx';'MCx';'SSCx';...
        'PiCx';'RSCx';'PaCx';'EnCx';'VCx';'AuCx';'RhCx';
        'DG';'CA1';'CA2';'CA3';'RHip';'Sub';'Fim';
        'Stri';'BFb';'SNi';'Sep';
        'StrTer';'SC';'IC';'DPAG';'VPAG';'DThal';'VThal';'Hab';'ZI';'PN';'GN';'RF';
        'BasAm';'LatAm';'CenAm';'CorAm';'ResAm';
        'DHthal';'LHthal';'VHthal';'VTA';'POA';'MN';'ON';
        'Cereb';'BS';'PG';'Opt';'Clau';'CC';'Ven'};
    
%     list_regions = generate_lists('DisplayObj','groups','DisplayMode','bilateral');
%     list_regions(strcmp(list_regions,'Vessels'))=[];
%     label_regions = list_regions;
    
elseif strcmp(reg_group,'LEFT-GROUPS')
    
    list_regions = {'OrbitalCortex-L';'LimbicCortex-L';'CingulateCortex-L';'InsularCortex-L';'MotorCortex-L';'SomatosensoryCortex-L';...
        'PiriformCortex-L';'RetrosplenialCortex-L';'ParietalCortex-L';'EntorhinalCortex-L';'VisualCortex-L';'AuditoryCortex-L';'RhinalCortex-L';
        'DentateGyrus-L';'CA1Region-L';'CA2Region-L';'CA3Region-L';'ResidualHippocampus-L';'Subiculum-L';'Fimbria-L';
        'Striatum-L';'BasalForebrain-L';'SubstantiaNigra-L';'Septum-L';
        'StriataTerminalis-L';'SuperiorColliculus-L';'InferiorColliculus-L';'DPAG-L';'VPAG-L';'DThalamus-L';'VThalamus-L';'Habenulla-L';'ZonaIncerta-L';'PretectalNuclei-L';'GeniculateNuclei-L';'ReticularFormation-L';
        'BasalAmygdala-L';'LateralAmygdala-L';'CentromedialAmygdala-L';'CorticalAmygdala-L';'ResidualAmygdala-L';
        'DHypothalamus-L';'LHypothalamus-L';'VHypothalamus-L';'VTegmentalArea-L';'PreopticArea-L';'MammillaryNuclei-L';'OlfactoryNuclei-L';
        'Cerebellum-L';'BrainStem-L';'PinealGland-L';'OptChiasm-L';'Claustrum-L';'CCallosum-L';'Ventricles-L'};
    label_regions = {'OrCx-L';'LiCx-L';'CCx-L';'ICx-L';'MCx-L';'SSCx-L';...
        'PiCx-L';'RSCx-L';'PaCx-L';'EnCx-L';'VCx-L';'AuCx-L';'RhCx-L';
        'DG-L';'CA1-L';'CA2-L';'CA3-L';'RHip-L';'Sub-L';'Fim-L';
        'Stri-L';'BFb-L';'SNi-L';'Sep-L';
        'StrTer-L';'SC-L';'IC-L';'DPAG-L';'VPAG-L';'DThal-L';'VThal-L';'Hab-L';'ZI-L';'PN-L';'GN-L';'RF-L';
        'BasAm-L';'LatAm-L';'CenAm-L';'CorAm-L';'ResAm-L';
        'DHthal-L';'LHthal-L';'VHthal-L';'VTA-L';'POA-L';'MN-L';'ON-L';
        'Cereb-L';'BS-L';'PG-L';'Opt-L';'Clau-L';'CC-L';'Ven-L'};
    
elseif strcmp(reg_group,'RIGHT-GROUPS')

        list_regions = {'OrbitalCortex-R';'LimbicCortex-R';'CingulateCortex-R';'InsularCortex-R';'MotorCortex-R';'SomatosensoryCortex-R';...
        'PiriformCortex-R';'RetrosplenialCortex-R';'ParietalCortex-R';'EntorhinalCortex-R';'VisualCortex-R';'AuditoryCortex-R';'RhinalCortex-R';
        'DentateGyrus-R';'CA1Region-R';'CA2Region-R';'CA3Region-R';'ResidualHippocampus-R';'Subiculum-R';'Fimbria-R';
        'Striatum-R';'BasalForebrain-R';'SubstantiaNigra-R';'Septum-R';
        'StriataTerminalis-R';'SuperiorColliculus-R';'InferiorColliculus-R';'DPAG-R';'VPAG-R';'DThalamus-R';'VThalamus-R';'Habenulla-R';'ZonaIncerta-R';'PretectalNuclei-R';'GeniculateNuclei-R';'ReticularFormation-R';
        'BasalAmygdala-R';'LateralAmygdala-R';'CentromedialAmygdala-R';'CorticalAmygdala-R';'ResidualAmygdala-R';
        'DHypothalamus-R';'LHypothalamus-R';'VHypothalamus-R';'VTegmentalArea-R';'PreopticArea-R';'MammillaryNuclei-R';'OlfactoryNuclei-R';
        'Cerebellum-R';'BrainStem-R';'PinealGland-R';'OptChiasm-R';'Claustrum-R';'CCallosum-R';'Ventricles-R'};
    label_regions = {'OrCx-R';'LiCx-R';'CCx-R';'ICx-R';'MCx-R';'SSCx-R';...
        'PiCx-R';'RSCx-R';'PaCx-R';'EnCx-R';'VCx-R';'AuCx-R';'RhCx-R';
        'DG-R';'CA1-R';'CA2-R';'CA3-R';'RHip-R';'Sub-R';'Fim-R';
        'Stri-R';'BFb-R';'SNi-R';'Sep-R';
        'StrTer-R';'SC-R';'IC-R';'DPAG-R';'VPAG-R';'DThal-R';'VThal-R';'Hab-R';'ZI-R';'PN-R';'GN-R';'RF-R';
        'BasAm-R';'LatAm-R';'CenAm-R';'CorAm-R';'ResAm-R';
        'DHthal-R';'LHthal-R';'VHthal-R';'VTA-R';'POA-R';'MN-R';'ON-R';
        'Cereb-R';'BS-R';'PG-R';'Opt-R';'Clau-R';'CC-R';'Ven-R'};
    
elseif strcmp(reg_group,'REGIONS')
    list_regions = generate_lists('AtlasType','ratcoronal','DisplayObj','regions','DisplayMode','bilateral');
    label_regions=list_regions;
    
elseif strcmp(reg_group,'LEFT-REGIONS')
    l1 = generate_lists('AtlasType','ratcoronal','DisplayObj','regions','DisplayMode','unilateral');
    list_regions = l1(endsWith(l1,'-L'));
    label_regions=list_regions;
    
elseif strcmp(reg_group,'RIGHT-REGIONS')
    l1 = generate_lists('AtlasType','ratcoronal','DisplayObj','regions','DisplayMode','unilateral');
    list_regions = l1(endsWith(l1,'-R'));
    label_regions=list_regions;
    
elseif strcmp(reg_group,'LEFT-RIGHT-REGIONS')
    l1 = generate_lists('AtlasType','ratcoronal','DisplayObj','regions','DisplayMode','unilateral');
    list_regions = l1;
    label_regions=list_regions;
    
elseif strcmp(reg_group,'VESSEL-GROUPS')
    %list_regions = {'Ventricules';'Vessels';'ach';'acer';'mcer';'basalvessel';'vessel';'lhia'};
    list_regions = {'Ventricules-L';'Ventricules-R';...
        'ach-L';'ach-R';'acer-L';'acer-R';'mcer-L';'mcer-R';...
        'basalvessel-L';'basalvessel-R';'vessel-L';'vessel-R';'lhia-L';'lhia-R'};
    label_regions=list_regions;

else
    list_regions = [];
    label_regions = [];
end
L.list_regions = list_regions;
L.label_regions = label_regions;

end