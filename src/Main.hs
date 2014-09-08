{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Data.ByteString.Lazy (ByteString)
import Blaze.ByteString.Builder (fromByteString)
import Network.HTTP.Types (status200, status301, status302)
import Network.HTTP.Client (Response, newManager, httpLbs)
import Network.Wai (Application, pathInfo)
import Network.Wai.Handler.Warp (run, defaultSettings)
import Pipes.Wai (Application, Flush (..), producerRequestBody, responseProducer, requestBody, rawPathInfo)
import Pipes (Producer, (>->), yield, lift, runEffect)
import Pipes.HTTP (parseUrl, withManager, withHTTP, defaultManagerSettings, responseBody)
import qualified Data.ByteString.Char8 as Char8
import qualified Data.Text as Text
import qualified Pipes.ByteString as PipeBS
import qualified Pipes.Prelude as Pipe
import qualified Data.Map as Map
import Data.Yaml.Etc.Config (Redirect (..), redirs, yaml)

main :: IO ()
main = main'

-- app

main' :: IO ()
main' = do 
  yml <- yaml "/etc/redir.yml"
  run 8080 $ app $ redirs yml

app :: [Redirect] -> Application
app rs req res = do
  let rmap = Map.fromList $ map (\r->(src r,(dst r, statusCode r))) rs -- $ redirs yml
      ps = pathInfo req
      k = if ps == [] then "url" else Text.unpack $ head ps
      key = "http://" ++ k
      (url, status) = case Map.lookup (key) rmap of 
                        Just pair -> pair
                        Nothing -> ("http://google.com", 0)
  let content = do
        get url >-> Pipe.map (Chunk . fromByteString)
        yield Flush
  res $ responseProducer status200 
          [("Content-Type", "text/plain"), ("Location", Char8.pack url)]
          content

get :: String -> Producer PipeBS.ByteString IO ()
get url = do
  req <- lift $ parseUrl url
  mgr <- lift $ newManager defaultManagerSettings
  res <- lift $ httpLbs req mgr
  PipeBS.fromLazy $ responseBody res

-- test code
get' :: String -> Producer PipeBS.ByteString IO ()
get' url = do
  req <- lift $ parseUrl url
  yield $ "yabba dabba doo"
