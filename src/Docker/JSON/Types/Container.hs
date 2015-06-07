{-# LANGUAGE
    DeriveGeneric
    , OverloadedStrings
    , RecordWildCards
    #-}

module Docker.JSON.Types.Container where

import Data.Aeson
import Data.Default
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Text as T
import GHC.Generics

------------------------------------------------------------------------------
-- * Containers
-- ** Request
-- *** ContainerSpec

-- | Specification for a container.
--
-- FIXME : This needs to be better typed, and cleaned up.
--
-- See <https://docs.docker.com/reference/api/docker_remote_api_v1.18/#create-a-container create a container>
-- for more information.
data ContainerSpec = ContainerSpec
    { containerHostname   :: T.Text
    , containerDomainName :: T.Text
    , containerUser       :: T.Text
    , attachedStdin       :: Bool
    , attachedStdout      :: Bool
    , attachedStderr      :: Bool
    , containerTty        :: Bool
    , openStdin           :: Bool
    , stdinOnce           :: Bool
    , containerEnv        :: Value -- possibly null
    , containerCmd        :: [T.Text]
    , entryPoint          :: T.Text
    , containerFromImage  :: T.Text
    , containerLabels     :: Map.Map T.Text T.Text
    , containerVolumes    :: Map.Map T.Text T.Text
    , containerWorkingDir :: T.Text -- should be a path
    , networkDisabled     :: Bool
    , macAddress          :: T.Text -- likely already MAC addr type
    , exposedPorts        :: Map.Map T.Text Object -- according to docs, Object here is always empty...
    , securityOpts        :: [T.Text]
    , hostConfig          :: HostConfig
    } deriving (Eq, Show)

-- | The Default instance for a ContainerSpec.
instance Default ContainerSpec where
    def = ContainerSpec
        { containerHostname  = ""
        , containerDomainName= ""
        , containerUser      = ""
        , attachedStdin      = False
        , attachedStdout     = True
        , attachedStderr     = True
        , containerTty       = False
        , openStdin          = False
        , stdinOnce          = False
        , containerEnv       = Null
        , containerCmd       = ["echo", "test"]
        , entryPoint         = ""
        , containerFromImage = "docker.io/fedora"
        , containerLabels    = Map.empty
        , containerVolumes   = Map.empty
        , containerWorkingDir= ""
        , networkDisabled    = False
        , macAddress         = "00:00:00:00:00:00"-- maybe this is auto if empty???
        , exposedPorts       = Map.empty
        , securityOpts       = [""]
        , hostConfig         = def
        }


-- | Convert JSON to a ContainerSpec.
instance FromJSON ContainerSpec where
    parseJSON (Object x) = ContainerSpec
        <$> x .: "HostName"
        <*> x .: "DomainName"
        <*> x .: "User"
        <*> x .: "AttachedStdin"
        <*> x .: "AttachedStdout"
        <*> x .: "AttachedStderr"
        <*> x .: "Tty"
        <*> x .: "OpenStdin"
        <*> x .: "StdinOnce"
        <*> x .: "Env"
        <*> x .: "Cmd"
        <*> x .: "EntryPoint"
        <*> x .: "Image"
        <*> x .: "Labels"
        <*> x .: "Volumes"
        <*> x .: "WorkingDir"
        <*> x .: "NetworkDisabled"
        <*> x .: "MacAddress"
        <*> x .: "ExposedPorts"
        <*> x .: "SecurityOpts"
        <*> x .: "HostConfig"
    parseJSON _ = fail "Expecting an Object!"


-- | Convert a ContainerSpec into JSON.
instance ToJSON ContainerSpec where
    toJSON (ContainerSpec {..}) =
        object [ "HostName"       .= containerHostname
               , "DomainName"     .= containerDomainName
               , "User"           .= containerUser
               , "AttachedStdin"  .= attachedStdin
               , "AttachedStdout" .= attachedStdout
               , "AttachedStderr" .= attachedStderr
               , "Tty"            .= containerTty
               , "OpenStdin"      .= openStdin
               , "StdinOnce"      .= stdinOnce
               , "Env"            .= containerEnv
               , "Cmd"            .= containerCmd
               , "EntryPoint"     .= entryPoint
               , "Image"          .= containerFromImage
               , "Labels"         .= containerLabels
               , "Volumes"        .= containerVolumes
               , "WorkingDir"     .= containerWorkingDir
               , "NetworkDisabled".= networkDisabled
               , "MacAddress"     .= macAddress
               , "ExposedPorts"   .= exposedPorts
               , "SecurityOpts"   .= securityOpts
               , "HostConfig"     .= hostConfig
               ]


-- ** HostConfig

-- | A containers HostConfig.
-- See example request in
-- <https://docs.docker.com/reference/api/docker_remote_api_v1.18/#create-a-container create a container.>
data HostConfig = HostConfig
    { binds           :: [T.Text] -- see binds, and create a type
    , links           :: [T.Text]
    , lxcConf         :: Map.Map T.Text T.Text
    , memory          :: Int
    , memorySwap      :: Int
    , cpuShares       :: Int
    , cpusetCpus      :: T.Text -- create a type
    , portBindings    :: Map.Map T.Text [Map.Map T.Text T.Text] -- Why is it defined like this!!!
    , publishAllPorts :: Bool
    , privileged      :: Bool
    , readOnlyRootfs  :: Bool
    , dns             :: [T.Text]
    , dnsSearch       :: [T.Text] -- Search domains
    , extraHosts      :: Value -- ["hostname:ip"], can be null???
    , volumesFrom     :: [T.Text]
    , capAdd          :: [T.Text]
    , capDrop         :: [T.Text]
    , restartPolicy   :: Map.Map T.Text T.Text -- only 2 keys possible
    , networkMode     :: T.Text
    , devices         :: [HCDevice]
    , ulimits         :: [Map.Map T.Text T.Text]
    , logConfig       :: HCLogConfig
    , cgroupParent    :: T.Text -- path
    } deriving (Eq, Generic, Show)


-- | Default instance for HostConfig
instance Default HostConfig where
    def = HostConfig
        { binds        = []
        , links        = []
        , lxcConf      = Map.empty
        , memory       = 0
        , memorySwap   = 0
        , cpuShares    = 512
        , cpusetCpus   = "0,1"
        , portBindings = Map.empty
        , publishAllPorts = False
        , privileged      = False
        , readOnlyRootfs  = False
        , dns             = ["8.8.8.8"]
        , dnsSearch       = []
        , extraHosts      = Null
        , volumesFrom     = []
        , capAdd          = []
        , capDrop         = []
        , restartPolicy   = Map.fromList [("Name", ""), ("MaximumRetryCount","0")]
        , networkMode     = "bridge"
        , devices         = []
        , ulimits         = []
        , logConfig       = def
        , cgroupParent    = ""
        }


-- | Convert JSON to a HostConfig.
instance FromJSON HostConfig


-- | Convert a HostConfig to JSON.
instance ToJSON HostConfig where
    toJSON (HostConfig {..}) =
        object [ "Binds"            .= binds
               , "Links"            .= links
               , "LxcConf"          .= lxcConf
               , "Memory"           .= memory
               , "MemorySwap"       .= memorySwap
               , "CpuShares"        .= cpuShares
               , "CpusetCpus"       .= cpusetCpus
               , "PortBindings"     .= portBindings
               , "PublishAllPorts"  .= publishAllPorts
               , "Privileged"       .= privileged
               , "ReadOnltRootfs"   .= readOnlyRootfs
               , "Dns"              .= dns
               , "DnsSearch"        .= dnsSearch
               , "ExtraHosts"       .= extraHosts
               , "VolumesFrom"      .= volumesFrom
               , "CappAdd"          .= capAdd
               , "CapDrop"          .= capDrop
               , "RestartPolicy"    .= restartPolicy
               , "NetworkMode"      .= networkMode
               , "Devices"          .= devices
               , "Ulimits"          .= ulimits
               , "LogConfig"        .= logConfig
               , "CgroupParent"     .= cgroupParent
               ]

-- | A device in the "Devices" field of a HostConfig object.
data HCDevice = HCDevice
    { pathOnHost        :: T.Text
    , pathInContainer   :: T.Text
    , cgroupPermissions :: T.Text
    } deriving (Eq, Generic, Show)


-- | Convert JSON to a HCDevice.
instance FromJSON HCDevice

-- | Convert a HCDevice to JSON.
instance ToJSON HCDevice where
    toJSON (HCDevice poh pic cgp) =
        object [ "PathOnHost"        .= poh
               , "PathInContainer"   .= pic
               , "CgroupPermissions" .= cgp
               ]


-- | Log config setting in the "LogConfig" field of a
-- HostConfig object.
data HCLogConfig = HCLogConfig
    { driverType   :: T.Text
    , config :: Map.Map T.Text T.Text
    } deriving (Eq, Generic, Show)

-- | Default instance for HCLogConfig.
instance Default HCLogConfig where
    def = HCLogConfig
        { driverType = "json-file"
        , config     = Map.empty
        }


-- | Convert JSON to a HCLogConfig.
instance FromJSON HCLogConfig


-- | Convert a HCLogConfig to JSON.
instance ToJSON HCLogConfig where
    toJSON (HCLogConfig driver config) =
        object [ "Type"   .= driver
               , "Config" .= config
               ]

-- ** Response

-- | Response from a POST to \/containers\/create
-- These should really just be lenses into an Object, I think..
-- Seems like it would be way more flexible.
data ContainerCreateResponse = ContainerCreateResponse
    { containerId       :: T.Text
    , containerWarnings :: Maybe [T.Text]
    } deriving (Eq, Show)

instance FromJSON ContainerCreateResponse where
    parseJSON (Object x) =  ContainerCreateResponse
        <$> x .: "Id"
        <*> x .:? "Warnings"

instance ToJSON ContainerCreateResponse where
    toJSON (ContainerCreateResponse {..}) = object $ catMaybes
        [ ("Id" .=) <$> pure containerId
        , ("Warnings" .=) <$> containerWarnings ]


-- | Reponse from a GET to \/containers\/\(id\)\/json
data ContainerInfo = ContainerInfo
    { ciAppArmorProfile :: T.Text
    , ciArgs            :: [T.Text]
    , ciConfig          :: ContainerInfoConfig
    , ciCreated         :: T.Text
    , ciDriver          :: T.Text
    , ciExecDriver      :: T.Text
    , ciExecIds         :: Maybe [T.Text]
    , ciHostConfig      :: HostConfig
    , ciHostnamePath    :: T.Text
    , ciHostsPath       :: T.Text
    , ciLogPath         :: T.Text
    , ciId              :: T.Text
    , ciImage           :: T.Text
    , ciMountLabel      :: T.Text
    , ciName            :: T.Text
    , ciNetworkSettings :: ContainerInfoNetworkSettings
    , ciPath            :: T.Text
    , ciProcessLabel    :: T.Text
    , ciResolvConfPath  :: T.Text
    , ciRestartCount    :: Int
    , ciState           :: ContainerInfoState
    , ciVolumes         :: Value
    , ciVolumesRW       :: Value
    }
instance FromJSON ContainerInfo where
    parseJSON (Object x) = ContainerInfo
        <$> x .: "AppArmourProfile"
        <*> x .: "Args"
        <*> x .: "Config"
        <*> x .: "Created"
        <*> x .: "Driver"
        <*> x .: "ExecDriver"
        <*> x .:? "ExecIDs"
        <*> x .: "HostConfig"
        <*> x .: "HostnamePath"
        <*> x .: "HostsPath"
        <*> x .: "LogPath"
        <*> x .: "Id"
        <*> x .: "Image"
        <*> x .: "MountLabel"
        <*> x .: "Name"
        <*> x .: "NetworkSettings"
        <*> x .: "Path"
        <*> x .: "ProcessLabel"
        <*> x .: "ResolvConfPath"
        <*> x .: "RestartCount"
        <*> x .: "State"
        <*> x .: "Volumes"
        <*> x .: "VolumesRW"

instance ToJSON ContainerInfo where
    toJSON (ContainerInfo {..}) = object $ catMaybes
        [ ("AppArmourProfile" .=) <$> pure ciAppArmorProfile
        , ("Args" .=) <$> pure ciArgs
        , ("Config" .=) <$> pure ciConfig
        , ("Created" .=) <$> pure ciCreated
        , ("Driver" .=) <$> pure ciDriver
        , ("ExecDriver" .=) <$> pure ciExecDriver
        , ("ExecIDs" .=) <$> ciExecIds
        , ("HostConfig" .=) <$> pure ciHostConfig
        , ("HostnamePath" .=) <$> pure ciHostnamePath
        , ("HostsPath" .=) <$> pure ciHostsPath
        , ("LogPath" .=) <$> pure ciLogPath
        , ("Id" .=) <$> pure ciId
        , ("Image" .=) <$> pure ciImage
        , ("MountLabel" .=) <$> pure ciMountLabel
        , ("Name" .=) <$> pure ciName
        , ("NetworkSettings" .=) <$> pure ciNetworkSettings
        , ("Path" .=) <$> pure ciPath
        , ("ProcessLabel" .=) <$> pure ciProcessLabel
        , ("ResolvConfPath" .=) <$> pure ciResolvConfPath
        , ("RestartCount" .=) <$> pure ciRestartCount
        , ("State" .=) <$> pure ciState
        , ("Volumes" .=) <$> pure ciVolumes
        , ("VolumesRW" .=) <$> pure ciVolumesRW
        ]


data ContainerInfoConfig = ContainerInfoConfig
    { cicAttachStderr    :: Bool
    , cicAttachStdin     :: Bool
    , cicAttachStdout    :: Bool
    , cicCmd             :: [T.Text]
    , cicDomainName      :: T.Text
    , cicEntryPoint      :: Maybe T.Text
    , cicEnv             :: [T.Text]
    , cicExposedPorts    :: Maybe Value
    , cicHostname        :: T.Text
    , cicImage           :: T.Text
    , cicLabels          :: Value
    , cicMacAddress      :: T.Text
    , cicNetworkDisabled :: Bool
    , cicOnBuild         :: Maybe Value
    , cicOpenStdin       :: Bool
    , cicPortSpecs       :: Maybe Value
    , cicStdinOnce       :: Bool
    , cicTty             :: Bool
    , cicUser            :: T.Text
    , cicVolumes         :: T.Text
    , cicWorkingDir      :: T.Text
    }

instance FromJSON ContainerInfoConfig where
    parseJSON (Object x) = ContainerInfoConfig
        <$> x .: "AttachedStderr"
        <*> x .: "AttachedStdin"
        <*> x .: "AttachedStdout"
        <*> x .: "Cmd"
        <*> x .: "DomainName"
        <*> x .:? "Entrypoint"
        <*> x .: "Env"
        <*> x .:? "ExposedPorts"
        <*> x .: "Hostname"
        <*> x .: "Image"
        <*> x .: "Labels"
        <*> x .: "MacAddress"
        <*> x .: "NetworkDisabled"
        <*> x .:? "OnBuild"
        <*> x .: "OpenStdin"
        <*> x .:? "PortSpecs"
        <*> x .: "StdinOnce"
        <*> x .: "Tty"
        <*> x .: "User"
        <*> x .: "Volumes"
        <*> x .: "WorkingDir"

instance ToJSON ContainerInfoConfig where
    toJSON (ContainerInfoConfig {..}) = object $ catMaybes
        [ ("AttachedStderr" .=) <$> pure cicAttachStderr
        , ("AttachedStdin" .=) <$> pure cicAttachStdin
        , ("AttachedStdout" .=) <$> pure cicAttachStdout
        , ("Cmd" .=) <$> pure cicCmd
        , ("DomainName" .=) <$> pure cicDomainName
        , ("EntryPoint" .=) <$> cicEntryPoint
        , ("Env" .=) <$> pure cicEnv
        , ("ExposedPorts" .=) <$> cicExposedPorts
        , ("Hostname" .=) <$> pure cicHostname
        , ("Image" .=) <$> pure cicImage
        , ("Labels" .=) <$> pure cicLabels
        , ("MacAddress" .=) <$> pure cicMacAddress
        , ("NetworkDisabled" .=) <$> pure cicNetworkDisabled
        , ("OnBuild" .=) <$> cicOnBuild
        , ("OpenStdin" .=) <$> pure cicOpenStdin
        , ("PortSpecs" .=) <$> cicPortSpecs
        , ("StdinOnce" .=) <$> pure cicStdinOnce
        , ("Tty" .=) <$> pure cicTty
        , ("User" .=) <$> pure cicUser
        , ("Volumes" .=) <$> pure cicVolumes
        , ("WorkingDir" .=) <$> pure cicWorkingDir
        ]



data ContainerInfoNetworkSettings = ContainerInfoNetworkSettings
    { cinBridge     :: T.Text
    , cinGateway    :: T.Text
    , cinIpAddress  :: T.Text
    , cinIpPrefixLen:: Int
    , cinMacAddress :: T.Text
    , cinPortMapping:: Maybe Value
    , cinPorts      :: Maybe Value
    }

instance FromJSON ContainerInfoNetworkSettings where
    parseJSON (Object x) = ContainerInfoNetworkSettings
        <$> x .: "Bridge"
        <*> x .: "Gateway"
        <*> x .: "IPAddress"
        <*> x .: "IPPrefixLen"
        <*> x .: "MacAddress"
        <*> x .:? "PortMapping"
        <*> x .:? "Ports"

instance ToJSON ContainerInfoNetworkSettings where
    toJSON (ContainerInfoNetworkSettings {..}) = object $ catMaybes
        [ ("Bridge" .=) <$> pure cinBridge
        , ("Gateway" .=) <$> pure cinGateway
        , ("IPAddress" .=) <$> pure cinIpAddress
        , ("IPPrefixLen" .=) <$> pure cinIpPrefixLen
        , ("MacAddress" .=) <$> pure cinMacAddress
        , ("PortMapping" .=) <$> cinPortMapping
        , ("Ports" .=) <$> cinPorts
        ]

data ContainerInfoState = ContainerInfoState
    { cisError      :: T.Text
    , cisExitCode   :: Int
    , cisFinishedAt :: T.Text
    , cisOOMKilled  :: Bool
    , cisPaused     :: Bool
    , cisPid        :: Int
    , cisRestarting :: Bool
    , cisRunning    :: Bool
    , cisStartedAt  :: T.Text
    }

instance FromJSON ContainerInfoState where
    parseJSON (Object x) = ContainerInfoState
        <$> x .: "Error"
        <*> x .: "ExitCode"
        <*> x .: "FinishedAt"
        <*> x .: "OOMKilled"
        <*> x .: "Paused"
        <*> x .: "Pid"
        <*> x .: "Restarting"
        <*> x .: "Running"
        <*> x .: "StartedAt"

instance ToJSON ContainerInfoState where
    toJSON (ContainerInfoState {..}) = object
        [ "Error"       .= cisError
        , "Exitode"     .= cisExitCode
        , "FinishedAt"  .= cisFinishedAt
        , "OOMKilled"   .= cisOOMKilled
        , "Paused"      .= cisPaused
        , "Pid"         .= cisPid
        , "Restarting"  .= cisRestarting
        , "Running"     .= cisRunning
        , "StartedAt"   .= cisStartedAt
        ]


