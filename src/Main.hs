{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Data.Map as Map
import qualified Data.Map.Strict as M
import Control.Exception (try)
import Data.ByteString.Char8 (pack)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)
import Network.Wai (Application,pathInfo,responseLBS)
import Network.HTTP.Types (status200,status301,status302)
import Network.Wai.Handler.Warp (run)
import Data.Yaml.Etc.Config

app :: Application
app req = do
  rs <- redirects ""
  let rr = head rs
      c = statusCode rr
      d = pack $ dst rr
  return $ responseLBS status301 [("Content-Type", "text/plain"), ("Location", d)] ""

main = run 8080 app

-- let ps = pathInfo req
-- k = if null ps then "" else ps !! 0
-- h = M.fromList [("hs","http://reddit.com/r/haskell"),("sci","http://hi.there.io"),("apple", "http://apple.com")]
-- r = case M.lookup k h of
--       Just r' -> r'
--       Nothing -> "http://phys.org"
