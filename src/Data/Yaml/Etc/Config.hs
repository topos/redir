{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Data.Yaml.Etc.Config (redirects,url,src,dst,statusCode,yaml) where

import GHC.Generics
import Control.Exception
import Control.Applicative ((<$>))
import Data.Yaml (FromJSON,decodeFileEither)

data Redirects = Redirects {redirects :: [Redirect]
                           ,url :: Redirect
                           } deriving (Generic,Eq,Show)
instance FromJSON Redirects

type Url = String

data Redirect = Redirect {statusCode :: Int
                         ,src :: Url
                         ,dst :: Url
                         } deriving (Generic,Eq,Show)
instance FromJSON Redirect

type Filename = String

yaml :: Filename -> IO Redirects
yaml file = do
  let f = if file == "" then 
              "./etc/redirect.yml"
          else 
              file
  either throw id <$> decodeFileEither f
