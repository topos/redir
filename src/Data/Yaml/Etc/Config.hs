{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Data.Yaml.Etc.Config where

import GHC.Generics
import Control.Applicative
import Control.Exception
import Data.Yaml (FromJSON, decodeFileEither)

data Redirect = Redirect {statusCode :: Int
                         ,src, dst :: String
                         } deriving (Generic,Eq,Show)
instance FromJSON Redirect

data Redirects = Redirects {list :: [Redirect]} deriving (Generic,Eq,Show)
instance FromJSON Redirects

redirects :: String -> IO [Redirect]
redirects file = do
  y <- yaml file
  let rs = list y
  return rs 

yaml :: String -> IO Redirects
yaml file = do
  let rfile = if file == "" then
                  "./etc/redirect.yml"
              else
                  file
  either throw id <$> decodeFileEither rfile

-- without Generic
-- instance FromJSON Redirect where
--     parseJSON (Object v) = Redirect <$>
--                            v .: "statusCode" <*>
--                            v .: "src" <*>
--                            v .: "dst"
--     -- A non-Object value is of the wrong type, so fail.
--     parseJSON _ = error "can't parse redirect rules from YAML/JSON"

