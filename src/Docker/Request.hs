{-# LANGUAGE
    DataKinds
    , DeriveFunctor
    , GADTs
    , KindSignatures
    , OverloadedStrings
    , TypeFamilies
    #-}

module Docker.Request where
import Data.Aeson
import qualified Data.ByteString.Char8 as BC
import Data.Default
import Data.Monoid
import Network.HTTP.Conduit hiding (Proxy)

import Docker.Language

import Debug.Trace


{-
data ApiRequestData = ApiRequestData
    { arPath          :: BS.ByteString
    , arRequestBody   :: BL.ByteString
    , arDaemonAddress :: DaemonAddress
    }
-}
getRequest
    :: SApiEndpoint e
    -> GetEndpoint e
    -> DaemonAddress
    -> Request
getRequest SInfoEndpoint _ addr =
    (defaultGetRequest addr) { path = "/info" }

getRequest SContainerInfoEndpoint d addr =
    (defaultGetRequest addr) {path = "/containers/" <> d <> "/json"}


postRequest
    :: SApiEndpoint e
    -> PostEndpoint e
    -> DaemonAddress
    -> Request
postRequest SContainerCreateEndpoint d addr =
    traceShow d $
    (defaultPostRequest addr)
        { requestBody = RequestBodyLBS $ encode d
        , path = "/containers/create"
        }

-- FIXME : Query string should be a type with:
-- fromImage – name of the image to pull
-- fromSrc – source to import.
-- repo – repository
-- tag – tag
-- registry – the registry to pull from
--
-- See <https://docs.docker.com/reference/api/docker_remote_api_v1.18/>
postRequest SImageCreateEndpoint d addr =
    (defaultPostRequest addr)
        { path        = "/images/create"
        , queryString = BC.pack d
        }

-- * Request builders
defaultRequest :: Request
defaultRequest =
    def { checkStatus = \_ _ _ -> Nothing
        , redirectCount = 0
        , requestHeaders = requestHeaders def ++
            [("content-type", "application/json")]
        }

defaultGetRequest :: DaemonAddress -> Request
defaultGetRequest da = defaultRequest
    { method = "GET"
    , host   = daemonHost da
    , port   = daemonPort da
    }

defaultPostRequest :: DaemonAddress -> Request
defaultPostRequest da = defaultRequest
    { method = "POST"
    , host   = daemonHost da
    , port   = daemonPort da
    }


