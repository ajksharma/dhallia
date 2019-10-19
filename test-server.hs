#! /usr/bin/env nix-shell
#! nix-shell -p haskellPackages.ghcid -p "haskellPackages.ghcWithPackages (ps: with ps; [snap-core snap-server aeson])" -i "ghcid -c 'ghci -Wall' -T main"

{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text.Encoding as Text
import qualified Data.Aeson as Aeson
import qualified Data.Foldable as Foldable
import System.Environment
import Snap.Http.Server
import Snap.Core

main :: IO ()
main = do
  args <- getArgs
  let port = case args of
        [pStr] -> read pStr :: Int
        _      -> 8080
  httpServe (setPort port mempty) go

go :: Snap ()
go = route [("greet/:name",greeter)
           ,("headers",echoHeaders)
           ]
  where
    greeter = do
      Just name <- getParam "name"
      writeLBS (Aeson.encode (Aeson.object [ "greet" Aeson..= ("Hi " <> Text.decodeUtf8 name) ]))

    echoHeaders = do
      allHeaders <- listHeaders =<< getRequest
      let
        showHeader :: (CI ByteString, ByteString) -> ByteString
        showHeader k v = (original k) <> ":" <> v

        renderedHeaders :: ByteString
        renderedHeaders =
          mconcat . intercalate "; " $ map showheader allHeadrs

      writeLBS renderedHeaders



-- Local Variables:
-- mode: haskell
-- End:
