{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Data.Yaml.Etc.Config (redirects,dst,src,statusCode) where

import GHC.Generics
import Control.Exception
import Control.Applicative ((<$>))
import Data.Yaml (FromJSON,decodeFileEither)

data Redirects = Redirects {list :: [Redirect]} deriving (Generic,Eq,Show)
instance FromJSON Redirects

type Url = String

data Redirect = Redirect {statusCode :: Int
                         ,src :: Url
                         ,dst :: Url
                         } deriving (Generic,Eq,Show)
instance FromJSON Redirect

type Filename = String

redirects :: Filename -> IO [Redirect]
redirects f = do
  y <- yaml f
  let rs = list y
  return rs

yaml :: Filename -> IO Redirects
yaml file = do
  let f = if file == "" then 
              "./etc/redirect.yml"
          else 
              file
  either throw id <$> decodeFileEither f

-- without Generic
-- instance FromJSON Redirect where
--     parseJSON (Object v) = Redirect <$>
--                            v .: "statusCode" <*>
--                            v .: "src" <*>
--                            v .: "dst"
--     -- A non-Object value is of the wrong type, so fail.
--     parseJSON _ = error "can't parse redirect rules from YAML/JSON"

