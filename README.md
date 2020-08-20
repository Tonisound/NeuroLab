=== NeuroLab ===
Main developer : Antoine Bergel <antoine.bergel@gmail.com>
Copyright INSERM
Software IDDN : IDDN.FR.001.090004.000.SP.2019.000.31230

This software allows to synchronize and visualize simultaneously ultrasound data (fUS movies) with electrophysiological data (EEG,EMG,LFP,EOG) and behvaioral data (VIDEO).
It offers a variety of analysis and processing tools embedded in a user-friendly and compact graphical interface in MATLAB.

---------------------------------------------------------------------------
NeuroLab Directions – Update August 2020

Importation
o	Homogenize length_burst/n_burst
		Affichage avec NaN values en mode burst
		Harmoniser code BURST/CONTINUOUS
o	Add rectangular selection upon Doppler importation
o	Option Import trigger as NLab trace
o	Dialog Box when no trigger.txt found (fsamp/offset)
o	Option Manual selection of trigs when irregular

Processes
o	Use uigetdir to select recording list
o	Add Delete Sources_fUS option

Figures
o	Correlation Ananlysis: 
		Add Autocorrelation fUS
		Add slider step Callback -> update lags and slider => DONE
o	Add TimePatchBox in Movie_Normalized
o	Add sliders for threshold in Figure Sleep Scoring
o	Add click function for threshold in Detect Locomotion

Bug Fixes: 
o	Replace movefile by simple loading in Synthesis/Cross-Correlation LFP-fUS
o	Save indexes as sources (detect surges/generate time indexes
		See Detect Locomotion Events
o	Fix Correlation Analysis when no regions selected
o	Delete info.txt
o	Fix boxMask_callback in Correlation Analysis
o	Divide LFP bands (Beta band)
o	Pixel/Box smoothing upon click/cursor motion (main interface)
o	Keep ratio video in Video Behavior
o	Detect left/right runs based on sources (not lines)

---------------------------------------------------------------------------
NeuroLab Directions – Update May 2020

Importation
o	Merge Doppler/Doppler_normalized in Doppler.mat
o	Export/crop video upon import
o	Add delay LFP-video delay upon import
o	Interpolate Doppler when timing is not regular
o	Homogenize length_burst/n_burst
		Affichage avec NaN values en mode burst
		Harmoniser code BURST/CONTINUOUS
o	Remove nlab folder upon failed import
o	Remove hidden files mp4 upon import
o	Add multiple File selection
o	Hide _S recording lists

Processes
o	Add sleep scoring
o	Group Region Definition (in Edit Regions)
o	Process Generate Region Groups
o	Divide frequency bands
o	Distinguish Import traces / Filter LFP / Compute LFP power
o	Process Actualize File Configuration (change_files) + Update FILES
o	Add Selected Option to lines in Main Layout 
		Change color/linewidth if selected

Figures
o	Add figure autocorrelation fUS
o	Add Group Region & Time Groups in fUS Correlation

Bug Fixes: 
o	Bug Autoscale (apply to all axes) in Wavelet Figure
o	Bug Update/show time upon cursor motion in Wavelet Figure
o	Bug Legend in Figure fUS statistics
o	Bug Duplicate Save traces (LFP) upon import + Save Config
o	Bug Duplicate Time Patch (Light and Full file mode)
o	Show/hide Group/RegionGroup patches according to RightPanelPopup
o	Confusion LabelBox (no labels) / Horizontal Axis Box
o	Bug Reset Button in Menu Edit Traces
o	Filter temperature upon import (bug fix)

---------------------------------------------------------------------------
NeuroLab Directions – Update January 2020

Importation
o	Merge Doppler/Doppler_normalized
o	Export/crop video upon import
o	Remove .*.mp4 upon import (hidden files)
o	Harmoniser length_burst/n_burst
		Affichage avec NaN values en mode burst
		Harmoniser code BURST/CONTINUOUS
o	Remove nlab folder upon failed import
o	Add multiple File selection
o	Filter temperature upon import (bug fix)
o	Hide _S recording lists

Processes
o	Ajouter sleep scoring
o	Ajout automatique time-groups
o	Définition de groupes de regions 
o	Add delay LFP video
o	Divide frequency bands

Layout
o	Overlay atlas checkbox in main interface
        Bug fix atlas coordinates
o	Aplats de couleur pour time-groups

Figures
o	Wavelet: Bug autoscale Wavelet
o	Wavelet: Update/show time upon cursor motion
o	Add figure autocorrelation fUS
o	Pb de légende Figure fus_statistics

---------------------------------------------------------------------------
NeuroLab Directions – Update November 2019

Figure Wavelet
o	Bug autoscale Wavelet
o	Update/show time upon cursor motion
o	Check Wavelet analysis + integrate Fourier

To do
o	Filter temperature upon LFP importation
o	Add delay video-LFP to read video

Processes
o	Integrate sleep scoring (base: script Marta)
o	Integrate Figure autocorrelation (base: script Chloé)
o	Option divide frequency bands
o	Automatic grouping of time tags – Define time groups
		(Grouper les tags qui contiennent une string puis écraser time groups)
o	Définir des groupes de régions (Trace_group) automatiquement/manuellement

---------------------------------------------------------------------------
NeuroLab Directions – Update October 2019

To fix 
o	Multiple File Selection upon Importation
o	Compute normalized movie from reference region
o	Function update offset from txt file
o	Bug fUS Episode stats if only 1 time group (legend bug + bug compute)
o	Figure Peak Detection Wavelet: bug nanconv does not work
o	Figure fUS Correlation Analysis (in Traces & Tags) Tab Time_group for selection

---------------------------------------------------------------------------
NeuroLab Directions – Update April 2019

To do 
o	Synthesis Cross-correlation LFP-fUS (Burst mode)
o	Figure Peak Detection (Burst mode)
o	Synthesis PeriEvent time histogram
o	Bug Global Episode Display

To fix
o	Allow channel update in Edit LFP config
o	Dissocier Filter LFP / Compute LFP power / store in separate folder
o	Do not move files in Synthesis (useless)
o	Movie add listeners
o	Export Raw Dataset > Export videos

---------------------------------------------------------------------------
NeuroLab Directions – Update January 2019

To do 
o	Load Time_reference.mat (n_burst, length_burst, rec_mode)
o	Affichage burst avec NaN

To fix
o	Remove nlab folder upon failed importation
o	Bug Trace creation -> smoothing
o	Check recording list without parent

---------------------------------------------------------------------------
NeuroLab Directions – Update December 2018

Video
o	Resize video to screen
o	Exportation video (check frame rate)

Load/import
o	Delete load function (merge load/import)
o	Import/export spiko regions (check importation file)

Filter/smooth
o	Export LFPband (Filter band + extract envelope)
o	Écraser les traces de même nom

Affichage
o	Pouvoir cliquer sur une trace -> selection
o	Option d’offset pour affichage
o	Afficher les traces en mode full (tous les points)

Figure Wavelet
o	Allow X-theta absent (early break mode)
o	Check electrode position + show traces first

Figure Peri Event
o	Add gaussian smoothing

---------------------------------------------------------------------------
NeuroLab Directions – Update June 2018

To do
o	Réhabiliter les différentes synthèses
o	Fix figure PeriEvent Time Histogram
o	Complete figure fUS frequency analysis (autoscale / time button / multiply by n / coherence)
o	Detect behavior
o	Sleep scoring algorithm

To do (future)
o	Remove length_burst/n_burst
o	Mettre le temps en secondes dans UserData
o	Charger mode d’affichage temporel
o	Charger video dans video.mat

To fix
o	Bug Clim scale / bug Box Patch / bug Autoscale Box
o	Bug Batch first file
o	Changer resample to interp1

---------------------------------------------------------------------------
NeuroLab Directions – Update August 2017

Wavelet Fourier analysis
o	Pouvoir calculer la cohérence inter-électrodes / inter-regions

fUS PeriEvent
o	Pouvoir sélectionner tout type d’épisode
o	Réparer sort
o	Affichage Trace_spiko
o	Synthesis inter-recording
o	Carte variabilité / pixel

Synthesis Correlation 
o	Slider dans infoPanel
o	Cartes différentielles theta/gamma
o	Comparer RT pattern

Saving Configuration
o	Do not save l.UserData.X
o	Save [X,Y] ds structure traces
o	Change l.UserData / l.UserData.UserData format

To do
o	Optimize LFP Wavelet
o	Optimize Doppler loading
o	Error message in Batch Processing
o	Include Trace_Region in movie normalized
o	Extracte Heart Rate from IQ data
o	Correction artefact de movement
