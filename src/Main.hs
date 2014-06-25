{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Exception (try)
import Data.ByteString.Char8 (pack)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text,unpack)
import Data.Text.Encoding (encodeUtf8)
import Network.Wai (Application,pathInfo,responseLBS)
import Network.HTTP.Types (status200,status301,status302)
import Network.Wai.Handler.Warp (run)
import qualified Data.Map as M
import qualified Data.Yaml.Etc.Config as C

main :: IO ()
main = run 8080 app

app :: Application
app req res = do
  y <- C.yaml ""
  let k = if (pathInfo req) == [] then
              "url"
          else
              unpack $ head $ pathInfo req
      u = C.dst $ C.url y
      rs = C.redirects y
      ps = map (\r->(C.src r,C.dst r)) rs
      m = M.fromList ps
      url = case M.lookup ("http://" ++ k) m of
              Nothing -> u
              Just u' -> u'
  res $ responseLBS status200 [("Content-Type","text/plain"),("Location",pack url)] ""
