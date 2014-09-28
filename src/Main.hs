{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import ProxyApp (start)

import Util.Header
import System.Plugins

main :: IO ()
main = do
    mv <- load "Plug.o" ["."] [] "helloPlugin"
    case mv of
        LoadFailure msg -> print msg
        LoadSuccess _ v -> print $ show (v :: PT Int)

main' :: IO ()
main' = start "/etc/redir.yaml"

