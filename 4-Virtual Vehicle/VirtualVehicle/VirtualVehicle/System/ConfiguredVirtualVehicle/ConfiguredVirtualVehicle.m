%% This file is autogenerated ...

%% This file contains virtual vehicle configuration information.

%% This file is saved at time 23-Jun-2024 16:58:25
                     ConfigInfos.Version = '24.1.0.2537033 (R2024a)';
                   ConfigInfos.SessionID = 'ConfiguredVirtualVehicle.m';
                   ConfigInfos.LicStatus = [1,1,1,1,1,1,1,1,1];
                ConfigInfos.ProjPathText = 'D:\Belgeler\Matlab Uygulamalar\4-Virtual Vehicle';
                    ConfigInfos.ProjPath = 'D:\Belgeler\Matlab Uygulamalar\4-Virtual Vehicle\VirtualVehicle\VirtualVehicle';
                 ConfigInfos.SessionName = 'ConfiguredVirtualVehicle';
                 ConfigInfos.XmlPathText = 'C:\Users\44ays\MATLAB\Projects\examples\VVCCustomCatalog.xml';
               ConfigInfos.TemplateModel = 'VirtualVehicleTemplateArchitecture';
          ConfigInfos.TemplatePlantModel = 'SimulinkPlantModelsArchitecture';
                 ConfigInfos.ConfigModel = 'ConfiguredVirtualVehicleModel';
            ConfigInfos.ConfigPlantModel = 'ConfiguredSimulinkPlantModel';
                    ConfigInfos.VehClass = 'Passenger Vehicle';
                     ConfigInfos.VehArct = 'Conventional Vehicle';
                      ConfigInfos.VehDyn = 0;
              ConfigInfos.PlantModelType = 'Simulink';
                  ConfigInfos.VehChassis = 'Vehicle Body 3DOF Longitudinal';
%% Vehicle Configuration
ConfigInfos.FeatureVariantSelectedMap=containers.Map;
ConfigInfos.FeatureVariantSelectedMap('Active Differential Control') = 'No Control';
ConfigInfos.FeatureVariantSelectedMap('Axle Interconnect') = 'No Interconnect';
ConfigInfos.FeatureVariantSelectedMap('Battery Management System') = 'No BMS';
ConfigInfos.FeatureVariantSelectedMap('Brake Control Unit') = 'Open Loop';
ConfigInfos.FeatureVariantSelectedMap('Brake System') = 'Brake System';
ConfigInfos.FeatureVariantSelectedMap('Chassis') = 'Vehicle Body 3DOF Longitudinal';
ConfigInfos.FeatureVariantSelectedMap('DC-DC Converter') = 'No DC-DC Converter';
ConfigInfos.FeatureVariantSelectedMap('Drive Shaft Torque Routing') = 'One Actuator FWD';
ConfigInfos.FeatureVariantSelectedMap('Driver') = 'Longitudinal Driver';
ConfigInfos.FeatureVariantSelectedMap('Drivetrain') = 'Front Wheel Drive';
ConfigInfos.FeatureVariantSelectedMap('Drivetrain Wheel Speed Route') = 'Bus';
ConfigInfos.FeatureVariantSelectedMap('Electric Machine 1') = 'Electric Vehicle 1EM';
ConfigInfos.FeatureVariantSelectedMap('Electric Machine 2') = 'Hybrid Electric Vehicle IPS';
ConfigInfos.FeatureVariantSelectedMap('Electric Machine 3') = 'Electric Vehicle 3EM Dual Front';
ConfigInfos.FeatureVariantSelectedMap('Electric Machine 4') = 'Electric Vehicle 4EM';
ConfigInfos.FeatureVariantSelectedMap('Electrical System') = 'NoEM';
ConfigInfos.FeatureVariantSelectedMap('Energy Storage') = 'Ideal Voltage Source';
ConfigInfos.FeatureVariantSelectedMap('Engine') = 'SI Mapped Engine';
ConfigInfos.FeatureVariantSelectedMap('Engine Control Unit') = 'SI Engine Controller';
ConfigInfos.FeatureVariantSelectedMap('Environment') = 'Ambient Conditions';
ConfigInfos.FeatureVariantSelectedMap('Front Axle Compliances') = 'Axle Compliances';
ConfigInfos.FeatureVariantSelectedMap('Front Brake Type') = 'Disc';
ConfigInfos.FeatureVariantSelectedMap('Front Differential System') = 'Open Differential';
ConfigInfos.FeatureVariantSelectedMap('Front Suspension') = 'No Suspension Front';
ConfigInfos.FeatureVariantSelectedMap('Front Tire') = 'MF Tires Longitudinal Front';
ConfigInfos.FeatureVariantSelectedMap('Front Tire Data') = 'MF Tires Longitudinal Front';
ConfigInfos.FeatureVariantSelectedMap('Hitch') = 'Hitch 3DOF';
ConfigInfos.FeatureVariantSelectedMap('Powertrain') = 'Conventional Vehicle';
ConfigInfos.FeatureVariantSelectedMap('Rear Axle Compliances') = 'No Axle Compliances';
ConfigInfos.FeatureVariantSelectedMap('Rear Brake Type') = 'Disc';
ConfigInfos.FeatureVariantSelectedMap('Rear Differential System') = 'No Differential Rear';
ConfigInfos.FeatureVariantSelectedMap('Rear Suspension') = 'No Suspension Rear';
ConfigInfos.FeatureVariantSelectedMap('Rear Tire') = 'MF Tires Longitudinal Rear';
ConfigInfos.FeatureVariantSelectedMap('Rear Tire Data') = 'MF Tires Longitudinal Rear';
ConfigInfos.FeatureVariantSelectedMap('Refrigeration Loop') = 'System Level';
ConfigInfos.FeatureVariantSelectedMap('Sensor') = 'No IMU Sensor';
ConfigInfos.FeatureVariantSelectedMap('Solver Configuration') = 'Solver Configuration';
ConfigInfos.FeatureVariantSelectedMap('Steering System') = 'No Steering';
ConfigInfos.FeatureVariantSelectedMap('Thermal') = 'No Thermal System';
ConfigInfos.FeatureVariantSelectedMap('Thermal Control') = 'No Thermal Control';
ConfigInfos.FeatureVariantSelectedMap('Trailer') = 'No Trailer';
ConfigInfos.FeatureVariantSelectedMap('Trailer Body') = 'Trailer Body 3DOF';
ConfigInfos.FeatureVariantSelectedMap('Trailer Tire') = 'MF Tires Longitudinal';
ConfigInfos.FeatureVariantSelectedMap('Transmission') = 'Ideal Fixed Gear Transmission';
ConfigInfos.FeatureVariantSelectedMap('Transmission Control Unit') = 'PRNDL Controller';
ConfigInfos.FeatureVariantSelectedMap('Variant Source') = 'One Actuator FWD';
ConfigInfos.FeatureVariantSelectedMap('Vehicle Architecture') = 'Conventional Vehicle';
ConfigInfos.FeatureVariantSelectedMap('Vehicle Control Unit') = 'No VCU';

%% Test Plan

             ConfigInfos.TestPlan{1}.Num = 1;
          ConfigInfos.TestPlan{1}.Source = 'Scenario.sldd';
            ConfigInfos.TestPlan{1}.Name = 'Drive Cycle';
           ConfigInfos.TestPlan{1}.Cycle = 'FTP75';
        ConfigInfos.TestPlan{1}.Data=[];

%% Selected Logging Signals
ConfigInfos.SelectedSignals = {
'Body.BdyFrm.Cg.Vel.xdot',...
'Body.BdyFrm.Cg.Acc.ax',...
'Body.BdyFrm.Cg.Acc.ay',...
'Body.BdyFrm.Cg.Acc.az',...
'Driver.SteerFdbk',...
'Driver.AccelFdbk',...
'Driver.DecelFdbk',...
'Driver.GearFdbk',...
'Trans.Info.Trans.TransGear',...
'Trans.Info.Trans.TransGearCmd',...
'Engine.EngTrq',...
'Engine.EngSpdOut',...
};

%% Finish
