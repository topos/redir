{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Blaze.ByteString.Builder (fromByteString)
import Data.ByteString (ByteString, append)
import Data.ByteString.Char8 (pack)
import Data.Text (unpack)
import Network.HTTP.Types (status200, status301, status302)
import Network.Wai (Application, pathInfo)
import Network.Wai.Handler.Warp (run, defaultSettings)
import Pipes.Wai (Application, Flush (..), producerRequestBody, responseProducer, requestBody, rawPathInfo)
import Pipes (Producer, (>->), yield, lift, runEffect)
import Pipes.HTTP (parseUrl, withManager, withHTTP, defaultManagerSettings, responseBody)
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
      k = if ps == [] then "url" else unpack $ head ps
      key = "http://" ++ k
      (url, status) = case Map.lookup (key) rmap of 
                        Just pair -> pair
                        Nothing -> ("http://example.com/default", 0)
  let content = do
        get url >-> Pipe.map (Chunk . fromByteString)
        yield Flush
  res $ responseProducer status200 
          [("Content-Type", "text/plain"), ("Location", pack url)]
          content

get :: String -> Producer ByteString IO ()
get url = do
  req <- lift $ parseUrl url
  yield $ "+++\n" `append` "apple carts\n" `append` "cat's meow\n" `append` "---\n"

-- test code

main'' :: IO ()
main'' = do
  req <- parseUrl "http://google.com/"
  withManager defaultManagerSettings $ \m ->
      withHTTP req m $ \res ->
          runEffect $ responseBody res >-> PipeBS.stdout
