%% Run Simulation
%Create an  autoblks.pwr.PlantInfo object that analyzes the model energy consumption. Use the PwrUnits and EnrgyUnits properties to set the units.
%After the simulation runs the script provides the energy summary.  You can use the results to analyze energy and power losses at the component and system level. For more information, see Explore the Electric Vehicle Reference Application.

SysName=string(bdroot(gcb));
set_param(SysName,'SimulationCommand','Update')
VehPwrAnalysis = autoblks.pwr.PlantInfo(SysName);
VehPwrAnalysis.PwrUnits = 'kW';
VehPwrAnalysis.EnrgyUnits = 'MJ';

%% Use run method to turn on logging, run simulation, and add logged data to the object.
VehPwrAnalysis.run;

%% Overall Summary

% Display the final energy values for each subsystem.
VehPwrAnalysis.dispSysSummary

%Write summary to spreadsheet.
VehPwrAnalysis.xlsSysSummary(fullfile(fileparts(which('GenerateEnergyReport')), 'EnergySummary.xlsx'))

%% Electric Plant Summary
ElecSysName = SysName + "/Vehicle/Plant Models/ConfiguredVirtualVehiclePlantModel/Electrical System";
VehPwrAnalysis.dispSignalSummary(ElecSysName);

%% Drivetrain Plant Summary
DrvtrnSysName = SysName + "/Vehicle/Plant Models/ConfiguredVirtualVehiclePlantModel/Drivetrain";
VehPwrAnalysis.dispSignalSummary(DrvtrnSysName);

%% SDI Plots
VehPwrAnalysis.sdiSummary([ElecSysName, DrvtrnSysName])

