{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Data.ByteString.Char8 (pack)
import Data.Text (unpack)
import Network.HTTP.Types (status200,status301,status302)
import Network.Wai (Application,pathInfo,responseLBS,responseStream)
import Network.Wai.Handler.Warp (run)
import Blaze.ByteString.Builder (fromByteString)
import Pipes ((>->),yield)
import Pipes.Wai (Application,Flush(..),producerRequestBody,responseProducer)
import qualified Pipes.Prelude as P
import qualified Data.Map as M
import Data.Yaml.Etc.Config (Redirects,redirs,src,dst,statusCode,yaml)

main :: IO ()
main = do 
  rs <- yaml "/etc/redir.yml"
  run 8080 $ app rs

app :: Redirects -> Application
app redirects req res = do
  let m = M.fromList $ map (\r->(src r,(dst r, statusCode r))) $ redirs redirects
      ps = pathInfo req
      k = if ps == [] then "url" else unpack $ head ps
      key = "http://" ++ k
      (url, status) = case M.lookup (key) m of
                        Just pair -> pair
                        Nothing -> ("-[default]-", 0)
  res $ responseProducer status200 [("Content-Type", "text/plain"),("Location", pack url)] $ yield Flush

-- import Data.ByteString.Char8 (pack)
-- import Data.Text (unpack)
-- import Network.Wai (Application,pathInfo,responseLBS,responseStream)
-- import Network.HTTP.Types (status200,status301,status302)
-- import Network.Wai.Handler.Warp (run)
-- import Blaze.ByteString.Builder (fromByteString)
-- import qualified Data.Map as M
-- import qualified Data.Yaml.Etc.Config as C
--
-- main :: IO ()
-- main = run 8080 app

-- app :: Application
-- app req res = do
--   y <- C.yaml "/etc/redir.yml"
--   let pi = pathInfo req
--       k = if pi == [] then
--               "url"
--           else
--               unpack $ head pi
--       rs = C.redirs y
--       m = M.fromList $ map (\r->(C.src r,(C.dst r, C.statusCode r))) rs
--       key = "http://" ++ k
--       (url, status) = case M.lookup (key) m of
--                         Just pair -> pair
--                         Nothing -> ("-[default]-", 0)
--   res $ responseLBS status200 [("Content-Type", "text/plain"), ("Location", pack url)] $ ""
