{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad
import Control.Exception (try)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)
import qualified Data.ByteString.Char8 as Char8
import qualified Data.Map as Map
import qualified Data.Map.Strict as M
import Network.Wai
import Network.HTTP.Types (status200,status301)
import Network.Wai.Handler.Warp (run)
import Data.Yaml.Etc.Config (readConfig)

app :: Application
app req = do
  let ps = pathInfo req
      k = if null ps then "" else ps !! 0
      h = M.fromList [("hs","http://reddit.com/r/haskell"),("sci","http://hi.there.io"),("apple", "http://apple.com")]
      r = case M.lookup k h of
            Just r' -> r'
            Nothing -> "http://phys.org"
  c <- readConfig "" 
  print c
  return $ responseLBS status301 [("Content-Type", "text/plain"), ("Location", r)] ""

main = run 8080 app
