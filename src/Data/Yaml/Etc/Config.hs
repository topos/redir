{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
module Data.Yaml.Etc.Config (redirs,src,dst,statusCode,yaml) where

import GHC.Generics
import Control.Exception
import Control.Applicative ((<$>))
import Data.ByteString (ByteString)
import Data.Yaml (FromJSON,decodeFileEither)

data Redirects = Redirects {redirs :: [Redirect]
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
yaml file = either throw id <$> decodeFileEither file
