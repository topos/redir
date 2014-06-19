{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Exception (try)
import Data.ByteString.Char8 (pack)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text)
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
  rs <- C.redirects ""
  let ps = map (\u->(C.src u,C.dst u)) rs
      m = M.fromList ps
      url = case M.lookup "http://2_src_" m of
              Nothing -> "http://foo.com/default/"
              Just u -> u
      -- url = fst $ head ps
  res $ responseLBS status200 [("Content-Type","text/plain"),("Location",pack url)] ""

-- responseLBS status301 [("Content-Type", "text/plain"), ("Location", "http://foo.com/")] ""

-- let ps = pathInfo req
-- k = if null ps then "" else ps !! 0
-- h = M.fromList [("hs","http://reddit.com/r/haskell"),("sci","http://hi.there.io"),("apple", "http://apple.com")]
-- r = case M.lookup k h of
--       Just r' -> r'
--       Nothing -> "http://phys.org"
