{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
module Data.Etc.Yaml (Redirects (..), Redirect (..), yaml, redirect) where

import GHC.Generics
import Control.Exception
import Control.Applicative ((<$>))
import Data.ByteString (ByteString)
import Data.Yaml (FromJSON, decodeFileEither)
import Network.Wai (Application, pathInfo)
import qualified Data.Map as Map

redirect :: String -> Redirects -> IO Redirect
-- redirect "foo" (yaml "/etc/redir.yaml")
redirect key rs = do
  let rmap = Map.fromList $ map (\r->(srcUrl r,r)) (redirs rs)
      key' = "http://" ++ key
  return $ case Map.lookup (key') rmap of 
             Just r -> r
             Nothing -> Redirect 0 "" ""

yaml :: String -> IO Redirects
yaml filename = either throw id <$> decodeFileEither filename

data Redirects = Redirects {redirs :: [Redirect]
                           } deriving (Generic,Eq,Show)
instance FromJSON Redirects

type Url = String

data Redirect = Redirect { statusCode :: Int 
                         , srcUrl :: Url
                         , dstUrl :: Url
                         } deriving (Generic,Eq,Show)
instance FromJSON Redirect


  -- let rmap = Map.fromList $ map (\r->(src r,(dst r, statusCode r))) rs
  --     ps = pathInfo req
  --     k = if ps == [] then "url" else Text.unpack $ head ps
  --     key = "http://" ++ k
  --     (url, status) = case Map.lookup (key) rmap of 
  --                       Just pair -> pair
  --                       Nothing -> ("http://google.com", 0)
