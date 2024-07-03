%This script is the callback for "Analyze Power and Energy" mask in the ConfiguredVirtualVehicle model. 
%
%This script converts GenerateEnergyReport.m to GenerateEnergyReport.mlx and opens it in MATLAB editor. 

%Copyright 2023 The MathWorks, Inc.

%Extract path where "GenerateEnergyReport.m" is located from the path of the model in the project.

SysName=string(bdroot(gcb));
FullPath = which (SysName);
VirtualVehiclePath = extractBefore(FullPath,"System");
virtualVehiclePath = pwd;
ScriptPath = VirtualVehiclePath + "Scripts";

%Assign the path for the .mlx to be written into.
FilePath = cd(ScriptPath);
reportName = 'GenerateEnergyReport';
sourceFileName = fullfile(pwd,[reportName '.m']);
destinationFile = fullfile(pwd,[reportName '.mlx']);

%Convert .m to .mlx
matlab.internal.liveeditor.openAndSave(sourceFileName, destinationFile);

%Open the .mlx in MATLAB editor
edit('GenerateEnergyReport.mlx');

%Change path to System folder
cd(VirtualVehiclePath + "System");