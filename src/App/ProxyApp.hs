{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module ProxyApp (start) where

import Blaze.ByteString.Builder (fromByteString)
import Network.HTTP.Types (status200)
import Network.HTTP.Client (Response, newManager, httpLbs)
import Network.Wai (Application, pathInfo)
import Network.Wai.Handler.Warp (run, defaultSettings)
import Pipes.Wai (Request, Application, Flush (..), responseProducer)
import Pipes (Producer, (>->), yield, lift)
import Pipes.HTTP (parseUrl, defaultManagerSettings, responseBody)
import qualified Data.ByteString.Char8 as Char8
import qualified Data.Text as Text
import qualified Pipes.ByteString as PipeBS
import qualified Pipes.Prelude as Pipe
import Data.Etc.Yaml (Redirects (..), yaml, dstUrl, redirect)

start :: String -> IO ()
start filename = do 
  redirs <- yaml filename
  run 8080 $ app redirs

app :: Redirects -> Application
app rs req res = do
  r <- redirect (req2key req) rs
  let url = dstUrl r
      headers = [("Content-Type", "text/plain"), ("Location", Char8.pack url)]
      content = do
        get url >-> Pipe.map (Chunk . fromByteString)
        yield Flush 
  res $ responseProducer status200 headers content

get :: String -> Producer PipeBS.ByteString IO ()
get url = do
  req <- lift $ parseUrl url
  mgr <- lift $ newManager defaultManagerSettings
  res <- lift $ httpLbs req mgr
  PipeBS.fromLazy $ responseBody res

req2key :: Request -> String
req2key req = if keys == [] 
              then "_default" 
              else Text.unpack (head keys) 
                  where keys = pathInfo req
