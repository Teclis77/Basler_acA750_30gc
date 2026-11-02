#!../../bin/linux-x86_64/pylonApp

< envPaths

dbLoadDatabase("$(TOP)/dbd/pylonApp.dbd")
pylonApp_registerRecordDeviceDriver(pdbbase)

# Camera settings
epicsEnvSet("CAMERA_ID",    "100.100.0.20")
# epicsEnvSet("NELEMENTS",    "1082880") -> Mono8
epicsEnvSet("NELEMENTS",    "1292544")
#epicsEnvSet("PREFIX",       "13PYLON1:")
epicsEnvSet("PREFIX",       "Bas_RXR:")
#epicsEnvSet("PORT",         "PYLON1")
epicsEnvSet("PORT",         "RXR")
epicsEnvSet("QSIZE",        "2000")
epicsEnvSet("NCHANS",       "2048")
epicsEnvSet("CBUFFS",       "500")
#epicsEnvSet("GENICAM_DB_FILE", "$(ADGENICAM)/db/Basler-acA750-30gc.template")
#epicsEnvSet("GENICAM_DB_FILE", "/home/xlabsrv2/epics/synApps_6_3/support/areaDetector-R3-12-1/ADGenICam/db/Basler-acA750-30gc.template")
epicsEnvSet("GENICAM_DB_FILE", "$(TOP)/db/Basler-acA750-30gc.template")

epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db:$(ADGENICAM)/db:$(ADPYLON)/db")

ADPylonConfig("$(PORT)", "$(CAMERA_ID)", 0, 0, 0)
asynSetTraceIOMask($(PORT), 0, 2)

dbLoadRecords("$(ADPYLON)/db/pylon.template", "P=$(PREFIX),R=cam1:,PORT=$(PORT)")
dbLoadRecords("$(GENICAM_DB_FILE)", "P=$(PREFIX),R=cam1:,PORT=$(PORT)")
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

< $(ADCORE)/iocBoot/commonPlugins.cmd

iocInit()

# Impostazioni camera dopo avvio
epicsThreadSleep 2
# dbpf 13PYLON1:cam1:GC_PixelFormat Mono8
dbpf $(PREFIX)cam1:GC_PixelFormat 1
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:ConvertPixelFormat RGB8
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:ImageMode Continuous
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:AcquireTime 0.008
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:GC_AcqFraRateEnable Yes
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:GC_AcqFrameRateAbs 5
epicsThreadSleep 0.5
dbpf $(PREFIX)cam1:GC_GevSCPSPacketSize 9000
epicsThreadSleep 0.5
dbpf $(PREFIX)image1:EnableCallbacks 1

create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")
